function [xden,denoisedcfs,origcfs,xdecoriginal,xdecdenoised] = ...
    blockthreshold(x, Lo_D, Hi_D, Lo_R, Hi_R, level, lambda, L)
% This function is for internal use only. It may change in a future
% release. The function implements the block James-Stein estimator
% described in Cai (1999).
%
%
%   References
%   Cai, T.T. (1999). Adaptive wavelet estimation: a block
%   thresholding and oracle inequality approach. Ann. Statist.,
%   27, 898-924.

%   Copyright 2017-2020 The MathWorks, Inc.

%#codegen

Norig = size(x,1);

% Default denoising level for block thresholding
xdec = mdwtdec('c',x,level,Lo_D,Hi_D,Lo_R,Hi_R);

xdecoriginal = xdec;
xdecdenoised = xdec;

% Original Coefficients
[origcfs, numDetCoefs] = wavelet.internal.repackmdwt(xdec);

% For block threshold we need at least L coefficients at the coarsest
% resolution where L = floor(log(N))
if min(numDetCoefs) < L
    temp = numDetCoefs(numDetCoefs>=L);
    CoarsestLevel = length(temp);
    coder.internal.assert(~(min(numDetCoefs) < L),'Wavelet:FunctionInput:InvalidBlockLevel', CoarsestLevel);
end

d1 = xdec.cd{1};

% Estimate noise variance based on finest-scale wavelet coefficients
% The normalization factor is equivalent to the inverse N(0,1) CDF
% evaluated at 0.75.
normfac = 1/(-sqrt(2)*erfcinv(2*0.75));
sigma = normfac*median(abs(d1));

% Initialize the thresholded wavelet coefficients to the original

for lev = level:-1:1
    xdecdenoised.cd{lev} = wavelet.internal.blockJS(xdec.cd{lev},lambda,L,sigma);
end

% Better to use filters here
xden = mdwtrec(xdecdenoised);
xden = xden(1:Norig,:);
xdecdenoised = xdec;

denoisedcfs = wavelet.internal.repackmdwt(xdecdenoised);


