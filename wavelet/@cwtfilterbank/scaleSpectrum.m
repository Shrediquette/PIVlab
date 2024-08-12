function [savgp,scidx] = scaleSpectrum(self,x,varargin)
%Scale-averaged wavelet spectrum
%   SAVGP = scaleSpectrum(FB,X) returns the scale-averaged wavelet power
%   spectrum of the signal X, using the CWT filter bank, FB. X is a double-
%   or single-precision real- or complex-valued vector. By default, SAVGP
%   is obtained by scale-averaging the magnitude-squared scalogram over all
%   scales. If X is real-valued, SAVGP is a 1-by-N vector where N is the
%   length of X. If X is complex-valued, SAVGP is 1-by-N-by-2 where the
%   first page is the scale-averaged wavelet spectrum for the positive
%   scales (analytic part or counterclockwise component) and the second
%   page is the scale-averaged wavelet spectrum for the negative scales
%   (anti-analytic part or clockwise component). See the documentation for
%   more details on the normalization of the scale-averaged wavelet
%   spectrum.
%
%   SAVGP  = scaleSpectrum(FB,CFS) returns the scale-averaged wavelet
%   spectrum for the CWT coefficient matrix, CFS. CFS is expected to be the
%   output of the WT method of the CWT filter bank, FB. SAVGP is 1-by-N
%   where N is size(CFS,2). If CFS is from a complex-valued signal, SAVGP
%   is 1-by-N-by-2.
%
%   [SAVGP,SCIDX] = scaleSpectrum(...) returns the scale indices over which
%   the scale-averaged wavelet spectrum is computed. If you do not specify
%   'FrequencyLimits' or 'PeriodLimits', SCIDX is a vector from 1 to the
%   number of scales. 
%
%   [...] = scaleSpectrum(...,'Normalization',NTYPE) specifies the
%   normalization of the scale-averaged wavelet spectrum as one of 'var',
%   'pdf', or 'none'. If NTYPE is 'var', the power or integral of the
%   scale-averaged wavelet spectrum is normalized to equal the variance of
%   the time series, X. If the CFS input is provided, the variance of the
%   last time series processed by the WT method is used. If NTYPE is 'pdf',
%   the scale-averaged wavelet spectrum is normalized to equal 1. If you
%   set NTYPE to 'none', no normalization is applied. If unspecified, NTYPE
%   defaults to 'var'. See the documentation for details on the
%   normalization used in scaleSpectrum.
%
%   [...] = scaleSpectrum(...,'SpectrumType',SPECTYPE) specifies the type
%   of wavelet spectrum to return as 'power' or 'density'. If you specify
%   'power', the averaged sum of the scale-averaged wavelet spectrum over
%   all scales is normalized according to the value of the 'Normalization'
%   name-value pair. If you specify 'density', the weighted integral of the
%   wavelet spectrum over all scales is normalized according to the value
%   of the 'Normalization' name-value pair. SPECTYPE defaults to 'power'.
%   See the documentation for details on the differences between 'power'
%   and 'density'.
%
%   [...]  = scaleSpectrum(...,'FrequencyLimits',FLIMS) returns the
%   scale-averaged wavelet spectrum where the magnitude-squared scalogram
%   is averaged over the frequency limits specified in FLIMS. FLIMS is a
%   two-element vector with nondecreasing elements. The values of FLIMS
%   must lie between the lowest and highest center frequencies returned by
%   the centerFrequencies method of FB. If a region of the specified limits
%   falls outside the frequency limits of the filter bank, FB,
%   scaleSpectrum truncates computations to within the range specified by
%   centerFrequencies(FB). FLIMS cannot be completely outside of the
%   Nyquist range. See the documentation for details on the minimum
%   required separation in the elements of FLIMS.
%
%   [...] = scaleSpectrum(...,'PeriodLimits',PLIMS) returns the
%   scale-averaged wavelet spectrum where the magnitude-squared scalogram
%   is averaged over the period limits specified in PLIMS. PLIMS is a
%   two-element vector with nondecreasing durations, which agree in type
%   and format with the SamplingPeriod of the filter bank, FB. The values
%   of PLIMS must lie between the lowest and highest center periods
%   returned by the centerPeriods method of FB. If a region of the
%   specified limits falls outside the period limits of the filter bank,
%   FB, scaleSpectrum truncates computations to within the range specified
%   by centerPeriods(FB). PLIMS cannot be completely outside the Nyquist
%   range of [2*Ts,N*Ts] where Ts is the 'SamplingPeriod' and N is the
%   signal length. See the documentation for details on the minimum
%   required separation in the elements of PLIMS. 
%
%   scaleSpectrum(...) with no output arguments plots the scale-averaged
%   wavelet spectrum in the current figure.
%
%   %Example: Plot the scale-averaged and time-averaged wavelet power
%   %   spectra of the Kobe earthquake data.
%   load kobe
%   fb = cwtfilterbank('SignalLength',length(kobe),...
%        'SamplingPeriod',seconds(1));
%   cfs = wt(fb,kobe);
%   scaleSpectrum(fb,cfs)
%   figure;
%   timeSpectrum(fb,cfs)
%
%   See also CWTFILTERBANK/timeSpectrum

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
validateattributes(x,{'double','single'},{'nonempty',...
    'finite','3d'},'scaleSpectrum','X');
