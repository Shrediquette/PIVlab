function [a,d] = haart(x,varargin)
%HAART Haar 1-D wavelet transform
% [A,D] = HAART(X) performs the 1-D Haar discrete wavelet transform of the
% real- or complex-valued even-length vector or matrix, X. If X is a
% matrix, HAART operates on each column of X. If the length of X is a power
% of two, the Haar transform is obtained down to level log2(length(X)). If
% the length of X is even, but not a power of two, the Haar transform is
% obtained down to level floor(log2(length(X)/2)). If X is a
% single-precision input, the numeric type of the Haar transform
% coefficients is single precision. For all other numeric types, the
% numeric type of the coefficients is double precision. A contains the
% approximation coefficients at the coarsest level. D is a cell array of
% vectors or matrices of wavelet coefficients. The elements of D are
% ordered from the finest resolution level to the coarsest. If the Haar
% transform is only computed at one level coarser in resolution, D is a
% vector or matrix.
%
% [A,D] = HAART(X,LEVEL) obtains the Haar transform down to level,
% LEVEL. LEVEL is a positive integer less than or equal to log2(length(X))
% when the length of X is a power of two or floor(log2(length(X)/2)) when
% the length of X is even, but not a power of two. If LEVEL is equal to 1,
% D is returned as a vector, or matrix.
%
% [A,D] = HAART(...,INTEGERFLAG) specifies how the Haar transform
% handles integer-valued data.
% 'noninteger'  -   (default) does not preserve integer-valued data in the
%                   Haar transform.
% 'integer'     -   preserves integer-valued data in the Haar transform.
% Note that the Haar transform uses floating-point arithmetic in both
% cases. However, the lifting transform is implemented in a manner that
% can return integer-valued wavelet coefficients if the input values are
% integer-valued. The data type of A and D is always double or single.
% The 'integer' option is only applicable if all elements of the input, X,
% are integer-valued.
%
%   % Example 1: Obtain the Haar transform down to the maximum level.
%   load wecg;
%   [A,D] = haart(wecg);
%
%   %Example 2: Obtain the Haar transform of a multivariate time series
%   %   dataset of electricity consumption data.
%   load elec35_nor;
%   signals = signals';
%   [a,d] = haart(signals);
%
% See also ihaart, haart2, ihaart2

%   Copyright 2016-2020 The MathWorks, Inc.

%#codegen

% Check number of inputs
narginchk(1,3);

% Parsing and Validating input arguments.
[Level,integerflag] = parseinputs(x,varargin{:});

if isvector(x)
    tempx = x(:);
else
    tempx = x;
end

if ~isUnderlyingType(tempx,'single')
    tempa = cast(tempx,'double');
else
    tempa = tempx;
end

if ~isempty(coder.target)
    coder.varsize('tempa','unbounded');
end

tempd = cell(1,Level);
for jj = 1:Level
    [tempa,tempd{jj}] = hlwt(tempa,integerflag);
end

a = tempa;
if (Level == 1) && isempty(coder.target)
    d = tempd{1};
else
    d = tempd;
end

function [a,d] = hlwt(x,integerflag)
% Haar lifting analysis step
%

% Test for integer transform.
notInteger = ~integerflag;

% Test for odd input.
odd = isodd(length(x(:,1)));
if odd
    [xrows,xcols] = size(x);
    tempx = zeros(xrows+1,xcols,'like',x);
    tempx(1:end-1,:) = x(1:end,:);
    tempx(end,:) = x(end,:);
else
    tempx = x;
end

% Lazy wavelet step
a = tempx(1:2:end,:);
d = tempx(2:2:end,:);

% Dual lifting step
d = d - a;

if notInteger
    % Primal lifting -- update scaling coefficients
    a = a + d/2;
    % Normalization step of wavelet transform
    d = d/sqrt(2);
    a = sqrt(2)*a;
else
    a = a + fix(d/2); % Primal lifting.
end

% Test for odd output.
if odd 
    d(end,:) = [];
end

function [Level,integerflag] = parseinputs(x,varargin)

% Validating x
if isrow(x)
    tempx = x.';
else
    tempx = x;
end

validateattributes(tempx,{'numeric'},{'finite','nonempty'},...
    'haart','X',1);
sz = size(tempx);

if length(sz)> 2
    coder.internal.error('Wavelet:FunctionInput:InvalidSizeHaart');
end

N = sz(1);
if isodd(N)
    coder.internal.error('Wavelet:FunctionInput:EvenLength');
end

% Check if N is a power of two
if ~rem(log2(N),1)
    maxlev = log2(N);
else
    maxlev = floor(log2(N/2));
end

integerflag = 0;
if isempty(varargin)
    Level = maxlev;
    return;
else
    %%% Parsing Varargin
    temp = nargin - 1;
    temp_parseinputs = cell(1,temp);
    [temp_parseinputs{:}] = convertStringsToChars(varargin{:});

     % Parsing Level
    if isempty(coder.target)
        levelidx = cellfun(@(x)(isscalar(x)||isvector(x)||ismatrix(x))...
            &&~ischar(x),temp_parseinputs);
        anyLevelIdx = any(levelidx);
        nnzLevelIdx = nnz(levelidx);
        notAllLevelIdx = any(~levelidx(~levelidx));
    else
        levelidx = zeros(1,temp,'logical');
        coder.unroll;
        for i = 1:temp
            levelidx(i) = ((isscalar(temp_parseinputs{i})||...
                isvector(temp_parseinputs{i})||...
                ismatrix(temp_parseinputs{i}))...
                &&~ischar(temp_parseinputs{i}));
        end
        levelidx = coder.const(levelidx);
        anyLevelIdx = coder.const(any(levelidx));
        nnzLevelIdx = coder.const(nnz(levelidx));
        notAllLevelIdx = coder.const(any(~levelidx(~levelidx)));
    end

    % Defining Level
    if coder.const(anyLevelIdx && nnzLevelIdx == 1 && ...
            isnumeric(temp_parseinputs{levelidx}))
        Level = temp_parseinputs{levelidx};
        validateattributes(temp_parseinputs{levelidx},{'numeric'},...
            {'integer','scalar','positive','<=',maxlev},'haart','LEVEL');
        temp = temp - 1;
    elseif coder.const(nnzLevelIdx > 1 && ...
            isnumeric(temp_parseinputs{levelidx(1)}))
        coder.internal.error('Wavelet:FunctionInput:Invalid_LevelInput');
    else
        Level = maxlev;
    end

    if coder.const(temp == 1 && notAllLevelIdx)
        transformtype = temp_parseinputs{~levelidx};
    elseif coder.const(temp > 1)
        if any(strncmpi(temp_parseinputs,'noninteger',6))&&...
                any(strncmpi(temp_parseinputs,'integer',3))
            coder.internal.error('Wavelet:FunctionInput:ConflictingOptions', ...
                char(temp_parseinputs{1}), char(temp_parseinputs{2}));
        end
        transformtype = '';
    else
        transformtype = 'noninteger';
    end

    if ~(startsWith(transformtype,'n')||startsWith(transformtype,'i'))
        coder.internal.error('Wavelet:FunctionInput:UnrecognizedString');
    elseif startsWith(transformtype,'i')
        integerflag = 1;
    end
end
