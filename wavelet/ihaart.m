function xrec = ihaart(a,d,varargin)
%IHAART Inverse Haar 1-D wavelet transform
% XREC = IHAART(A,D) returns the 1-D inverse Haar transform, XREC, for the
% approximation coefficients, A, and vector, matrix, or cell array of
% wavelet coefficients, D. A and D are outputs of HAART. If D is a vector
% or matrix, the Haar transform was computed only down to one level coarser
% in resolution. If D is a cell array, the level of the Haar transform is
% equal to the number of elements in D. If A and the elements of D are
% vectors, XREC is a vector. If A and the elements of D are matrices, XREC
% is a matrix where each column is the inverse Haar transform of the
% corresponding columns in A and D.
%
% XREC = IHAART(A,D,LEVEL) returns the 1-D inverse Haar transform at level,
% LEVEL. LEVEL is a nonnegative integer less or equal to length(D)-1 if D
% is a cell array. If D is a vector or matrix, LEVEL must equal 0 or be
% unspecified. If unspecified, LEVEL defaults to 0.
%
% XREC = IHAART(...,INTEGERFLAG) specifies how the inverse Haar transform
% handles integer-valued data.
% 'noninteger'  -   (default) does not preserve integer-valued data in the
%                   Haar transform.
% 'integer'     -   preserves integer-valued data in the Haar transform.
% Note that the inverse Haar transform still uses floating-point arithmetic
% in both cases. However, the lifting transform is implemented in a manner
% that returns integer-valued wavelet coefficients if the input values are
% integer-valued. The 'integer' option is only applicable if all elements
% of the inputs, A and D, are integer-valued.
%
%   %Example:
%   load noisdopp;
%   [a,d] = haart(noisdopp);
%   xrec = ihaart(a,d);
%   max(abs(xrec-noisdopp'))
%
%   %Example
%   x = randi(10,100,1);
%   [a,d] = haart(x,'integer');
%   xrec = ihaart(a,d,'integer');
%   subplot(2,1,1)
%   stem(x); title('Original Data');
%   subplot(2,1,2);
%   stem(xrec); title('Reconstructed Integer-to-Integer Data');
%   max(abs(x(:)-xrec(:)))
%
% See also HAART, HAART2, IHAART2

%   Copyright 2016-2020 The MathWorks, Inc.

%#codegen

% Check number of input arguments
narginchk(2,4);

[level, Nlevels, integerflag] = parseinputs(a,d,varargin{:});
evar = zeros(0,0,'like',a);
tempd = coder.nullcopy({evar});
coder.varsize('tempd');
if Nlevels == 1 && isnumeric(d) && isempty(coder.target)
    tempd = mat2cell(d,size(d,1),size(d,2));
elseif Nlevels == 1 && isnumeric(d)
    tempd = {d};
elseif iscell(d)
    tempd = d;
end

d_final = tempd;
if level>0
    for kk = 1:level
        d_final{kk} = zeros(size(tempd{kk}),'like',tempd{kk});
    end
end

tempa = a;
if ~(isempty(coder.target))
    coder.varsize('tempa','unbounded');
end

for jj = Nlevels:-1:1
    tempa = ihlwt(tempa,d_final{jj},integerflag);
end

xrec = tempa;

function x = ihlwt(a,d,integerflag)
%IHLWT Haar (Integer) Wavelet reconstruction 1-D using lifting.
%   IHLWT performs performs the 1-D lifting Haar wavelet reconstruction.
%
%   X = IHLWT(CA,CD) computes the reconstructed vector X
%   using the approximation coefficients vector CA and detail
%   coefficients vector CD obtained by the Haar lifting wavelet
%   decomposition.
%
%   X = IHLWT(CA,CD,INTFLAG) computes the reconstructed
%   vector X, using the integer scheme.
%

tempx = zeros(2*size(a,1),size(a,2),'like',a);
temp_d = d;
coder.varsize('temp_d',[Inf Inf]);
% Test for integer transform.

% Test for odd input.
odd = length(d(:,1))<length(a(:,1));
if odd
    [drows,dcols] = size(d);
    tempd = zeros(drows+1,dcols,'like',a);
    tempd(1:end-1,:) = temp_d(1:end,:);
    tempd(end,:) = 0;
else
    tempd = temp_d;
end

% Reverse Lifting.
if ~integerflag
    tempd = sqrt(2)*tempd;          % Normalization.
    a = a/sqrt(2);
    a = a-tempd/2;      % Reverse primal lifting.
else
    a = (a-fix(tempd/2)); % Reverse primal lifting.
end

tempd = a + tempd;   % Reverse dual lifting.

% Merging.
tempx(1:2:end,:) = a;
tempx(2:2:end,:) = tempd;

% Test for odd output.
if odd
    x = tempx(1:end-1,:);
else
    x = tempx;
end


function [Level, Nlevels, integerflag] = parseinputs(a,d,varargin)

Level = 0;
Nlevels = length(d);
integerflag = 0;

validateattributes(a,{'double','single'},{'nonempty','finite'},...
    'ihaart','A',1);
validateattributes(d,{'double','single','cell'},{'nonempty'},'ihaart','D',2);

if isnumeric(d) && ~iscell(d)
    validateattributes(d,{'double','single'},{'real','finite'},...
        'ihaart','D',2);
    Nlevels = 1;
elseif iscell(d) && isempty(coder.target)
    cellfun(@(x)validateattributes(x,{'numeric'},{'finite'},...
        'ihaart','D',2),d);
elseif iscell(d)
    for i = 1:length(d)
        validateattributes(d{i},{'double','single'},{'finite'},...
            'ihaart','D',2);
    end
end

if isempty(varargin)
    return;
else
    %%% Parsing Varargin
    temp = nargin - 2;
    temp_parseinputs = cell(1,temp);
    [temp_parseinputs{:}] = convertStringsToChars(varargin{:});

    if isempty(coder.target)
        level_idx = cellfun(@(x)(isscalar(x)||isvector(x)||ismatrix(x))...
            &&~ischar(x),temp_parseinputs);
        anyLevelIdx = any(level_idx);
        nnzLevelIdx = nnz(level_idx);
        notAllLevelIdx = any(~level_idx(~level_idx));
    else
        level_idx = zeros(1,temp,'logical');
        coder.unroll;
        for i = 1:temp
            level_idx(i) = ((isscalar(temp_parseinputs{i})||...
                isvector(temp_parseinputs{i})||...
                ismatrix(temp_parseinputs{i}))...
                &&~ischar(temp_parseinputs{i}));
        end
        level_idx = coder.const(level_idx);
        anyLevelIdx = coder.const(any(level_idx));
        nnzLevelIdx = coder.const(nnz(level_idx));
        notAllLevelIdx = coder.const(any(~level_idx(~level_idx)));
    end

    % Defining Level
    if coder.const(anyLevelIdx && nnzLevelIdx == 1 && ...
            isnumeric(temp_parseinputs{level_idx}))
        Level = temp_parseinputs{level_idx};
        validateattributes(Level,{'numeric'},...
            {'integer','scalar','>=',0,'<',Nlevels},...
            'ihaart','LEVEL',3);
        temp = temp - 1;
    elseif coder.const(nnzLevelIdx > 1 && ...
            isnumeric(temp_parseinputs{level_idx(1)}))
        coder.internal.error('Wavelet:FunctionInput:InvalidVector');
    end

    % Parsing Transformtype
    if coder.const(temp == 1 && notAllLevelIdx)
        transformtype = temp_parseinputs{~level_idx};
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
