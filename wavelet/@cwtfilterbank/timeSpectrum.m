function [tavgp,f] = timeSpectrum(self,x,varargin)
%timeSpectrum Time-averaged wavelet spectrum
%   TAVGP = timeSpectrum(FB,X) returns the time-averaged wavelet power
%   spectrum of the signal X, using the CWT filter bank, FB. X is a double-
%   or single-precision real- or complex-valued vector. By default, TAVGP
%   is obtained by time-averaging the magnitude-squared scalogram over all
%   times. If X is real-valued, TAVGP is a F-by-1 vector where F is the
%   number of wavelet center frequencies or center periods in the CWT
%   filter bank, FB. If X is complex-valued, TAVGP is F-by-1-by-2 where the
%   first page is the time-averaged wavelet spectrum for the positive
%   scales (analytic part or counterclockwise component) and the second
%   page is the time-averaged wavelet spectrum for the negative scales
%   (anti-analytic part or clockwise component).
%
%   [TAVGP,F] = timeSpectrum(FB,X) returns the wavelet center frequencies
%   or center periods for the time-averaged wavelet spectrum. F is a
%   column vector or duration array depending on whether the sampling
%   frequency or sampling period is specified in the CWT filter bank, FB.
%
%   [...] = timeSpectrum(FB,CFS) returns the time-averaged wavelet
%   spectrum for the CWT coefficient matrix, CFS. CFS is expected to be
%   the output of the WT method of the CWT filter bank, FB.
%
%   [...] = timeSpectrum(...,'Normalization',NTYPE) specifies the
%   normalization of the time-averaged wavelet spectrum as one of
%   'var', 'pdf', or 'none'. If NTYPE is 'var', the power or integral of the
%   time-averaged wavelet spectrum is normalized to equal the variance of
%   the time series, X. If the CFS input is provided, the variance of the
%   last time series processed by the WT method is used. If NTYPE is 'pdf',
%   the time-averaged wavelet spectrum is normalized to equal 1. If you set
%   NTYPE to 'none', no normalization is applied. If unspecified, NTYPE
%   defaults to 'var'. See the documentation for details on the
%   normalization used in timeSpectrum.
%
%   [...] = timeSpectrum(...,'SpectrumType',SPECTYPE) specifies the type of
%   wavelet spectrum to return as 'power' or 'density'. If you specify
%   'power', the averaged sum of the time-averaged wavelet spectrum over
%   all times is normalized according to the value of the 'Normalization'
%   name-value pair. If you specify 'density', the weighted integral of the
%   wavelet spectrum over all times is normalized according to the value
%   of the 'Normalization' name-value pair. SPECTYPE defaults to 'power'.
%   See the documentation for details on the differences between 'power'
%   and 'density'.
%
%   [...] = timeSpectrum(...,'TimeLimits',TLIM) returns the wavelet
%   spectrum averaged over the time limits specified in samples in TLIM.
%   TLIM is a two-element vector with nondecreasing elements between 1 and
%   the length of X for a vector, or 1 and size(CFS,2) for a CWT
%   coefficient matrix input. If unspecified, TLIM defaults to 
%   [1 length(X)] or [1 size(CFS,2)].
%
%   timeSpectrum(...) with no output arguments plots the time-averaged
%   wavelet power spectrum in the current figure.
%
%   %Example: Load the NPG2006 dataset. Plot eastward and northward
%   %   displacement of the subsurface float. The triangle marks the
%   %   initial position. The sampling period is 4 hours for this data.
%   %   Plot the scalograms and time-averaged wavelet power spectra using
%   %   the default Morse wavelet. Note the clockwise rotation of the 
%   %   float is captured in the clockwise rotary scalogram and
%   %   time-averaged spectrum.
%   load npg2006;
%   fb = cwtfilterbank('SignalLength',length(npg2006.cx),...
%       'SamplingPeriod',hours(4));
%   plot(npg2006.cx); hold on; grid on;
%   xlabel('Eastward Displacement (km)');
%   ylabel('Northward Displacement (km)');
%   plot(npg2006.cx(1),'^','markersize',11,'color','r',...
%       'markerfacecolor',[1 0 0 ]);
%   figure;
%   timeSpectrum(fb,npg2006.cx)
%
%   See also CWTFILTERBANK/scaleSpectrum

