function [xden,denoisedcfs,origcfs,xdecoriginal,xdecdenoised] = ...
    ebayesdenoise(x,Lo_D,Hi_D,Lo_R,Hi_R,level,noiseestimate,threshold)
% This function is for internal use only. It may change in a future
% release.

%   Copyright 2017-2020 The MathWorks, Inc.

%#codegen
xdec = mdwtdec('c',x,level,Lo_D,Hi_D,Lo_R,Hi_R);

xdecoriginal = xdec;
xdecdenoised = xdec;

% Original Coefficients
origcfs = wavelet.internal.repackmdwt(xdec);

temp_levdep = false;
normfac = 1/(-sqrt(2)*erfcinv(2*0.75));
if strcmpi(noiseestimate,'levelindependent')
    d1 = xdec.cd{1};
    vscale = normfac*median(abs(d1)); 
else
    vscale = zeros(1,size(x,2));
    temp_levdep = true;
end

for lev = 1:level
    if temp_levdep
        xdecdenoised.cd{lev} = wavelet.internal.ebayesthresh(...
            xdec.cd{lev},'leveldependent',threshold,'decimated');
    else
        xdecdenoised.cd{lev} = wavelet.internal.ebayesthresh(...
            xdec.cd{lev},vscale,threshold,'decimated');
    end
end

% Denoised Coefficients
denoisedcfs = wavelet.internal.repackmdwt(xdecdenoised);

xden = mdwtrec(xdecdenoised);

