function [U_phi,U_psi,psires,psi3dB] = forward(self,U,res,threedB,nfb)
% This function is for internal use only. It may change or be removed in
% a future release.

%   Copyright 2018-2022 The MathWorks, Inc.

%#codegen
Nchan = size(U{1},2);
Nbatch = size(U{1},3);
coder.varsize('U_phi');
phids = max(self.filterparams{nfb}.philog2ds-self.OversamplingFactor,0);
Ncfs = floor(self.paddedlength/2^phids);
U_phi = zeros(0,Ncfs,Nchan,Nbatch,'like',U{1});
coder.varsize('psicfs');
coder.varsize('tmpres');
coder.varsize('tmp3dB');
npaths = self.npaths;
numpaths = npaths(nfb+1);
psicoefs = zeros(0,Nchan,Nbatch,'like',U{1});
psicfs = repmat({psicoefs},numpaths,1);
psires = coder.nullcopy(zeros(numpaths,1));
psi3dB = coder.nullcopy(zeros(numpaths,1));

startidx = 1;
for kk = 1:length(U)
    % Determine which wavelet filters are used in scattering transform
    validwav = waveletScattering.frequencyoverlap(res(kk),...
        self.filterparams{nfb});
    if self.OptimizePath
        validwav = waveletScattering.optimizePath(validwav,threedB(kk),...
            self.filterparams{nfb});
    end
    [phicoefs,psicoefs,tmpres,tmp3dB] = self.wt1d(U{kk},res(kk),validwav,nfb);
    U_phi = [U_phi; phicoefs]; %#ok<AGROW>
    if ~isempty(validwav)
        endidx = startidx+numel(validwav)-1;
        for jj = startidx:endidx
            psicfs{jj} = psicoefs{jj-startidx+1};
        end
        psires(startidx:startidx+numel(validwav)-1) = tmpres;
        psi3dB(startidx:startidx+numel(validwav)-1) = tmp3dB;
        startidx = startidx+numel(validwav);
    end
end
U_psi = psicfs;











