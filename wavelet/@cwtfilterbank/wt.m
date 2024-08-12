function varargout = wt(self,x)
%WT Continuous wavelet transform
%   CFS = WT(FB,X) returns the continuous wavelet transform
%   (CWT) coefficients of the signal X, using the CWT filter
%   bank, FB. X is a double- or single-precision real- or
%   complex-valued vector. X must have at least four samples.
%   If X is real-valued, CFS is a 2-D matrix where each row
%   corresponds to one scale. The column size of CFS is equal
%   to the length of X. If X is complex-valued, CFS is a 3-D
%   matrix, where the first page is the CWT for the positive
%   scales (analytic part or counterclockwise component) and
%   the second page is the CWT for the negative scales
%   (anti-analytic part or clockwise component).
%
%   [CFS,F] = WT(FB,X) returns the frequencies, F,
%   corresponding to the scales (rows) of CFS if the
%   'SamplingPeriod' property is not specified in the
%   CWTFILTERBANK, FB. If you do not specify a sampling
%   frequency, F is in cycles/sample.
%
%   [CFS,F,COI] = WT(FB,X) returns the cone of influence, COI,
%   for the CWT. COI is in the same units as F. If the input X
%   is complex, COI applies to both pages of CFS.
%
%   [CFS,P] = WT(FB,X) returns the periods, P, corresponding to
%   the scales (rows) of CFS if you specify a sampling period
%   in the CWTFILTERBANK, FB. P has the same units and format
%   as the duration scalar sampling period.
%
%   [CFS,P,COI] = WT(FB,X) returns the cone of influence in
%   periods for the CWT. COI is an array of durations with the
%   same Format property as the sampling period. If the input X
%   is complex, COI applies to both pages of CFS.
%
%   [...,SCALCFS] = WT(FB,X) returns the scaling
%   coefficients, SCALCFS, for the wavelet transform.
%
%   % Example Obtain the continuous wavelet transform of the
%   %   Kobe earthquake data.
%   load kobe;
%   fb = cwtfilterbank('SignalLength',numel(kobe));
%   [cfs,f] = wt(fb,kobe);

%   Copyright 2020-2021 The MathWorks, Inc.

%#codegen

nargoutchk(0,4);
% Allow both real and complex input. Double or Single precision
N = self.SignalLength;
validateattributes(x,{'double','single'},{'vector','finite','nonempty'...
    'nonsparse','numel',N},'CWTFILTERBANK','X');
coder.internal.assert(numel(x) >= 4,...
    'Wavelet:synchrosqueezed:NumInputSamples');

% Coder target alone: needed in a couple places
isMATLAB = coder.target('MATLAB');
% Is input a gpuArray and target is MATLAB
isMATLABGPU = isMATLAB && isa(x,'gpuArray');
% MATLAB only -- target is MATLAB but input is CPU
isMATLABonly = isMATLAB && ~isa(x,'gpuArray');

% Need the class of the data or the underlying class of the GPU
% array
dataclass = underlyingType(x);
% Check if this is the first time we've called WT() and if not,
% has the data type changed. We do not care about this for
% C/C++ code generation since type is declared at compile time.
% We need this if the target is MATLAB irrespective of GPU or
% CPU
if isMATLAB && ~isempty(self.CurrentClass)
    classChanged = ~strcmpi(dataclass,self.CurrentClass);
    % Throw warning and change CurrentClass
    if classChanged
        warning(message('Wavelet:cwt:PrecisionChange',...
            self.CurrentClass,dataclass));
        
        
    end
end
% Use single-precision filterbank for single input. If the
% input is a gpuArray, check to see if the cached array exists
% and is of the correct type.
if isMATLAB && ...
        ~strcmpi(dataclass,class(self.PsiDFT))
    % If the data is double and the filter bank is single,
    % we need to completely redesign.
    if strcmpi(dataclass,'double') && ...
            strcmpi(class(self.PsiDFT),'single')
        self.PsiDFT = self.filterbank();
        % For double to single, cast.
    else
        self.PsiDFT = cast(self.PsiDFT,dataclass);
    end
    
    % For code generation. The input type cannot change so we just
    % cast to the datatype of the input. This could also be
    % ~isMATLAB
elseif ~isMATLABGPU
    % Create new variable for code generation. We cannot change
    % the data type of an existing variable.
    psihat = cast(self.PsiDFT,dataclass);
    
end


