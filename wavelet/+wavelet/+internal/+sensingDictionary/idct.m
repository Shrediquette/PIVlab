function a = idct(b,varargin)
% This function is for internal use only, it may change or be removed in a
% future release.
%IDCT Inverse discrete cosine transform.
%   X = IDCT(Y) inverts the DCT transform, returning the original vector
%   if Y was obtained using Y = DCT(X).  If Y is a matrix, the IDCT 
%   operation is applied to each column.  For N-D arrays, IDCT operates 
%   on the first non-singleton dimension.  
%
%   % Example:
%   %   Generate a noisy 25 Hz sinusoidal sequence sampled at 1000 Hz and
%   %   compute the DCT of this sequence and reconstruct the signal using 
%   %   only those components with magnitude greater than 0.9
%   
%   t = (0:999)/1000;           % Time vector
%   x = sin(2*pi*25*t);         % Sinusoid
%   x = x + 0.1*randn(1,1000);  % Add noise
%   y = dct(x);                 % Compute DCT
%   y(abs(y) < 0.9) = 0;        % remove small components
%   z = idct(y);                % Reconstruct signal w/inverse DCT
%   subplot(2,1,1) 
%   plot(t,x)
%   title('Original Signal')
%   subplot(2,1,2)
%   plot(t,z)
%   title('Reconstructed Signal')
%
%   See also FFT, IFFT, DCT.

%   Copyright 2021 The MathWorks, Inc.

% checks if X is a valid numeric data input
validateattributes(b,{'numeric'},{'2d','nonnan','finite'},'idct','b');

if isempty(b)
  a = zeros(0,0,'like',b);
  return
end

a = idctinternal(b,varargin{:});

function a = idctinternal(varargin)

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

scale = sqrt([2*(n-1) 2*n 2*n 2*n]);
dcscale = sqrt([1/2 2 1/2 1]);

x = x .* scale(type);
idc = 1+dimselect(dim,size(x));
x(idc) = x(idc) * dcscale(type);

if n==1 
  if dim==1
    a = matlab.internal.math.transform.mlidct(x(1,:),n,dim,'Variant',type);
  elseif dim==2
    a = matlab.internal.math.transform.mlidct(x(:,1),n,dim,'Variant',type);
  else
    a = matlab.internal.math.transform.mlidct(x,n,dim,'Variant',type);
  end      
else
  a = matlab.internal.math.transform.mlidct(x,n,dim,'Variant',type);
end

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
