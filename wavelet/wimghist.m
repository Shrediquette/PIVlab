function [count,y] = wimghist(x,nb)
%WIMGHIST Compute histograms.
%   [N,X] = WIMGHIST(Y,NB)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Last Revision: 28-Dec-2006.
%   Copyright 1995-2020 The MathWorks, Inc.

x    = double(x(:));
xlen = length(x);
if nargin==1 , nb = 1+length(find(diff(sort(x)))); end
minx = min(x);
x    = x - minx;
maxx = max(x);
if abs(maxx)<eps
    count = [xlen zeros(1,nb-1)];
    y     = minx*ones(1,nb);
else
    x       = fix(1 + (nb*x)/maxx);
    x(x>nb) = nb;
    count   = full(sum(sparse(1:xlen,x,1,xlen,nb)));
    y       = minx+((maxx*(0.5:nb))/nb);
end