% This could be a GPU array. Use to cast when we want to preserve whether
% the object is a gpuArray
rPrototype = real(cast(1,"like",x));
% Still need this pure data type of code generation.
dataType = underlyingType(x);

IsVector = isvector(x);
[rdim,coldim,pdim] = size(x);
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
defaultSL = [1 numel(self.Scales)];
defaultFLIM = zeros(0,2);
% The following is supported for code generation even though the class does
% not currently support durations for code generation.
defaultPLIM = seconds(zeros(0,2));
cF = self.WaveletCenterFrequencies;
% Only on MATLAB path
if isMATLAB
    cP = self.centerPeriods();
else
    cP = 1./cF;
end
% Defaults for parsing for both MATLAB and code generation
defaultnorm = 'var';
validnorm = {'var','pdf','none'};
validspectra = {'power','density'};
defaultspectype = 'power';
NyquistRange = [0 self.SamplingFrequency/2];
parms = struct('Normalization',uint32(0),...
    'SpectrumType',uint32(0),...
    'FrequencyLimits',uint32(0),...
    'PeriodLimits',uint32(0));
popts = struct('CaseSensitivity',false, ...
    'PartialMatching',true);
pstruct = coder.internal.parseParameterInputs(parms,...
    popts,varargin{:});
tmpnt = ...
    coder.internal.getParameterValue(...
    pstruct.Normalization,defaultnorm,varargin{:});
normtype = validatestring(tmpnt,validnorm,'scaleSpectrum',...
    'NTYPE');
freqlim  = ...
    coder.internal.getParameterValue(...
    pstruct.FrequencyLimits,defaultFLIM,varargin{:});
plim = ...
    coder.internal.getParameterValue(...
        pstruct.PeriodLimits,defaultPLIM,varargin{:});
tmpspectype = ...
    coder.internal.getParameterValue(...
    pstruct.SpectrumType,defaultspectype,varargin{:});
spectype = validatestring(tmpspectype,validspectra,...
    'scaleSpectrum','SPECTYPE');

coder.internal.errorIf(~isMATLAB && ~isempty(plim),...
    'Wavelet:codegeneration:MethodNotSupported');
% Cannot specify both frequency limits and period limits in MATLAB
coder.internal.errorIf(~isempty(freqlim) && ~isempty(plim),...
    'Wavelet:cwt:freqperiodrange');

% Will happen only on MATLAB path
coder.internal.errorIf(~isempty(plim) && isempty(self.SamplingPeriod),...
    'Wavelet:cwt:periodwithsampfreq_fb');

if ~isempty(freqlim)
    validateattributes(freqlim,{'numeric'},{'vector',...
        'numel',2,'increasing'},...
        'scaleSpectrum','FLIM');
    % We check the permissible range.
    if (freqlim(2) <= NyquistRange(1)) || ...
                (freqlim(1) >= NyquistRange(2))
            coder.internal.error('Wavelet:cwt:InvalidFrequencyBand',...
            sprintf('%f', NyquistRange(1)),sprintf('%f',NyquistRange(2)));
    end
    % Keeping with our convention, we truncate the frequency limits if they
    % exceed the range.
    if freqlim(1) < cF(end)
        freqlim(1) = cF(end);
    end
    if freqlim(2) > cF(1)
        freqlim(2) = cF(1);
    end
    % Sufficient spacing in frequencies to respect
    % VoicesPerOctave
    freqsep = log2(freqlim(2))-log2(freqlim(1)) >= ...
        1/self.VoicesPerOctave;
    coder.internal.errorIf(~freqsep,'Wavelet:cwt:freqsep',...
        sprintf('%2.2f',1.0/self.VoicesPerOctave));
    
    [idxU,idxL] = ...
        wavelet.internal.cwt.iFindScaleLimits(cF,freqlim,true);
    SL = [idxL idxU];
    