% Determine if we need a CachedGPUArray. Only needed for MATLAB
% target and GPU.
if isMATLABGPU
    tfCache = self.cacheNeeded(dataclass);
else
    tfCache = false;
end

% If we need to create a cached gpuArray
if tfCache
    self.PsiGPU = parallel.internal.gpu.CachedGPUArray(self.PsiDFT);
end

% Store current class. The first time WT() is called this
% property is empty
self.CurrentClass = dataclass;


% Check whether input is real or complex
isRealX = isreal(x);
coder.varsize('xv');
x = x(:).';
% Store signal variance. The dimension argument is needed for code
% generation. We have converted the input to a row vector.
self.sigvar = var(x,1,2);
if ~isRealX
    x = x./2;
end
xv = x;
Norig = self.SignalLength;
if self.SignalPad > 0
     xv = [fliplr(xv(1:self.SignalPad)) xv ...
          xv(end:-1:end-self.SignalPad+1)];
end

% Fourier transform of input
xposdft = fft(xv);

% For MATLAB and GPU array paths, use implicit expansion.
% For C/C++ code gen we must use bsxfun(), implicit expansion
% not supported

% Obtain the CWT in the Fourier domain
if isMATLABonly
    cfsposdft = xposdft.*self.PsiDFT;
    % For GPU array use GPUValue property of cached array
elseif isMATLABGPU
    cfsposdft = xposdft.*self.PsiGPU.GPUValue;
else
    cfsposdft = bsxfun(@times,xposdft,psihat);
    
end

% Invert to obtain wavelet coefficients
cfspos = ifft(cfsposdft,[],2);

if isRealX
    cfs = cfspos;
elseif ~isRealX
    xnegdft = fft(conj(xv));
    if isMATLABonly
        cfsnegdft = xnegdft.*self.PsiDFT;
    elseif isMATLABGPU
        cfsnegdft = xnegdft.*self.PsiGPU.GPUValue;
    else
        cfsnegdft = bsxfun(@times,xnegdft,psihat);
        
    end
    cfsneg = conj(ifft(cfsnegdft,[],2));
    cfs = cat(3,cfspos,cfsneg);
end

if self.SignalPad > 0
    cfs = cfs(:,self.SignalPad+1:self.SignalPad+Norig,:);
end

varargout{1} = cfs;

if nargout >= 2
    % Output center frequencies with type consistent to input
    % data type
    f = cast(self.WaveletCenterFrequencies,dataclass);
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
    samples = cwtfilterbank.createCoiIndices(Norig);
    % Output COI with numeric type consistent with input data type
    coitmp = cast(coiScalar*dt*samples,dataclass);
    if isempty(self.SamplingPeriod)
        coi = 1./coitmp;
        % Truncate COI values at max
        coi(coi>max(self.WaveletCenterFrequencies)) = ...
            max(self.WaveletCenterFrequencies);
        % The following is needed if the target is MATLAB
        % irrespective of GPU or CPU
    elseif ~isempty(self.SamplingPeriod) && isMATLAB
        % Initialize the coi to have the same units as DT
        % For plotting in CWT, we may use different units
        % dtfunch is a function handle returned by
        % getDurationandUnits
        coi = dtfunch(coitmp);
        %coi = createDurationObject(coitmp,func);
        f = dtfunch(1./f);
        % Duration array
        f.Format = self.SamplingPeriod.Format;
        % Format of COI must match for of Periods
        coi.Format = f.Format;
        coi(coi< min(f)) = min(f);
    end
    
    % For GPU array inputs and numeric f,coi, return gpuArrays.
    if isMATLABGPU && ~isduration(f)
        f = gpuArray(f);
        coi = gpuArray(coi);
    end
    varargout{2} = f;
    varargout{3} = coi;
end

% If scaling coefficients requested
if nargout == 4
    self.PhiDFT = scalingFunction(self);
    % Cast to data type
    phidft = cast(self.PhiDFT,dataclass);
    
    % For MATLAB path with gpuArray, put phidft in gpuArray
    if isMATLABGPU
        scaldft = xposdft.*gpuArray(phidft);
    else
        scaldft = xposdft.*phidft;
    end
    
    scalcfstmp = ifft(scaldft);
    if self.SignalPad > 0
        scalcfs = ...
            scalcfstmp(self.SignalPad+1:self.SignalPad+Norig);
    else
        scalcfs = scalcfstmp;
    end
    if ~isRealX
        varargout{4} = 2.0*scalcfs;
    else
        varargout{4} = real(scalcfs);
    end
end

end
