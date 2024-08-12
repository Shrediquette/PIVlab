function [xden,denoisedcfs,origcfs,xdecoriginal,xdecdenoised,thr] = ...
    FDRDenoise(x,Lo_D,Hi_D,Lo_R,Hi_R,level,q,noiseestimate)
% This function is for internal use only. It may change in a future
% release.

%   Copyright 2017-2020 The MathWorks, Inc.

%#codegen

xdec = mdwtdec('c',x,level,Lo_D,Hi_D,Lo_R,Hi_R);
C = xdec.cd;

nj = length(C);

% Original Coefficients
origcfs = wavelet.internal.repackmdwt(xdec);

xdecoriginal = xdec;
xdecdenoised = xdec;

if strcmpi(noiseestimate,'levelindependent')
    d1 = xdec.cd{1};
    normfac = 1/(-sqrt(2)*erfcinv(2*0.75));
    sigma = normfac*median(abs(d1));
else
    sigma = [];
end

if isempty(q)
    tempq = 0.05;
else
    tempq = q;
end

[temp_cden,thr] = wavelet.internal.fdrthreshcfs(C,nj,tempq,sigma,xdec.ca);

xdecdenoised.cd = temp_cden;
xden = mdwtrec(xdecdenoised);
denoisedcfs = wavelet.internal.repackmdwt(xdecdenoised);

    
    
    
    
