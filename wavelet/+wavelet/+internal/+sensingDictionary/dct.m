function b = dct(a,varargin)
% This function is for internal use only, it may change or be removed in a
% future release.
%   Y = DCT(X) returns the discrete cosine transform of vector X.
%   If X is a matrix, the DCT operation is applied to each
%   column.  For N-D arrays, DCT operates on the first non-singleton 
%   dimension.  This transform can be inverted using IDCT.             
%
%   See also FFT, IFFT, IDCT.

%   Copyright 2021 The MathWorks, Inc.

validateattributes(a,{'numeric'},{'2d','nonnan','finite'},'dct','a');

if isempty(a)
  b = zeros(0,0,'like',a);
  return
end

b = dctinternal(a,varargin{:});

function b = dctinternal(varargin)

p = inputParser;
p.addRequired('X');
p.addOptional('N',[]);
p.addOptional('DIM',[]);
p.addParameter('Type',2);
p.parse(varargin{:});

r = p.Results;
x = r.X;
type = r.Type;
if isempty(r.N) && isempty(r.DIM)
  [dim,n] = firstNonSingletonDimension(x);
elseif isempty(r.N)
  dim = r.DIM;
  n = size(x,dim);
elseif isempty(r.DIM)
  dim = firstNonSingletonDimension(x);
  n = r.N;
else
  dim = r.DIM;
  n = r.N;
end

validateattributes(n,{'numeric'},{'integer','scalar','positive','finite'});
validateattributes(dim,{'numeric'},{'integer','scalar','positive','finite'});
n = double(n);

scale = sqrt([1/(2*(n-1)) 1/(2*n) 1/(2*n) 1/(2*n)]);
dcscale = sqrt([2 1/2 2 1]);

if n==1 
  if dim==1
    b = matlab.internal.math.transform.mldct(x(1,:),n,dim,'Variant',type);
  elseif dim==2
    b = matlab.internal.math.transform.mldct(x(:,1),n,dim,'Variant',type);
  else
    b = matlab.internal.math.transform.mldct(x,n,dim,'Variant',type);
  end      
else
  b = matlab.internal.math.transform.mldct(x,n,dim,'Variant',type);
end

b = b .* scale(type);
idc = 1+dimselect(dim,size(b));
b(idc) = b(idc) * dcscale(type);


function idx = dimselect(idim, dim)
ndim = numel(dim);
nel = prod(dim);
dcterm = prod(dim(1:min(idim-1,ndim)));
if idim<=ndim
  nskip = dcterm*dim(idim);
else
  nskip = dcterm;
end
idx = (0:dcterm-1)' + (0:nskip:nel-1);
idx = idx(:);
    
function [dim,n] = firstNonSingletonDimension(a)
sz = size(a);
dim = find(sz~=1,1,'first');
if isempty(dim)
  dim = 1;
  n = 1;
else
  n = sz(dim);
end
