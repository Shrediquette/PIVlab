function xrec = ihaart2(a,h,v,d,varargin)
%IHAART2 Inverse Haar 2-D wavelet transform
% XREC = IHAART2(A,H,V,D) returns the 2-D inverse Haar transform, XREC, for
% the approximation coefficients, A, and matrices, or cell array of wavelet
% coefficients in H, V, and D. A, H, V, and D are outputs of HAART2. If A,
% H, V, and D are matrices, the 2-D Haar transform was computed only down
% to one level coarser in resolution.
%
% XREC = IHAART2(A,H,V,D,LEVEL) returns the inverse 2-D Haar transform at
% level, LEVEL. LEVEL is a nonnegative integer less than or equal to
% length(H)-1 if H is a cell array. If H is a matrix, LEVEL must equal 0 or
% be unspecified.
%
% XREC = IHAART2(...,INTEGERFLAG) specifies how the inverse Haar
% transform handles integer-valued data.
% 'noninteger'  -   (default) does not preserve integer-valued data in the
%                   Haar transform.
% 'integer'     -   preserves integer-valued data in the Haar transform.
% Note that the inverse Haar transform still uses floating-point arithmetic
% in both cases. However, the lifting transform is implemented in a manner
% that preserves integer-valued data. The 'integer' option is only
% applicable if all elements of the inputs, A, H, V, and D, are
% integer-valued.
%
%
%   %Example 1:
%   load woman;
%   [A,H,V,D] = haart2(X);
%   xrec = ihaart2(A,H,V,D);
%   subplot(2,1,1)
%   imagesc(X); title('Original Image');
%   subplot(2,1,2)
%   imagesc(xrec); title('Inverted Haar Transform');
%
%   %Example 2:
%   im = imread('mandrill.png');
%   [A,H,V,D] = haart2(im);
%   XREC = ihaart2(A,H,V,D);
%   subplot(2,1,1)
%   imagesc(im); title('Original RGB Image');
%   axis off;
%   subplot(2,1,2)
%   imagesc(uint8(XREC)); title('Reconstructed RGB Image');
%   axis off;
%
% See also haart2, haart, ihaart

%   Copyright 2016-2020 The MathWorks, Inc.

%#codegen

% Check number of input arguments
narginchk(4,6)

[level, Nlevels, integerflag, temph, tempv, tempd] = parseinputs(a,h,v,d,varargin{:});

h_final = temph;
v_final = tempv;
d_final = tempd;
if level>0
    for kk = 1:level
        h_final{kk} = zeros(size(temph{kk}),'like',temph{kk});
        v_final{kk} = zeros(size(tempv{kk}),'like',temph{kk});
        d_final{kk} = zeros(size(tempd{kk}),'like',temph{kk});
    end
end

tempa = a;
if ~(isempty(coder.target))
    coder.varsize('tempa',Inf(1,coder.internal.ndims(a)));
end

for jj = Nlevels:-1:1
    tempa = ihlwt2(tempa,h_final{jj},v_final{jj},d_final{jj},integerflag);
end
xrec = tempa;

function x = ihlwt2(a,hin,vin,din,integerflag)
%IHLWT2 Haar (Integer) Wavelet reconstruction 2-D using lifting.
%   IHLWT2 performs the 2-D lifting Haar wavelet reconstruction.
%
%   X = IHLWT2(CA,CH,CV,CD) computes the reconstructed matrix X
%   using the approximation coefficients vector CA and detail
%   coefficients vectors CH, CV, CD obtained by the Haar lifting
%   wavelet decomposition.
%
%   X = IHLWT2(CA,CH,CV,CD,INTFLAG) computes the reconstructed
%   matrix X, using the integer scheme.
%

% Test for odd input.
odd_Col = size(din,2)<size(a,2);
if odd_Col
    [drows,dcols,dDim3,dDim4] = size(din);
    [vrows,vcols,vDim3,vDim4] = size(vin);
    
    tempd = zeros(drows,dcols+1,dDim3,dDim4,'like',a);
    tempv = zeros(vrows,vcols+1,vDim3, vDim4,'like',a);
    
    tempd(:,1:end-1,:,:) = din(:,1:end,:,:);
    tempv(:,1:end-1,:,:) = vin(:,1:end,:,:);
else
    tempd = din;
    tempv = vin;
end

odd_Row = size(din,1) < size(a,1);
if odd_Row
    [drows,dcols,dDim3,dDim4] = size(tempd);
    [hrows,hcols,hDim3,hDim4] = size(hin);
    
    tempd_final = zeros(drows+1,dcols,dDim3,dDim4,'like',a);
    temph = zeros(hrows+1,hcols,hDim3,hDim4,'like',a);
    
    tempd_final(1:end-1,:,:,:) = tempd(1:end,:,:,:);
    temph(1:end-1,:,:,:) = hin(1:end,:,:,:);
