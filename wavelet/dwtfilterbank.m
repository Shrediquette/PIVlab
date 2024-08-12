classdef dwtfilterbank < dynamicprops & matlab.mixin.CustomDisplay
    %DWTFILTERBANK Discrete wavelet transform filter bank
    %   FB = DWTFILTERBANK creates a discrete wavelet transform (DWT) filter
    %   bank. The default filter bank is designed for a signal with 1024
    %   samples. The default filter bank uses the analysis (decomposition) sym4
    %   wavelet and scaling filter with seven resolution levels.
    %
    %   FB = DWTFILTERBANK(Name,Value) creates a DWT filter bank, FB, with the
    %   specified property Name set to the specified Value. You can specify
    %   additional name-value pair arguments in any order as
    %   (Name1,Value1,...,NameN,ValueN).
    %
    %   DWTFILTERBANK methods:
    %
    %   filters             - DWT filters
    %   freqz               - Wavelet and scaling filter frequency responses
    %   powerbw             - Bandpower measurements
    %   wavelets            - Wavelets
    %   scalingfunctions    - Scaling functions
    %   waveletsupport      - Wavelet and scaling function time support
    %   isOrthogonal        - Orthogonal filter bank
    %   isBiorthogonal      - Biorthogonal filter bank
    %   qfactor             - Wavelet Q-factor
    %   framebounds         - Frame bounds
    %   dwtpassbands        - DWT passbands
    %
    %   DWTFILTERBANK properties:
    %
    %   SignalLength            - Signal length
    %   Wavelet                 - Wavelet name
    %   FilterType              - Filter type
    %   Level                   - Level of wavelet transform
    %   SamplingFrequency       - Sampling frequency
    %   CustomWaveletFilter     - User-supplied wavelet filter
    %   CustomScalingFilter     - User-supplied scaling filter
    %
    %   % Example: Create a DWT filter bank using the Daubechies least
    %   %   asymmetric wavelet with eight vanishing moments for a signal length
    %   %   of 2048 samples. Visualize the magnitude frequency responses of the
    %   %   wavelets and coarsest-scale scaling function. Measure the bandpower
    %   %   concentration of the wavelets.
    %   fb = dwtfilterbank('Wavelet','sym8','SignalLength',2048);
    %   freqz(fb)
    %   ptable = powerbw(fb);
    
    %   Copyright 2017-2021 The MathWorks, Inc.
    
    
    properties (SetAccess = private)
        %Wavelet Wavelet name specified as a character array or scalar
        %   string. Wavelet is an orthogonal or biorthogonal wavelet and
        %   must be recognized by WAVEMNGR or 'Custom'. The default wavelet
        %   is 'sym4'. To use a wavelet filter not recognized by WAVEMNGR,
        %   set the Wavelet property to 'Custom' and specify the
        %   CustomWaveletFilter and CustomScalingFilter properties.
        Wavelet
        %SignalLength Signal length specified as a positive integer
        %   greater than or equal to 2.
        SignalLength
        %Level Wavelet transform level specified as a positive integer
        %   less than or equal to floor(log2(SignalLength)). By default the
        %   level is equal to floor(log2(SignalLength/(L-1))) where L is
        %   the length of the wavelet filter. For wavelets recognized by
        %   WAVEMNGR this is equivalent to wmaxlev(SignalLength,WNAME)
        %   where WNAME is the wavelet name. If
        %   floor(log2(SignalLength/(L-1))) is less than or equal to 0,
        %   Level defaults to floor(log2(SignalLength)).
        Level
        %SamplingFrequency Sampling frequency in hertz. Sampling frequency
        %   is a positive scalar.
        SamplingFrequency
        %FilterType  Wavelet filter type specified as one of 'Analysis'
        %   or 'Synthesis'. If unspecified, FilterType defaults to
        %   'Analysis'. 'Analysis' uses the decomposition filters
        %   returned by WFILTERS. 'Synthesis' uses the reconstruction
        %   filters.
        FilterType
        %CustomWaveletFilter User-supplied wavelet filters.
        %   This property only applies when you set the Wavelet property
        %   to 'Custom'. CustomWaveletFilter must be an even-length
        %   column vector for an orthogonal wavelet or a two-column matrix
        %   with an even number of rows for a biorthogonal wavelet.
        CustomWaveletFilter
        %CustomScalingFilter User-supplied scaling filters.
        %   This property only applies when you set the Wavelet property
        %   to 'Custom'. CustomScalingFilter must be an even-length
        %   column vector for an orthogonal wavelet or a two-column matrix
        %   with an even number of rows for a biorthogonal wavelet.
        CustomScalingFilter
        
        
    end
    
    properties (SetAccess = private,Hidden)
        
        PsiHalfPowerBandWidth
        PsiHalfPowerFrequencies
        PhiHalfPowerBandWidth
        PhiHalfPowerFrequencies
        PercentPWRinBandPsi
        PercentPWRinBandPhi
        BandPowerPsi
        BandPowerPhi
        normfreqflag = true
        IsEven
        DCBin
    end
    
    
    methods
        function self = dwtfilterbank(varargin)
            if nargin == 0
                self.SignalLength = 1024;
                self.IsEven = true;
                self.Wavelet = 'sym4';
                % Length of 'sym4' scaling filter
                L = 8;
                self.Level = floor(log2(self.SignalLength/(L-1)));
                self.SamplingFrequency = 1;
                self.FilterType = 'Analysis';
            elseif nargin > 0
                [varargin{:}] = convertStringsToChars(varargin{:});
                self = setProperties(self,varargin{:});
            end
            filters(self);
            mrafilters(self);
            %setDCBin(self);
            
            
        end
        
    end
    
    
    methods (Access = public)
        function [G,H,L] = filters(self)
            %DWT filters
            %   [Lo,Hi] = filters(fb) returns the lowpass (scaling) and
            %   and highpass (wavelet) filters for the DWT filter bank, FB.
            %   Lo and Hi are L-by-2 matrices. L is an even positive
            %   integer and is the length of the filter. The first columns
            %   of Lo and Hi are the analysis filters and the second
            %   columns contain the synthesis filters.
            %
            %   % Example Obtain filters for biorthogonal 4.4 wavelet
            %   fb = dwtfilterbank('Wavelet','bior4.4');
            %   [Lo,Hi] = filters(fb);
            %   isBiorthogonal(fb)
            
            
            Gprop = self.findprop('ScalingFilter');
            Hprop = self.findprop('WaveletFilter');
            if ~isempty(Gprop) && ~isempty(Hprop)
                G = self.ScalingFilter;
                L = size(G,1);
                H = self.WaveletFilter;
                return;
            else
                self.addprop('WaveletFilter');
                self.addprop('ScalingFilter');
            end
            if isempty(self.CustomScalingFilter) && ...
                    isempty(self.CustomWaveletFilter)
                [Ga,Ha,Gs,Hs] = wfilters(self.Wavelet);
                G = [Ga.' Gs.'];
                H = [Ha.' Hs.'];
                L = size(G,1);
                self.WaveletFilter = H;
                self.ScalingFilter = G;
            elseif ~isempty(self.CustomScalingFilter)
                G = self.CustomScalingFilter;
                if isvector(G)
                    G = [G(:) flip(G(:))];
                end
                H = self.CustomWaveletFilter;
                if isvector(H)
                    H = [H(:) flip(H(:))];
                end
                L = size(G,1);
                self.ScalingFilter = G;
                self.WaveletFilter = H;
                
                
            end
            Gself = self.findprop('ScalingFilter');
            Hself = self.findprop('WaveletFilter');
            Gself.SetMethod = @setProp;
            Gself.Hidden = true;
            Hself.SetMethod = @setProp;
            Hself.Hidden = true;
        end
        
        function dwtbands = dwtpassbands(self)
            %DWT Passbands
            %   DWTBANDS = DWTPASSBANDS(FB) returns the theoretical DWT
            %   passbands for the DWT filter bank, FB. DWTBANDS is a
            %   L+1-by-2 matrix where L is the level of the wavelet
            %   transform. The first L rows of DWTBANDS contain the
            %   theoretical passband frequencies for the DWT listed in
            %   order of decreasing resolution (increasing scale). The
            %   first column of DWTBANDS contains the lower frequency limit
            %   and the second column contains the upper frequency limit.
            %   The final row of DWTBANDS contains the theoretical
            %   passband for the coarsest resolution scaling filter.
            %
            %   % Example: Obtain the theoretical DWT passbands for a four
            %   %   level wavelet transform with a sampling frequency of
            %   %   1 kHz.
            %   fb = dwtfilterbank('SamplingFrequency',1e3,'Level',4);
            %   dwtpassbands(fb)
            
            J = self.Level;
            bfprop = self.findprop('PassbandFrequencies');
            if ~isempty(bfprop)
                dwtbands = self.PassbandFrequencies;
                return;
            end
            % Final row contains scaling filter frequencies
            % Dynamic property associated wit this instance
            self.addprop('PassbandFrequencies');
            dwtfreqs = zeros(J+1,2);
            Fs = self.SamplingFrequency;
            for j = 1:J
                dwtfreqs(j,:) = [Fs/2^(j+1) Fs/2^j];
            end
            dwtfreqs(end,:) = [0 Fs/2^(J+1)];
            self.PassbandFrequencies = dwtfreqs;
            bfprop = self.findprop('PassbandFrequencies');
            bfprop.Hidden = true;
            bfprop.SetMethod = @setProp;
            dwtbands = dwtfreqs;
            
            
        end
        
        function bptable = powerbw(self)
            %POWERBW Power bandwidth measurements
            %   BWTABLE = POWERBW(FB) returns a table with the DWT levels,
            %   the theoretical DWT frequency bands by level, the measured
            %   wavelet 3-dB bandwidths, the measured scaling filter
            %   3-dB bandwidths, and the proportions of the total energy
            %   in the reported bands.
            %
            %   % Example Measure the 3-dB bandwidths of a four level
            %   %   discrete wavelet transform with the 'fk18' wavelet.
            %   fb = dwtfilterbank('Wavelet','fk18','Level',4);
            %   powerbw(fb)
            
            
            % Measure fraction of total L2 norm in the DWT bands
            [~] = dwtpassbands(self);
            self.BandPowerPsi = self.BandPowerPsi(:);
            self.BandPowerPhi = self.BandPowerPhi(:);
            % We will work on one-sided spectra
            SxxPsi = abs(self.PsiDFT(:,self.DCBin:end));
            % Determine if the Nyquist frequency is present based on the
            % length.
            if isodd(self.SignalLength)
                s.hasNyquist = false;
            else
                s.hasNyquist = true;
            end
            [bwpsi,fhpsi,flpsi,pwrpsi,totpwrpsi] = ...
                halfpowerbandwidth(self,SxxPsi',[],s);
            pwrbandpsi = pwrpsi./totpwrpsi;
            self.PsiHalfPowerBandWidth = bwpsi;
            self.PsiHalfPowerFrequencies = [fhpsi' flpsi'];
            SxxPhi = self.PhiDFT(:,self.DCBin:end);
            [bwphi,fhphi,flphi,pwrphi,totpwrphi] = ...
                halfpowerbandwidth(self,SxxPhi',[],s);
            pwrbandphi = pwrphi./totpwrphi;
            self.PhiHalfPowerBandWidth = bwphi;
            self.PhiHalfPowerFrequencies = [fhphi' flphi'];
            self.PercentPWRinBandPsi = pwrbandpsi(:);
            self.PercentPWRinBandPhi = pwrbandphi(:);
            bandpowerpsi = zeros(self.Level,1);
            for kk = 1:self.Level
                [~,~,~,pwrspi,totpwrpsi] = ...
                    halfpowerbandwidth(self,SxxPsi(kk,:)',self.PassbandFrequencies(kk,:),s);
                bandpowerpsi(kk) = pwrspi/totpwrpsi;
            end
            bandpowerphi = zeros(self.Level,1);
            for kk = 1:self.Level
                frange = [0 self.PassbandFrequencies(kk,1)];
                [~,~,~,pwrphi,totpwrphi] = ...
                    halfpowerbandwidth(self,SxxPhi(kk,:)',frange,s);
                bandpowerphi(kk) = pwrphi/totpwrphi;
            end
            self.BandPowerPsi = bandpowerpsi(:);
            self.BandPowerPhi = bandpowerphi(:);
            bptable = powertable(self);
            
            
        end
        
        
        function [psisupport,phisupport,tlow,thigh] = waveletsupport(self,thresh)
            %WAVELETSUPPORT Wavelet time support
            %   SPsi = WAVELETSUPPORT(FB) returns the wavelet time supports
            %   defined as the time interval in which all of the energy
            %   occurs (> 99.99% of the energy for the default threshold).
            %   SPsi is an L-by-1 vector where L is the number of levels in
            %   DWT filter bank.
            %
            %   SPsi = WAVELETSUPPORT(FB,THRESH) specifies the threshold
            %   for the integrated energy. THRESH is a positive real number
            %   in the interval (0,0.05]. If unspecified, THRESH defaults
            %   to 1e-6. The percent energy contained in the time support
            %   is (1-2*THRESH)*100. The time support of the wavelet is
            %   defined as the first instant the integrated energy exceeds
            %   THRESH and the last instant it is less than 1-THRESH. The
            %   wavelets are normalized to have unit energy for the
            %   computation.
            %
            %   [SPsi,SPhi] = WAVELETSUPPORT(FB) returns the scaling
            %   function time supports. SPhi is an L-by-1 vector where L is
            %   the number of levels in DWT filter bank.
            %
            %   [SPsi,SPhi,TLOW,THIGH] = WAVELETSUPPORT(FB) returns the
            %   instants the integrated energy in the wavelets and scaling
            %   functions exceed THRESH in TLOW and the last instant the
            %   integrated energy is less than 1-THRESH in THIGH. TLOW and
            %   THIGH are L-by-2 matrices where L is the level of the
            %   wavelet transform. The first columns of TLOW and THIGH
            %   contain the times for the wavelets. The second columns of
            %   TLOW and THIGH contain the times for the scaling functions.
            %   The difference of the corresponding columns in THIGH and
            %   TLOW plus one sampling period equals the values in SPsi and
            %   SPhi respectively.
            %
            %
            %   % Example Find the time supports for a Haar wavelet filter
            %   %   bank.
            %   fb = dwtfilterbank('Wavelet','haar','Level',8);
            %   Spsi = waveletsupport(fb);
            %
            % See also DWTFILTERBANK/WAVELETS
            
            % Check that number of input arguments is 2 or less
            narginchk(1,2);
            if nargin == 1
                thresh = 1e-6;
            elseif nargin == 2
                validateattributes(thresh,{'numeric'},{'real','positive',...
                    '<=',0.05});
            end
            T = size(self.Psi,2)*1/self.SamplingFrequency;
            t = -T/2:1/self.SamplingFrequency:T/2-1/self.SamplingFrequency;
            
            
            % Compute wavelet support
            zpsi = wavelet.internal.normalize(1:self.SignalLength,...
                self.Psi,2,'vector');
            zphi = wavelet.internal.normalize(1:self.SignalLength,...
                self.Phi,2,'vector');
            zpsi= cumsum(abs(zpsi).^2,2);
            zphi = cumsum(abs(zphi).^2,2);
            psisupport = zeros(size(zpsi,1),1);
            phisupport = zeros(size(zphi,1),1);
            tlow = zeros(size(zpsi,1),2);
            thigh = zeros(size(zpsi,1),2);
            for kk = 1:size(zpsi,1)
                idxbegin = find(zpsi(kk,:)<= thresh,1,'last');
                if isempty(idxbegin)
                    idxbegin = 1;
                end
                tlow(kk,1) = t(idxbegin);
                idxend = find(zpsi(kk,:) <= 1-thresh,1,'last');
                if isempty(idxend)
                    idxend = size(zpsi,2);
                end
                thigh(kk,1) = t(idxend);
                psisupport(kk) = (idxend-idxbegin+1)*1/self.SamplingFrequency;
                idxbegin = find(zphi(kk,:)<= thresh,1,'last');
                if isempty(idxbegin)
                    idxbegin = 1;
                end
                tlow(kk,2) = t(idxbegin);
                idxend = find(zphi(kk,:) <= 1-thresh,1,'last');
                if isempty(idxend)
                    idxend = size(zpsi,2);
                end
                thigh(kk,2) = t(idxend);
                phisupport(kk) = (idxend-idxbegin+1)*1/self.SamplingFrequency;
            end
            
            
        end
        
        function varargout = freqz(self)
            %FREQZ Wavelet and scaling filter frequency responses
            %   [PSIDFT,F] = FREQZ(FB) returns the complex-valued
            %   frequency responses for the wavelet filters, PSIDFT, and
            %   the frequency vector, F, in cycles/sample or Hz. The
            %   frequency responses are centered so that zero frequency is
            %   in the middle. PSIDFT is a L-by-N matrix where L is the
            %   value of the Level property and N is the value of the
            %   SignalLength property.
            %
            %   [PSIDFT,F,PHIDFT] = FREQZ(FB) returns the frequency
            %   responses of the scaling filters at all levels.
            %
            %   FREQZ(FB) plots the one-sided magnitude frequency responses
            %   for the wavelet filter bank, FB. Magnitude frequency
            %   responses are plotted for all wavelet bandpass filters and
            %   the coarsest resolution scaling filter. The legend is
            %   interactive. Click on the line in the legend to toggle the
            %   visibility of the corresponding filter magnitude response.
            %
            %   %Example Plot frequency responses of wavelet filters and
            %   %   final resolution scaling filter for the default signal
            %   %   length and the 'sym8' wavelet.
            %   fb = dwtfilterbank('Wavelet','sym8');
            %   freqz(fb)
            
            nargoutchk(0,3);
            if nargout > 0
                varargout{1} = self.PsiDFT;
                varargout{2} = self.Frequencies;
                varargout{3} = self.PhiDFT;
            elseif nargout == 0
                varnames = cell(self.Level+1,1);
                for kk = 1:numel(varnames)-1
                    varnames{kk} = ['D ' num2str(kk)];
                end
                varnames{kk+1} = ['A ' num2str(self.Level)];
                
                mra = [abs(self.PsiDFT(:,self.DCBin:end))' ...
                    abs(self.PhiDFT(end,self.DCBin:end))'];
                if self.normfreqflag
                    frequnitstrs = wavelet.internal.wgetfrequnitstrs;
                    freqlbl = frequnitstrs{1};
                    freq = self.Frequencies;
                    
                else
                    [freq,~,uf] = engunits(self.Frequencies,'unicode');
                    freqlbl = wavelet.internal.wgetfreqlbl([uf 'Hz']);
                    
                end
                hf = gcf;
                clf(hf);
                ax = axes('Parent',hf);
                plot(ax,freq(self.DCBin:end),mra,'linewidth',1.5);
                hl = legend(ax,varnames,'Location','NorthEast');
                hl.ItemHitFcn = @(src,evt)self.interactiveLegend(src,evt);
                grid on;
                xlabel(freqlbl);
                ylabel(getString(message('Wavelet:cwt:Magnitude')));
                title({getString(message('Wavelet:cwt:dwtfilterbank')); self.Wavelet});
                hf.NextPlot = 'replace';
            end
            
        end
        
        function qf = qfactor(self)
            %QFACTOR Wavelet quality factor
            %   QF = QFACTOR(FB) returns the quality factor for the wavelet
            %   filter bank, FB. The quality factor, QF, is defined to be
            %   the geometric mean frequency of the lower and upper 3-dB
            %   bandwidth frequencies divided by the 3-dB bandwidth. For
            %   orthogonal wavelets, the measured quality factor
            %   approximates the theoretical value of sqrt(2).
            %
            %   % Example: Obtain the quality factor for the orthogonal
            %   %   wavelet, 'coif4'.
            %   fb = dwtfilterbank('Wavelet','coif4');
            %   qfac = qfactor(fb);
            
            
            bptable = powerbw(self);
            bwfreqpsi = bptable.Wavelet3dBBandwidth(1,:);
            % Use finest scale filters
            bwpsi = bwfreqpsi(2)-bwfreqpsi(1);
            gmpsi = dwtfilterbank.geomean(bwfreqpsi);
            qf = gmpsi/bwpsi;
        end
        
        
        
        function [A,B] = framebounds(self)
            %FRAMEBOUNDS Filter bank frame bounds
            %   [A,B] = FRAMEBOUNDS(FB) returns the frame bounds for the
            %   DWT filter bank, FB. For an orthogonal wavelet filter bank
            %   the frame bounds A and B should be approximately 1.
            %
            %   % Example Obtain the frame bounds for an orthogonal wavelet
            %   %   filter bank. Note the lower and upper frame bounds are
            %   %   both equal to 1 as expected.
            %   fb = dwtfilterbank('Wavelet','db2');
            %   [A,B] = framebounds(fb);
            %
            % See also DWTFILTERBANK/ISORTHOGONAL DWTFILTERBANK/ISBIORTHOGONAL
            
            
            % The frame operator is self-adjoint so we compute the
            % eigenvalues for the smallest matrix
            N = size(self.PsiDFT,2);
            % Append coarsest-resolution scaling filter response
            dwtmatrix = [self.PsiDFT ; self.PhiDFT(end,:)];
            frameoperator = 1/N*(dwtmatrix*dwtmatrix');
            A = min(real(eig(frameoperator)));
            B = max(real(eig(frameoperator)));
        end
        
        
        function tf = isOrthogonal(self,tol)
            %ISORTHOGONAL Determine if filter bank is orthogonal
            %   TF = isOrthogonal(FB) returns true if the DWT filter bank,
            %   FB is an orthogonal filter bank. Use isBiorthogonal to
            %   determine whether a filter bank is biorthogonal.
            %   isOrthogonal returns false for a biorthogonal filter bank.
            %
            %   TF = isOrthogonal(FB,TOL) uses the positive real-valued
            %   tolerance, TOL, to determine the orthogonality of the
            %   filter bank. TOL is a small positive number in the interval
            %   (0,1e-2]. If unspecified, TOL defaults to 1e-5.
            %
            %   % Example Check whether a filter bank is orthogonal.
            %   fb = dwtfilterbank('Wavelet','sym2');
            %   isOrthogonal(fb)
            %
            % See also DWTFILTERBANK/FRAMEBOUNDS
            
            % Method takes 1 or 2 inputs
            narginchk(1,2);
            if nargin == 1
                tol = 1e-5;
            elseif nargin == 2
                validateattributes(tol,{'numeric'},...
                    {'positive','>',0,'<=',1e-2},'isOrthogonal','TOL');
            end
            
            % For a user-supplied scaling and wavelet filter, check that
            % both correspond to an orthogonal wavelet
            LoD = self.ScalingFilter(:,1);
            LoR = self.ScalingFilter(:,2);
            HiD = self.WaveletFilter(:,1);
            HiR = self.WaveletFilter(:,2);
            
                     
            tfAnalysis = isorthwfb(LoD,HiD,tolerance = tol);
            tfSynthesis = isorthwfb(LoR,HiR,tolerance = tol);
            tf = tfAnalysis && tfSynthesis;
            
            
        end
        
        function tf = isBiorthogonal(self,tol)
            %ISBIORTHOGONAL Determine if filter bank is biorthogonal
            %   TF = isBiorthogonal(FB) returns true if the DWT filter bank
            %   is a biorthogonal filter bank. This function returns false
            %   for an orthogonal filter bank. Use isOrthogonal to check
            %   that the filter bank satisfies the orthogonality
            %   conditions.
            %
            %   TF = isBiorthogonal(FB,TOL) uses the positive real-valued
            %   tolerance, TOL, to determine the biorthogonality of the
            %   filter bank. TOL is a positive number in the interval
            %   (0,1e-2]. If unspecified, TOL defaults to 1e-5.
            %
            %   % Example Check whether a filter bank is biorthogonal.
            %   fb = dwtfilterbank('Wavelet','bior4.4');
            %   isBiorthogonal(fb)
            %
            % See also DWTFILTERBANK/FRAMEBOUNDS
            
            % Method takes 1 or 2 inputs
            narginchk(1,2);
            if nargin == 1
                tol = 1e-5;
            elseif nargin == 2
                validateattributes(tol,{'numeric'},...
                    {'positive','>',0,'<=',1e-2},'isBiorthogonal','TOL');
                
            end
            
            msfilt = self.findprop('ScalingFilter');
            mwfilt = self.findprop('WaveletFilter');
            if isempty(msfilt) && isempty(mwfilt)
                [~,~] = filters(self);
            end
            LoD = self.ScalingFilter(:,1);
            LoR = self.ScalingFilter(:,2);
            HiD = self.WaveletFilter(:,1);
            HiR = self.WaveletFilter(:,2);
            tf = isbiorthwfb(LoR,LoD,HiR,HiD,tolerance=tol);
            
            
        end
        
        function  [psi,t] = wavelets(self)
            %WAVELETS Time-domain wavelets
            %   PSI = WAVELETS(FB) returns the time-domain and centered
            %   wavelets corresponding to the wavelet passband filters. PSI
            %   is an L-by-N matrix where L is the number of levels and N
            %   is the value of the SignalLength property.
            %
            %   [PSI,T] = WAVELETS(FB) returns the sampling instants,
            %   T. T are returned in the interval [-(N*DT)/2 (N*DT)/2)
            %   where N*DT is the signal length multiplied by the sampling
            %   period (reciprocal of the sampling frequency).
            %
            %   % Example
            %   fb = dwtfilterbank('SignalLength',2048,...
            %       'Wavelet','db2','Level',7,'SamplingFrequency',1e3);
            %   [psi,t] = wavelets(fb);
            %   plot(t,psi'); grid on;
            %   xlim([-1024*1e-3 1024*1e-3]);
            %
            % See also DWTFILTERBANK/SCALINGFUNCTIONS
            
            psi = self.Psi;
            T = self.SignalLength/self.SamplingFrequency;
            t = -T/2:1/self.SamplingFrequency:T/2-1/self.SamplingFrequency;
            
        end
        
        function [phi,t] = scalingfunctions(self)
            %SCALINGFUNCTIONS Time-domain scaling functions
            %   PHI = SCALINGFUNCTIONS(FB) returns the time-domain and
            %   centered scaling functions for each level. PHI is an
            %   L-by-N matrix where L is the number of levels and N is
            %   the value of the SignalLength property.
            %
            %   [PHI,T] = SCALINGFUNCTIONS(FB) returns the sampling
            %   instants, T. T are returned in the interval [-(N*DT)/2
            %   (N*DT)/2) where N*DT is the signal length multiplied by the
            %   sampling period (reciprocal of the sampling frequency).
            %
            %   % Example
            %   fb = dwtfilterbank('SignalLength',2048,...
            %       'Wavelet','db2','Level',7,'SamplingFrequency',1e3);
            %   [phi,t] = scalingfunctions(fb);
            %   plot(t,phi'); grid on;
            %   xlim([-1024*1e-3 1024*1e-3]);
            %
            % See also DWTFILTERBANK/WAVELETS
            
            phi = self.Phi;
            T = self.SignalLength/self.SamplingFrequency;
            t = -T/2:1/self.SamplingFrequency:T/2-1/self.SamplingFrequency;
            
        end
        
    end
    
    methods (Access = private, Hidden)
        function [psidft,phidft,F,psi,phi] = mrafilters(self)
            %   [PSIDFT,PHIDFT,F] = MRAFILTERS(FB) returns the
            %   frequency responses for the wavelet filters, PSIDFT, and
            %   scaling filters, PHIDFT, in the DWT filter bank, FB. PSIDFT
            %   and PHIDFT are L-by-N matrices where L is the number of
            %   levels in the wavelet transform. The frequency responses
            %   are ordered from the finest-scale (highest resolution) to
            %   coarsest scale (lowest resolution). PSIDFT and PHIDFT are
            %   the two-sided centered complex-valued frequency responses.
            %   F is a frequency vector. The units of F are cycles/sample
            %   if a sampling frequency is not specified, or Hz if you
            %   specify a sampling frequency.
            %
            %   fb = dwtfilterbank;
            %   [psidft,phidft,f] = mrafilters(fb);
            %   plot(f,[abs(psidft(3,:))' abs(phidft(3,:))']);
            %   grid on; xlabel('Cycles/Sample'); ylabel('Magnitude');
            
            
            J = self.Level;
            
            if strcmpi(self.FilterType,'Analysis')
                g = self.ScalingFilter(:,1);
                h = self.WaveletFilter(:,1);
            elseif strcmpi(self.FilterType,'Synthesis')
                g = self.ScalingFilter(:,2);
                h = self.WaveletFilter(:,2);
            end
            N = self.SignalLength;
            
            % Ensure the filters are row vectors
            g = g(:)';
            h = h(:)';
            wavdft = fft(h,N);
            scaldft = fft(g,N);
            
            psidft = zeros(J,N);
            phidft = zeros(J,N);
            psidft(1,:) = wavdft;
            phidft(1,:) = scaldft;
            
            % Loop is only needed for j>1
            for jj = 2:J
                
                upfactor = 2^(jj-1);
                Gup = scaldft(1+mod(upfactor*(0:N-1),N));
                Hup = wavdft(1+mod(upfactor*(0:N-1),N));
                psidft(jj,:) = Hup.*phidft(jj-1,:);
                phidft(jj,:) = Gup.*phidft(jj-1,:);
                
            end
            
            psi = ifftshift(ifft(psidft,[],2,'symmetric'),2);
            phi = ifftshift(ifft(phidft,[],2,'symmetric'),2);
            [~,~] = centerwaveforms(self,psi,phi);
            psidft = fftshift(psidft,2);
            phidft = fftshift(phidft,2);
            frequencyVector(self);
            F = self.Frequencies;
            if self.IsEven
                psidft = circshift(psidft,-1,2);
                phidft = circshift(phidft,-1,2);
            end
            % Add these as dynamic hidden properties to the object
            pnames = {'PsiDFT','PhiDFT'};
            pvalues = {psidft,phidft};
            for idx = 1:numel(pnames)
                name = pnames{idx};
                self.addprop(name);
                self.(name).Hidden = true;
                self.(name) = pvalues{idx};
                mself = self.findprop(name);
                mself.Hidden = true;
                mself.SetMethod=@setProp;
            end
            
            
        end
        
        function setProp(~,~)
            % Set method for dynamic properties
            error(message('Wavelet:cwt:dynamicpropsdwt'));
        end
        
        function frequencyVector(self)
            % Add centered frequency vector
            Fs = self.SamplingFrequency;
            DF = Fs/self.SignalLength;
            F = 0:DF:Fs-DF;
            F = fftshift(F);
            setDCBin(self);
            F(1:self.DCBin-1) = F(1:self.DCBin-1)-Fs;
            % For even length shift so that the Nyquist in the shifted
            % input is on the positive side
            if self.IsEven
                F = circshift(F,-1);
                F(end) = abs(F(end));
                self.DCBin = self.DCBin-1;
            end
            self.addprop('Frequencies');
            self.Frequencies = F;
            mself = self.findprop('Frequencies');
            mself.Hidden = true;
            mself.SetMethod = @setProp;
            
            
            
        end
        
        
        function [psi,phi] = centerwaveforms(self,psi,phi)
            %   Use center of energy argument to center wavelets
            %   and scaling functions
            %   Hess-Nielsen, N. & Wickerhauser, M.V. (1996) "Wavelets
            %   and time-frequency analysis",Proceedings of the IEEE, 84,4,
            %   523-540.
            %
            %   Percival, D.B. & Walden, A.T. (2000) "Wavelet methods for
            %   time series analysis", Cambridge University Press, pp.
            %   215-231.
            
            [psishifts,phishifts] = QMFphaseshift(self);
            for ii = 1:size(psi,1)
                psi(ii,:) = circshift(psi(ii,:),-psishifts(ii));
            end
            
            for ii = 1:size(phi,1)
                phi(ii,:) = circshift(phi(ii,:),-phishifts(ii));
            end
            pnames = {'Psi','Phi'};
            pvalues = {psi,phi};
            for kk = 1:numel(pnames)
                name = pnames{kk};
                self.addprop(name);
                self.(name) = pvalues{kk};
                mself = self.findprop(name);
                mself.Hidden = true;
                mself.SetMethod=@setProp;
            end
            
        end
        
        
        
        function self = setProperties(self,varargin)
            
            gvalid = @(G)validateattributes(G, {'numeric'}, ...
                {'2d', 'finite', 'nonempty'}, ...
                'DWTFILTERBANK', 'CustomScalingFilter');
            hvalid = @(H)validateattributes(H, {'numeric'}, ...
                {'2d', 'finite', 'nonempty'}, ...
                'DWTFILTERBANK', 'CustomWaveletFilter');
            slvalid = @(sl)validateattributes(sl,...
                {'numeric'},{'>=',2,'scalar','finite'},...
                'DWTFILTERBANK','SignalLength');
            sfvalid = @(sf)validateattributes(sf,{'numeric'},...
                {'scalar','positive','finite'},'DWTFILTERBANK',...
                'SamplingFrequency');
            lvalid = @(l)validateattributes(l,{'numeric'}, ...
                {'scalar', 'positive', 'finite'}, 'DWTFILTERBANK', ...
                'Level');
            
            p = inputParser();
            
            defaultFiltertype = 'Analysis';
            validFiltertypes = {'Analysis','Synthesis'};
            addParameter(p,'Wavelet','sym4');
            addParameter(p,'Level',[], lvalid);
            addParameter(p,'FilterType',defaultFiltertype);
            addParameter(p,'SignalLength',1024, slvalid);
            addParameter(p,'SamplingFrequency',[], sfvalid);
            addParameter(p,'CustomWaveletFilter',[],hvalid);
            addParameter(p,'CustomScalingFilter',[],gvalid);
            parse(p,varargin{:});
            
            filtertype = validatestring(p.Results.FilterType,...
                validFiltertypes);
            self.Wavelet = p.Results.Wavelet;
            self.SignalLength = p.Results.SignalLength;
            if iseven(self.SignalLength)
                self.IsEven = true;
            else
                self.IsEven = false;
            end
            
            self.FilterType = filtertype;
            if ~isempty(p.Results.SamplingFrequency)
                self.normfreqflag = false;
                self.SamplingFrequency = p.Results.SamplingFrequency;
            else
                self.SamplingFrequency = 1;
            end
            
            
            self.CustomWaveletFilter = p.Results.CustomWaveletFilter;
            self.CustomScalingFilter = p.Results.CustomScalingFilter;
            if ~strcmpi(self.Wavelet,'Custom') && ...
                    (~isempty(self.CustomWaveletFilter) || ~isempty(self.CustomScalingFilter))
                error(message('Wavelet:FunctionInput:customfilter'));
            end
            
            if ~isempty(self.CustomWaveletFilter) && isempty(self.CustomScalingFilter)
                error(message('Wavelet:FunctionInput:notbothcustom'));
            elseif isempty(self.CustomWaveletFilter) && ~isempty(self.CustomScalingFilter)
                error(message('Wavelet:FunctionInput:notbothcustom'));
            end
            
            if ~isempty(self.CustomWaveletFilter) && ~isempty(self.CustomScalingFilter)
                % validate sizes
                dwtfilterbank.validateCustomFilters(...
                    self.CustomScalingFilter,self.CustomWaveletFilter);
                
            end
            % validate and assign the level. We will assign the level to
            % the maximum level with at least one non-boundary coefficient
            % by default. If that is 0, we will assign to the max level.
            validateLevel(self,p.Results.Level);
            
            
            
        end
        
        function bptable = powertable(self)
            % This method creates the MATLAB table for bandpower method.
            Lev = 1:self.Level;
            bptable = table(Lev',self.PassbandFrequencies(1:end-1,:),...
                self.PsiHalfPowerFrequencies,self.PhiHalfPowerFrequencies,...
                self.PercentPWRinBandPsi,self.PercentPWRinBandPhi,...
                self.BandPowerPsi,self.BandPowerPhi,...
                'VariableNames',{'Level','DWTBand',...
                'Wavelet3dBBandwidth','Scaling3dBBandwidth','WaveletPowerIn3dBBand'...
                'ScalingPowerIn3dBBand','WaveletPowerInDWTBand','ScalingPowerInDWTBand'});
            
            
        end
        
        function [bw,fhi,flo,pwr,totpwr] = halfpowerbandwidth(self,Sxx,freqrange,s)
            % Determine 1/2 power bandwidth for transfer functions
            % we are only using real-valued wavelets here
            onesided = true;
            % Sxx is magnitude data. We will
            Pxx = wavelet.internal.psdfrommag(Sxx,...
                self.SamplingFrequency,onesided,self.SignalLength);
            % 3 dB point
            R = -10*log10(2);
            F = self.Frequencies(self.DCBin:end);
            % The following set so that the internals of computePowerBW
            % work correctly with dwtfilterbank
            s.inputType = 'time';
            [bw,fhi,flo,pwr,totpwr] = ...
                signalwavelet.internal.computePowerBW(Pxx,F(:),freqrange,R,s);
            
        end
        
        function setDCBin(self)
            % Frequency responses are all centered from (-Fs/2,Fs/2)
            % This method determines the zero frequency, DC, bin.
            
            N = self.SignalLength;
            if isodd(N) % N odd
                idxbin = ceil(N/2);
            else % N even
                idxbin = N/2+1;
            end
            self.DCBin = idxbin;
            
        end
        
        function [psishifts,phishifts] = QMFphaseshift(self)
            % Use Wickerhauser's center of energy argument to compute
            % shifts.
            
            % Obtain correct filter pair based on FilterType property
            if strcmpi(self.FilterType,'Analysis')
                Lo = self.ScalingFilter(:,1);
                Hi = self.WaveletFilter(:,1);
            else
                Lo = self.ScalingFilter(:,2);
                Hi = self.WaveletFilter(:,2);
            end
            % Obtain center of energy
            [eScaling,eWavelet] = dwtfilterbank.coe(Lo,Hi);
            % Calculate QMF shift
            [psishifts,phishifts] = dwtfilterbank.QMFshifts(self.Level,...
                eScaling,eWavelet);
            
        end
        
        function validateLevel(self,Level)
            [~,~,L] = filters(self);
            maxlev = floor(log2(self.SignalLength));
            if isempty(Level)
                % The default level is the maximum level where there is
                % at least one boundary coefficient
                self.Level = fix(log2(self.SignalLength/(L-1)));
                % If this is less than or equal to 0, we set the level to
                % maxlev.
                if self.Level <= 0
                    self.Level = maxlev;
                end
            else 
                self.Level = Level;
            end
            if self.Level > maxlev
                error(message('Wavelet:FunctionInput:InvalidLevelWavelet',maxlev,self.SignalLength));
            end
            
        end
    end
    methods (Static,Hidden)
        function gm = geomean(x)
            % Calculate geometric mean frequency for Q-factors
            N = size(x,2);
            gm = exp(sum(log(x),2)./N);
        end
        
        
        function [eScaling,eWavelet] = coe(Lo,Hi)
            %Determine the center of energy
            L = numel(Lo);
            Lo = Lo(:).';
            Hi = Hi(:).';
            eScaling = sum((0:L-1).*Lo.^2);
            eScaling = eScaling/norm(Lo,2)^2;
            eWavelet = sum((0:L-1).*Hi.^2);
            eWavelet = eWavelet/norm(Hi,2)^2;
        end
        
        function [psishifts,phishifts] = QMFshifts(level,eScaling,eWavelet)
            % Determine circular shifts for wavelets at levels j = 1,2,..J
            psishifts = round(2.^(0:level-1).*(eScaling+eWavelet)-eScaling);
            % Determine circular shifts for scaling functions at levels
            % j = 1,2...J
            phishifts = round((2.^(1:level)-1).*eScaling);
        end
        
        function interactiveLegend(~,event)
            % This private method provides an interactive legend
            if strcmp(event.Peer.Visible,'on')   % If current line is visible
                event.Peer.Visible = 'off';      % Set the visibility to 'off'
            else                                 % Else
                event.Peer.Visible = 'on';       % Set the visibility to 'on'
            end
            
            
        end
        
        function validateCustomFilters(G,H)
            
            %validateattributes(G, {'numeric'}, {'vector', 'finite', 'nonempty'}, ...
            %    'DWTFILTERBANK', 'CustomScalingFilter');
            %validateattributes(H, {'numeric'}, {'vector', 'finite', 'nonempty'}, ...
            %    'DWTFILTERBANK', 'CustomWaveletFilter');
            
            % Even length cols with 1 or 2 cols
            if (isvector(G) && ~iscolumn(G)) || (isvector(H) && ~iscolumn(H))
                error(message('Wavelet:FunctionInput:customsize'));
            end
            
            Ng = size(G,1);
            Nh = size(H,1);
            Cg = size(G,2);
            Ch = size(H,2);
            
            if any(size(G) ~= size(H)) || ...
                    isodd(Ng) || isodd(Nh) || ...
                    Cg > 2 || Ch > 2
                error(message('Wavelet:FunctionInput:customsize'));
            end
            
        end
        
    end
    
end




