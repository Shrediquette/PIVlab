classdef cwtfilterbank  < handle
    %CWTFILTERBANK Continuous wavelet transform filter bank
    %   FB = CWTFILTERBANK creates a continuous wavelet transform (CWT) filter
    %   bank. The default filter bank is designed for a signal with 1024
    %   samples. The default filter bank uses the analytic Morse (3,60)
    %   wavelet. The wavelets are normalized so that the peak magnitudes for
    %   all passbands are approximately equal to 2. The filter bank uses the
    %   default scales: approximately 10 wavelet bandpass filters per octave
    %   (10 voices per octave). The highest-frequency passband is designed so
    %   that the magnitude falls to 1/2 the peak value at the Nyquist frequency.
    %
    %   FB = CWTFILTERBANK(Name,Value) creates a CWT filter bank, FB, with the
    %   specified property Name set to the specified Value. You can specify
    %   additional name-value pair arguments in any order as
    %   (Name1,Value1,...,NameN,ValueN).
    %
    %   CWTFILTERBANK methods:
    %
    %   wt                  - Continuous wavelet transform
    %   freqz               - Wavelet frequency responses
    %   timeSpectrum        - Time-averaged wavelet spectrum
    %   scaleSpectrum       - Scale-averaged wavelet spectrum
    %   wavelets            - Time-domain wavelets
    %   scales              - Wavelet scales
    %   waveletsupport      - Wavelet time support
    %   qfactor             - Wavelet Q-factor
    %   powerbw             - 3-dB bandwidths of wavelet bandpass filters
    %   centerFrequencies   - Wavelet bandpass center frequencies
    %   centerPeriods       - Wavelet bandpass center periods
    %
    %   CWTFILTERBANK properties:
    %
    %   SignalLength        - Signal length
    %   Wavelet             - Analysis wavelet
    %   VoicesPerOctave     - Voices per octave
    %   SamplingFrequency   - Sampling frequency
    %   FrequencyLimits    -  Frequency limits
    %   SamplingPeriod      - Sampling period
    %   PeriodLimits        - Period limits
    %   TimeBandwidth       - Time-bandwidth product
    %   WaveletParameters   - Morse wavelet parameters
    %   Boundary            - Reflect or treat data as periodic
    %
    %   % Example:
    %   %   Construct a default filter bank and display the frequency
    %   %   responses.
    %
    %   fb = cwtfilterbank;
    %   freqz(fb)
    %
    % See also CWT, CWTFREQBOUNDS, DWTFILTERBANK, ICWT
    
    %   Copyright 2017-2021 The MathWorks, Inc.
    
    %#codegen
    
    properties (SetAccess = private)
        %VoicesPerOctave Approximate number of wavelet filters per octave.
        %   VoicesPerOctave is a positive integer between 1 and 48.
        %   VoicesPerOctave defaults to 10.
        VoicesPerOctave
        %Wavelet Analysis wavelet used in filter bank.
        %   Valid options are 'Morse', 'amor', or 'bump'. The wavelet
        %   defaults to 'Morse'.
        Wavelet
        %SamplingFrequency Sampling frequency in hertz. SamplingFrequency
        %   is a positive scalar. If unspecified, frequencies are in
        %   cycles/sample and the Nyquist is 1/2. SamplingFrequency
        %   defaults to 1 which is equivalent to frequencies in
        %   cycles/sample.
        SamplingFrequency
        %SamplingPeriod Sampling as a scalar duration. You cannot
        %   specify both the SamplingFrequency and SamplingPeriod properties.
        SamplingPeriod
        %PeriodLimits Period limits of the wavelet filter bank specified
        %   as a two-element duration array with positive strictly
        %   increasing entries. The first element of PeriodLimits specifies
        %   the largest peak passband frequency and must be greater than or
        %   equal to twice the SamplingPeriod. The base 2 logarithm of the
        %   ratio of minimum period to maximum period must be less than or
        %   equal to -1/NV where NV is the number of voices per octave. 
        %   If a region of the specified period limits falls outside the 
        %   Nyquist range, [2*Ts N*Ts] where Ts is the sampling period and
        %   N is the signal length, CWTFILTERBANK truncates computations
        %   to within the range specified by minimum and maximum valid 
        %   values. 
        %   Use <a href="matlab:help cwtfreqbounds">cwtfreqbounds</a> 
        %   to determine period limits for different parameterizations of 
        %   the wavelet transform. The period limits cannot be completely 
        %   outside of the Nyquist range.
        PeriodLimits
        %SignalLength Signal length in samples.
        %   Signal length is a positive integer greater than or equal to 4.
        SignalLength
        %FrequencyLimits  Frequency limits of the wavelet filter bank
        %   specified as a two-element vector with positive strictly
        %   increasing entries. The first element of FrequencyLimits
        %   specifies the lowest peak passband frequency and must be
        %   greater than or equal to the product of the wavelet peak
        %   frequency in hertz and two time standard deviations divided by
        %   the length of the signal. The base 2 logarithm of the ratio of
        %   maximum frequency to minimum frequency must be greater than or
        %   equal to 1/NV where NV is the number of voices per octave.
        %   If a region of the specified frequency limits falls outside the
        %   Nyquist range, CWTFILTERBANK truncates computations to within
        %   the range specified by minimum and maximum valid values. 
        %   Use <a href="matlab:help cwtfreqbounds">cwtfreqbounds</a> to 
        %   determine frequency limits for different parameterizations of 
        %   the wavelet transform. 
        FrequencyLimits
        %TimeBandwidth 	Time-bandwidth product for Morse wavelets.
        %   This property is only valid when the Wavelet property is 'Morse'.
        %   This property specifies the time-bandwidth product of the
        %   Morse wavelet with the symmetry parameter (gamma) fixed at 3.
        %   The time-bandwidth product (TB) is a positive number greater
        %   than or equal to 3 and less than or equal to 120. If 
        %   unspecified, the time-bandwidth parameter defaults to 60. The
        %   larger the time-bandwidth parameter, the more spread out the 
        %   wavelet is in time and narrower the wavelet is in frequency. 
        %   The TimeBandwidth and WaveletParameters properties cannot both
        %   be specified.
        TimeBandwidth
        %WaveletParameters Morse wavelet parameters. WaveletParameters is
        %   a two-element vector. WaveletParameters defaults to [3,60]. 
        %   The first element is the symmetry parameter (gamma), which must 
        %   be greater than or equal to 1. The second element is the 
        %   time-bandwidth parameter, which must be greater than or equal 
        %   to gamma. The ratio of the time-bandwidth parameter to gamma 
        %   cannot exceed 40. When gamma is equal to 3, the Morse wavelet 
        %   is perfectly symmetric in the frequency domain. The skewness is 
        %   equal to 0. Values of gamma greater than 3 result in positive 
        %   skewness, while values of gamma less than 3 result in negative
        %   skewness. WaveletParameters is only valid if the Wavelet 
        %   property is 'Morse'. The WaveletParameters and TimeBandwidth 
        %   properties cannot both be specified.
        %
        WaveletParameters
        %Boundary Determines how the signal is handled at the boundary.
        %   Boundary is one of 'reflection' (default) or 'periodic'.
        Boundary
        
        
        
    end
    
    properties(Hidden, SetAccess = private)
        Scales
        PsiDFT
        PhiDFT
        NyquistBin
        WaveletCenterFrequencies
        % GPU cache variable.
        PsiGPU
        % data variance
        sigvar = 1;           
    end
    
    properties(Hidden,Access = private)
        Frequencies
        Beta
        Gamma
        npad;
        PsiHalfPowerBandwidth
        PsiHalfPowerFrequencies
        SignalPad
        normfreqflag = true;
        PlotString
        WaveletCF
        Omega
        CutOff
        CurrentClass        
    end      
    
    methods (Access = public)
        function self = cwtfilterbank(varargin)
            if numel(varargin) == 0
                self.VoicesPerOctave = 10;
                self.Wavelet = 'Morse';
                self.Beta = 20;
                self.Gamma = 3;
                self.TimeBandwidth = self.Gamma*self.Beta;
                self.SignalLength = 1024;
                self.SamplingFrequency = 1;
                self.SamplingPeriod = [];
                self.FrequencyLimits = [];
                self.PeriodLimits = [];
                self.SignalPad = floor(self.SignalLength/2);
                self.Boundary = 'reflection';
                self.CutOff = 50;
                self.WaveletCF = ...
                    wavelet.internal.cwt.morsepeakfreq(self.Gamma,...
                        self.Beta);
            else
                self = setProperties(self,varargin{:});
            end
            
            % Construct the frequency grid for the wavelet DFT
            FrequencyGrid(self);
            if coder.target('MATLAB')
                if ~isempty(self.FrequencyLimits)
                    % freqtoscales() adds scales
                    freqtoscales(self);
                elseif ~isempty(self.PeriodLimits)
                    % periodtoscales() add scales
                    periodtoscales(self);
                else
                    
                    self.Scales = wavelet.internal.cwt.getCWTScales(...
                        self.Wavelet,self.SignalLength,self.Gamma,self.Beta,...
                        self.VoicesPerOctave, 2, self.CutOff);
                end
            else
                if ~all(isnan(self.FrequencyLimits))
                    freqtoscales(self);
                else
                    
                    self.Scales = wavelet.internal.cwt.getCWTScales(...
                        self.Wavelet,self.SignalLength,self.Gamma,self.Beta,...
                        self.VoicesPerOctave, 2, self.CutOff);
                end
            end          
            
            % Compute filter bank. This method must output values because
            % we may not be able to directly use properties in the freqz()
            % and wavelets() methods.
            [psidft,f] = self.filterbank();
            self.PsiDFT = psidft;
            self.WaveletCenterFrequencies = f;            
        end
        
        
        function [rs,cs] = scales(self)
            %SCALES Wavelet scales
            %   RS = SCALES(FB) returns the raw scales (unitless) scales
            %   used in creating the wavelet bandpass filters. Scales are
            %   ordered from finest scale to coarsest scale.
            %
            %   [RS,CS] = SCALES(FB) returns the wavelet scales converted
            %   to units of the sampling frequency or sampling period.
            %
            %   % Example Return the raw scales and converted scales
            %   %   for the filter bank using the default Morse wavelet
            %   %   and a sampling period of 0.001 seconds.
            %
            %   fb = cwtfilterbank('SamplingPeriod',seconds(0.001));
            %   [rs,cs] = scales(fb);
            %   P = centerPeriods(fb);
            %   max(P) / seconds(0.001)
            %   max(cs)
            %
            % See also CWTFILTERBANK/CENTERFREQUENCIES CWTFILTERBANK/CENTERPERIODS
            
            rs = self.Scales / self.SamplingFrequency;
            cs = (2*pi*self.Scales)./self.WaveletCF;
        end
        
        function bpcf = centerFrequencies(self)
            %CENTERFREQUENCIES Wavelet bandpass center frequencies
            %   F = centerFrequencies(FB) returns the wavelet bandpass
            %   filter center frequencies for the CWT filter bank, FB. By
            %   default, F has units cycles/sample. If you specify a
            %   sampling frequency, F has units of hertz. If you specify a
            %   SamplingPeriod, F has units cycles/unit time where the time
            %   unit is the same as the time unit in the duration
            %   SamplingPeriod.
            %
            %   % Example Determine the wavelet center frequencies for a
            %   %   Morse wavelet filter bank with a sampling frequency of 1
            %   %   Hz.
            %   fb = cwtfilterbank('SamplingFrequency',1);
            %   F = centerFrequencies(fb);
            %
            % See also CWTFILTERBANK/CENTERPERIODS CWTFILTERBANK/FREQZ
            
            narginchk(1,1);
            bpcf = self.WaveletCenterFrequencies;
        end
        
        function bpcf = BPfrequencies(self)
            %BPFREQUENCIES Wavelet bandpass frequencies
            % BPFREQUENCIES is not recommended and may be removed in a
            % future release. Use CENTERFREQUENCIES instead.
            %
            %   F = BPfrequencies(FB) returns the wavelet bandpass filter
            %   frequencies for the CWT filter bank, FB. By default, F
            %   has units cycles/sample. If you specify a sampling
            %   frequency, F has units of hertz. If you specify a
            %   SamplingPeriod, F has units cycles/unit time where the time
            %   unit is the same as the time unit in the duration
            %   SamplingPeriod.
            %
            %   % Example Determine the wavelet bandpass frequencies for a
            %   %   Morse wavelet filter bank with a sampling frequency of 1
            %   %   Hz.
            %   fb = cwtfilterbank('SamplingFrequency',1);
            %   F = BPfrequencies(fb);
            %
            % See also CWTFILTERBANK/CENTERPERIODS CWTFILTERBANK/FREQZ
            
            bpcf = self.WaveletCenterFrequencies;
        end
        
        function bpper = centerPeriods(self)
            %CENTERPERIODS Wavelet bandpass center periods
            %   P = centerPeriods(FB) returns the wavelet bandpass filter
            %   center periods for the CWT filter bank, FB. If you specify
            %   a SamplingPeriod, P is a duration array with the same units
            %   and format as the SamplingPeriod. If you specify a
            %   SamplingFrequency, P is in seconds.
            %
            %   % Example Determine the wavelet bandpass periods for a Morse
            %   %   wavelet filter bank with a sampling period of 1 second.
            %   fb = cwtfilterbank('SamplingPeriod',seconds(1));
            %   P = centerPeriods(fb);
            %
            % See also CWTFILTERBANK/CENTERFREQUENCIES
            
            if ~coder.target('MATLAB')
                coder.internal.assert(false,'Wavelet:codegeneration:MethodNotSupported');
            end
            narginchk(1,1);
            bpcf = self.WaveletCenterFrequencies;
            bpper = 1./bpcf;
            if ~isempty(self.SamplingPeriod)
                [~,~,durarionfunc] = ...
                    wavelet.internal.getDurationandUnits(self.SamplingPeriod);
                bpper = durarionfunc(bpper);
                bpper.Format = self.SamplingPeriod.Format;
            end
        end
        
        
        function bpper = BPperiods(self)
            %BPPERIODS Wavelet bandpass periods
            % BPPERIODS is not recommended and may be removed in a future
            % release. Use CENTERPERIODS instead
            %
            %   P = BPperiods(FB) returns the wavelet bandpass filter
            %   periods for the CWT filter bank, FB. If you specify a
            %   SamplingPeriod, P is a duration array with the same units
            %   and format as the SamplingPeriod. If you specify a
            %   SamplingFrequency, P is in seconds.
            %
            %   % Example Determine the wavelet bandpass periods for a Morse
            %   %   wavelet filter bank with a sampling period of 1 second.
            %   fb = cwtfilterbank('SamplingPeriod',seconds(1));
            %   P = BPperiods(fb);
            %
            % See also CWTFILTERBANK/CENTERFREQUENCIES            
            
            if ~coder.target('MATLAB')
                coder.internal.assert(false,'Wavelet:codegeneration:MethodNotSupported');
            end
            bpper = self.centerPeriods();            
        end
        
        function [psi,t] = wavelets(self)
            %WAVELETS Time-domain wavelets
            %   PSI = WAVELETS(FB) returns the time-domain wavelets for the
            %   filter bank, FB.
            %
            %   [PSI,T] = WAVELETS(FB) returns the sampling instants for
            %   the wavelets.
            %
            %   % Example Obtain the time-domain wavelets for a CWT
            %   % filter bank. Plot the largest scale wavelet.
            %   [minf,maxf] = cwtfreqbounds(1024,'StandardDeviations',4,...
            %   'CutOff',0);
            %   fb = cwtfilterbank('FrequencyLimits',[minf,maxf]);
            %   [psi,t] = wavelets(fb);
            %   plot(t,[real(psi(end,:)).' imag(psi(end,:)).']); grid on;
            
            if ~coder.target('MATLAB')
                coder.internal.assert(isempty(self.SamplingPeriod),...
                    'Wavelet:codegeneration:DurationNotSupported');
            end
            if strcmpi(self.CurrentClass,'double')
                psihat = self.PsiDFT;
            else
                psihat = self.filterbank();
            end
            
            psi = ifftshift(ifft(psihat,[],2),2);
            if self.SignalPad > 0
                psi = psi(:,self.SignalPad+1:self.SignalPad+self.SignalLength);
            end
            
            if coder.target('MATLAB')
                if isempty(self.SamplingPeriod)
                    T = self.SignalLength/self.SamplingFrequency;
                    t = -T/2:1/self.SamplingFrequency:T/2-1/self.SamplingFrequency;
                else
                    T = self.SignalLength*self.SamplingPeriod;
                    t = -T/2:self.SamplingPeriod:T/2-self.SamplingPeriod;
                end
            else
                T = self.SignalLength/self.SamplingFrequency;
                t = -T/2:1/self.SamplingFrequency:T/2-1/self.SamplingFrequency;
            end           
            
        end
        
        function sptable  = waveletsupport(self,thresh)
            %WAVELETSUPPORT Wavelet time support
            %   SPSI = WAVELETSUPPORT(FB) returns the wavelet time supports
            %   defined as the time interval in which all of the wavelet
            %   energy occurs (> 99.99% of the energy for the default
            %   threshold) SPSI is a Ns-by-5 MATLAB table with the following
            %   variables: CF (wavelet center frequency), IsAnalytic,
            %   TimeSupport, Begin, End.
            %
            %   IsAnalytic is a string which designates the wavelet as
            %   "Analytic" or "Nonanalytic". Wavelets that do not decay to 5%
            %   of their peak value at the Nyquist frequency are not considered
            %   analytic. The time support information for those wavelets is
            %   returned as NaN.
            %
            %   TimeSupport is the wavelet time support returned in samples,
            %   seconds, or MATLAB durations. The units of TimeSupport depend
            %   on whether you specify a SamplingFrequency or SamplingPeriod.
            %   If you specify a SamplingFrequency, the units are in seconds.
            %   If you specify a SamplingPeriod, the units are the same as the
            %   SamplingPeriod. If no SamplingFrequency or SamplingPeriod is
            %   specified, the units are in samples.
            %
            %   Begin is the beginning of the wavelet support defined as the
            %   first instant the wavelet integrated energy exceeds the default
            %   threshold, 1e-4. Begin has the same units as TimeSupport.
            %
            %   End is the end of the wavelet support defined as the last
            %   instant the wavelet integrated energy is less than 1-1e-4. End
            %   has the same units as TimeSupport.
            %
            %   SPSI = WAVELETSUPPORT(FB,THRESH) specifies the threshold for
            %   the integrated energy. THRESH is a positive real number
            %   between 0 and 0.05. If unspecified, THRESH defaults to 1e-4.
            %   The time support of the wavelet is defined as the first instant
            %   the integrated energy exceeds THRESH and the last instant the
            %   integrated energy is less than 1-THRESH.
            %
            %   % Example Obtain the time supports for the default Morse
            %   %   wavelet filter bank. Note the first two wavelet filter
            %   %   frequency responses have values at the Nyquist frequency of
            %   %   greater than 5% of the nominal peak value of 2. Therefore,
            %   %   they are designated as "Nonanalytic" in the table.
            %
            %   fb = cwtfilterbank;
            %   spsi = waveletsupport(fb);
            
            if ~coder.target('MATLAB')
                coder.internal.assert(false,'Wavelet:codegeneration:MethodNotSupported');
            end
            % Method takes 1 or 2 inputs
            narginchk(1,2)
            
            if nargin == 1
                thresh = 1e-4;
            elseif nargin == 2
                validateattributes(thresh,{'numeric'},{'real','positive',...
                    '<=',0.05});
                
            end
            psi = wavelets(self);
            if isempty(self.SamplingPeriod)
                T = size(psi,2)*1/self.SamplingFrequency;
                %t = 0:1/self.SamplingFrequency:T-1/self.SamplingFrequency;
                t = -T/2:1/self.SamplingFrequency:T/2-1/self.SamplingFrequency;
            else
                T = size(psi,2)*self.SamplingPeriod;
                %t = 0:self.SamplingPeriod:T-self.SamplingPeriod;
                t = -T/2:self.SamplingPeriod:T/2-self.SamplingPeriod;
            end
            
            % Compute wavelet support
            zpsi = wavelet.internal.normalize(1:self.SignalLength,...
                psi,2,'vector');
            zpsi= cumsum(abs(zpsi).^2,2);
            wavsp = zeros(size(zpsi,1),1);
            if isempty(self.SamplingPeriod)
                idxlow = zeros(numel(self.WaveletCenterFrequencies),1);
                idxhigh = zeros(numel(self.WaveletCenterFrequencies),1);
            else
                idxlow = repelem(self.SamplingPeriod,...
                    numel(self.WaveletCenterFrequencies));
                idxhigh = repelem(self.SamplingPeriod,...
                    numel(self.WaveletCenterFrequencies));
            end
            for kk = 1:size(zpsi,1)
                idxbegin = find(zpsi(kk,:) > thresh,1,'first');
                if isempty(idxbegin)
                    idxbegin = 1;
                end
                idxlow(kk) = t(idxbegin);
                idxend = find(zpsi(kk,:) > 1-thresh,1,'first');
                if isempty(idxend)
                    idxend = size(zpsi,2);
                end
                idxhigh(kk) = t(idxend);
                wavsp(kk) = (idxend-idxbegin);
            end
            if ~isempty(self.SamplingPeriod)
                wavsp = wavsp.*self.SamplingPeriod;
            else
                wavsp = wavsp.*1/self.SamplingFrequency;
            end
            tlow = idxlow(:);
            thigh = idxhigh(:);
            valuesAtNyquist = self.PsiDFT(:,self.NyquistBin);
            idxNonAnalytic = valuesAtNyquist > 0.1;
            analyticstring = strings(size(self.PsiDFT,1),1);
            analyticstring(:) = "Analytic";
            analyticstring(idxNonAnalytic) = "Nonanalytic";
            wavsp(idxNonAnalytic) = NaN;
            tlow(idxNonAnalytic) = NaN;
            thigh(idxNonAnalytic) = NaN;
            sptable = table(self.WaveletCenterFrequencies,analyticstring,...
                wavsp,tlow,thigh,'VariableNames', ...
                {'CF','IsAnalytic','TimeSupport','Begin','End'});
            
        end                     
               
        function bw = powerbw(self)
            %POWERBW Power bandwidth
            %   BW = POWERBW(FB) returns 3-dB (half-power) bandwidths for
            %   the wavelet filters in the filter bank, FB. BW is a MATLAB
            %   table that is Ns-by-2 where Ns is the number of wavelet
            %   bandpass frequencies (equal to the number of scales). The
            %   first variable of BW is the bandpass frequencies and the
            %   second variable is a Ns-by-2 matrix where the first column
            %   is the lower frequency edge of the 3-dB bandwidth and the
            %   second column is the upper frequency edge.
            %
            %   % Example Obtain the 3-dB bandwidths for the wavelet
            %   %   bandpass filters.
            %   [minf,maxf] = cwtfreqbounds(1024,'StandardDeviations',8,...
            %   'CutOff',100);
            %   fb = cwtfilterbank('FrequencyLimits',[minf maxf]);
            %   bw = powerbw(fb);
            
            if ~coder.target('MATLAB')
                coder.internal.assert(false,'Wavelet:codegeneration:MethodNotSupported');
            end
            N = size(self.PsiDFT,2);
            SxxPsi = self.PsiDFT(:,1:self.NyquistBin);
            % Determine if the Nyquist frequency is present for the
            % computation of the 3-dB bandwidths
            if signalwavelet.internal.isodd(N)
                s.hasNyquist = false;
            else
                s.hasNyquist = true;
            end
            [bwpsi,fhpsi,flpsi] = halfpowerbandwidth(self,SxxPsi',s);
            self.PsiHalfPowerBandwidth = bwpsi;
            self.PsiHalfPowerFrequencies = [fhpsi' flpsi'];
            bw = powertable(self);
            
        end
        
        function pwrtable = powertable(self)
            if ~coder.target('MATLAB')
                coder.internal.assert(false,'Wavelet:codegeneration:MethodNotSupported');
            end
            freq = self.WaveletCenterFrequencies;
            bw = self.PsiHalfPowerBandwidth(:);
            flo = self.PsiHalfPowerFrequencies(:,1);
            fhi = self.PsiHalfPowerFrequencies(:,2);
            pwrtable = table(freq,bw,flo,fhi,...
                'VariableNames',{'Frequencies','HalfPowerBandwidth',...
                'LowFrequencyBorder','HighFrequencyBorder'});
            
        end
        
        function qf = qfactor(self)
            %QFACTOR Wavelet quality factor
            %   QF = QFACTOR(FB) returns the quality factor for the wavelet
            %   bandpass filters in FB. The quality factor is the ratio of
            %   the 3-dB bandwidth to the center frequency. The center
            %   frequency is defined to be the geometric mean of the lower
            %   and upper 3-dB frequencies. The larger the quality factor,
            %   the more frequency localized the wavelet. For reference, a
            %   half-band filter has a quality factor of sqrt(2).
            %
            %   % Example Return the quality factor for the default Morse
            %   %   wavelet.
            %   fb = cwtfilterbank;
            %   qfac = qfactor(fb);
            
            if ~coder.target('MATLAB')
                coder.internal.assert(false,'Wavelet:codegeneration:MethodNotSupported');
            end
            om = linspace((2*pi)/1e4,4*pi,1e4);
            
            if strcmpi(self.Wavelet, 'morse')
                psihat = wavelet.internal.cwt.morsebpfilters(...
                    om, 1, self.Gamma, self.Beta);
            else
                psihat = wavelet.internal.cwt.wavbpfilters(self.Wavelet,...
                    om, 1);
            end
            
            psihat = psihat(:);
            om = om(:);
            Pxx = wavelet.internal.psdfrommag(psihat,1,false,size(psihat,1));
            R = -10*log10(2);
            % Here the input length is even
            s = struct('hasNyquist',true,'inputType','time');
            [bw,flo,fhigh] = signalwavelet.internal.computePowerBW(Pxx,om,[],R,s);
            qf = cwtfilterbank.geomean([flo fhigh])/bw;
        end

        function [psif,f] = freqz(self,varargin)
            %FREQZ Wavelet frequency responses
            %   [PSIDFT,F] = FREQZ(FB) returns the frequency responses for
            %   the wavelet filters, PSIDFT, and the frequency vector, F,
            %   in cycles/sample or Hz. If you specify a sampling period,
            %   the frequencies are in cycles/unit time where the time unit
            %   is the unit of the duration sampling period. The frequency
            %   responses for PSIDFT are one-sided frequency responses. For
            %   the analytic wavelets supported by CWTFILTERBANK, the
            %   wavelet frequency responses are real-valued and are
            %   equivalent to the magnitude frequency response.
            %
            %   [PSIDFT,F] = FREQZ(...,"IncludeLowpass",TF) appends the 
            %   lowpass, or scaling filter, frequency response as the final
            %   row of PSIDFT. For the analytic wavelets supported by
            %   CWTFILTERBANK, the scaling filter frequency response is
            %   real-valued and is equivalent to the magnitude frequency
            %   response. If unspecified, "IncludeLowpass" defaults to
            %   false.
            %
            %   [...] = FREQZ(...,"FrequencyRange",FREQRANGE) returns the
            %   wavelet and scaling function frequency responses over a
            %   specified range of frequencies based on the value of
            %   FREQRANGE:
            %
            %   "onesided" - returns the frequency responses from [0,1/2] 
            %   when the length of the padded filters is even and [0,1/2) 
            %   when the length of the padded filters is odd. Whether or 
            %   not any padding is added to the filters depends on the 
            %   setting of the "Boundary" property in the filter bank. 
            %   See the CWTFILTERBANK or CWT documentation for details.
            %
            %   If a sampling frequency is specified in the filter bank,
            %   the intervals become [0,Fs/2] and [0,Fs/2) respectively.
            %
            %   "twosided" - returns the full two-sided frequency responses
            %   over the range [0,1). If a sampling frequency is specified
            %   in the filter bank, the interval corresponds to [0,Fs).
            %
            %   If unspecified, FREQRANGE defaults to "onesided".
            %
            %   To use the wavelet and scaling filters in the inverse CWT
            %   set Boundary = "periodic" in the filter bank, and use
            %   IncludeLowpass = true, and FrequencyRange = "twosided".
            %
            %   FREQZ(FB) plots the magnitude frequency responses for the
            %   wavelet filter bank, FB.
            %
            %   % Example 1: Plot frequency responses for the default Morse
            %   %   wavelet filter bank.
            %   fb = cwtfilterbank;
            %   freqz(fb)
            %
            %   % Example 2: Obtain the two-sided wavelet and scaling filter
            %   % responses. Use these to invert the CWT of the Kobe
            %   % earthquake recording.
            %   load kobe
            %   fb = cwtfilterbank(SignalLength = numel(kobe),...
            %       Boundary="periodic");
            %   [cfs,~,~,scalcfs] = wt(fb,kobe);
            %   psif = freqz(fb,IncludeLowpass=true,FrequencyRange="twosided");
            %   xrec = ...
            %   icwt(cfs,ScalingCoefficients=scalcfs,AnalysisFilterBank=psif);
            %   plot([kobe(:) xrec(:)])

            if isempty(coder.target)
                nargoutchk(0,2);
            else
                nargoutchk(1,2);
            end

            if nargout == 0 && ~coder.target('MATLAB')
                coder.internal.assert(false,'Wavelet:codegeneration:Plotting');
            end

            narginchk(1,5);
            popts = struct(...
                'CaseSensitivity',false, ...
                'PartialMatching','unique',...
                'SupportOverrides', false);
            pArgs = struct('FrequencyRange',uint32(0),...
                    'IncludeLowpass',uint32(0));
            params = ...
                coder.internal.parseParameterInputs(pArgs,popts,varargin{:});
            tmpfrange = ...
                coder.internal.getParameterValue(params.FrequencyRange,...
                'onesided',varargin{:});
            frange = validatestring(tmpfrange,{'onesided','twosided'},...
                'FREQZ','FrequencyRange');
            includeLP = ...
                coder.internal.getParameterValue(params.IncludeLowpass,...
                    false,varargin{:});
            validateattributes(includeLP,{'numeric','logical'},{'scalar'});
            
            if strcmpi(self.CurrentClass,'double')
                tmppsif = self.PsiDFT;
            else
                tmppsif = self.filterbank();
            end
            
            tmpf = self.Frequencies;
            tmpf(tmpf<0) = tmpf(tmpf<0) + self.SamplingFrequency;

            if includeLP
                tmpphif = self.scalingFunction();
                tmppsif = cat(1,tmppsif,tmpphif);
            end
            

            idxNyquist = self.NyquistBin;

            if startsWith(frange,"o")
                tmppsif = tmppsif(:,1:idxNyquist);
                tmpf = tmpf(1:idxNyquist);                
            end

            if nargout == 0 && isempty(coder.target)

                if self.normfreqflag
                    frequnitstrs = wavelet.internal.wgetfrequnitstrs;
                    freqlbl = frequnitstrs{1};
                    freq = tmpf;

                elseif isempty(self.PlotString)
                    [freq,~,uf] = engunits(tmpf,'unicode');
                    freqlbl = wavelet.internal.wgetfreqlbl([uf 'Hz']);

                else
                    freqlbl = ['cycles/' self.PlotString];
                    freq = tmpf;

                end
                plot(freq,abs(tmppsif.'));
                xlabel(freqlbl);
                ylabel(getString(message('Wavelet:cwt:Magnitude')));
                grid on;
                title(getString(message('Wavelet:cwt:cwtfb')));
            end

            if nargout
                psif = tmppsif;
                f = tmpf;                
            end

        end

        function clearCache(self)
            if isempty(self.PsiGPU)
                return;
            elseif ~isempty(self.PsiGPU) && isCacheEmpty(self.PsiGPU)
                return;
            else
                clearCache(self.PsiGPU);
            end
        end




        % Public method signatures implemented in class folder
        [tavgp,f] = timeSpectrum(self,x,varargin)
        [savgp,scidx] = scaleSpectrum(self,x,varargin)
        [cfs,f,coi,scalcfs] = wt(self,x)

    end

    methods (Static,Hidden)
        function gm = geomean(x)
            N = size(x,2);
            gm = exp(sum(log(x),2)./N);
        end

        function indices = createCoiIndices(N)
            indices = zeros(N,1);
            if signalwavelet.internal.isodd(N)
                % Odd length case
                M = ceil(N/2);
                indices(1:M) = (1:M);
                indices(M+1:N) = (M-1:-1:1);
            else
                % Even length case
                indices(1:N/2) = (1:N/2);
                indices(N/2+1:N) = (N/2:-1:1);
            end
        end

        function idxbin = setNyquistBin(Nt)
            N = cast(Nt,coder.internal.indexIntClass);
            idxbin = bitshift(N,-1) + 1;
        end

    end

    methods (Access = private, Hidden)
        function self = setProperties(self,varargin)
            % These defaults apply to both coder.target('MATLAB') and
            % codegen
            defaultWav = 'Morse';
            defaultSigLen = 1024;
            defaultvoices = coder.internal.const(10);
            defaultboundary = 'reflection';

            % Initialize to an integer for code generation equal to 50.
            % Later set equal to 10 if the wavelet is not Morse
            self.CutOff = 50;

            if isempty(coder.target)
                p = inputParser;
                checkbw = @(x) isscalar(x) && (x >= 3 && x<=120) && ...
                    ~issparse(x);
                checkwavparams = @(x) isnumeric(x) && numel(x)==2 && ...
                    x(1) >= 1 && x(2) >= x(1) && x(2)/x(1) <= 40 && ...
                    ~issparse(x);

                voicescheck = @(x)validateattributes(x,{'numeric'},...
                    {'positive','scalar','integer','nonsparse', ...
                    '>=',1,'<=',48},'CWTFILTERBANK','VoicesPerOctave');
                sampperiodcheck = @(x)isduration(x) && isscalar(x) && x>0 ...
                    && isfinite(x);
                addParameter(p,'Wavelet',defaultWav);
                addParameter(p,'TimeBandwidth',[],checkbw);
                addParameter(p,'WaveletParameters',[],checkwavparams);
                addParameter(p,'SignalLength',defaultSigLen);
                addParameter(p,'SamplingFrequency',[]);
                addParameter(p,'VoicesPerOctave',defaultvoices,voicescheck);
                addParameter(p,'FrequencyLimits',[]);
                addParameter(p,'Boundary',defaultboundary);
                addParameter(p,'SamplingPeriod',[],sampperiodcheck);
                addParameter(p,'PeriodLimits',[]);
                parse(p,varargin{:});
                % Assign property values from parser results
                self.Wavelet = p.Results.Wavelet;
                self.SignalLength = p.Results.SignalLength;
                self.WaveletParameters = p.Results.WaveletParameters;
                self.SamplingFrequency = p.Results.SamplingFrequency;
                self.SamplingPeriod = p.Results.SamplingPeriod;
                self.VoicesPerOctave = p.Results.VoicesPerOctave;
                self.TimeBandwidth = p.Results.TimeBandwidth;
                self.WaveletParameters = p.Results.WaveletParameters;
                self.FrequencyLimits = p.Results.FrequencyLimits;
                self.PeriodLimits = p.Results.PeriodLimits;
                self.Boundary = p.Results.Boundary;
                validateInputsMATLAB(self);

            else
                parms = struct('Wavelet',uint32(0),...
                    'TimeBandwidth',uint32(0),...
                    'WaveletParameters',uint32(0),...
                    'SignalLength',uint32(0),...
                    'SamplingFrequency',uint32(0),...
                    'VoicesPerOctave',uint32(0),...
                    'FrequencyLimits',uint32(0),...
                    'Boundary',uint32(0));
                popts = struct('CaseSensitivity',false, ...
                    'PartialMatching',true);
                defaultFS = 1;
                % 1x1 doubles
                defaultTB = NaN;
                % 1x2 doubles
                defaultWP = [NaN NaN];
                flim = [NaN NaN];
                % Use these values as defaults for Morse wavelet
                self.Gamma = 3;
                self.Beta = 20;

                pstruct = coder.internal.parseParameterInputs(parms,popts,varargin{:});
                wname = ...
                    coder.internal.getParameterValue(pstruct.Wavelet,defaultWav,varargin{:});
                self.Wavelet = validatestring(wname,{'Morse','amor','bump'},'CWTFILTERBANK','Wavelet');
                TB = ...
                    coder.internal.getParameterValue(pstruct.TimeBandwidth,defaultTB,varargin{:});
                self.TimeBandwidth = TB;
                WP = ...
                    coder.internal.getParameterValue(pstruct.WaveletParameters,defaultWP,varargin{:});
                self.WaveletParameters = WP;
                SigLen = ...
                    coder.internal.getParameterValue(pstruct.SignalLength,defaultSigLen,varargin{:});
                self.SignalLength = SigLen;
                self.SignalPad = floor(self.SignalLength/2);
                VP  = ...
                    coder.internal.getParameterValue(pstruct.VoicesPerOctave,defaultvoices,varargin{:});
                self.VoicesPerOctave = VP;
                FS = ...
                    coder.internal.getParameterValue(pstruct.SamplingFrequency,defaultFS,varargin{:});
                self.SamplingFrequency = FS;
                FreqLimits = ...
                    coder.internal.getParameterValue(pstruct.FrequencyLimits,flim,varargin{:});
                self.FrequencyLimits = FreqLimits;
                Bndry = ...
                    coder.internal.getParameterValue(pstruct.Boundary,defaultboundary,varargin{:});
                self.Boundary = Bndry;
                % On code generation path PeriodLimits and SamplingPeriod
                % not supported so these are empty
                self.PeriodLimits = [];
                self.SamplingPeriod = [];
                validateInputsCODEGEN(self);


            end

            % If the wavelet is not Morse, set the cutoff to 10
            if ~strcmpi(self.Wavelet,'Morse')
                self.CutOff = 10;
            end

            % Obtain wavelet center frequency
            [~,~,self.WaveletCF] = wavelet.internal.cwt.wavCFandSD(...
                self.Wavelet, self.Gamma, self.Beta);

        end



        function [psidft,f] = filterbank(self)
            % Wavelet Filter Bank
            %   PSIDFT = FILTERBANK(FB) returns the CWT wavelet filter bank
            %   frequency responses in PSIDFT. PSIDFT is an Ns-by-N matrix
            %   where Ns is the number of scales (frequencies) and N is the
            %   number of time points.
            %
            %   [PSIDFT,F] = FILTERBANK(FB) returns the frequency grid in
            %   hertz or cycles/sample for plotting the filter bank. Use
            %   centerFrequencies to obtain the passband peak frequencies
            %   for the filter bank.
            %

            if strcmpi(self.Wavelet,'Morse')
                [psidft,f] = wavelet.internal.cwt.morsebpfilters(...
                    self.Omega,self.Scales,self.Gamma,self.Beta);
            else
                [psidft,f] = wavelet.internal.cwt.wavbpfilters(...
                    self.Wavelet,self.Omega,self.Scales);
            end

            Nt = size(psidft,2);
            f = f.*self.SamplingFrequency;
            f = f(:);
            self.NyquistBin = cwtfilterbank.setNyquistBin(Nt);

        end

        function phidft = scalingFunction(self)
            % Return scaling coefficients
            if strcmpi(self.Wavelet,'Morse')
                tmpphidft = ...
                    wavelet.internal.cwt.morsescalingfunction(self.Gamma,...
                    self.Beta,self.Omega,max(self.Scales));

            elseif strcmpi(self.Wavelet,'amor')
                tmpphidft = ...
                    wavelet.internal.cwt.morletscalingfunction(self.Omega,...
                    max(self.Scales));
            else
                Ns = numel(self.Scales);
                thresh = cast(1e-6,'like',self.PsiDFT);
                firstNonzero = find(self.PsiDFT(Ns,:) > thresh,1,'first');
                tmpphidft = ...
                    wavelet.internal.cwt.bumpscalingfunction(self.Omega,...
                    firstNonzero);
            end
            % Construct anti-analytic version
            if signalwavelet.internal.iseven(numel(tmpphidft))
                % N even
                phidft = [tmpphidft(1:self.NyquistBin)  flip(tmpphidft(2:self.NyquistBin-1))];
            else
                % N odd
                phidft = [tmpphidft(1:self.NyquistBin)  flip(tmpphidft(2:self.NyquistBin))];
            end
        end

        function self = FrequencyGrid(self)
            % This method constructs the frequency grid to compute the
            % Fourier transforms of the analyzing wavelets

            N = self.SignalLength+2*self.SignalPad;
            omega = (1:fix(N/2));
            omega = omega.*(2*pi)/N;
            omega = [0, omega, -omega(fix((N-1)/2):-1:1)];
            self.Omega = omega;
            self.Frequencies = self.SamplingFrequency*self.Omega./(2*pi);

        end

        function validateInputsMATLAB(self)
            validateattributes(self.SignalLength,{'numeric'},...
                {'integer','scalar','nonsparse','>=',4},...
                'CWTFILTERBANK','SignalLength');
            validboundary = {'reflection','periodic'};
            self.Wavelet = validatestring(self.Wavelet,{'morse','amor',...
                'bump'}, 'CWTFILTERBANK', 'Wavelet');
            if strcmpi(self.Wavelet,'Morse')
                self.CutOff = 50;
            else
                self.CutOff = 10;
            end


            if ~isempty(self.SamplingFrequency) && ~isempty(self.SamplingPeriod)
                error(message('Wavelet:cwt:sampfreqperiod'));
            elseif ~isempty(self.SamplingFrequency)
                validateattributes(self.SamplingFrequency,{'numeric'},...
                    {'scalar','positive','finite','nonsparse'},'CWTFILTERBANK','SamplingFrequency');
                self.normfreqflag = false;
            elseif ~isempty(self.SamplingPeriod)
                validateattributes(self.SamplingPeriod,{'duration'},...
                    {'scalar','nonempty'},'CWTFILTERBANK','SamplingPeriod');
                [Ts,~,~,pstring] = ...
                    wavelet.internal.getDurationandUnits(self.SamplingPeriod);
                self.PlotString = pstring;
                self.SamplingFrequency = 1/Ts;
                self.normfreqflag = false;
            else
                self.SamplingFrequency = 1;
            end

            if ~strcmpi(self.Wavelet,'morse') && (~isempty(self.TimeBandwidth) || ...
                    ~isempty(self.WaveletParameters))
                error(message('Wavelet:cwt:InvalidParamsWavelet'));
            end

            if strcmpi(self.Wavelet,'Morse') && ...
                    isempty(self.TimeBandwidth) && isempty(self.WaveletParameters)
                % Default gamma and beta values
                self.Gamma = 3;
                self.Beta = 20;
                self.TimeBandwidth = self.Gamma*self.Beta;

            elseif strcmpi(self.Wavelet,'Morse') && ...
                    ~isempty(self.TimeBandwidth) && ...
                    isempty(self.WaveletParameters)

                self.Gamma = 3;
                self.Beta = self.TimeBandwidth/self.Gamma;

            elseif strcmpi(self.Wavelet,'Morse') && ...
                    isempty(self.TimeBandwidth) && ...
                    ~isempty(self.WaveletParameters)
                self.Gamma = self.WaveletParameters(1);
                self.Beta = self.WaveletParameters(2)/self.Gamma;

            elseif ~isempty(self.TimeBandwidth) && ~isempty(self.WaveletParameters)
                error(message('Wavelet:cwt:paramsTB'));
            end

            if ~isempty(self.PeriodLimits)
                validateattributes(self.PeriodLimits,{'duration'},...
                    {'numel',2},'CWTFILTERBANK',...
                    'PeriodLimits');
            end
            if ~isempty(self.SamplingPeriod) && ~isempty(self.FrequencyLimits)
                error(message('Wavelet:cwt:freqrangewithts'));
            elseif isempty(self.SamplingPeriod) && ~isempty(self.PeriodLimits)
                error(message('Wavelet:cwt:periodswithoutTS'));
            end

            if ~isempty(self.FrequencyLimits)
                validateFrequencyRange(self);
            end

            if ~isempty(self.PeriodLimits)
                validatePeriodRange(self);
            end

            validatestring(self.Boundary,validboundary);
            if strcmpi(self.Boundary,'reflection')
                if self.SignalLength <= 1e5
                    self.SignalPad =  floor(self.SignalLength/2);
                else
                    self.SignalPad = ceil(log2(self.SignalLength));
                end
            else
                self.SignalPad = 0;
            end


            if strcmpi(self.Wavelet,'Morse') && ...
                    isempty(self.TimeBandwidth) && isempty(self.WaveletParameters)
                % Default gamma and beta values
                self.Gamma = 3;
                self.Beta = 20;
                self.TimeBandwidth = self.Gamma*self.Beta;

            elseif strcmpi(self.Wavelet,'Morse') && ...
                    ~isempty(self.TimeBandwidth) && ...
                    isempty(self.WaveletParameters)

                self.Gamma = 3;
                self.Beta = self.TimeBandwidth/self.Gamma;

            elseif strcmpi(self.Wavelet,'Morse') && ...
                    isempty(self.TimeBandwidth) && ...
                    ~isempty(self.WaveletParameters)
                self.Gamma = self.WaveletParameters(1);
                self.Beta = self.WaveletParameters(2)/self.Gamma;

            elseif ~isempty(self.TimeBandwidth) && ~isempty(self.WaveletParameters)
                error(message('Wavelet:cwt:paramsTB'));
            end


        end

        function validateInputsCODEGEN(self)

            checkwavparams = @(x) isnumeric(x) && numel(x)==2 && ...
                x(1) >= 1 && x(2)>x(1) && x(2)/x(1) <= 40;
            coder.internal.errorIf(~strcmpi(self.Wavelet,'morse') && ...
                (~isnan(self.TimeBandwidth) || ~all(isnan(self.WaveletParameters))), ...
                'Wavelet:cwt:InvalidParamsWavelet');

            validateattributes(self.VoicesPerOctave,{'numeric'},...
                {'positive','scalar','even','nonsparse','>=',4,'<=',48},...
                'CWTFILTERBANK','VoicesPerOctave');

            validateattributes(self.SignalLength',{'numeric'},...
                {'scalar','integer','nonsparse','>=',4},'CWTFILTERBANK','SignalLength');

            coder.internal.errorIf(~isnan(self.TimeBandwidth) && ...
                ~all(isnan(self.WaveletParameters)),'Wavelet:cwt:paramsTB');
            if ~isnan(self.TimeBandwidth) && all(isnan(self.WaveletParameters))
                validateattributes(self.TimeBandwidth,{'numeric'}, ...
                    {'>',3, '<=',120,'scalar','nonsparse'},'CWTFILTERBANK','TimeBandwidth');
                self.Beta = self.TimeBandwidth/self.Gamma;
            elseif ~all(isnan(self.WaveletParameters)) && isnan(self.TimeBandwidth)
                checkWP = checkwavparams(self.WaveletParameters);
                coder.internal.errorIf(~checkWP,'Wavelet:codegeneration:WavParams');
                self.Gamma = self.WaveletParameters(1);
                self.Beta = self.WaveletParameters(2)/self.Gamma;
            end

            if strcmpi(self.Boundary,'reflection')
                if self.SignalLength <= 1e5
                    self.SignalPad =  floor(self.SignalLength/2);
                else
                    self.SignalPad = ceil(log2(self.SignalLength));
                end
            else
                self.SignalPad = 0;
            end

            if ~all(isnan(self.FrequencyLimits))
                validateFrequencyRange(self);
            end


        end

        function validateFrequencyRange(self)
            freqrange = self.FrequencyLimits;
            validateattributes(freqrange,{'numeric'},{'finite',...
                'increasing','nonsparse','numel',2},'CWTFILTERBANK',...
                'FrequencyLimits');
            NyquistRange = [0 self.SamplingFrequency/2];
            if (freqrange(2) <= NyquistRange(1)) || ...
                    (freqrange(1) >= NyquistRange(2))
                coder.internal.error('Wavelet:cwt:InvalidFrequencyBand',...
                    sprintf('%f', NyquistRange(1)),sprintf('%f',NyquistRange(2)));
            end

            fs = self.SamplingFrequency;
            [minfreq,~, ~] = minmaxfreq(self);
            % If the minimum frequency is less than the minimum allowable
            % frequency, set equal to the minimum.
            if freqrange(1) < minfreq
                self.FrequencyLimits(1) = minfreq;
                % Change freqrange if needed
                freqrange(1) = self.FrequencyLimits(1);
            end

            if freqrange(2) > fs/2
                % If the maximum frequency is greater than the Nyquist, set
                % equal to the Nyquist.
                self.FrequencyLimits(2) = fs/2;
                % Change freqrange if needed
                freqrange(2) = self.FrequencyLimits(2);
            end
            % Sufficient spacing in frequencies to respect VoicesPerOctave
            freqsep = log2(freqrange(2))-log2(freqrange(1)) >= ...
                1/self.VoicesPerOctave;
            coder.internal.errorIf(~freqsep,'Wavelet:cwt:freqsep',sprintf('%2.2f',1.0/self.VoicesPerOctave));

        end

        function validatePeriodRange(self)
            if ~coder.target('MATLAB')
                coder.internal.assert(false,'Wavelet:codegeneration:MethodNotSupported');
            end
            periodrange = self.PeriodLimits;
            % validateattributes does not work on durations
            [p1,~,~,~,dtFunc] = wavelet.internal.parseDuration(self.PeriodLimits(1),self.PeriodLimits(1).Format(1));
            % Make sure durations are converted to double using the same
            % method
            p2 = dtFunc(self.PeriodLimits(2));
            validateattributes([p1 p2],{'numeric'},{'finite',...
                'increasing'},'CWTFILTERBANK','PeriodRange');
            NyquistRange = [2*dtFunc(self.SamplingPeriod) ...
                self.SignalLength*dtFunc(self.SamplingPeriod)];
            if p2 <= NyquistRange(1) || p1 >= NyquistRange(2)
                coder.internal.error('Wavelet:cwt:InvalidPeriodBand',...
                    sprintf('%f', NyquistRange(1)),sprintf('%f',NyquistRange(2)));
            end
            T = self.SamplingPeriod;
            if ~strcmpi(periodrange.Format,T.Format)
                error(message('Wavelet:cwt:InvalidPeriodFormat'));
            end
            [~,maxp] = minmaxfreq(self);

            % Is the requested maximum period less than or equal to the
            % valid maximum period
            upperBound = self.PeriodLimits(2) <= maxp;
            if ~upperBound
                self.PeriodLimits(2) = maxp;
                p2 = dtFunc(self.PeriodLimits(2));
            end
            % Is the requested minimum period greater than or equal to the
            % valid minimum period
            lowerBound = self.PeriodLimits(1) >= 2*self.SamplingPeriod;
            if ~lowerBound
                self.PeriodLimits(1) = 2*self.SamplingPeriod;
                p1 = wavelet.internal.parseDuration(self.PeriodLimits(1),self.PeriodLimits(1).Format(1));

            end
            % Verify separation
            periodsep = log2(p1)-log2(p2) <= -1/self.VoicesPerOctave;
            if ~periodsep
                error(message('Wavelet:cwt:periodsep',...
                    num2str(-1/self.VoicesPerOctave)));
            end

        end

        function freqtoscales(self)
            % Obtain the frequency range
            frange = self.FrequencyLimits;
            % Convert frequencies in Hz to radians/sample
            wrange = frange.*1/self.SamplingFrequency*2*pi;
            nv = self.VoicesPerOctave;
            a0 = 2^(1/nv);
            [~,~,omega_psi] = wavelet.internal.cwt.wavCFandSD(...
                self.Wavelet, self.Gamma, self.Beta);

            % If the frequencies are valid
            s0 = omega_psi/wrange(2);
            smax = omega_psi/wrange(1);
            numoctaves = log2(smax/s0);
            scales = s0*a0.^(0:(nv*numoctaves));
            % For handle class
            self.Scales = scales;


        end

        function periodtoscales(self)
            if ~coder.target('MATLAB')
                coder.internal.assert(false,'Wavelet:codegeneration:MethodNotSupported');
            end
            [Ts,~,convertFunc] = ...
                wavelet.internal.getDurationandUnits(self.SamplingPeriod);
            % Obtain the period limits in units of sampling period
            prange = convertFunc(self.PeriodLimits);
            prange = prange*(1/Ts);
            nv = self.VoicesPerOctave;
            a0 = 2^(1/nv);
            [~,~,omega_psi] = wavelet.internal.cwt.wavCFandSD(...
                self.Wavelet, self.Gamma, self.Beta);
            % s = \frac{\omega_{\psi}}{\omega}
            scalerange = (omega_psi*prange)/(2*pi);
            s0 = min(scalerange);
            smax = max(scalerange);
            numoctaves = log2(smax/s0);
            scales = s0*a0.^(0:nv*numoctaves);
            % For handle class
            self.Scales = scales;


        end

        function [minfreq,maxperiod,maxfreq,minperiod] = minmaxfreq(self)
            wav = self.Wavelet;
            ga = self.Gamma;
            be = self.Beta;
            N = self.SignalLength;
            nv = self.VoicesPerOctave;
            numsd = 2;
            cutoff = self.CutOff;

            timebase = self.SamplingFrequency;
            if ~isempty(self.SamplingPeriod) && coder.target('MATLAB')
                timebase = self.SamplingPeriod;
            end

            [minfreq,maxperiod,~,~,maxfreq,minperiod] = ...
                wavelet.internal.cwt.cwtfreqlimits(...
                wav,N,cutoff,ga,be,timebase,numsd,nv);
        end

        function [bw,fhi,flo] = halfpowerbandwidth(self,Sxx,s)
            if ~coder.target('MATLAB')
                coder.internal.assert(false,'Wavelet:codegeneration:MethodNotSupported');
            end
            % Determine 1/2 power bandwidth for transfer functions
            % We are only using real-valued wavelets here
            onesided = true;
            % Sxx is magnitude data.
            % Power bandwidth calculation is designed to work on PSD
            % estimates. Convert power spectra to PSD. We are scaling the
            % PSD in psdfrommag.
            N = size(self.PsiDFT,2);
            Pxx = wavelet.internal.psdfrommag(Sxx,...
                self.SamplingFrequency,onesided,N);
            % 3 dB point -- 1/2 power bandwidth
            R = -10*log10(2);
            F = self.Frequencies(1:self.NyquistBin);
            % This is set so that the internals of computePowerBW() work
            % correctly with cwtfilterbank
            s.inputType = 'time';
            [bw,fhi,flo] = signalwavelet.internal.computePowerBW(Pxx,F(:),[],R,s);

        end


        function tf = cacheNeeded(self,dataclass)

            tf = false;
            % Check whether a cache already exists
            cacheEmpty = isempty(self.PsiGPU);
            % If the cache is empty, then we must create the cache
            if cacheEmpty
                tf = true;
                % Do we need to refresh the cache for a change in data type?
            elseif ~cacheEmpty
                % If the underlying class of the data does not match the existing
                % cache.
                if ~strcmpi(dataclass,classUnderlying(self.PsiGPU.GPUValue))
                    % Set the logical to true
                    tf = true;
                    % Clear existing cache
                    clearCache(self.PsiGPU);
                end
            end

        end

    end

    methods(Hidden)
        function TF = isNormalizedFrequency(self)
            TF = self.normfreqflag;
        end

        function [ga,be] = getGammaBeta(self)
            if strcmpi(self.Wavelet,'morse')
                ga = self.Gamma;
                be = self.Beta;
            else
                ga = [];
                be = [];
            end
        end


    end

end


