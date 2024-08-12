function m = wrmcoef(o,c,l,varargin)
%WRMCOEF Reconstruct row matrix of single branches 
%   from 1-D wavelet coefficients.
%   M = WRMCOEF(O,C,L,W,N) computes the matrix of
%   reconstructed coefficients, based on the wavelet
%   decomposition structure [C,L], of levels given 
%   in vector N.
%   W is a string containing the wavelet name.
%   If O = 'a', approximation coefficients are reconstructed
%   and value 0 for level is allowed, else detail coefficients 
%   are reconstructed and only strictly positive values for
%   level are allowed.
%   Vector N must contains positive integers <= length(L)-2. 
%
%   M is the output matrix of reconstructed coefficients 
%   vectors stored row-wise.
%   
%   For M = WRMCOEF(O,C,L,Lo,Hi,N) 
%   Lo is the reconstruction low-pass filter and
%   Hi is the reconstruction high-pass filter.
%
%   M = WRMCOEF(O,C,L,W) or M = WRMCOEF(O,C,L,Lo,Hi) reconstructs 
%   coefficients of all possible levels.
%
%   See also APPCOEF, DETCOEF, WRCOEF, WAVEDEC.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 06-Feb-2011.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check arguments.
narginchk(4,6)
o = lower(o(1));
rmax = length(l); nmax = rmax-2;
if o=='a', nmin = 0; else nmin = 1; end
if ischar(varargin{1})
    [Lo_R,Hi_R] = wfilters(varargin{1},'r'); next = 2;
else
    Lo_R = varargin{1}; Hi_R = varargin{2};  next = 3;
end
if nargin>=(3+next), n = varargin{next}; else n = nmin:nmax; end
if find((n<nmin) | (n>nmax) | (n~=fix(n)))
    error(message('Wavelet:FunctionArgVal:Invalid_LevVal'));
end

% Initialization
if size(l,1)>1 , c = c'; l = l'; end
m = zeros(length(n),l(rmax));

% Get DWT_Mode
dwtATTR = dwtmode('get');

switch o
    case 'a'
        for p = nmax:-1:0
            [c,l,a] = upwlev(c,l,Lo_R,Hi_R);
            j = find(p==n);
            if ~isempty(j)
                % Approximation reconstruction.
                imin   = length(l)-p;
                nbrows = length(j);
                m(j,:) = ReconsCoefs(a,Lo_R,Lo_R,l,imin,p,nbrows,dwtATTR);
            end
        end

    case 'd'
        for p = 1:nmax
            j = find(p==n);
            if ~isempty(j)
                % Extract detail coefficients.
                d = detcoef(c,l,p);

                % Detail reconstruction.
                imin   = rmax-p;
                nbrows = length(j);
                m(j,:) = ReconsCoefs(d,Hi_R,Lo_R,l,imin,p,nbrows,dwtATTR);
            end
        end

    otherwise
        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end


%--------------------------------------------------------%
% Internal Function(s)
%--------------------------------------------------------%
function x = ReconsCoefs(x,f1,f2,l,i,p,n,dwtATTR)
if p>0
    x  = upsconv1(x,f1,l(i+1),dwtATTR);
    for k=2:p , x = upsconv1(x,f2,l(i+k),dwtATTR); end
end
x = x(ones(n,1),:);
