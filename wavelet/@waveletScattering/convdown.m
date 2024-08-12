function [y,dsfilter] = convdown(xdft,dsfilter,dsfactor,res,normfactor)
% This function is for internal use only. It may change or be removed in a
% future release.
%

%   Copyright 2018-2022 The MathWorks, Inc.

%#codegen
% Filters are in the Fourier domain
if normfactor == 0
    normfac = 1;
else
    normfac = 2^dsfactor;
end
M = size(xdft,1);
dsfilter = reshape(dsfilter,M,2^(-res));
dsfilter = sum(dsfilter,2);
if isempty(coder.target)
    cfsFT = xdft.*dsfilter;
else
    cfsFT = bsxfun(@times,xdft,dsfilter);
end
% These vectors will always be a power of two in length and downsampling
% factors will always be a power of two less than the signal length.
pow2len = log2(M);
Period = 2^pow2len/2^dsfactor;
cfsFT = reshape(cfsFT,Period,2^dsfactor,size(cfsFT,2),size(cfsFT,3));
cfsFT = sum(cfsFT,2);
% We are using this for wavelet coefficents with complex-valued wavelets.
% We do not want to ignore the imaginary part. But we could have another
% flag for the scaling coefficients using 'symmetric'
y = ifft(cfsFT)./normfac;
y = squeeze(y);