% Copyright 2020 The MathWorks, Inc.

%#codegen

% Minimally two inputs -- object and data.
narginchk(2,8);
% Coder target alone: needed in a couple places
isMATLAB = isempty(coder.target);
% MATLAB allows zero output arguments, code generation does
% not.
if isMATLAB
    nargoutchk(0,2);
else
    nargoutchk(1,2);
end
% Validate input type and general size
validateattributes(x,{'double','single'},{'nonempty',...
    'finite','3d'},'timeSpectrum','X');
% This could be a GPU array. Use to cast when we want to preserve whether
% the object is a gpuArray
rPrototype = real(cast(1,"like",x));
% Still need this pure data type of code generation.
dataType = underlyingType(x);

IsVector = isvector(x);
[rdim,coldim,pdim] = size(x);
% Number of samples is number of elements in vector for signal, column
% dimension of matrix if CFS
if IsVector
    Nsamp = numel(x);
else
    Nsamp = size(x,2);
end
% If input is CWT coefficient matrix, it should be
% complex-valued and the 3rd dimension cannot exceed 2. The row dimension
% of X should be equal to the number of scales in the filter bank. Consider
% z = a+1j*0 as real.
coder.internal.errorIf(~IsVector && ~any(imag(x(:))),...
    'Wavelet:cwt:CFSComplex');
coder.internal.errorIf(~IsVector && pdim > 2,'Wavelet:cwt:CFS3Dsize');
coder.internal.errorIf(~IsVector && (rdim ~= length(self.Scales)...
    || coldim ~= self.SignalLength),'Wavelet:cwt:CFSSize');
% Set up defaults for input parsing
defaultnorm = 'var';
validnorm = {'var','pdf','none'};
defaultspectype = 'power';
validspectra = {'power','density'};
defaultTL = [1 Nsamp];

parms = struct('Normalization',uint32(0),...
    'SpectrumType',uint32(0),...
    'TimeLimits',uint32(0));
popts = struct('CaseSensitivity',false, ...
    'PartialMatching',true);
pstruct = coder.internal.parseParameterInputs(parms,...
    popts,varargin{:});
tmpnt = ...
    coder.internal.getParameterValue(...
    pstruct.Normalization,defaultnorm,varargin{:});
% Validate normalization 
normtype = validatestring(tmpnt,validnorm,'timeSpectrum',...
    'NTYPE');
tlim  = ...
    coder.internal.getParameterValue(...
    pstruct.TimeLimits,defaultTL,varargin{:});
validateattributes(tlim,{'numeric'},{'nonempty',...
    'finite','integer','vector','numel',2,'increasing',...
    '>=',1,'<=',Nsamp},'timeSpectrum','TLIM');
tmpspectype = ...
    coder.internal.getParameterValue(...
    pstruct.SpectrumType,defaultspectype,varargin{:});
% Validate spectrum type
spectype = validatestring(tmpspectype,validspectra,...
    'timeSpectrum','SPECTYPE');


% If the input is a GPU array and the 'SpectrumType' is 'density'.
% We will integrate, so move scales to gpuArray
Scales = cast(self.Scales,"like",rPrototype);
% If the input is a signal, we need to obtain the CWT of that
% signal.
if IsVector
    varsig = var(x,1);
    cfs = self.wt(x);
    
else
    % Assume the variance is the variance of the last signal processed by
    % the filter bank.
    varsig = self.sigvar;
    cfs = x;
    
end

% For PDF normalization, use 1. Used inside of sqrt() so we do not want to 
% make this a gpuArray. For normalization 'none' set to 0.
if strcmpi(normtype,'pdf')
    varsig = cast(1,dataType);
% Set to zero for 'none' normalization
elseif strcmpi(normtype,'none')
    varsig = cast(0,dataType);
end

% Obtain admissibility constant for integration if necessary
if strcmpi(spectype,'density')
    cpsi = wavelet.internal.cwt.numCpsi(self.Wavelet,...
        self.Gamma,self.Beta);
