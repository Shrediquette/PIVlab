function x = wrcoef(o,c,l,varargin)
%WRCOEF Reconstruct single branch from 1-D wavelet coefficients.
%   WRCOEF reconstructs the coefficients of a 1-D signal,
%   given a wavelet decomposition structure (C and L) and
%   either a specified wavelet ('wname', see WFILTERS for more information) 
%   or specified reconstruction filters (Lo_R and Hi_R).
%
%   X = WRCOEF('type',C,L,'wname',N) computes the vector of reconstructed
%   coefficients, based on the wavelet decomposition structure [C,L] (see
%   WAVEDEC for more information), at level N. 'wname' is a character
%   vector containing the name of the wavelet.
% 
%   Argument 'type' determines whether approximation
%   ('type' = 'a') or detail ('type' = 'd') coefficients are
%   reconstructed.
%   When 'type' = 'a', N is allowed to be 0; otherwise, 
%   a strictly positive number N is required.
%   Level N must be an integer such that N <= length(L)-2. 
%
%   X = WRCOEF('type',C,L,Lo_R,Hi_R,N) computes coefficient
%   as above, given the reconstruction you specify.
%
%   X = WRCOEF('type',C,L,'wname') and
%   X = WRCOEF('type',C,L,Lo_R,Hi_R) reconstruct coefficients
%   of maximum level N = length(L)-2.
%
%   See also APPCOEF, DETCOEF, WAVEDEC.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 06-Feb-2011.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check arguments.
if isStringScalar(o)
    o = convertStringsToChars(o);
end

if nargin > 3
    [varargin{:}] = convertStringsToChars(varargin{:});
end

narginchk(4,6)
o = lower(o(1));
rmax = length(l); nmax = rmax-2;

if o=='a'
    nmin = 0; 
    else nmin = 1; 
end
if ischar(varargin{1})
    [Lo_R,Hi_R] = wfilters(varargin{1},'r'); next = 2;
else
    Lo_R = varargin{1};  Hi_R = varargin{2}; next = 3;
end
if nargin>=(3+next) , n = varargin{next}; else n = nmax; end

if (n<nmin) || (n>nmax) || (n~=fix(n))
    error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end

% Get DWT_Mode
dwtATTR = dwtmode('get');

switch o
  case 'a'
    % Extract approximation.
    x = appcoef(c,l,Lo_R,Hi_R,n);
    if n==0, return; end
    F1 = Lo_R;

  case 'd'
    % Extract detail coefficients.
    x = detcoef(c,l,n);
    F1 = Hi_R;

  otherwise
    error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end

imin = rmax-n;
x  = upsconv1(x,F1,l(imin+1),dwtATTR);
for k=2:n , x = upsconv1(x,Lo_R,l(imin+k),dwtATTR); end
