function varargout = swt2(x,n,varargin)
%SWT2 stationary wavelet transform 2-D.
%   SWC = SWT2(X,LEVEL,WNAME) returns the stationary wavelet transform of
%   the real-valued 2-D or 3-D matrix X at level, LEVEL, using the
%   orthogonal or biorthogonal wavelet, WNAME. Orthogonal and biorthogonal
%   wavelets are designated as type 1 and type 2 wavelets respectively in
%   the wavelet manager, WAVEMNGR. Valid built-in orthogonal wavelet
%   families begin with 'haar', 'dbN', 'fkN', 'coifN', or 'symN' where N is
%   the number of vanishing moments for all families except 'fk'. For 'fk',
%   N is the number of filter coefficients. Valid biorthgonal wavelet
%   families begin with 'biorNr.Nd' or 'rbioNd.Nr', where Nr and Nd are the
%   number of vanishing moments in the reconstruction (synthesis) and
%   decomposition (analysis) wavelet. Determine valid values for the
%   vanishing moments by using waveinfo with the wavelet family short name.
%   For example, enter waveinfo('db') or waveinfo('bior'). Use
%   wavemngr('type',WNAME) to determine if a wavelet is orthogonal (returns
%   1) or biorthogonal (returns 2). LEVEL is a strictly positive integer
%   and 2^LEVEL must divide size(X,1) and size(X,2). If X is a 3-D matrix,
%   the third dimension of X must equal 3. Internally, SWT2 uses
%   double-precision arithmetic to compute the wavelet transform and
%   returns double-precision coefficient matrices. SWT2 warns if there is a
%   loss of precision when converting to double. If X is a 2-D matrix, SWC
%   is M-by-N-by-3*LEVEL+1. If X is a 3-D matrix, SWC is
%   M-by-N-by-3-by-3*LEVEL+1.
%
%   [A,H,V,D] = SWT2(X,LEVEL,WNAME) returns the approximation coefficients,
%   A, and wavelet coefficients, H, V, and D at each level. If X is a 2-D
%   matrix, A, H, V, and D are M-by-N-by-LEVEL if LEVEL is greater than 1,
%   and M-by-N if LEVEL is equal to 1. If X is a 3-D matrix, A, H, V, and D
%   are M-by-N-by-3-by-LEVEL if LEVEL is greater than 1, and
%   M-by-N-by-1-by-3 if LEVEL is equal to 1.
%
%   [...] = SWT2(X,LEVEL,LoD,HiD) uses the scaling and wavelet analysis
%   filters, LoD and HiD, in the stationary wavelet transform. LoD and HiD
%   must be even-length row or column vectors. LoD and HiD must be equal in
%   length. SWT2 does not check LoD and HiD to ensure they are valid
%   scaling and wavelet analysis filters.
%
%   %Example:
%   load xbox;
%   [A,H,V,D] = swt2(xbox,1,'sym4');
%   subplot(2,1,1)
%   imagesc(abs(V));
%   subplot(2,1,2);
%   imagesc(abs(D));
%
%
%   See also DWT2, WAVEDEC2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 02-Oct-95.
%   Copyright 1995-2020 The MathWorks, Inc.

%#codegen

% Check arguments.
narginchk(3,4);
nargoutchk(0,4);

coder.extrinsic('wavemngr','wfilters');

% There must be at least one varargin
temp_parseinputs = cell(1,nargin-2);
[temp_parseinputs{:}] = convertStringsToChars(varargin{:});

validateattributes(n, {'numeric'}, ...
    {'integer', 'positive', 'scalar'}, 'swt2', 'N', 2);

validateattributes(x, {'numeric'}, {'real', 'nonempty'}, 'swt2', 'X', 1);

% Check for loss of precision
origclass = class(x);
PrecisionLoss = ~all(cast(double(x(:)),origclass) == x(:));
if PrecisionLoss
    coder.internal.warning('Wavelet:FunctionInput:PrecisionLossWT',...
        origclass);
end

% Preserve initial size.
s = size(x);
numDims = ndims(x);
% Check if the input is a tricolor image or matrix.
if numDims > 3
    coder.internal.error('Wavelet:FunctionInput:InvalidSizeVector');
elseif numDims == 3  && (s(3) ~= 3)
     coder.internal.error('Wavelet:FunctionInput:InvalidImageType');
end

% Is it a RGB image
a3d_Flag = (numel(s)>2 && s(3) == 3);
size2D = s(1:2);

% 2^N must divide each dimension of the image.
pow = 2^n;
if any(rem(size2D,pow))
    sOK = ceil(size2D/pow)*pow;
    oriStr = ['(' int2str(s(1))   ',' int2str(s(2)) ')'];
    sugStr = ['(' int2str(sOK(1)) ',' int2str(sOK(2)) ')'];
    coder.internal.error('Wavelet:moreMSGRF:SWT_size_MSG',n,oriStr,sugStr);
