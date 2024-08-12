function filters = gabor1Dfilters(self)
% This function is for internal use only. It may change or be removed in a
% future release.

%   Copyright 2018-2022 The MathWorks, Inc.

%#codegen

% Number of wavelet scattering filter banks
Nfb = numel(self.filterparams);
filters = cell(Nfb,1);
N = cast(self.paddedlength,self.Precision);
% Frequency grid from 0 to 2*pi*(N-1)/N
omega = (0:N-1).*(2*pi/N);
omega = omega(:);
gparams = self.filterparams;
for nc = 1:Nfb
    filters{nc} = struct('phift',zeros(N,1,'like',omega), ...
        'psift',zeros(N,numel(gparams{nc}.omegapsi),'like',omega));
end
for nl = 1:Nfb    
    sigmapsi = gparams{nl}.freqsigmapsi;
    varpsi = sigmapsi.*sigmapsi;
    sigmaphi = gparams{nl}.freqsigmaphi;
    varphi = sigmaphi*sigmaphi;
    nfilt = numel(gparams{nl}.omegapsi);
    psift = zeros(N,nfilt,'like',omega);
    cf = gparams{nl}.omegapsi;    
    for numf = 1:nfilt
        gaborpsif = exp(-(omega-cf(numf)).^2./(2*varpsi(numf)));
        psift(:,numf) = gaborpsif;        
        psift(:,numf) = ...
            MorletCorrection(psift(:,numf),omega,varpsi(numf));   
    end
    psift = normalizepsift(psift);
    filters{nl}.psift = psift;
    filters{nl}.phift = gaussian1d(omega,varphi);
end
%--------------------------------------------------------------------------
function psift = normalizepsift(psift)
% We want the scattering transform to be contractive
S = sum(abs(psift.*psift),2);
psiamp = sqrt(2/max(S));
psift = psiamp*psift;
%-------------------------------------------------------------------------
function psift = MorletCorrection(psift,omega,varpsi)
% Here we subtract off a correction term that is based on the nonzero value
% of the Gabor (Morlet) wavelet at \omega = 0 and decays quickly to zero as
% \omega increases.
DCterm = psift(1);
% Correction term for admissibility constant
correction_term = exp(-(omega.*omega)./(2*varpsi));
psift = psift-DCterm*correction_term;
%-------------------------------------------------------------------------
function phift = gaussian1d(omega,varphi)
Nomega = size(omega,1);
Nyquist = Nomega/2+1;
omega_half = omega(1:Nyquist);
phift_pos = exp(-omega_half.^2./(2*varphi));
phift_neg = flip(conj(phift_pos(2:Nyquist-1)));
phift = [phift_pos ; phift_neg];

