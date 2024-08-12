function [wthr,thresh] = surethreshcfs(w,nj)
%   This function is for internal use only. It may change in a future
%   release.
%   This function thresholds coefficients based on Stein's unbiased risk
%   The function uses soft thresholding

%   Copyright 2016-2020 The MathWorks, Inc.

L = length(nj)-1;
wthr = w;
Numcoefs = cumsum(nj);

for lev = L:-1:1
   [wthr(Numcoefs(lev)+1:Numcoefs(lev+1),:),thresh] = ...
   surethresh(w(Numcoefs(lev)+1:Numcoefs(lev+1),:),'s');
end


%------------------------------------------------------------------------
function [w, thresh] = surethresh(cfs,type)
minstd = 1e-9;
M = size(cfs,1);
N = size(cfs,2);
% Compensate for nonzero means
meanz = mean(cfs);
cfs = detrend(cfs,0);
% normfac = 1/norminv(0.75,0,1);
normfac = 1/(-sqrt(2)*erfcinv(2*0.75));
stdest = 1.4826*median(abs(cfs));
stdest = repmat(stdest,M,1);
% Guard against zero standard deviation
stdest(stdest<minstd) = minstd;
% Vectors have unit standard deviation
cfsstd = cfs./stdest;

A = sort(abs(cfsstd)).^2 ;
% Take the cumsum along the first dimension
% This will the same size as A
B = cumsum(A,1);
C = linspace(M-1,0,M);
C = C(:);
C = repmat(C,1,N);
S = B+C.*A;
factor = (M-(2.*(1:M)))';
risk = (factor + S)./M;
[~,bestidx] = min(risk);
bestidx = sub2ind(size(A),bestidx,1:N);
thresh = sqrt(A(bestidx));
% Thresholds as a row vector
thresh = (stdest.*repmat(thresh,M,1))+meanz;


switch type
    case 's'
    res = (abs(cfs) - thresh);
	res = (res + abs(res))/2;
	w   = sign(cfs).*res;
    
    case 'h'
        w   = cfs .* (abs(cfs) > thresh);
end
%w = w.*stdest;