end

% Compute decomposition filters.
if ischar(temp_parseinputs{1}) && nargin == 3
    % The wavelet type must be orthogonal or biorthogonal.
    wtype = coder.const(@wavemngr,'type',varargin{1});
    if ~any(wtype == [1 2])
        coder.internal.error('Wavelet:FunctionInput:OrthorBiorthWavelet');
    end
    [lo,hi] = coder.const(@wfilters,varargin{1},'d');
else
    if nargin < 4
        coder.internal.assert(~(nargin < 4),'Wavelet:FunctionInput:InvalidLoHiFilters');
    end
    lo = temp_parseinputs{1};
    hi = temp_parseinputs{2};
    
    validateattributes(lo,{'numeric'},...
        {'vector','finite','real'},'swt2','Lo_D',3);
    validateattributes(hi,{'numeric'},...
        {'vector','finite','real'},'swt2','Hi_D',4);
    
    % The filters must have an even length greater than 2.
    if (length(lo) < 2) || (length(hi) < 2) || ...
            isodd(length(lo)) || isodd(length(hi))
        coder.internal.error('Wavelet:FunctionInput:Invalid_Filt_Length');
    end
end
lo = lo(:)';
hi = hi(:)';

% Set DWT_Mode to 'per'.
modeDWT = 'per';

% Cast image to double-precision
x = double(x);

% Compute non-decimate wavelet coefficients.
a = zeros([s,n]);
h = zeros([s,n]);
v = zeros([s,n]);
d = zeros([s,n]);

temp_lo = lo;
temp_hi = hi;
temp_x =  x;

if ~isempty(coder.target)
    coder.varsize('temp_x',inf(1,coder.internal.ndims(x)));
    coder.varsize('temp_lo',inf(1,2));
    coder.varsize('temp_hi',inf(1,2));
end

for k = 1:n
    % Extension.
    lf = length(temp_lo);
    first = [lf+1,lf+1];
    
    temp_x  = wextend('2D',modeDWT,temp_x,[lf/2,lf/2]);
    
    % Decomposition.
    if ~a3d_Flag
        [a(:,:,k),h(:,:,k),v(:,:,k),d(:,:,k)] = decomposeLOC(temp_x,temp_lo,...
            temp_hi,first,size2D);
        temp_x = a(:,:,k);
    else
        for j=1:3
            [a(:,:,j,k),h(:,:,j,k),v(:,:,j,k),d(:,:,j,k)] = ...
                decomposeLOC(temp_x(:,:,j),temp_lo,temp_hi,first,size2D);
        end
        temp_x = a(:,:,:,k);
    end
    
    % upsample filters.
    templo = [];
    temphi = [];
    
    if ~isempty(coder.target)
        coder.varsize('templo',inf(1,2));
        coder.varsize('temphi',inf(1,2));
    end
    
    templo = [templo; temp_lo; zeros(1,lf)];
    temp_lo = templo(:)';
    
    temphi = [temphi; temp_hi; zeros(1,lf)];
    temp_hi = temphi(:)';
end

% Handle case where RGB images are decomposed to one level
if n == 1 && a3d_Flag
    tempa = reshape(a,[s(1), s(2), 1, 3]);
    temph = reshape(h,[s(1),s(2),1,3]);
    tempv = reshape(v,[s(1),s(2),1,3]);
    tempd = reshape(d,[s(1),s(2),1,3]);
else
    tempa = a;
    temph = h;
    tempv = v;
    tempd = d;
end

if nargout==4
    varargout = {tempa,temph,tempv,tempd};
else
    tempa = squeeze(tempa);
    temph = squeeze(temph);
    tempv = squeeze(tempv);
    tempd = squeeze(tempd);
    if ~a3d_Flag
        varargout{1} = cat(3,temph,tempv,tempd,tempa(:,:,n));
    else
        varargout{1} = cat(4,temph,tempv,tempd,tempa(:,:,:,n));
    end
end
%---------------------------------------------------------

function [ca,ch,cv,cd] = decomposeLOC(x,lo,hi,first,size2D)

y = conv2(x,lo);
z = (conv2(y',lo))';
ca = keepLOC(z,size2D,first);
z = (conv2(y',hi))';
ch = keepLOC(z,size2D,first);
y = conv2(x,hi);
z = (conv2(y',lo))';
cv = keepLOC(z,size2D,first);
z = (conv2(y',hi))';
cd = keepLOC(z,size2D,first);
%---------------------------------------------------------

function y = keepLOC(z,siz,first)
sz = size(z);
siz(siz>sz) = sz(siz>sz);
last = first+siz-1;
y = z(first(1):last(1),first(2):last(2),:);
%---------------------------------------------------------

