function [S,U] = featureMatrix(self,x,varargin)
%Scattering coefficient matrix
%   SMAT = FEATUREMATRIX(SN,X) returns the scattering coefficient matrix
%   for the scattering network, SN, and the real-valued input data X. X is
%   a real-valued vector, matrix, or 3-D array. If X is a vector, the
%   number of samples in X must match the SignalLength property of SN. If X
%   is a matrix or 3-D array, the number of rows in X must match the
%   SignalLength property of SN. If X is 2-D, the first dimension is
%   assumed to be time and the columns of X are assumed to be separate
%   channels. If X is 3-D, the dimensions of X are
%   Time-by-Channel-by-Batch.
%
%   For a vector input, SMAT is Npath-by-Nscat where Npath is the number of
%   scattering paths and Nscat is the number of scattering coefficients in
%   each path, or the resolution of the scattering coefficients. If X is a
%   matrix, SMAT is Npath-by-Nscat-by-Nchan where Nchan is the number of
%   columns in X. If X is 3-D, SMAT is Npath-by-Nscat-by-Nchan-by-Nbatch.
%
%   [SMAT,U] = FEATUREMATRIX(...) returns the scalogram coefficients in the
%   cell array of cell arrays, U. The number of elements in U is equal to
%   the order of the scattering network. The i-th element of U contains
%   the scalogram coefficients corresponding to the (i-1)-th order
%   scattering coefficients. Note that U{1} contains a single cell array
%   and U{1}{1} contains the original data.
%
%   SMAT = FEATUREMATRIX(...,'Normalization',NORMTYPE) normalizes the
%   scattering coefficients using NORMTYPE. NORMTYPE is one of 'parent' or
%   'none'. If unspecified, 'Normalization' defaults to 'none'. If NORMTYPE
%   is 'parent', scattering coefficients of order greater than 0 are
%   normalized by the mean of their parents along the scattering path.
%
%   SMAT = FEATUREMATRIX(...,'Transform',TRANSFORMTYPE) applies
%   the transformation specified by TRANSFORMTYPE to the
%   scattering coefficients. Valid options for TRANSFORMTYPE
%   are 'log' and 'none'. If unspecified, TRANSFORMTYPE
%   defaults to 'none'.
%
%   % Example: Obtain the scattering feature matrix for an ECG
%   %   signal.
%
%   load wecg;
%   sn = waveletScattering('SignalLength',2048);
%   smat = featureMatrix(sn,wecg,'Transform','log');

%  Copyright 2018-2022 The MathWorks, Inc.

%#codegen
nargoutchk(0,2);
narginchk(2,6)
parentNorm = false;
%Scattering feature matrix
validnorm = {'none','parent'};
validtransform = {'none','log'};
defaultnorm = 'none';
defaultTransform = 'none';
parms = struct('Normalization',uint32(0),'Transform',uint32(0));
popts = struct('CaseSensitivity',false,'PartialMatching',true);
pstruct = coder.internal.parseParameterInputs(parms,popts,...
    varargin{:});
pnorm = coder.internal.getParameterValue(pstruct.Normalization,...
    defaultnorm,varargin{:});
ptransform = coder.internal.getParameterValue(pstruct.Transform,...
    defaultTransform,varargin{:});
normalize = validatestring(pnorm,validnorm,'featureMatrix');
transform = validatestring(ptransform,validtransform,'featureMatrix');
if startsWith(normalize,'p')
    parentNorm = true;
end
coder.internal.errorIf(iscell(x) && ~isempty(coder.target),...
    'Wavelet:scattering:featureMatrixCellNotSupported');
if iscell(x) && isempty(coder.target) && nargout < 2
    S = iScell2mat(x,self.npaths,self.parentchild,parentNorm,transform);
    return;    
end

% Validate X. If X is a row vector, convert to column vector. Subsequent
% routines operate on columns
if isrow(x)
    tmpx = x(:);
else
    tmpx = x;
end
validateattributes(tmpx,{'double','single'},...
    {'real','finite','nonsparse','nonempty','nrows',self.SignalLength},...
        'featureMatrix','X');
Nd = ndims(tmpx);
coder.internal.errorIf(Nd > 3,'Wavelet:scattering:NdimsInput');
isSingle = isUnderlyingType(tmpx,'single');

if startsWith(self.Boundary,'p')
    repfac = ceil(self.paddedlength/self.SignalLength);
    padx = repmat(tmpx,repfac,1);
    padx = padx(1:self.paddedlength,:,:);
else
    % For reflection extension we start with twice the original signal
    % length
    repfac = ceil(self.paddedlength/(2*self.SignalLength));
    xflip = flip(tmpx);
    xtmp = [tmpx ; xflip];
    padx = repmat(xtmp,repfac,1);
    padx = padx(1:self.paddedlength,:,:);
 end

