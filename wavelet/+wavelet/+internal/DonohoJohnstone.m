function [xden,denoisedcfs,origcfs,sigmahat,thr,xdec,xdecdenoised] = ...
    DonohoJohnstone(x,level,Lo_D,Hi_D,Lo_R,Hi_R,denoisemethod,threshrule,noisestimate)
% This function is for internal use only. It may change in a future release

%   Copyright 2017-2020 The MathWorks, Inc.

%#codegen

xdec = mdwtdec('c',x,level,Lo_D,Hi_D,Lo_R,Hi_R);
xdecdenoised = xdec;

% Original CFS.
[origcfs,~,numCoefs] = wavelet.internal.repackmdwt(xdec);

N = size(x,2);
% Noise estimates
sigmahat = varest(xdec.cd,N,noisestimate);
% Thresholds obtained from noise estimates and denoising method
threst = threshest(xdec.cd,[numCoefs N],sigmahat,denoisemethod);
thr = sigmahat.*threst;
for jj = 1:length(xdec.cd)
    % Thresholds rescaled for application to actual coefficients
    xdecdenoised.cd{jj} = wthresh2(xdec.cd{jj},threshrule,thr(jj,:));
end

% Package denoised coefficients
denoisedcfs = wavelet.internal.repackmdwt(xdecdenoised);

% Invert transform
xden = mdwtrec(xdecdenoised);

end

%-------------------------------------------------------------------------
function sigmahat = varest(wavecfs,numsignals,levelmethod)
% Noise estimates: either level independent where we use just the finest
% scale wavelet coefficients or level dependent where each scale is used
numlevels = numel(wavecfs);

% The following is equivalent to norminv(0.75,0,1) the population MAD
% for a N(0,1) RV
normfac = -sqrt(2)*erfcinv(2*0.75);
sigmahat = NaN(numlevels,numsignals);
if strcmpi(levelmethod,'LevelIndependent')
    sigmaest = median(abs(wavecfs{1}))*(1/normfac);
    % Guard against edge case where the variance of the coefficients is
    % zero so if we denoise ones(16,1) we obtain ones(16,1)
    sigmaest(sigmaest<realmin('double')) = realmin('double');
    sigmahat = repmat(sigmaest,numlevels,1);
elseif strcmpi(levelmethod,'LevelDependent')
    for lev = 1:numlevels
        sigmaest = median(abs(wavecfs{lev}))*(1/normfac);
        % Guard against edge case where the variance of the coefficients is
        % zero
        sigmaest(sigmaest<realmin('double')) = realmin('double');
        sigmahat(lev,:) = sigmaest;
    end
end
end

%--------------------------------------------------------------------------
function thr = threshest(wavecfs,sz,sigmahat,denoisemethod)
M = numel(wavecfs);
if strcmpi(denoisemethod,'sqtwolog') || strcmpi(denoisemethod,'minimaxi')
    thr = thselect(ones(sz(1),sz(2)),denoisemethod);
    thr = repmat(thr,M,1);
else
    thr = zeros(M,sz(2));
    for jj = 1:numel(wavecfs)
        temp = bsxfun(@rdivide,wavecfs{jj},sigmahat(jj,:));
        thr(jj,:) = thselect(temp, denoisemethod);
    end
end
end

%--------------------------------------------------------------------------
function [x,temp] = wthresh2(x,in2,t)

temp_in2 = char(in2);

if strcmpi(temp_in2,'s')
    tmp = bsxfun(@minus,abs(x),t);
    tmp = (tmp + abs(tmp))/2;
    temp = logical([]);
    x  = bsxfun(@times,sign(x),tmp);
else
    temp =  bsxfun(@gt,abs(x),t);
    x  = x .* temp;
end

end

