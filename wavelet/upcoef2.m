function y = upcoef2(o,x,varargin)
%UPCOEF2 Direct reconstruction from 2-D wavelet coefficients.
%   Y = UPCOEF2(O,X,'wname',N,S) computes the N-step 
%   reconstructed coefficients of matrix X and takes the
%   size-S central portion of the result.
%   'wname' is a string containing the name of the wavelet.
%   If O = 'a', approximation coefficients are reconstructed,
%   otherwise if O = 'h' (or 'v' or 'd'), horizontal
%   (vertical or diagonal, respectively),
%   detail coefficients are reconstructed.
%   N must be a strictly positive integer.
%
%   Instead of giving the wavelet name, you can give the
%   filters.
%   For Y = UPCOEF2(O,X,Lo_R,Hi_R,N,S) 
%   Lo_R is the reconstruction low-pass filter and
%   Hi_R is the reconstruction high-pass filter.
% 
%   Y = UPCOEF2(O,X,'wname') is equivalent to
%   Y = UPCOEF2(O,X,'wname',1).
%
%   Y = UPCOEF2(O,X,Lo_R,Hi_R) is equivalent to
%   Y = UPCOEF2(O,X,Lo_R,Hi_R,1).
%
%   NOTE: If X is obtained from an indexed image analysis
%   (respectively a truecolor image analysis) then 
%   it is an m-by-n matrix (respectively m-by-n-by-3 array).
%   In the first case the output array Y is an m-by-n matrix,
%   in the second case Y is an m-by-n-by-3 array.
%   For more information on image formats, see the reference
%   pages of IMAGE and IMFINFO functions.
%
%   See also IDWT2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 06-Feb-2011.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check arguments.
narginchk(3,6)
if isempty(x) , y = x; return; end
if isStringScalar(o)
    o = convertStringsToChars(o);
end
[varargin{:}] = convertStringsToChars(varargin{:});
o = lower(o(1));
dim = length(size(x));
y = x; n = 1; s = zeros(1,dim);
if ischar(varargin{1})
    [Lo_R,Hi_R] = wfilters(varargin{1},'r'); next = 2;
else
    Lo_R = varargin{1}; Hi_R = varargin{2};  next = 3;
end
if nargin>=(2+next)
    n = varargin{next}; 
    if nargin>=(3+next), s = varargin{next+1}; end
end

if (n<0) || (n~=fix(n)) || ~isempty(find(s<0,1)) || ...
        ~isempty(find(s~=fix(s),1))
    error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end
if n==0 , return; end

switch o
    case 'a' , F1 = Lo_R; F2 = Lo_R;
    case 'h' , F1 = Hi_R; F2 = Lo_R;
    case 'v' , F1 = Lo_R; F2 = Hi_R;
    case 'd' , F1 = Hi_R; F2 = Hi_R;
    otherwise
        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end
lf = length(Lo_R);

% Compute Maximum Sizes.
sizUP = zeros(n,dim);
sy = size(y);
sizUP(1,1:2) = 2*sy(1:2)+lf-2;
for k=2:n
    sizUP(k,1:2) = 2*sizUP(k-1,1:2)+lf-2;
end
if prod(s)
    for k = 1:2
        idx = sizUP(:,k)>2*s(k);
        sizUP(idx,k) = 2*s(k);
    end
end

y = upsconv2(y,{F1,F2},sizUP(1,:));
for p=2:n
    y = upsconv2(y,{Lo_R,Lo_R},sizUP(p,:));
end
if prod(s)
    y = wkeep2(y,s);
end
