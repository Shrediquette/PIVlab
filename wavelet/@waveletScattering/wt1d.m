function [phicoefs,psicoefs,psires,psi3dB] = wt1d(self,x,res,vwav,nfb)
% This function is for internal use only. It may change or be removed in a
% future release
%
% [phicoefs,psicoefs,phimet,psimeta] = ...
%       wt1d(x,res,filters,filtparams,vwav,OversampleFactor);

%   Copyright 2018-2022 The MathWorks, Inc.

%#codegen
phids = max(self.filterparams{nfb}.philog2ds-self.OversamplingFactor,0);
% Number of scattering coefficients in padded transform
Ncfs = floor(self.paddedlength/2^phids);
[~,nchan,nbatch] = size(x);
% Set-up for multichannel
xdft = fft(x,[],1);
% Allocate arrays for the update resolutions and bandwidths
Nwav = numel(vwav);
psicfs = zeros(0,nchan,nbatch,'like',x);
psicoefs = repmat({psicfs},Nwav,1);
psires = zeros(Nwav,1);
psiftsup = zeros(Nwav,1);
psi3dB = zeros(Nwav,1);
phicoefs = coder.nullcopy(zeros(Nwav,Ncfs,size(x,2),size(x,3),'like',x));
[~,psids] = ...
    waveletScattering.log2DecimationFactor(self.filterparams{nfb},res,...
        self.OversamplingFactor,vwav);
coder.varsize('phicoefs');
for nf = 1:Nwav
    psires(nf) = res-psids(nf);
    psiftsup(nf) = self.filterparams{nfb}.psiftsupport(vwav(nf));
    psi3dB(nf) = self.filterparams{nfb}.psi3dBbw(vwav(nf));
    [Stmp,psicoefs{nf}] = ...
        waveletScattering.scatconvdown(xdft,self.filters{nfb}.psift(:,vwav(nf)),...
            self.filters{nfb}.phift,psids(nf),phids,res);
    Stmp = reshape(Stmp,[1 size(Stmp,1) size(Stmp,2) ...
     size(Stmp,3)]);
    phicoefs(nf,:,:,:) = Stmp;
end


    







