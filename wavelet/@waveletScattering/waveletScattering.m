% waveletScattering Wavelet Time Scattering
%   SN = waveletScattering creates a wavelet time scattering network with
%   two filter banks. The first filter bank has a quality factor of 8
%   wavelets per octave and the second filter bank has a quality factor of
%   1 wavelet per octave. By default, waveletScattering assumes a signal
%   input length of 1024 samples. The scale invariance length is 512
%   samples. By default, waveletScattering uses periodic boundary
%   conditions.
%
%   SN = waveletScattering(Name,Value) creates a wavelet time scattering
%   network, SN, with the specified property Name set to the specified
%   Value. You can specify additional name-value pair arguments in any
%   order as (Name1,Value1,...,NameN,ValueN).
%
%   waveletScattering methods:
%
%   scatteringTransform             - Wavelet 1D scattering transform
%   featureMatrix                   - Scattering feature matrix
%   log                             - Natural logarithm of scattering
%                                     transform
%   filterbank                      - Wavelet and scaling filters
%   littlewoodPaleySum              - Littlewood-Paley sum
%   scattergram                     - Visualize scattering or scalogram
%                                     coefficients
%   centerFrequencies               - Wavelet bandpass center frequencies
%   numorders                       - Number of scattering orders
%   numfilterbanks                  - Number of scattering filter banks
%   numCoefficients                 - Length of transform coefficients
%   paths                           - Scattering network paths
%
%
%   waveletScattering properties:
%
%   SignalLength                    - Signal length
%   SamplingFrequency               - Sampling frequency
%   InvarianceScale                 - Invariance scale
%   QualityFactors                  - Scattering filter bank Q factors
%   Boundary                        - Reflect or treat data as periodic
%   Precision                       - Precision of scattering decomposition
%   OversamplingFactor              - Oversampling factor
%   OptimizePath                    - Path optimization
%
%   See also CWT, CWTFILTERBANK, waveletScattering2