coder.internal.assert(size(padx,1) == size(self.filters{1}.phift,1),...
    'Wavelet:scattering:paddedLenAssert');

GPU = isempty(coder.target) && isa(x,'gpuArray');
MATLABOnly = isempty(coder.target) && ~isa(x,'gpuArray');

if isSingle && ~startsWith(self.Precision,'s') && isempty(coder.target)
    singleFilters(self);
    self.Precision = 'single';
end

if GPU && ~self.GPUFilters
    createGPUarrays(self);
end

if MATLABOnly && self.GPUFilters
    gatherGPUarrays(self);
end
% Number of filter banks
nfb = self.nFilterBanks;
% The 0-th order coefficients of the scattering transform are the data
% convolved with the scaling filter
M = size(padx,1);
npaths = self.npaths;

U = cell(nfb+1,1);
for ii = 1:length(U)
    U{ii} = cell(npaths(ii),1);
end
% Allocate cell array elements
Ucfs = zeros(0,size(padx,2),size(padx,3),'like',padx);
for ii = coder.unroll(1:nfb+1)
    U{ii} = repmat({Ucfs},npaths(ii),1);
end
U{1}{1} = padx;
coder.varsize('psires','psiftsup','psi3dB');
psires = 0;
psi3dB = 2*pi;

if isempty(coder.target)
    phi0tmp = fft(U{1}{1}).*self.filters{1}.phift;
else
    phi0tmp = bsxfun(@times,fft(U{1}{1}),self.filters{1}.phift);
end
phids = max(self.filterparams{1}.philog2ds-self.OversamplingFactor,0);
period = M/2^phids;
phi0 = reshape(phi0tmp,period,2^phids,size(phi0tmp,2),size(phi0tmp,3));
phi0 = 1/2^phids.*sum(phi0,2);
phi0 = reshape(phi0,[size(phi0,1) size(phi0,3) size(phi0,4) size(phi0,2)]);
phi0 = real(ifft(phi0));
% Use coder.ignoreConst to tell Coder that S is going to grow along the 
% first dimension, so it should not assume S is a vector.
% This should become unnecessary once g2640414 is completed.
S = reshape(phi0,[coder.ignoreConst(1) size(phi0,1) size(phi0,2) size(phi0,3)]);
Snorm0 = mean(abs(S),'all');
for nL = coder.unroll(1:self.nFilterBanks)
    [Stmp,WT,psires,psi3dB] = self.forward(U{nL},psires,psi3dB,nL);
    U{nL+1} = WT;
    S = cat(1, S, Stmp);
end
if parentNorm
    S = waveletScattering.iParentChildNormalize(S,Snorm0,self.parentchild);
end
if strcmpi(transform,'log')
    dtype = underlyingType(S);
    S = log(abs(S)+realmin(dtype));
end
phids = max(self.filterparams{1}.philog2ds-self.OversamplingFactor,0);
S = waveletScattering.unpadsignal(S,phids,self.SignalLength);
for ii = 2:length(U)
    U{ii} = waveletScattering.unpadsignal(U{ii},-self.currpaths{ii}.log2res,...
        self.SignalLength);
end

%--------------------------------------------------------------------------
function Saccum = iScell2mat(S,npaths,parentchild,parentNorm,transform)
isGPU = isa(S{1}.signals{1},'gpuArray');
% cell2mat does not work for objects
if ~isGPU
    Saccum = [];
    for ii = 1:length(S)
        Stmp = S{ii}.signals;
        Stmp = cellfun(@(x)permute(x,[4 1 2 3]),Stmp,'UniformOutput',false);
        Smat = cell2mat(Stmp);
        Saccum = [Saccum ; Smat]; %#ok<AGROW>
    end
    if parentNorm
        Snorm0 = mean(abs(S(1,:,:,:)));
        S = waveletScattering.iParentChildNormalize(Sa,Snorm0,parentchild);
    end
    
    if strcmpi(transform,'log')
        % realmin() does not support string input
        dtype = underlyingType(S);
        S = log(abs(S)+realmin(dtype));
    end
 else
    Np = sum(npaths);
    [M,N,P] = size(S{1}.signals{1});
    Saccum = gpuArray(zeros(Np,M,N,P,'like',S{1}.signals{1}));
    for ii = 1:length(S)
        Stmp = S{ii}.signals;
        Stmp = cellfun(@(x)permute(x,[4 1 2 3]),Stmp,'UniformOutput',false);
        for jj = 1:npaths(ii)
            Saccum(jj,:,:,:) = Stmp{jj};
        end
    end
end

if parentNorm
    Snorm0 = mean(abs(Saccum(1,:,:,:)));
    Saccum = waveletScattering.iParentChildNormalize(Saccum,Snorm0,parentchild);
end

if strcmpi(transform,'log')
    % realmin() does not support string input
    dtype = underlyingType(S);
    Saccum = log(abs(Saccum)+realmin(dtype));
end