else
    cpsi = 1;
end

% For power, we obtain the total power to use in normalization. Else we set
% the total power to be 1.
totpow = cast(1,dataType);
if strcmpi(spectype,'power') && ~strcmpi(normtype,'none')
    totpow = cast(sum(1/Nsamp*sum(abs(cfs).^2,'all')),"like",totpow);
end

% The following scalar is used in sqrt() so do not cast to gpuArray
if strcmpi(normtype,'var')
    numfac = self.sigvar;
else
    numfac = cast(1,dataType);
end

% Computation of time-averaged wavelet spectrum
if strcmpi(spectype,'power')
    scaleFac = sqrt(numfac/totpow);
    % The following needed for codegeneration
    if isMATLAB
        cfsnorm = scaleFac.*cfs;
    else
        cfsnorm = bsxfun(@times,scaleFac,cfs);
    end
    % Time-averaged wavelet power
    tavgpTMP = 1/Nsamp*sum(abs(cfsnorm(:,tlim(1):tlim(2),:)).^2,2);
else
    cfsnorm = ...
        wavelet.internal.cwt.scNormalize(cfs,cpsi,...
        Scales,varsig);
    % Integrate
    tavgpTMP = ...
        trapz(tlim(1):tlim(2),...
        abs(cfsnorm(:,tlim(1):tlim(2),:)).^2,2);
end

% Periods not supported for code generation
if ~isempty(self.SamplingPeriod) && isempty(coder.target)
    fTMP = self.centerPeriods();
else
    fTMP = cast(self.centerFrequencies(),"like",rPrototype);
end

pltData = false;
% Do not bother evaluating isMATLAB && nargout == 0 statement if nargout >0
if nargout == 1
    tavgp = tavgpTMP;
    
elseif nargout == 2
    tavgp = tavgpTMP;
    f = fTMP;  
    
else
    pltData = true;
    
end

% Only in the case of plotting do we need the COI
if pltData
    % Gather data for plotting
    [cfs,tavgpTMP,fTMP] = gather(cfs,tavgpTMP,fTMP);
    if strcmpi(self.Wavelet,'morse')
        [FourierFactor, sigmaPsi] = wavelet.internal.cwt.wavCFandSD(...
            self.Wavelet, self.Gamma, self.Beta);
    else
        [FourierFactor, sigmaPsi] = wavelet.internal.cwt.wavCFandSD(...
            self.Wavelet);
    end
    coiScalar = FourierFactor/sigmaPsi;
    
    
    if ~isempty(self.SamplingPeriod) && isMATLAB
        [dt,~,dtfunch] = ...
            wavelet.internal.getDurationandUnits(self.SamplingPeriod);
    else
        dt = 1/self.SamplingFrequency;
    end
    samples = cwtfilterbank.createCoiIndices(Nsamp);
    % Output COI with numeric type consistent with input data type
    coitmp = cast(coiScalar*dt*samples,dataType);
    if isempty(self.SamplingPeriod)
        coi = 1./coitmp;
        % Truncate COI values at max
        coi(coi>max(self.WaveletCenterFrequencies)) = ...
            max(self.WaveletCenterFrequencies);
        % The following is needed if the target is MATLAB
        % irrespective of GPU or CPU
    elseif ~isempty(self.SamplingPeriod)
        
        coi = coitmp;
        % Duration array
        fTMP = dtfunch(self.centerPeriods());
        coi(coi< min(fTMP)) = min(fTMP);
    end
    
    % Plot
    if self.normfreqflag
        wavelet.internal.cwt.margplot(cfs,tavgpTMP,fTMP,coi,...
            spectype,self.normfreqflag);
    elseif ~self.normfreqflag && ~isempty(self.SamplingPeriod)
        wavelet.internal.cwt.margplot(cfs,tavgpTMP,fTMP,coi,...
            spectype,self.SamplingPeriod);
    elseif ~self.normfreqflag && isempty(self.SamplingPeriod)
        wavelet.internal.cwt.margplot(cfs,tavgpTMP,fTMP,coi,...
            spectype,self.SamplingFrequency);
    end
    
end








