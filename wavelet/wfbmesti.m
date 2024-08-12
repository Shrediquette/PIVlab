function Hest = wfbmesti(x)
%WFBMESTI Estimate fractal index.
%   HEST = WFBMESTI(X) returns a row vector HEST which contains
%   three estimates of the fractal index H of the signal X supposed
%   to come from a fractional Brownian motion of parameter H.
%
%   The two first estimates are based on second order discrete 
%   derivative, the second one is wavelet based.
%   The third estimate is based on the linear regression in 
%   loglog plot, of the variance of detail versus level.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 22-May-2003.
%   Last Revision: 11-Jul-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

% First method : second order discrete derivative.
%-------------------------------------------------
y = diff(x); % x is a Fractional Gaussian Noise
y = cumsum(y(:)');  
n = length(y);
b1 = [1 -2 1];
b2 = [1  0 -2 0 1];
y1 = filter(b1,1,y);
y1 = y1(length(b1):n);
y2 = filter(b2,1,y);
y2 = y2(length(b2):n);
s1 = mean(y1.^2);
s2 = mean(y2.^2);
Hest(1) = 0.5*log2(s2/s1);
        
% Second method : second order discrete derivative (using wavelets).
%-------------------------------------------------------------------
[~,c1,~,~] = wfilters('sym5'); 
c2 = [c1;zeros(1,length(c1))];
c2 = c2(:)';
cy1 = filter(c1,1,y);
cy1 = cy1(length(c1):n);
cy2 = filter(c2,1,y);
cy2 = cy2(length(c2):n);
cs1 = mean(cy1.^2);
cs2 = mean(cy2.^2);
Hest(2) = 0.5*log2(cs2/cs1);
        
% Third method : variance versus level.
%-------------------------------------------------

% Wavelet decomposition of the fractal signal.
levdec = min(wmaxlev(size(x),'haar'),6);
[c,l]  = wavedec(x,levdec,'haar');

% Robust estimates of the standard deviation of detail coeff.
% Recall that x is supposed to be Gaussian.
lvls  = [1:levdec];
stdc  = wnoisest(c,l,lvls);

% Perform regression and compute estimate of h.
p = polyfit(lvls,log2(stdc.^2),1);
Hest(3) = (p(1)-1)/2;