elseif ~isempty(plim) && isempty(coder.target)
    validateattributes(plim,{'duration'},{'numel',2,'nonempty'},...
        'scaleSpectrum','PeriodLimits');
    wavelet.internal.cwt.validatePeriodRange(self.SignalLength, ...
            self.SamplingPeriod,plim,self.VoicesPerOctave);
    if plim(1) < cP(1)
        plim(1) = cP(1);
    end
    if plim(2) > cP(end)
        plim(2) = cP(end);
    end
    [idxL,idxU] = ...
        wavelet.internal.cwt.iFindScaleLimits(cP,plim,false);
    SL = [idxL idxU];
else
    SL = defaultSL;
end

scidxTMP = cast((SL(1):SL(2))',"like",rPrototype);
Scales = cast(self.Scales,"like",rPrototype);

% If the input is a signal, we need to obtain the CWT of that
% signal.
if IsVector
    varsig = var(x,1);
    cfs = self.wt(x);
else
    varsig = self.sigvar;
    cfs = x;
    
end

% Factor for power. Number of scales.
Nscale = length(Scales);

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
    totpow = cast(sum(1/Nscale*sum(abs(cfs).^2,'all')),"like",totpow);
end

if strcmpi(normtype,'var')
    numfac = self.sigvar;
else
    % Used in a sqrt() calculation so do not make gpuArray
    numfac = cast(1,dataType);
end

% Computation of scale-averaged wavelet spectrum
if strcmpi(spectype,'power')
    scaleFac = sqrt(numfac/totpow);
    % Following needed for codegeneration
    if isMATLAB
        cfsnorm = scaleFac.*cfs;
    else
        cfsnorm = bsxfun(@times,scaleFac,cfs);
    end
    % Scale-averaged power
    savgpTMP = 1/Nscale*sum(abs(cfsnorm(SL(1):SL(2),:,:)).^2);
else
    cfsnorm = ...
        wavelet.internal.cwt.scNormalize(cfs,cpsi,...
        Scales,varsig);
    % Needed for code generation because we need to use bsxfun
    abswt2 = abs(cfsnorm).^2;
    if isempty(coder.target)
        abswt2S = abswt2./Scales(:);
    else
        abswt2S = bsxfun(@rdivide,abswt2,Scales(:));
    end
    sc = Scales(SL(1):SL(2));
    % Scale-averaged power
    savgpTMP = ...
        trapz(sc,abswt2S);
    
end

pltData = false;

% Do not bother evaluating isMATLAB && nargout == 0 statement if nargout >0
if nargout == 1
    savgp = savgpTMP;
    
elseif nargout == 2
    savgp = savgpTMP;
    scidx = scidxTMP;
    
else
    pltData = true;
    
end

if pltData
    % Gather data before plotting
    [cfs,savgpTMP] = gather(cfs,savgpTMP);
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
    % I do not want this to be a gpuArray
    coitmp = cast(coiScalar*dt*samples,dataType);
    if isempty(self.SamplingPeriod)
        coi = 1./coitmp;
        f = self.WaveletCenterFrequencies;
        % Truncate COI values at max
        coi(coi>max(f)) = ...
            max(f);
        % The following is needed if the target is MATLAB
        % irrespective of GPU or CPU
    elseif ~isempty(self.SamplingPeriod) && isMATLAB
        % Initialize the coi to have the same units as DT
        % For plotting in CWT, we may use different units
        % dtfunch is a function handle returned by
        % getDurationandUnits
        coi = coitmp;
        f = dtfunch(self.centerPeriods());
        coi(coi< min(f)) = min(f);
    end
    
    
    % Plot
    if self.normfreqflag
        wavelet.internal.cwt.margplot(cfs,savgpTMP,f,coi,...
            spectype,self.normfreqflag);
    elseif ~self.normfreqflag && ~isempty(self.SamplingPeriod)
        wavelet.internal.cwt.margplot(cfs,savgpTMP,f,coi,...
            spectype,self.SamplingPeriod);
    elseif ~self.normfreqflag && isempty(self.SamplingPeriod)
        wavelet.internal.cwt.margplot(cfs,savgpTMP,f,coi,...
            spectype,self.SamplingFrequency);
    end
    
    
end