%   Copyright 2018-2022 The MathWorks, Inc.
classdef waveletScattering < handle
    %#codegen
    properties (SetAccess = private)
        %SignalLength Signal length in samples. SignalLength is a positive
        %   integer greater than or equal to 16. By default, SignalLength
        %   is 1024. If the input to the scattering network is a row
        %   vector, SignalLength must match the number of columns in the
        %   input data. If the input to the scattering network is a column
        %   vector, matrix, or 3-D array, SignalLength must match the
        %   number of rows in the data.
        SignalLength = 1024
        %InvarianceScale Invariance scale
        %   The InvarianceScale specifies the translation invariance of the
        %   scattering transform. If you do not specify SamplingFrequency,
        %   InvarianceScale is in samples. If you specify
        %   SamplingFrequency, InvarianceScale is in units of seconds. The
        %   InvarianceScale cannot exceed SignalLength in samples. By
        %   default, the InvarianceScale is one-half the SignalLength in
        %   samples.
        InvarianceScale = 512
        %QualityFactors Quality factors for scattering filter banks
        %   The quality factor is the number of wavelet filters per octave.
        %   Quality factors must be less than or equal to 32 and greater
        %   than or equal to 1. If QualityFactors is specified as a vector,
        %   the elements of QualityFactors must be monotonically
        %   decreasing. By default, QualityFactors is the vector, [8 1].
        QualityFactors = [8 1]
        %Boundary Signal extension at the boundary
        %   Determines how the signal is extended to match the length of
        %   the wavelet filters, which are powers of two. Boundary is one
        %   of 'periodic' (default) or 'reflection'. If Boundary is
        %   'periodic', the signal is extended periodically to length
        %   2^ceil(log2(N)) where N is the length of the signal. If
        %   Boundary is 'reflection', the signal is extended by reflection
        %   to length 2^ceil(log2(2*N)).
        Boundary = 'periodic'
        %SamplingFrequency Sampling frequency in hertz. SamplingFrequency
        %   is a positive scalar. If unspecified, frequencies are in
        %   cycles/sample and the Nyquist is 1/2.
        SamplingFrequency = 1
        %Precision Numeric precision of scattering filter banks. Precision
        %   is a scalar string or character array equal to 'double' or
        %   'single'. If unspecified, Precision defaults to 'double'. If
        %   you construct a scattering network with double precision
        %   filters and apply the network to single-precision data, the
        %   filters are cast internally to single-precision. Subsequent
        %   filtering is done with single precision until a new network is
        %   created regardless of input data type. Specifying Precision as
        %   'single' at construction is especially useful in code
        %   generation because it eliminates the need to create an extra
        %   copy of the scattering filter banks.
        Precision = 'double'
    end

    properties (Access = public)
        %OversamplingFactor Oversampling factor
        %   The OversamplingFactor  specifies the factor by which the
        %   number of scattering coefficients per signal are increased on a
        %   log2 scale as a nonnegative integer or Inf. By default,
        %   OversamplingFactor is set to 0. This value corresponds to
        %   critically downsampling the coefficients to the maximum amount.
        %   To obtain a fully undecimated scattering transform, set
        %   OversamplingFactor to Inf. Setting OversamplingFactor to a
        %   value that would result in more coefficients than samples is
        %   equivalent to setting OversamplingFactor to Inf. Increasing the
        %   OversamplingFactor significantly increases the computational
        %   complexity and memory requirements of the scattering transform.
        OversamplingFactor
        %OptimizePath Path optimization
        %   OptimizePath is a logical scalar. OptimizePath defaults to
        %   false. If you specify OptimizePath as true, the scattering
        %   transform excludes scattering paths of order 2 and greater
        %   which do not satisfy the following criterion:
        %   The center frequency minus 1/2 the 3-dB bandwidth of the
        %   wavelet filter in the (i+1)-th filter bank must overlap 0 (DC)
        %   plus 1/2 the 3-dB bandwidth of the wavelet filter in the i-th
        %   filter bank. If this criterion is not satisfied, the
        %   higher-order path is excluded. Setting OptimizePath to true can
        %   significantly reduce the number of scattering paths and
        %   computational complexity of the scattering transform for most
        %   networks. See the documentation for details.
        OptimizePath
    end

    properties (SetAccess = private,Hidden)
        % Private, hidden properites for filters and filter parameters
        filters = {};
        filterparams = repmat({table(zeros(0,1))},2,1);
        numscatcfs = 0
        paddedlength
        normfreqflag = true
        nFilterBanks = 2
        T
        OBW
        Decimate
        CriticalResolution
        currpaths
        npaths
        parentchild
        GPUFilters = false
    end

    methods (Access = public)
        % Constructor
        function self = waveletScattering(varargin)
            if nargin == 0
                % Defaults for the scattering decomposition
                self.QualityFactors = [8 1];
                self.nFilterBanks = coder.const(numel(self.QualityFactors));
                self.Boundary = 'periodic';
                self.InvarianceScale = 512;
                self.T = 512;
                self.SignalLength = 1024;
                self.OBW = 0.995;
                self.SamplingFrequency = 1;
                self.Decimate = true;
                self.OversamplingFactor = 0;
                self.OptimizePath = false;
            elseif nargin > 0
                self = setProperties(self,varargin{:});
            end
            self.paddedlength = waveletScattering.padlength(self.SignalLength,...
                self.Boundary);
            ftables = gaborparameters(self);
            self.filterparams = ftables;
            self.filters = gabor1Dfilters(self);
            self.CriticalResolution = criticalResolution(self);
            self.numscatcfs = self.numCoefficients();
            [self.currpaths,self.npaths,self.parentchild] = ...
                self.paths();
        end

        % Public methods in separate functions
        [S,U] = scatteringTransform(self,x,includeMeta)
        [lpsum,F] = littlewoodPaleySum(self,fb)
        [levelOneTable,lastidx] = iLevelOnePaths(self);
        [S,U] = featureMatrix(self,x,varargin)

        function  [filters,F,filterparams] = filterbank(self,order)
            %Wavelet and scaling filters
            %   FILTERS = FILTERBANK(SF) returns the filter banks used in
            %   the computation of the scattering coefficients. FILTERS is
            %   a cell array of structure arrays with NORDER elements where
            %   NORDER is the number of scattering orders. The first
            %   element of FILTERS contains the scaling filter, PHIFT, used
            %   in the computation of the 0-th order scattering
            %   coefficients. Subsequent elements of FILTERS contain the
            %   wavelet filters, PSIFT, and scaling filter, PHIFT,
            %   for the corresponding filter banks of the scattering
            %   decomposition.
            %
            %   [FILTERS,F] = FILTERBANK(SF) returns the frequencies
            %   corresponding to the DFT bins in the PSIFT and PHIFT fields
            %   of FILTERS. If you specify a sampling frequency in the
            %   construction of the scattering decomposition framework, F
            %   is in units of hertz. If you do not specify a sampling
            %   frequency, F is in units of cycles/sample.
            %
            %   [FILTERS,F,FILTERPARAMS] = FILTERBANK(SF) returns the
            %   filter parameters for each element of FILTERS. FILTERPARAMS
            %   is a cell array with NORDER elements. Each element of
            %   FILTERPARAMS is a MATLAB table. The first element of
            %   FILTERPARAMS contains a MATLAB table with the following
            %   variables:
            %
            %       boundary: The signal extension used in the filters.
            %
            %       precision: The precision used in the filters. Precision
            %       is one of 'double' or 'single'.
            %
            %       sigmaphi: The time standard deviation of the scaling
            %       function. If you specify a sampling frequency, sigmaphi
            %       is in seconds. If you do not specify a sampling
            %       frequency, sigmaphi is in samples.
            %
            %       freqsigmaphi: The frequency standard deviation of the
            %       scaling function. If you specify a sampling frequency,
            %       freqsigmaphi is in hertz. If you do not specify a
            %       sampling frequency, freqsigmaphi is in cycles/sample.
            %
            %       phiftsupport: The frequency support of the scaling
            %       function. If you specify a sampling frequency, the
            %       frequency support is in hertz. If you do not specify
            %       the sampling frequency, the frequency support is in
            %       cycles/sample.
            %
            %       phi3dBbw: The 3-dB bandwidth of the scaling function.
            %
            %   Subsequent elements of FILTERPARAMS include additional
            %   variables giving the wavelet parameters:
            %
            %       J: The integer number of logarithmically spaced wavelet
            %       filters in the scattering filter bank.
            %
            %       omegapsi: The center frequencies for the wavelet
            %       filters in descending order (highest to lowest). The
            %       omegapsi variable includes the center frequencies for
            %       any linearly spaced filters.
            %
            %       freqsigmapsi: The wavelet frequency standard
            %       deviations.
            %
            %       timesigmapsi: The wavelet time standard deviations.
            %
            %       psi3dBbw: The wavelet 3-dB bandwidths.
            %
            %       psiftsupport: The wavelet frequency supports.
            %
            %   [...] = FILTERBANK(SF,ORDER) returns the filter banks used
            %   to compute the specified ORDER scattering coefficients.
            %   ORDER is an integer between 0 and the number of filter
            %   banks in the scattering decomposition.
            %
            %   % Example Plot the wavelet filters used in the computation
            %   %   of the first-order scattering coefficients.
            %
            %   sf = waveletScattering('SignalLength',2^16);
            %   [filters,f] = filterbank(sf);
            %   plot(f,filters{2}.psift)
            %   title('Wavelet Filters with Q=8');
            %   xlabel('Cycles/Sample'); ylabel('Magnitude');

            narginchk(1,2);
            % Obtain the number of orders in the scattering decomposition
            if nargin > 1
                % The second input must be the order
                no = numorders(self);
                validateattributes(order,{'numeric'},...
                    {'nonempty','>=',0,'<=',no-1,'increasing'},...
                    'waveletScattering','ORDER');
                % MATLAB indexing
                idxorder = order+1;
            else
                idxorder = 1:numel(self.filters)+1;
            end
            type = underlyingType(self.filters{1}.phift);
            N = cast(size(self.filters{1}.phift,1),type);
            Fsfilterparams = normfreqToHz(self);
            tf = isNormalizedFrequency(self);
            if ~tf
                Fs = cast(self.SamplingFrequency,type);
                F = 0:Fs/N:Fs-Fs/N;
                F = F(:);
            else
                F = 0:1/N:1-1/N;
                F = F(:);
            end
            if self.GPUFilters && isempty(coder.target)
                F = gpuArray(F);
            end
            % The following is for code generation. MATLAB Coder does not
            % support concatenation of cell arrays or smooth indexing into
            % cell arrays
            tmpfilterparams = cell(length(Fsfilterparams)+1,1);
            tmpfilters = cell(length(Fsfilterparams)+1,1);
            f0 = table({self.Boundary},{self.Precision},...
                Fsfilterparams{1}.sigmaphi,...
                Fsfilterparams{1}.freqsigmaphi,...
                Fsfilterparams{1}.phiftsupport,...
                Fsfilterparams{1}.phi3dBbw,'VariableNames',...
                {'boundary','precision','sigmaphi','freqsigmaphi',...
                'phiftsupport','phi3dBbw'});
            tmpfilterparams{1} = f0;
            % MATLAB Coder does not support delete variables by assignment
            % to an empty matrix
            for ii = 2:length(Fsfilterparams)+1
                tmpfilterparams{ii} = table(Fsfilterparams{ii-1}.Q,...
                    Fsfilterparams{ii-1}.J,Fsfilterparams{ii-1}.boundary,...
                    Fsfilterparams{ii-1}.precision,...
                    Fsfilterparams{ii-1}.omegapsi,...
                    Fsfilterparams{ii-1}.freqsigmapsi,...
                    Fsfilterparams{ii-1}.timesigmapsi,...
                    Fsfilterparams{ii-1}.sigmaphi,...
                    Fsfilterparams{ii-1}.freqsigmaphi,...
                    Fsfilterparams{ii-1}.psi3dBbw,...
                    Fsfilterparams{ii-1}.psiftsupport,...
                    Fsfilterparams{ii-1}.phiftsupport,...
                    Fsfilterparams{ii-1}.phi3dBbw,...
                    'VariableNames',{'Q','J','boundary','precision',...
                    'omegapsi','freqsigmapsi',...
                    'timesigmapsi','sigmaphi',...
                    'freqsigmaphi','psi3dBbw',...
                    'psiftsupport','phiftsupport',...
                    'phi3dBbw'});
            end
            filtphi = struct('phift',self.filters{1}.phift);
            tmpfilters{1} = filtphi;
            for ii = 1:length(self.filters)
                tmpfilters{ii+1} = self.filters{ii};
            end
            filters = cell(length(idxorder),1);
            filterparams = cell(length(idxorder),1);
            for ii = 1:length(idxorder)
                filters{ii} = tmpfilters{idxorder(ii)};
                filterparams{ii} = tmpfilterparams{idxorder(ii)};
            end
        end

        function no = numorders(self)
            % Number of scattering orders
            %   NO = NUMORDERS(SF) returns the number of orders for the
            %   scattering decomposition framework, SF. The number of
            %   orders is equal to the number of filterbanks+1.
            %
            %   % Example: Return the number of orders for the default
            %   %   scattering framework.
            %
            %   sn = waveletScattering;
            %   no = numorders(sn);

            no = numel(self.filters)+1;
        end

        function y = log(self,x)
            %Natural logarithm of scattering transform
            %   Slog = log(SF,S) returns the natural logarithm of the
            %   scattering coefficients in the cell array, S. S is the
            %   output of scatteringTransform and is a cell array of
            %   structure arrays with a signals field.
            %
            %   Ulog = log(SF,U) returns the natural logarithm of the
            %   scalogram coefficients in U. U is the output of
            %   scatteringTransform and is a cell array of structure arrays
            %   with a coefficients field.
            %
            %   Xlog = log(SF,X) returns the natural logarithm of the
            %   scattering feature matrix, X. X is the first output of the
            %   featureMatrix method.

            validateattributes(x,{'cell','numeric'},{'nonempty'},'log','x');
            coder.internal.errorIf(~iscell(x) && ...
                (~isnumeric(x) || isvector(x)), ...
                'Wavelet:scattering:logmatrix');
            if iscell(x)
                % Use logscatteringtransform method
                ytmp = ...
                    waveletScattering.logscatteringtransform(x,...
                    char(self.Precision));
            else
                ytmp = log(abs(x)+realmin(char(self.Precision)));
            end
            y = ytmp;
        end

        function F = centerFrequencies(self,filterbanks)
            %Wavelet bandpass center frequencies
            %   F = centerFrequencies(SF) returns the wavelet bandpass
            %   frequencies for all filter banks of the scattering
            %   decomposition framework, SF. F is a cell array with Nfb
            %   elements where Nfb is the number of scattering filter
            %   banks. If there is only one filter banks in the scattering
            %   architecture, F is a vector containing the wavelet bandpass
            %   center frequencies. If you specify a sampling frequency, F
            %   is in units of hertz. If you do not specify a sampling
            %   frequency, F is in units of cycles/sample.
            %
            %   F = centerFrequencies(SF,FILTERBANKS) returns the wavelet
            %   bandpass center frequencies for the specified filter banks,
            %   FILTERBANKS. FILTERBANKS may be a scalar or vector with all
            %   elements between 1 and the number of filter banks in the
            %   scattering framework.
            %
            %   % Example: Return the wavelet bandpass frequencies for the
            %   %   first filter bank of a scattering decomposition
            %   %   framework with a sampling frequency of 1 kHz.
            %
            %   sf = waveletScattering('SignalLength',2048,...
            %   'SamplingFrequency',1000);
            %   F = centerFrequencies(sf,1);

            % Get the number of filter banks
            Nfb = self.nFilterBanks;
            if nargin > 1
                validateattributes(filterbanks,{'numeric'},{'<=',Nfb,'positive'},...
                    'centerFrequencies','filterbanks');
            else
                filterbanks = 1:Nfb;
            end

            NF = numel(filterbanks);

            if ~self.normfreqflag
                factor = self.SamplingFrequency/(2*pi);
            else
                factor = 1/(2*pi);
            end
            Ftmp = cell(Nfb,1);
            for nL = coder.unroll(1:Nfb)
                Ftmp{nL} = (self.filterparams{nL}.omegapsi.*factor)';
            end
            F = cell(NF,1);

            for ii = 1:NF
                F{ii} = Ftmp{filterbanks(ii)};
            end

            if isempty(coder.target)
                if (nargin > 1 && isscalar(filterbanks)) || (Nfb == 1)
                    F = cell2mat(Ftmp(filterbanks));
                elseif nargin > 1 && ~isscalar(filterbanks)
                    F = Ftmp(filterbanks);
                end
            end

            if self.GPUFilters && isempty(coder.target)
                if iscell(F)
                    F = cellfun(@gpuArray,F,'UniformOutput',false);
                else
                    F = gpuArray(F);
                end
            end
        end

        function nfb = numfilterbanks(self)
            %Number of scattering filter banks
            %   NFB = NUMFILTERBANKS(SF) returns the number of filter banks
            %   in the scattering decomposition framework, SF. The number
            %   of filter banks in a scattering decomposition framework is
            %   equal to the number of orders-1.
            %
            %   % Example: Return the number of filter banks for the default
            %   %   scattering decomposition.
            %   sf = waveletScattering;
            %   nfb = numfilterbanks(sf);

            nfb = numel(self.QualityFactors);
        end

        function img = scattergram(self,S,varargin)
            %Scattergram
            %   IMG = SCATTERGRAM(SF,S) returns the scattergram as a matrix
            %   for the first-order scattering coefficients, S. S is the
            %   output of scatteringTransform computed using the scattering
            %   framework, SF.
            %
            %   IMG = SCATTERGRAM(SF,U) returns the scattergram as a matrix
            %   for the first-order scalogram coefficients, U. U is the
            %   output of scatteringTransform computed using the scattering
            %   decomposition framework, SF.
            %
            %   IMG = SCATTERGRAM(...,'FilterBank',FB) returns the
            %   scattergram for the FB-th filter bank. FB is an integer
            %   between 1 and NUMFILTERBANKS(SF). For filter banks greater
            %   than 1, SCATTERGRAM averages the scalogram or scattering
            %   coefficients over all paths terminating at each wavelet
            %   bandpass filter. To obtain only paths with a common parent,
            %   use the 'Parent',P name-value pair.
            %
            %   IMG = SCATTERGRAM(...,'FilterBank',FB,'Parent',P) returns
            %   the scattergram for the path at the FB-th filter bank with
            %   parent, P. P is a nonnegative scalar integer representing
            %   the P-th wavelet filter at filter bank, FB-1. If FB is
            %   equal to 1, the 0-th filter bank corresponds to the input
            %   signal in the case of the scalogram coefficients and the
            %   lowpass filtering of the input signal with the scaling
            %   function in the case of the scattering coefficients. Lower
            %   values of P correspond to wavelets with higher bandpass
            %   frequencies. If you specify a value for P which results in
            %   a single child, IMG is a vector. If you specify a value for
            %   P which results in no children, SCATTERGRAM returns
            %   SCATTERGRAM(...,'FilterBank',FB).
            %
            %   SCATTERGRAM(...) plots the scattergram in the current
            %   figure. If you use the 'Parent' name-value pair and specify
            %   a value for P which results in a single child, SCATTERGRAM
            %   produces a line plot. Otherwise, SCATTERGRAM produces a
            %   surface plot consisting of all the children.
            %
            %   % Example Display the scattergram for the first-order
            %   %   scalogram coefficients of the Kobe earthquake data.
            %
            %   load kobe;
            %   sf = waveletScattering('SignalLength',numel(kobe),...
            %   'InvarianceScale',1e3,'QualityFactors',[12 8],...
            %   'SamplingFrequency',1);
            %   [S,U] = scatteringTransform(sf,kobe);
            %   scattergram(sf,U,'FilterBank',1);

            coder.internal.errorIf(~isempty(coder.target),...
                'Wavelet:scattering:ScattergramNoCodegen');
            nargoutchk(0,1);
            narginchk(2,6);
            validateattributes(S,{'cell'},{'nonempty'},'scattergram','S');
            nelem = numel(S);
            if nelem < 2
                error(message('Wavelet:scattering:scattergramcell'));
            end
            % Number of filter banks in the scattering transform
            nfb = numfilterbanks(self);
            validfb = @(x)validateattributes(x,{'numeric'},{'scalar','>=',1,...
                '<=',nfb},'scattergram','FilterBank');
            validparent = @(x)validateattributes(x,{'numeric'},...
                {'scalar','integer','nonnegative','finite'},...
                'scattergram','Parent');
            % MATLAB only parser is OK here.
            p = inputParser;
            p.addParameter('FilterBank',1,validfb);
            p.addParameter('Parent',[]);
            p.parse(varargin{:});
            fb = p.Results.FilterBank+1;
            origfb = fb-1;
            parent = p.Results.Parent;
            if ~isempty(parent)
                validparent(parent);
            end
            S = S{fb};
            % The input S is expected to be a MATLAB table with the correct fields
            if ~istable(S)
                error(message('Wavelet:scattering:scattergramtable'));
            end

            if ~any(strcmpi('path',S.Properties.VariableNames)) ...
                    && (~any(strcmpi('signals',S.Properties.VariableNames))|| ...
                    ~any(strcmpi('coefficients',S.Properities.VariableNames)))
                error(message('Wavelet:scattering:tablevariables'));
            end

            % This should return a vector for a scattering decomposition
            % with one filter bank
            F = self.centerFrequencies(fb-1);
            if any(strcmpi(S.Properties.VariableNames,'signals'))
                type = 'scattering';
            elseif any(strcmpi(S.Properties.VariableNames,'coefficients'))
                type = 'wavelet';
            end
            [cfs,freqidx,t,parentidx] = waveletScattering.scattergramFB(S,parent,type,origfb);
            if isrow(cfs)
                isVector = true;
                cfs = cfs.';
            else
                isVector = false;
            end
            if ~isempty(freqidx)
                F = F(freqidx);
            end

            if ~self.normfreqflag
                t.time = t.time.*(1/self.SamplingFrequency);
            end
            if nargout == 0
                tstamps = t.time.*2^(-t.resolution);
                hf = gcf;
                clf;
                AX = axes('parent',hf);
                % vector case: use line plot
                if isVector
                    plot(AX,tstamps,cfs); grid on;
                    axis tight;
                else
                    surf(AX,tstamps,F,cfs); view(0,90);
                    shading interp; axis tight;
                end
                if self.normfreqflag
                    xlbl = getString(message('Wavelet:scattering:Samples'));
                    if strcmpi(type,'wavelet')
                        titleString = ...
                            getString(message('Wavelet:scattering:ScattergramWav',origfb));
                    elseif strcmpi(type,'scattering')
                        titleString = ...
                            getString(message('Wavelet:scattering:ScattergramScat',origfb));
                    end
                elseif ~self.normfreqflag
                    xlbl = getString(message('Wavelet:scattering:Seconds'));
                    if strcmpi(type,'wavelet')
                        titleString = ...
                            getString(message('Wavelet:scattering:ScattergramWav',origfb));
                    elseif strcmpi(type,'scattering')
                        titleString = ...
                            getString(message('Wavelet:scattering:ScattergramScat',origfb));
                    end
                end
                % Obtain the proper ylabel for a vector or matrix case
                if isVector
                    ylbl = getString(message('Wavelet:scattering:Mag'));
                elseif ~isVector && self.normfreqflag
                    ylbl = getString(message('Wavelet:scattering:Cycles'));
                elseif ~isVector && ~self.normfreqflag
                    ylbl = getString(message('Wavelet:scattering:Hz'));
                end
                xlabel(AX,xlbl);
                ylabel(AX,ylbl);
                if ~isempty(parentidx) && origfb > 1
                    parentFreq = self.centerFrequencies(origfb-1);
                    titleStringParent = ...
                        getString(message('Wavelet:scattering:SGPntFreq',num2str(parentFreq(parent))));
                    titleString = {titleString; titleStringParent};
                end
                title(titleString);
                hf.NextPlot = 'replace';
            elseif nargout > 0
                img = cfs;
            end
        end

        function len = numCoefficients(self)
            %Number of scattering coefficients
            %   NCF = NUMCOEFFICIENTS(SF) returns the number of scattering
            %   coefficients for the specified scattering framework SF. The
            %   number of scattering coefficients depends on the values of the
            %   SignalLength, InvarianceScale, and OversamplingFactor
            %   properties of the scattering framework SF.
            %
            %   % Example: Return the number of scattering coefficients for the
            %   %   scattering framework.
            %   sf = waveletScattering;
            %   numCoeff = numCoefficients(sf);

            narginchk(1,1);
            nargoutchk(0,1);
            osfac = self.OversamplingFactor;
            if isempty(self.CriticalResolution)
                self.CriticalResolution = criticalResolution(self);
            end
            cr = self.CriticalResolution;
            sl = self.SignalLength;
            tf = false;
            if ~isinf(osfac) && (osfac < cr)
                tf = true;
            end
            len = waveletScattering.iDetermineLength(sl,cr,...
                osfac,tf);
        end

        function [paths,npaths,parentchild] = paths(self)
            %Scattering network paths
            %   SPATHS = paths(SN) returns the scattering paths for the
            %   network, SN. SPATHS is a NO-by-1 cell array of MATLAB
            %   tables, where NO is the number of orders in the scattering
            %   network. The variables in the MATLAB tables are:
            %
            %   path - Scattering network paths. In the k-th element of
            %   SPATHS, path is a N-by-k matrix where each row contains a
            %   path from the input data through the (k-1)-th wavelet
            %   filter bank. For example, when k equals 1, N is equal to 1
            %   and the only path is 0 denoting the input data. When k
            %   equals 2, N is equal to the number of wavelet filters in
            %   the first filter bank and path is a N-by-2 matrix
            %   describing the path from the input data, 0, through the
            %   wavelet filters in the first filter bank. The second column
            %   of path contains the wavelet filters in the first filter
            %   bank ordered by decreasing center frequency.
            %
            %   log2ds - The incremental log2 downsampling factor for the
            %   scalogram coefficients corresponding to the cumulative path
            %   in the same row.
            %
            %   log2res - The cumulative log2 resolution of the scalogram
            %   coefficients corresponding to the cumulative path in the
            %   same row.
            %
            %   [PATHS,NPATHS] = PATHS(SN) returns the number of wavelet
            %   scattering paths by order. NPATHS is a NO-by-1 vector
            %   where NO is the number of orders in the scattering network.
            %   The i-th element of NPATHS contains the number of
            %   scattering paths in the (i-1)-th order.
            %
            %   %Example:
            %   %   Obtain the scattering path information for a wavelet
            %   %   scattering network with a signal length of 2000, an
            %   %   invariance scale of 500 and Q-factors of 4 and 1.
            %   %   First obtain the path information without optimization
            %   %   of path. Repeat with 'OptimizePath' set to true.
            %
            %       sn = waveletScattering('SignalLength',2000,...
            %       'InvarianceScale',500,'QualityFactors',[4 1]);
            %       [spaths,npaths] = paths(sn); sn.OptimizePath = true;
            %       [spaths,npaths] = paths(sn);

            Nfb = length(self.filterparams);
            if isempty(self.filterparams{1})
                paths = cell(Nfb+1,1);
                npaths = zeros(Nfb+1,1);
                parentchild = cell(Nfb,1);
                return;
            end
            paths = cell(Nfb+1,1);
            OptPath = self.OptimizePath;
            OSfac = self.OversamplingFactor;
            tmpnpaths = zeros(Nfb+1,1);
            tmpnpaths(1) = 1;
            parentchild = cell(Nfb,1);
            paths{1} = table(0,0,0,'VariableNames',...
                {'path','log2ds','log2res'});
            [paths{2},lastidx] = iLevelOnePaths(self);
            coder.varsize('threedB');
            threedB = (self.filterparams{1}.psi3dBbw)';
            parentchild{1} = {2:lastidx};
            tmpnpaths(2) = size(paths{2},1);
            nextLevelStart = lastidx+1;
            for ii = coder.unroll(3:Nfb+1)
                ftable = self.filterparams{ii-1};
                [paths{ii},parentchild{ii-1},threedB,nextLevelStart] = ...
                    waveletScattering.iNextLevelPath(paths{ii-1},threedB,...
                    ftable,OSfac,OptPath,nextLevelStart);
                tmpnpaths(ii) = size(paths{ii},1);
            end
            npaths = tmpnpaths;
            %Check whether any of the paths of order 2 and higher are empty
            for ii = coder.unroll(2:Nfb+1)
                if isempty(paths{ii})
                    coder.internal.warning('Wavelet:scattering:emptypath',...
                        num2str(ii-1));
                end
            end
        end
    end

    %set method for OversamplingFactor and OptimizePath properties
    methods
        function set.OversamplingFactor(self, value)
            if (isnumeric(value) && isscalar(value) ...
                    && (value>=0) && (floor(value)==value)) || (isinf(value)&&(value>=0))
                self.OversamplingFactor = value;
            else
                coder.internal.error('Wavelet:scattering:InvalidLOSF');
            end
            % For code generation the oversampling factor is a compile
            % time constant
            if isempty(coder.target)
                if ~isempty(self.filterparams{1}) %#ok<MCSUP>
                    self.updatePaths();
                end
            end
        end

        function set.OptimizePath(self,value)
            validateattributes(value,{'logical','numeric'},{'scalar',...
                'nonempty','finite'},'waveletScattering','OptimizePath');
            self.OptimizePath = value;
            % For code generation optimizePath is a compile
            % time constant
            if isempty(coder.target)
                if ~isempty(self.filterparams{1}) %#ok<MCSUP>
                    self.updatePaths();
                end
            end
        end
    end

    methods (Access = private, Hidden)
        function self = setProperties(self,varargin)
            self.OBW = coder.const(0.995);
            defaultQ = [8 1];
            defaultT = [];
            defaultFs = [];
            defaultSL = 1024;
            defaultOptimize = false;
            defaultOSfac = 0;
            defaultB = 'periodic';
            defaultPrecision = 'double';
            % Test for Q-factors in scattering architecture
            validQ = @(x)validateattributes(x,{'numeric'},...
                {'vector','real','nonincreasing','integer','<=',32},'waveletScattering','QualityFactors');
            validT = @(x)validateattributes(x,{'numeric'},{'positive','scalar',...
                'nonempty'});
            validFs = @(x)validateattributes(x,{'numeric'},{'positive','scalar',...
                'finite','nonempty'},'waveletScattering','SamplingFrequency');
            validSL = @(x)validateattributes(x,{'numeric'},{'real',...
                'positive','>=',16,'scalar','finite'},'waveletScattering','SignalLength');
            validOversamplingFactor = @(x) assert((isnumeric(x) && isscalar(x) ...
                && x>=0 && floor(x)==x) || (isinf(x)&& x>=0),message('Wavelet:scattering:InvalidLOSF'));
            validOptimizePath = @(x)validateattributes(x,...
                {'logical','numeric'},{'scalar','nonempty'},...
                'waveletScattering','OptimizePath');
            parms = struct('QualityFactors',uint32(0),...
                'SignalLength',uint32(0),'InvarianceScale',uint32(0),...
                'SamplingFrequency',uint32(0),...
                'OversamplingFactor',uint32(0),...
                'OptimizePath',uint32(0),...
                'Boundary',uint32(0),...
                'Precision',uint32(0));
            popts = struct('CaseSensitivity',false,...
                'PartialMatching',true);
            pstruct = coder.internal.parseParameterInputs(parms,popts,...
                varargin{:});
            SL = coder.internal.getParameterValue(pstruct.SignalLength,...
                defaultSL,varargin{:});
            validSL(SL);
            self.SignalLength = SL;
            Q = coder.internal.getParameterValue(pstruct.QualityFactors,...
                defaultQ,varargin{:});
            validQ(Q);
            self.QualityFactors = Q;
            coder.internal.assert(coder.internal.isConst(size(self.QualityFactors)),...
                'Wavelet:scattering:Qconst');
            Tinput = coder.internal.getParameterValue(pstruct.InvarianceScale,...
                defaultT,varargin{:});

            Fs = coder.internal.getParameterValue(pstruct.SamplingFrequency,...
                defaultFs,varargin{:});
            if isempty(Fs)
                self.normfreqflag = true;
                self.SamplingFrequency = 1;
            else
                self.normfreqflag = false;
                self.SamplingFrequency = Fs;
            end
            validFs(self.SamplingFrequency);
            OSfac = ...
                coder.internal.getParameterValue(pstruct.OversamplingFactor,...
                defaultOSfac,varargin{:});
            validOversamplingFactor(OSfac);
            self.OversamplingFactor = OSfac;
            optpath = ...
                coder.internal.getParameterValue(pstruct.OptimizePath,...
                defaultOptimize,varargin{:});
            validOptimizePath(optpath);
            self.OptimizePath = optpath;
            bnd = coder.internal.getParameterValue(pstruct.Boundary,...
                defaultB,varargin{:});
            coder.internal.assert(coder.internal.isConst(bnd),...
                'Wavelet:scattering:constantboundary');
            matchedB = validatestring(bnd,{'periodic','reflection'},...
                'waveletScattering','Boundary');
            self.Boundary = matchedB;
            prec = coder.internal.getParameterValue(pstruct.Precision,...
                defaultPrecision,varargin{:});
            coder.internal.assert(coder.internal.isConst(prec),...
                'Wavelet:scattering:constantprecision');
            matchedPrec = validatestring(prec,{'double','single'},...
                'waveletScattering','Precision');
            self.Precision = matchedPrec;

            % Help MATLAB Coder know this is a scalar
            self.InvarianceScale = round(self.SignalLength/2);
            if ~self.normfreqflag && isempty(Tinput)
                self.InvarianceScale = ...
                    self.SignalLength/2*1/self.SamplingFrequency;
            elseif ~isempty(Tinput)
                self.InvarianceScale = Tinput;
            end
            validateattributes(self.InvarianceScale,{'numeric'},...
                {'positive','scalar','nonempty'},...
                'waveletScattering','InvarianceScale');
            validT(self.InvarianceScale);
            coder.internal.errorIf(self.InvarianceScale < 1 ...
                && self.normfreqflag,'Wavelet:scattering:HighFSmissing');
            coder.internal.errorIf(self.InvarianceScale > self.SignalLength...
                && self.normfreqflag,'Wavelet:scattering:LowFSmissing');
            % T is defined in terms of samples
            self.T = waveletScattering.invariantToN(self.SignalLength,...
                self.InvarianceScale,self.SamplingFrequency);
            % The number of filter banks cannot be varsize.
            self.nFilterBanks = coder.const(numel(self.QualityFactors));
        end

        function TF = isNormalizedFrequency(self)
            TF = self.normfreqflag;
        end

        function filterparams = normfreqToHz(self)
            filterparams = self.filterparams;
            tf = isNormalizedFrequency(self);
            if tf
                Fs = 1;
                DT = 1;
            else
                Fs = self.SamplingFrequency;
                DT = 1/self.SamplingFrequency;
            end
            % This is a cell array of tables
            for nl = 1:self.nFilterBanks
                filterparams{nl}{:,{'omegapsi','freqsigmapsi'}} = ...
                    filterparams{nl}{:,{'omegapsi','freqsigmapsi'}}.*Fs/(2*pi);
                filterparams{nl}{:,{'freqsigmaphi','psi3dBbw'}} = ...
                    filterparams{nl}{:,{'freqsigmaphi','psi3dBbw'}}.*Fs/(2*pi);
                filterparams{nl}{:,{'psiftsupport','phiftsupport'}} = ...
                    filterparams{nl}{:,{'psiftsupport','phiftsupport'}}.*Fs/(2*pi);
                filterparams{nl}{:,{'phi3dBbw'}} = ...
                    filterparams{nl}{:,{'phi3dBbw'}}.*Fs/(2*pi);
                filterparams{nl}{:,{'timesigmapsi','sigmaphi'}} = ...
                    filterparams{nl}{:,{'timesigmapsi','sigmaphi'}}.*DT;
            end
        end

        function criticalRes = criticalResolution(self)
            totalBW = 2*pi;
            criticalRes = round(log2(totalBW/self.filterparams{1}.phiftsupport));
        end

        function createGPUarrays(self)
            % All filters are stored as GPU arrays.
            coder.internal.errorIf(~isempty(coder.target),...
                'Wavelet:scattering:CodegenNotsupported');
            if self.GPUFilters
                return;
            end
            phift = ...
                parallel.internal.gpu.CachedGPUArray(self.filters{1}.phift);
            self.filters{1}.phift = phift.GPUValue;
            for nfb = 1:self.nFilterBanks
                psift = ...
                    parallel.internal.gpu.CachedGPUArray(self.filters{nfb}.psift);
                self.filters{nfb}.psift = psift.GPUValue;
                % This is the same array as in nfb =1 but the GPU
                % implementation appears to just do this as a pointer not
                % resulting in more memory being consumed
                self.filters{nfb}.phift = phift.GPUValue;
            end
            self.GPUFilters = true;
        end

        function gatherGPUarrays(self)
            % All filters are stored as GPU arrays.
            coder.internal.errorIf(~isempty(coder.target),...
                'Wavelet:scattering:CodegenNotsupported');
            self.filters{1}.phift = gather(self.filters{1}.phift);
            for nfb = 1:self.nFilterBanks
                self.filters{nfb}.psift = gather(self.filters{nfb}.psift);
                self.filters{nfb}.phift = gather(self.filters{nfb}.phift);
            end
            self.GPUFilters = false;
        end

        function singleFilters(self)
            % All filters are stored single
            coder.internal.errorIf(~isempty(coder.target),...
                'Wavelet:scattering:CodegenNotSupported');
            hatphif = cast(self.filters{1}.phift,'single');
            self.filters{1}.phift = hatphif;
            for nfb = 1:self.nFilterBanks
                self.filters{nfb}.psift = ...
                    cast(self.filters{nfb}.psift,'single');
                self.filters{nfb}.phift = hatphif;
            end
            self.Precision = 'single';
        end

        function self = updatePaths(self)
            coder.internal.errorIf(~isempty(coder.target),...
                'Wavelet:scattering:CodegenNotSupported');
            [self.currpaths,self.npaths,self.parentchild] = ...
                self.paths();
            self.numscatcfs = self.numCoefficients();
        end

        function self = updateNumSCFS(self)
            coder.internal.errorIf(~isempty(coder.target),...
                'Wavelet:scattering:CodegenNotSupported');
            self.numscatcfs = self.numCoefficients();
        end
        % Hidden methods defined in separate files in the
        % @waveletScattering directory
        filterparams = gaborparameters(self)
        filters = gabor1Dfilters(self)
        [U_phi,U_psi,psires,psiftsup,psi3dB] = forward(self,U,res,threedB,nfb)
        [phicoefs,psicoefs,psires,psi3dB] = wt1d(self,x,res,vwav,nfb)
    end

    methods(Static,Hidden)
        % These are the small static methods defined in class. Additional
        % static methods in @waveletScattering directory
        function phi_J_L = invariantToN(N,T,Fs)
            if isempty(Fs)
                phi_J_L = T;
            elseif ~isempty(Fs)
                % We want the invariant expressed in samples internally
                phi_J_L = round(T*Fs);

            end
            coder.internal.errorIf(phi_J_L > N, ...
                'Wavelet:scattering:Tlength',phi_J_L,N);
        end
        function Npad = padlength(Norig,boundary)
            % Determine pad length depending on boundary conditions
            if strcmpi(boundary,'periodic')
                Npad = 2^ceil(log2(Norig));
            else
                Norig = 2*Norig;
                Npad = 2^ceil(log2(Norig));
            end
        end
        function len = iDetermineLength(sl,cr,osfac,tf)
            if tf
                len = 1+fix((sl-1)./2^(cr-osfac));
            else
                len = sl;
            end
        end
    end
    methods(Static,Hidden)
        function props = matlabCodegenSoftNontunableProperties(~)
            % This property is used as the upper bound on coder.unroll() loops
            props = {'nFilterBanks','Precision','QualityFactors',...
                'npaths'};
        end
        % Hidden static methods defined in @waveletScattering
        X = apply_nonlinearity(option,X)
        tf = frequencyoverlap(res,gparams)
        [log2_phi_os, log2_psi_os] = ...
            log2DecimationFactor(gparams,resolution,validwav,...
            overSampleFactor)
        x = logscatteringtransform(x,precision)
        y = padsignal(x,npad,type)
        y = unpadsignal(x,res,origsize)
        [img,freqidx,t,parentidx] = scattergramFB(S,parent,type,fb)
        [y,dsfilter] = convdown(xdft,dsfilter,dsfactor,res,normfactor)
        validwav = optimizePath(validwav,current3dB,gparams)
        [nextpath,parentchild,threedB,lastidx] = iNextLevelPath(prevtable,...
            prev3dB,ftable,OSfac,OptimizePath,startidx)
        [S,U,Udft] = layerOneConvdown(xdft,psif,phif,dspsi,dsphi)
        [S,U] = scatconvdown(xdft,dspsif,dsphif,dspsi,dsphi,res)
        Snorm = iParentChildNormalize(S,Snorm0,parentchild)
    end
end
