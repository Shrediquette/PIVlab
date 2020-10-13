function [y,w] = dctn(y,w)

%DCTN N-D discrete cosine transform.
%   Y = DCTN(X) returns the discrete cosine transform of X. The array Y is
%   the same size as X and contains the discrete cosine transform
%   coefficients. This transform can be inverted using IDCTN.
%
%   Class Support
%   -------------
%   Input array can be numeric or logical. The returned array is of class
%   double.
%
%   Reference
%   ---------
%   Narasimha M. et al, On the computation of the discrete cosine
%   transform, IEEE Trans Comm, 26, 6, 1978, pp 934-936.
%
%   Example
%   -------
%       RGB = imread('autumn.tif');
%       I = rgb2gray(RGB);
%       J = dctn(I);
%       imshow(log(abs(J)),[]), colormap(jet), colorbar
%
%   The commands below set values less than magnitude 10 in the DCT matrix
%   to zero, then reconstruct the image using the inverse DCT.
%
%       J(abs(J)<10) = 0;
%       K = idctn(J);
%       figure, imshow(I)
%       figure, imshow(K,[0 255])
%
%   See also IDCTN, DCT, DCT2.
%
%   -- Damien Garcia -- 2008/06, revised 2009/11

% ----------
%   [Y,W] = DCTN(X,W) uses and returns the weights which are used by the
%   program. If DCTN is required for several large arrays of same size, the
%   weights can be reused to make the algorithm faster. A typical syntax is
%   the following:
%      w = [];
%      for k = 1:10
%          [y{k},w] = dctn(x{k},w);
%      end
%   The weights (w) are calculated during the first call of DCTN then
%   reused in the next calls.
% ----------

error(nargchk(1,2,nargin))

y = double(y);
sizy = size(y);
y = squeeze(y);

dimy = ndims(y);
if isvector(y)
    dimy = 1;
    y = y(:);
end

if ~exist('w','var') || isempty(w)
    for dim = 1:dimy
        n = (dimy==1)*numel(y) + (dimy>1)*sizy(dim);
        w{dim} = exp(1i*(0:n-1)'*pi/2/n);
    end
end

if ~isreal(y)
    y = complex(dctn(real(y),w),dctn(imag(y),w));
else
    for dim = 1:dimy
        siz = size(y);
        n = siz(1);
        y = y([1:2:n 2*floor(n/2):-2:2],:);
        y = reshape(y,n,[]);
        y = y*sqrt(2*n);
        y = ifft(y,[],1);
        y = bsxfun(@times,y,w{dim});
        y = real(y);
        y(1,:) = y(1,:)/sqrt(2);
        y = reshape(y,siz);
        y = shiftdim(y,1);
    end
end
        
y = reshape(y,sizy);



