function [cfsnorm,scint] = scNormalize(cfs,cpsi,scales,normfac)
% This function is for internal use only. It may change or be removed
% in a future release.
% cfsnorm = scNormalize(cfs,cpsi,scales,normfac,type)

%   Copyright 2020 The MathWorks, Inc.

% Copyright, The MathWorks, 2020

%#codegen
[~,~,p] = size(cfs);
abscfssq = abs(cfs).^2;
% Ensure scales is a column vector for implicit expansion
scales = scales(:);
% To get the proper Lebesgue measure. The division by $s$ as opposed to
% $s^2$ reflects the $L_1$-normalization of the CWT in Wavelet Toolbox.

% In R2020b, MATLAB coder does not support implicit expansion.
if isempty(coder.target)
    abscfssq = abscfssq./scales;
else
    abscfssq = bsxfun(@rdivide,abscfssq,scales);
end
N = size(abscfssq,2);
if p == 1
    scint = 2/cpsi*1/N*trapz(scales,trapz(1:N,abscfssq,2));
    
else
    scintAnal = trapz(scales,trapz(1:N,abscfssq(:,:,1),2));
    scintAntiAnal = trapz(scales,trapz(1:N,abscfssq(:,:,2),2));
    scint = 1/cpsi*1/N*(scintAnal+scintAntiAnal);
end

fac = normfac/scint;
% If normfac is passed as 0, this is the 'none' normalization.
% The cast is not necessary on the MATLAB path, just being paranoid for
% MATLAB coder.
if normfac == cast(0,'like',normfac)
    cfsnorm = cfs;
else
    cfsnorm = sqrt(fac)*cfs;
end
    
