function y = upcoef(o,x,varargin)
%UPCOEF Direct reconstruction from 1-D wavelet coefficients.
%   Y = UPCOEF(O,X,'wname',N) computes the N-step 
%   reconstructed coefficients of vector X. 'wname' is a
%   string containing the wavelet name.
%   N must be a strictly positive integer.
%   If O = 'a', approximation coefficients are reconstructed.
%   If O = 'd', detail coefficients are reconstructed.
%
%   Y = UPCOEF(O,X,'wname',N,L) computes the N-step 
%   reconstructed coefficients of vector X and takes the 
%   length-L central portion of the result.
%
%   Instead of giving the wavelet name, you can give the
%   filters.
%   For Y = UPCOEF(O,X,Lo_R,Hi_R,N) or 
%   Y = UPCOEF(O,X,Lo_R,Hi_R,N,L),
%   Lo_R is the reconstruction low-pass filter and
%   Hi_R is the reconstruction high-pass filter.
%
%   Y = UPCOEF(O,X,'wname') is equivalent to 
%   Y = UPCOEF(O,X,'wname',1).
%
%   Y = UPCOEF(O,X,Lo_R,Hi_R) is equivalent to 
%   Y = UPCOEF(O,X,Lo_R,Hi_R,1).
%
%   See also IDWT.

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
y = x; n = 1; l = 0;
if ischar(varargin{1})
    [Lo_R,Hi_R] = wfilters(varargin{1},'r'); next = 2;
else
    Lo_R = varargin{1}; Hi_R = varargin{2};  next = 3;
end
if nargin>=(2+next)
    n = varargin{next}; 
    if nargin>=(3+next), l = varargin{next+1}; end
end

if (n<0) || (n~=fix(n)) || (l<0) || (l~=fix(l))
    error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end
if n==0 , return; end

switch o
    case 'a' ,  F1 = Lo_R;  % Approximation reconstruction.
    case 'd' ,  F1 = Hi_R;  % Detail reconstruction.
    otherwise
        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end

lf = length(Lo_R);
ly = 2*length(y)+lf-2;
y  = upsconv1(y,F1,ly);
for k=2:n
    ly = 2*length(y)+lf-2;
    y  = upsconv1(y,Lo_R,ly);
end
if l , y = wkeep1(y,l); end