else
    tempd_final = tempd;
    temph = hin;
end

h = temph;
v = tempv;
d = tempd_final;

% Reverse Lifting.
if ~integerflag
    % Normalization.
    a = a/2;
    d = 2*d;
    v = (v-d/2);      % Reverse primal lifting.
else
    v = (v-fix(d/2)); % Reverse primal lifting.
end
d = v+d;   % Reverse dual lifting.

% Merging.
SZ = size([d ; v]);
H = zeros(SZ,'like',v);
H(1:2:end,:,:,:) = v;
H(2:2:end,:,:,:) = d;

% Reverse Lifting.
if ~integerflag
    a = (a-h/2);      % Reverse primal lifting.
else
    a = (a-fix(h/2)); % Reverse primal lifting.
end
h = a+h;   % Reverse dual lifting.

% Merging.
L = zeros(SZ,'like',a);
L(1:2:end,:,:,:) = a;
L(2:2:end,:,:,:) = h;

% Reverse Lifting.
if ~integerflag
    L = (L-H/2);      % Reverse primal lifting.
else
    L = (L-fix(H/2)); % Reverse primal lifting.
end
H = L+H;   % Reverse dual lifting.

% Merging.
SZX = size([L H]);
x = zeros(SZX,'like',a);
x(:,1:2:end,:,:) = L;
x(:,2:2:end,:,:) = H;

% Test for odd output.
if odd_Col 
    x(:,end,:,:) = []; 
end
if odd_Row 
    x(end,:,:,:) = [];
end

function [level, Nlevels, integerflag, h_out, v_out,d_out] = ...
    parseinputs(a,h,v,d,varargin)

level = 0;
integerflag = 0;

validateattributes(a,{'double','single'},{'real','finite','nonempty'},...
    'ihaart2','A',1);

[hvd_flag, Nlevels] = validatewaveletcoeffs(h,v,d);
if iscell(h)
    evar = zeros(0,0,'like',h{1});
else
    evar = zeros(0,0,'like',h);
end

h_out =  coder.nullcopy({evar});
v_out =  coder.nullcopy({evar});
d_out =  coder.nullcopy({evar});
coder.varsize('h_out');
coder.varsize('v_out');
coder.varsize('d_out');
if hvd_flag 
    h_out = {h};
    v_out = {v};
    d_out = {d};
elseif iscell(h) &&  iscell(v) && iscell(d) 
    h_out = h;
    v_out = v;
    d_out = d;
end

if isempty(varargin)
    return;
else
    %%% Parsing Varargin
    temp = nargin - 4;
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
            'ihaart2','LEVEL',3);
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

function [hvd_flag, Nlevels] = validatewaveletcoeffs(h,v,d)

checkCell_h = iscell(h);
checkCell_v = iscell(v);
checkCell_d = iscell(d);

validateattributes(h,{'double','single','cell'},{'nonempty'},'ihaart2','H',2);
validateattributes(v,{'double','single','cell'},{'nonempty'},'ihaart2','V',3);
validateattributes(d,{'double','single','cell'},{'nonempty'},'ihaart2','D',4);

ndimh = 0;
hvd_flag = false;
Nlevels = 1;

if checkCell_h && checkCell_v && checkCell_d
    Nlevels = length(d);
    if isempty(coder.target)
        ndimh = cellfun(@ndims,h);
        validationFunc = @(x)validateattributes(x,{'double','single'},...
            {'nonempty','real','finite'},'ihaart2','H,V,D');
        cellfun(validationFunc,h);
        cellfun(validationFunc,v);
        cellfun(validationFunc,d);
    else
        ndimh = zeros(1,length(h));
        for i = 1:length(h)
            ndimh(i) = ndims(h);
        end
        
        for i = 1:length(h)
            validateattributes(h{i},{'double','single'},...
                {'nonempty','real','finite'},'ihaart2','H',2);
        end
        
        for i = 1:length(d)
            validateattributes(d{i},{'double','single'},...
                {'nonempty','real','finite'},'ihaart2','D',4);
        end
        
        for i = 1:length(v)
            validateattributes(v{i},{'double','single'},...
                {'nonempty','real','finite'},'ihaart2','V',3);
        end
    end
    
end

if ~checkCell_h && ~checkCell_v && ~checkCell_d
    % Get dimension of H details for testing
    ndimh = ndims(h);
    validateattributes(h,{'double','single'},{'nonempty','real','finite'},...
        'ihaart2','H',2);
    validateattributes(v,{'double','single'},{'nonempty','real','finite'},...
        'ihaart2','V',3);
    validateattributes(d,{'double','single'},{'nonempty','real','finite'},...
        'ihaart2','D',4);
    hvd_flag = true;
end

coder.internal.errorIf(~all(ndimh ==2) && ~all(ndimh == 3) && ...
    ~all(ndimh == 4), 'Wavelet:FunctionInput:InvalidTensorInput');


