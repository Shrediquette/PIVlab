function [perfl2,perf0] = wscrupd(c,l,n,thr,sorh)
%WSCRUPD Update Compression Scores using Wavelets thresholding.
%   For 1D case :
%   [PERFL2,PERF0] = WSCRUPD(C,L,N,THR,SORH) returns
%   compression scores induced by wavelet coefficients
%   thresholding of the decomposition structure [C,L]
%   (performed at level N) using level-dependent thresholds
%   contained in vector THR (THR must be of length N).
%   SORH ('s' or 'h') is for soft or hard thresholding
%   (see WTHRESH for more details).
%   Output arguments PERFL2 and PERF0 are L^2 recovery
%   and compression scores in percentages.
%
%   For 2D case :
%   [PERFL2,PERF0] = WSCRUPD(C,L,N,THR,SORH)
%   THR must be a matrix 3 by N containing the level
%   dependent thresholds in the three orientations
%   horizontal, diagonal and vertical.
%
%   See also WDENCMP, WCMPSCR.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check arguments and set problem dimension.
if errargt(mfilename,n,'int')
    error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end
if errargt(mfilename,thr,'re0')
    error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end
if errargt(mfilename,sorh,'str')
    error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end
dim = 1; if min(size(l))~=1, dim = 2; end

% Wavelet coefficients thresholding.
if dim == 1
    cxc = wthcoef('t',c,l,1:n,thr,sorh);
else
    cxc = wthcoef2('h',c,l,1:n,thr(1,:),sorh);
    cxc = wthcoef2('d',cxc,l,1:n,thr(2,:),sorh);
    cxc = wthcoef2('v',cxc,l,1:n,thr(3,:),sorh);
end

% Compute L^2 recovery and compression scores.
sumc2 = sum(c.^2);
if sumc2<eps
    perfl2 = 100;
else
    perfl2 = 100*(sum(cxc.^2)/sumc2);
end
perf0 = 100*(length(find(cxc==0))/length(cxc));

