function y = upsample(x,N,varargin)
%UPSAMPLE Upsample input signal.
%   UPSAMPLE(X,N) upsamples input signal X by inserting
%   N-1 zeros between input samples.  X may be a vector
%   or a signal matrix (one signal per column).
%
%   UPSAMPLE(X,N,PHASE) specifies an optional sample offset.
%   PHASE must be an integer in the range [0, N-1].
%
%   % Example 1:
%   %   Increase the sampling rate of a sequence by 3.
%
%   x = [1 2 3 4];      % Defining data
%   y = upsample(x,3)   % Upsample input signal
%
%   % Example 2:
%   %   Increase the sampling rate of the sequence by 3 and add a
%   %   phase offset of 2.
%
%   x = [1 2 3 4];      % Defining data
%   y = upsample(x,3,2) % Upsample by 3 and adding phase offset of 2
%
%   % Example 3:
%   %   Increase the sampling rate of a matrix by 3.
%
%   x = [1 2; 3 4; 5 6;];   % Defining data
%   y = upsample(x,3)       % Increasing sampling rate
%
%   See also DOWNSAMPLE, UPFIRDN, INTERP, DECIMATE, RESAMPLE.

%   Copyright 1988-2020 The MathWorks, Inc.
%#codegen

narginchk(2,3);

if isempty(varargin)
    phase = 0;
else
    phase = varargin{1};
end

isMATLAB = coder.target('MATLAB');
% Input validation
% Validate x
coder.internal.assert(~isempty(x),'signal:upsample:Nonempty');
if ~isMATLAB
    coder.internal.assert(isnumeric(x) || islogical(x) || ischar(x),'signal:upsample:InvalidType');
end
% Validate phase and upsample factor
validateattributes(N,{'numeric'},{'scalar','nonempty','finite','real','positive','integer'},'upsample','N');
validateattributes(phase,{'numeric'},{'scalar','nonempty','integer','real','nonnegative','<=',N-1},'upsample','PHASE');

% Scalar lockdown
N = double(N(1));
phase = phase(1);

% Save original size of x (possibly N-D)
sizeX = size(x);

% Total elements in x
nx = numel(x);

if isMATLAB
    dim = find(sizeX~=1,1,'first');
    if isempty(dim)
        dim = 1;
    end
    origSiz = sizeX;
    nElements = nx;
    upFactor = N;
    pOffset = phase;
else
    % for codegen
    if isscalar(x)
        dim = coder.internal.indexInt(1);
    else
        dim = coder.internal.indexInt(coder.internal.preferConstNonSingletonDim(x));
    end
    origSiz = coder.internal.indexInt(sizeX);
    nElements = coder.internal.indexInt(nx);
    upFactor = coder.internal.indexInt(N);
    pOffset = coder.internal.indexInt(phase);
end

% Converting to column vectors
xCol = reshape(x,nElements,1);
if isMATLAB && isduration(x)
    yCol = x(1);
    yCol(1:nElements*upFactor,1) = 0;
elseif isnumeric(x) || islogical(x)
    yCol = zeros(nElements*upFactor,1,'like',x);
else
    % Create double zeros then cast to deal with char and other types not
    % supported by zeros.
    yCol = cast(zeros(nElements*upFactor,1),'like',x);
end
% Perform the upsample
yCol(pOffset+1:upFactor:end,1) = xCol;

% Update sampled dimension
origSiz(1,dim) = origSiz(1,dim)*upFactor;

% Restore N-D shape
y = reshape(yCol,origSiz);

% [EOF]

% LocalWords:  upsamples lockdown
