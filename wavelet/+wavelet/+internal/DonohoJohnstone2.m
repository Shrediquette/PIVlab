function [imden,Cden,C,S,sigmahat,thr] = DonohoJohnstone2(im,level,Lo_D,Hi_D,Lo_R,Hi_R,denoisemethod,threshrule,noiseestimate,noisedir,ns)
% This function is for internal use only. It may change in a future release

%   Copyright 2018-2020 The MathWorks, Inc.

%#codegen

if strcmpi(threshrule,"hard")
    threshrule = 'h';
else
    threshrule = 's';
end

% To use thselect(), translate "UniversalThreshold" to "sqtwolog"
if strcmpi(denoisemethod,"universalthreshold")
    temp_denoisemethod = 'sqtwolog';
elseif strcmpi(denoisemethod,"minimax")
    temp_denoisemethod = 'minimaxi';
else
    temp_denoisemethod = 'rigrsure';
end
N = 1;
if ns ~= 0
    shifts = wavelet.internal.getCycleSpinShifts2(ns);
    N = size(shifts,2);
else
    shifts = [0 ; 0 ; 0];
end

if strcmpi(noiseestimate,'leveldependent')
    sigmahat = zeros(level,N);
else
    sigmahat = zeros(1,N);
end

thr = [];
Cden = [];
C = [];
imden = zeros(size(im));

if ~isempty(coder.target)
    coder.varsize('sigmahat',Inf(1,2));
    coder.varsize('thr');
    coder.varsize('Cden',Inf(1,2));
    coder.varsize('C',Inf(1,2));
    temp = zeros(N+2,2);
end


for nt = 1:N
    % Shift image
    imcs = circshift(im,shifts(:,nt));
    % Obtain wavelet transform
    [Ctmp,tempS] = wavedec2(imcs,level,Lo_D,Hi_D);
    [Cdentmp,tempSigmahat,thr_temp] = DJdenoise(Ctmp,tempS,level,...
        temp_denoisemethod,noiseestimate,noisedir,threshrule);
    sigmahat(:,nt) = tempSigmahat;
    thr = [thr thr_temp];
    Cden = [Cden; Cdentmp];
    C = [C; Ctmp];
    imcurr = waverec2(Cdentmp,tempS,Lo_R,Hi_R);
    imcurr = circshift(imcurr,-shifts(:,nt));
    imden =  imden*(nt-1)/nt + imcurr/nt;
    if nt == N
        temp = tempS;
    end
end
S = temp;
end

%-------------------------------------------------------------------------
function [Cden,sigmahat,thr] = DJdenoise(C,S,level,denoisemethod,noisestimate,noisedir,threshrule)

numlevels = size(S,1)-2;
% Obtain detail coefficients
detbegin = prod(S(1,:))+1;
Cden = C(detbegin:end);
% Noise estimates
sigmahat = varest(C,S,level,noisestimate,noisedir);
% Thresholds obtained from noise estimates and denoising method
threst = threshest(C,S,sigmahat,denoisemethod);
if isempty(coder.target)
    thr = sigmahat.*threst;
else
    thr = bsxfun(@times,threst,sigmahat);
end

% Level independent
if strcmpi(noisestimate,'levelindependent') && ...
        (strcmpi(denoisemethod,"sqtwolog") || strcmpi(denoisemethod,"minimaxi"))
    Cden = wthresh2(Cden,threshrule,thr);
    Cden = [C(1:detbegin-1) Cden];
else
    for nl = 1:numlevels
        Idx = wavelet.internal.getLevelIndices(S,nl);
        % Thresholds rescaled for application to actual coefficients
        C(Idx) = wthresh2(C(Idx),threshrule,thr(nl));
    end
    Cden = C;
end
end

%-------------------------------------------------------------------------
function sigmahat = varest(C,S,numlevels,levelmethod,noisedir)
% Noise estimates: either level independent where we use just the finest
% scale wavelet coefficients or level dependent where each scale is used


% The following is equivalent to norminv(0.75,0,1) the population MAD
% for a N(0,1) RV
normfac = -sqrt(2)*erfcinv(2*0.75);

if strcmpi(levelmethod,'LevelIndependent')
    wavecfs = wavelet.internal.getdetcoef2(C,S,noisedir,1);
    sigmaest = median(abs(wavecfs))*(1/normfac);
    % Guard against edge case where the variance of the coefficients is
    % zero so if we denoise ones(16,16) we obtain ones(16,16)
    
    % For level independent estimates, sigmaest is a scalar.
    sigmaest(sigmaest<realmin('double')) = realmin('double');
    sigmahat = sigmaest;
elseif strcmpi(levelmethod,'LevelDependent')
    sigmahat = NaN(numlevels,1);
    for lev = 1:numlevels
        wavecfs = wavelet.internal.getdetcoef2(C,S,noisedir,lev);
        sigmaest = median(abs(wavecfs))*(1/normfac);
        % Guard against edge case where the variance of the coefficients is
        % zero
        sigmaest(sigmaest<realmin('double')) = realmin('double');
        sigmahat(lev) = sigmaest;
    end
else
    sigmahat = NaN(numlevels,1);
end
end

%--------------------------------------------------------------------------
function thr = threshest(wavecfs,sz,sigmahat,denoisemethod)
NumLevels = size(sz,1)-2;
M = numel(wavecfs);
levsigma = sigmahat;
if strcmpi(denoisemethod,'sqtwolog') || strcmpi(denoisemethod,'minimaxi')
    thr = thselect(ones(M,1),denoisemethod);
else
    thr = zeros(NumLevels,1);
    if numel(sigmahat) ~= NumLevels
        levsigma = repmat(sigmahat,NumLevels,1);
    end
    for lev = 1:NumLevels
        Idx = wavelet.internal.getLevelIndices(sz,lev);
        cfs = wavecfs(Idx)';
        thr(lev) = thselect(cfs./levsigma(lev,:),denoisemethod);
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

