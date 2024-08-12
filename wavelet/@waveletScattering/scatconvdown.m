function [S,U] = scatconvdown(xdft,dspsif,dsphif,dspsi,dsphi,res)
% This function is for internal use only. It may change or be removed in a
% future release.

%   Copyright 2018-2022 The MathWorks, Inc.
%#codegen
% Filters are in the Fourier domain
dsphi = max(dsphi-(dspsi-res),0);
nfacpsi = 2^dspsi;
nfacphi = 2^dsphi;
M = size(xdft,1);
dspsif = reshape(dspsif,M,2^(-res));
dspsif = sum(dspsif,2);
if isempty(coder.target)
    cfsFT = xdft.*dspsif;
else
    cfsFT = bsxfun(@times,xdft,dspsif);
end
% These vectors will always be a power of two in length and downsampling
% factors will always be a power of two less than the signal length.
pow2len = log2(M);
Period = 2^pow2len/nfacpsi;
%%
cfsFT = reshape(cfsFT,Period,2^dspsi,size(cfsFT,2),size(cfsFT,3));
cfsFT = sum(cfsFT,2);
% We are using this for wavelet coefficents with complex-valued wavelets.
% We do not want to ignore the imaginary part. But we could have another
% flag for the scaling coefficients using 'symmetric'
U = abs(ifft(cfsFT,Period))./nfacpsi;
U = reshape(U,[size(U,1) size(U,3) size(U,4) size(U,2)]);
MU = size(U,1);
Udft = fft(U);
dsphif = reshape(dsphif,MU,2^(dspsi-res));
dsphif = sum(dsphif,2);
if isempty(coder.target)
    scatFT = Udft.*dsphif;
else
    scatFT = bsxfun(@times,Udft,dsphif);
end
pow2len = log2(MU);
Period = 2^pow2len/nfacphi;
scatFT = reshape(scatFT,Period,2^dsphi,size(scatFT,2),size(scatFT,3));
scatFT = sum(scatFT,2);
scatFT = reshape(scatFT,[size(scatFT,1) size(scatFT,3) size(scatFT,4) size(scatFT,2)]);
S = real(ifft(scatFT))./nfacphi;




