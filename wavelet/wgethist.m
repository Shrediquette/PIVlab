function hval = wgethist(signal,nbbar,mode)
%WGETHIST Build values to plot histogram.
%   P = WGETHIST(X,N) returns a 2xN matrix
%   X is a vector or a matrix.
%   N is the number of bins.
%   P(1,:) = x coordinates of points of histogram.
%   P(2,:) = y coordinates of points of histogram.
%
%   P = WGETHIST(X) is equivalent to P = WGETHIST(X,10)
%
%   P = WGETHIST(X,N,MODE) (with MODE = 'center' or 'left')
%   If X is constant, the main class of the histogram is
%   centered or not (depending of MODE).
%
%   See also WIMGHIST.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Last Revision: 01-May-1998.
%   Copyright 1995-2020 The MathWorks, Inc.

sig_len = length(signal);
if sig_len==0, hval = []; return; end
if nargin==1
    nbbar = 10;
else
    nbbar = fix(nbbar);
    if nbbar<2 , nbbar = 10; end
end
if nargin<3 | ~isequal(lower(mode),'left')
    mode = 'center';
end
[n,x] = wimghist(signal,nbbar);

if abs(max(x)-min(x))<1000*eps
    switch mode
        case 'left'
          n    = [sum(n) zeros(1,nbbar-1)];
          step = 1;
          xx   = linspace(0,step,nbbar);
          x    = xx+x(1);

        case 'center'
          nn   = (nbbar-1)/2;
          n    = [zeros(1,floor(nn)) sum(n) zeros(1,ceil(nn))];
          step = 0.5;
          xx   = linspace(-step,step,nbbar);
          x    = xx-xx(floor(nn)+1)+x(1);
    end
end

d       = diff(x)/2;
d       = [d d(1)];
xs      = [x-d;x-d;x+d;x+d];
ns      = zeros(size(xs));
ns(2:3,:) = [n;n];
xs      = xs(:)';
ns      = ns(:)';
hval    = [xs;ns];
