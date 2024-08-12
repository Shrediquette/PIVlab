function [a,h,v,d] = haart2(x,varargin)
%HAART2 Haar 2-D wavelet transform
% [A,H,V,D] = HAART2(X) performs the 2-D Haar discrete wavelet transform of
% the matrix, X. X is a 2-D, 3-D, or 4-D matrix with even-length row and
% column dimensions. The Haar transform is always computed along the row
% and column dimensions of the input. If the row and column dimensions of X
% are powers of two, the Haar transform is obtained down to level
% log2(min([size(X,1) size(X,2)])). If the row and column dimensions of X
% are even, but at least one is not a power of two, the Haar transform is
% obtained down to level floor(log2(min([size(X,1) size(X,2)]/2))). If X is
% a single-precision input, the numeric type of the Haar transform
% coefficients is single precision. For all other numeric types, the
% numeric type of the coefficients is double precision. A contains the 
% approximation coefficients at the coarsest level. H, V, and D are cell
% arrays of matrices containing the 2-D wavelet horizontal, vertical, and
% diagonal details by level. If the Haar transform is only computed at one
% level coarser in resolution, H, V, and D are matrices.
%
% [A,H,V,D] = HAART2(X,LEVEL) performs the 2-D Haar transform down to
% level, LEVEL. LEVEL is a positive integer less than or equal to
% log2(min([size(X,1) size(X,2)])) when both the row and column sizes of X
% are powers of two or floor(log2(min([size(X,1) size(X,2)]/2))) when both
% the row and column sizes of X are even, but at least one is not a power
% of two. When LEVEL is equal to 1, H, V, and D are purely numeric outputs.
%
% [A,H,V,D] = HAART2(...,INTEGERFLAG) specifies how the Haar
% transform handles integer-valued data.
% 'noninteger'  -   (default) does not preserve integer-valued data in the
%                   Haar transform.
% 'integer'     -   preserves integer-valued data in the Haar transform.
% Note that the Haar transform uses floating-point arithmetic in both
% cases. However, the lifting transform is implemented in a manner that
% can return integer-valued wavelet coefficients if the input values are
% integer-valued. The 'integer' option is only applicable if all elements
% of the input, X, are integer-valued.
%
%   %Example:
%   load xbox;
%   [A,H,V,D] = haart2(xbox);
%   subplot(2,1,1)
%   imagesc(D{1})
%   title('Diagonal Level-1 Details');
%   subplot(2,1,2)
%   imagesc(H{1})
%   title('Horizontal Level 1 Details');
%
% See also ihaart2, haart, ihaart

%   Copyright 2016-2020 The MathWorks, Inc.

%#codegen

% Check number of input and output arguments
narginchk(1,3);

% Check whether the INTEGERFLAG is used and remove
[Level,integerflag] = parseinputs(x,varargin{:});

%Cast data to double-precision
if ~isUnderlyingType(x,'single')
    tempx = double(x);
else
    tempx = x;
end

if ~isempty(coder.target)
    coder.varsize('tempx','unbounded');
end

temph = cell(1,Level);
tempv = cell(1,Level);
tempd = cell(1,Level);

for jj = 1:Level
    [tempx,temph{jj},tempv{jj},tempd{jj}] = hlwt2(tempx,integerflag);
end
a = tempx;
% If there is only one level in the MRA, returns matrices
% instead of cell arrays
if (Level == 1) && isempty(coder.target)
    h = temph{:};
    v = tempv{:};
    d = tempd{:};
else
    h = temph;
    v = tempv;
    d = tempd;
end

function [a,h,v,d] = hlwt2(x,integerflag)
%HLWT2 Haar (Integer) Wavelet decomposition 2-D using lifting.
%	HLWT2 performs the 2-D lifting Haar wavelet decomposition.
%
%   [CA,CH,CV,CD] = HLWT2(X) computes the approximation
%   coefficients matrix CA and detail coefficients matrices
%   CH, CV and CD obtained by the haar lifting wavelet
%   decomposition, of the matrix X.
%
%   [CA,CH,CV,CD] = HLWT2(X,INTFLAG) returns integer coefficients.

% Test for odd input.
s = size(x);

odd_Col = isodd(s(2));
if odd_Col
    [xrows,xcols,Dim3,Dim4] = size(x);
    tempx = zeros(xrows,xcols+1,Dim3,Dim4,'like',x);
    tempx(:,1:end-1,:,:) = x(:,1:end,:,:);
    tempx(:,end,:,:) = x(:,end,:,:);
else
    tempx = x;
end

odd_Row = isodd(s(1));
if odd_Row
    [xrows,xcols,Dim3,Dim4] = size(tempx);
    tempx_final = zeros(xrows+1,xcols,Dim3,Dim4,'like',tempx);
    tempx_final(1:end-1,:,:,:) = tempx(1:end,:,:,:);
    tempx_final(end,:,:,:) = tempx(end,:,:,:);
else
    tempx_final = tempx;
end

% Splitting.
L = tempx_final(:,1:2:end,:,:);
H = tempx_final(:,2:2:end,:,:);

% Lifting.
H = H-L;        % Dual lifting.
if ~integerflag
    L = (L+H/2);      % Primal lifting.
else
    L = (L+fix(H/2)); % Primal lifting.
end

% Splitting.
a = L(1:2:end,:,:,:);
h = L(2:2:end,:,:,:);

% Lifting.
h = h-a;        % Dual lifting.
if ~integerflag
    a = (a+h/2);      % Primal lifting.
    a = 2*a;
else
    a = (a+fix(h/2)); % Primal lifting.
end

% Splitting.
v = H(1:2:end,:,:,:);
d = H(2:2:end,:,:,:);

% Lifting.
d = d-v;         % Dual lifting.
if ~integerflag
    v = (v+d/2); % Primal lifting.
    % Normalization.
    d = d/2;
else
    v = (v+fix(d/2)); % Primal lifting.
end

if odd_Col
    v(:,end,:,:) = [];
    d(:,end,:,:) = [];
end

if odd_Row
    h(end,:,:,:) = [];
    d(end,:,:,:) = [];
end

function [Level,integerflag] = parseinputs(x,varargin)

%%% Validating x
validateattributes(x,{'numeric'},{'real','finite','nonempty'},...
    'haart2','X',1);

coder.internal.errorIf(isrow(x) || iscolumn(x) || ndims(x) < 2 ...
    || ndims(x) > 4, 'Wavelet:FunctionInput:InvalidTensorInput');
    
Ny = size(x,1);
Nx = size(x,2);
if isodd(Nx) || isodd(Ny)
    coder.internal.error('Wavelet:FunctionInput:InvalidRowOrColSize');
end

N = min([Ny Nx]);
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
            {'integer','scalar','positive','<=',maxlev},'haart2','LEVEL');
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
