function [Y,Tband] = synthesisFilterBank(scalDFT,wavDFT,N)
% This function is for internal use only. It may change or be removed in a
% future release.
% [Y,Tband] = synthesisFilterBank(scalDFT,wavDFT,N);

% Copyright 2021 The MathWorks, Inc.

%#codegen
[~,nchan,nbatch] = size(scalDFT);
Nscal = size(scalDFT,1);
Nwav = size(wavDFT,1);
% The following is the same code in analysisFilterBank
P = (N-Nwav)/2;
T = (Nscal+Nwav-N)/2-1;
S = (N-Nscal)/2;
% In case the length is specified incorrectly
coder.internal.errorIf(P < 0 || T < 0 || S < 0,'Wavelet:tqwt:IndicesAssert');
eta = ((1:T)./(T+1)*1/2)';
Tband = 1/2*(1+cos(2*pi*eta)).*sqrt(2-cos(2*pi*eta));

% Allocate output
Ylow = zeros(N,nchan,nbatch,'like',scalDFT);
Yhigh = zeros(N,nchan,nbatch,'like',scalDFT);

%DC term
Ylow(1:P+1,:,:) = scalDFT(1:P+1,:,:);

if isempty(coder.target)
    Ylow(P+(1:T)+1,:,:) = scalDFT(P+(1:T)+1,:,:).*Tband; 
else
    Ylow(P+(1:T)+1,:,:) = bsxfun(@times,scalDFT(P+(1:T)+1,:,:),Tband);
end
Ylow(P+T+(1:S)+1,:,:) = zeros(1,1,'like',scalDFT);    
Ylow(N-(1:P)+1,:,:) = scalDFT(Nscal-(1:P)+1,:,:);
% If N is even, ensure that the Nyquist value if 0
if signalwavelet.internal.iseven(N)
    Ylow(N/2+1,:,:) = zeros(1,1,'like',scalDFT);                                
end
Ylow(N-P-T-(1:S)+1,:,:) = zeros(1,1,'like',scalDFT);                   
if isempty(coder.target)
    Ylow(N-P-(1:T)+1,:,:) = scalDFT(Nscal-P-(1:T)+1,:,:).*Tband;
else
    Ylow(N-P-(1:T)+1,:,:) = ...
        bsxfun(@times,scalDFT(Nscal-P-(1:T)+1,:,:),Tband);
end
Ylow(N-(1:P)+1,:,:) = scalDFT(Nscal-(1:P)+1,:,:);

%High pass
if isempty(coder.target)
    Yhigh(P+(1:T)+1,:,:) = wavDFT((1:T)+1,:,:).*Tband(T:-1:1);
    Yhigh(N-P-(1:T)+1,:,:) = wavDFT(Nwav-(1:T)+1,:,:).*Tband(T:-1:1);
else
    Yhigh(P+(1:T)+1,:,:) = ...
        bsxfun(@times,wavDFT((1:T)+1,:,:),Tband(T:-1:1));
    Yhigh(N-P-(1:T)+1,:,:) = ...
        bsxfun(@times,wavDFT(Nwav-(1:T)+1,:,:),Tband(T:-1:1));
end

Yhigh(P+T+(1:S)+1,:,:) = wavDFT(T+(1:S)+1,:,:);
if signalwavelet.internal.iseven(N)
    Yhigh(N/2+1,:,:) = wavDFT(Nwav/2+1,:,:);
end
Yhigh(N-P-T-(1:S)+1,:,:) = wavDFT(Nwav-T-(1:S)+1,:,:);
Yhigh(N-(1:P)+1,:,:) = zeros(1,1,'like',scalDFT);


Y = Ylow + Yhigh;