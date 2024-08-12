function [scalDFT,wavDFT,Tband] = analysisFilterBank(xdft,Nscal,Nwav)
% This function is for internal use only. It may change or be removed in a
% future release.
%
% [scalDFT,wavDFT,Tband] = analysisFilterBank(xdft,Nscal,Nwav)

% Copyright 2021 The MathWorks, Inc.

%#codegen

[N,nchan,nbatch] = size(xdft);
P = (N-Nwav)/2;
T = (Nscal+Nwav-N)/2-1;
S = (N-Nscal)/2;
eta = ((1:T)./(T+1)*1/2)';

Tband = 1/2*(1+cos(2*pi*eta)).*sqrt(2-cos(2*pi*eta));
% Allocate arrays for scaling and wavelet coefficients
scalDFT = zeros(Nscal,nchan,nbatch,'like',xdft);
wavDFT = zeros(Nwav,nchan,nbatch,'like',xdft);

% Lowpass subband
scalDFT(1:P+1,:,:) = xdft(1:P+1,:,:);

% bsxfun still needed to support code generation in R20201b
if isempty(coder.target)
    scalDFT(P+(1:T)+1,:,:) = xdft(P+(1:T)+1,:,:).*Tband;
    scalDFT(Nscal-P-(1:T)+1,:,:) = xdft(N-P-(1:T)+1,:,:).*Tband;
else
    
    scalDFT(P+(1:T)+1,:,:) = bsxfun(@times,xdft(P+(1:T)+1,:,:),Tband);
    scalDFT(Nscal-P-(1:T)+1,:,:) = bsxfun(@times,xdft(N-P-(1:T)+1,:,:),...
        Tband);
end


scalDFT(Nscal-(1:P)+1,:,:) = xdft(N-(1:P)+1,:,:);

% Highpass subband bsxfun still needed to support code generation 
% in R20201b
if isempty(coder.target)
    wavDFT((1:T)+1,:,:) = xdft(P+(1:T)+1,:,:).*Tband(T:-1:1);  
    wavDFT(Nwav-(1:T)+1,:,:) = xdft(N-P-(1:T)+1,:,:).*Tband(T:-1:1);
else
    wavDFT((1:T)+1,:,:) = bsxfun(@times,xdft(P+(1:T)+1,:,:),Tband(T:-1:1));
    wavDFT(Nwav-(1:T)+1,:,:) = ...
    bsxfun(@times,xdft(N-P-(1:T)+1,:,:),Tband(T:-1:1));
    
end

wavDFT(T+(1:S)+1,:,:) = xdft(P+T+(1:S)+1,:,:);
% Equate Nyquist values
wavDFT(Nwav/2+1,:,:) = xdft(N/2+1,:,:);
wavDFT(Nwav-T-(1:S)+1,:,:) = xdft(N-P-T-(1:S)+1,:,:);

























