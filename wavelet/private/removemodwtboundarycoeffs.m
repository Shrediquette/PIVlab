function [cfs,MJ,LJ] = removemodwtboundarycoeffs(ocfs,VJ,N,J,L,scalingvar)
%Remove MODWT boundary coefficients
%   [cfs,MJ,LJ] = removemodwtboundarycoeffs(cfs,VJ,N,J,L,scalingvar)
%   cfs -- wavelet coefficients
%   VJ --  scaling coefficients if the level is scalingvar or -corr is true
%   N -- length adjusted for boundary
%   J -- level
%   L -- Filter length
%   scalingvar -- logical to indicate scaling variance is computed

%   Copyright 2015-2019 The MathWorks, Inc.

%#codegen

LJ = zeros(1,J);
temp_MJ = zeros(1,J+1);
M = 1;

if (scalingvar)
    temp_cfs = zeros(size(ocfs,1)+1,size(ocfs,2));
else
    temp_cfs = zeros(size(ocfs));
end

for jj = 1:J
    LJ(jj) = (2^jj - 1) * (L - 1);
    M = min(LJ(jj), N);
    temp_cfs(jj,:) = ocfs(jj,:);
    temp_cfs(jj,1:M) = NaN;
    temp_MJ(jj) = N-M;
end

if (scalingvar)
    temp_cfs(J+1,:) = VJ;
    temp_cfs(J+1,1:M) = NaN;
    temp_MJ(J+1) = N-M;
    MJ = temp_MJ;
else
    MJ = temp_MJ(1:J);
end
cfs = temp_cfs;
