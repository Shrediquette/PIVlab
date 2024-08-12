function gparams = gaborparameters(self)
% This function is for internal use only. It may change or be removed in a
% future release.
% This method returns the parameters for the Gabor (Morlet) wavelet filters
% used in the scattering decomposition. The filter bank parameters are
% returned as a cell array of MATLAB tables.

%   Copyright 2018-2022 The MathWorks, Inc.

%#codegen
Q = self.QualityFactors;
boundary = self.Boundary;
% T is the invariant in terms of samples
T = self.T;
% Occupied BW for Gaussian
OBW = self.OBW;
[freqsigmaphi,phiftsupport] = phi_invariant(T,OBW);
% The following is a scalar
sigmaphi = 1/freqsigmaphi;
mother_omega = mwavcf(Q);
[~,freqsigmapsi] = QtoSigma(mother_omega,Q);
coder.internal.errorIf(any(freqsigmapsi < freqsigmaphi),...
    'Wavelet:scattering:sigmapsitoosmall');
J = convertTtoJ(Q,freqsigmapsi,freqsigmaphi);
% Number of filter banks
nfb = numel(Q);
gparams = cell(nfb,1);

for nl = 1:nfb
    % Scalar, won't change.
    tmpJ = J(nl);
    resolutions = 2.^((0:-1:1-J(nl))./Q(nl));
    fpsilog = mother_omega(nl).*resolutions;
    Nlogf = numel(fpsilog);
    fsigmapsilog = ...
        freqsigmapsi(nl).*resolutions;
    minsigmapsi = fsigmapsilog(Nlogf);
    phi3dBbw = ...
        2*sqrt(3/10*log(10))*freqsigmaphi;
    tmp3dBlog = ...
        2*sqrt(3/10*log(10))*fsigmapsilog;
    psiftsuplog = ...
        2*wavelet.internal.gaussianCriticalValue(OBW)*fsigmapsilog;
    minpsiftsup = psiftsuplog(Nlogf);
    % 3-dB frequency for \hat{\phi}(\omega) + \hat{\psi}(\omega)
    lowWav = (freqsigmaphi+minsigmapsi)*sqrt(3/10*log(10));
    df = tmp3dBlog(Nlogf);
    linf = lowWav:df:fpsilog(Nlogf)-df;
    if isempty(linf)
        linf = lowWav;
    end
    if ~isempty(linf) 
        Nlinf = numel(linf);
        linf = flip(linf);
        fpsilin = linf;
        fsigmapsilin = repelem(minsigmapsi,Nlinf);
        tmp3dBlin = repelem(minsigmapsi*2*sqrt(3/10*log(10)),Nlinf);
        psiftsuplin = repelem(minpsiftsup,Nlinf);
    else
        fpsilin = zeros(1,0,'like',fpsilog);
        fsigmapsilin = zeros(1,0,'like',fpsilog);
        tmp3dBlin = zeros(1,0,'like',fpsilog);
        psiftsuplin = zeros(1,0,'like',fpsilog);
    end
    fpsi = cat(2,fpsilog,fpsilin);
    fsigmapsi = cat(2,fsigmapsilog,fsigmapsilin);
    tsigmapsi = 1./fsigmapsi;
    tmp3dB = cat(2,tmp3dBlog,tmp3dBlin);
    psiftsup = cat(2,psiftsuplog,psiftsuplin);
    tmpQ = Q(nl);
    psilog2ds = round(log2((2*pi)./psiftsup));
    philog2ds = round(log2((2*pi)./phiftsupport));
    gparams{nl} = table(tmpQ,tmpJ,{boundary},{self.Precision},fpsi,fsigmapsi,...
        tsigmapsi,sigmaphi,freqsigmaphi,tmp3dB,psiftsup,...
        phiftsupport,phi3dBbw, psilog2ds,philog2ds,'VariableNames',...
        {'Q','J','boundary','precision','omegapsi','freqsigmapsi','timesigmapsi',...
            'sigmaphi','freqsigmaphi','psi3dBbw','psiftsupport',...
            'phiftsupport','phi3dBbw','psilog2ds','philog2ds'});
end

%-------------------------------------------------------------------------
function J = convertTtoJ(Q,sigmapsi,sigmaphi)
% Convert T which is the scale of the invariance to a J.
% sigmapsi and sigmaphi here are frequential sigmas.
sigmapsi(sigmapsi < sigmaphi) = ...
    sigmaphi+eps(ones(1,1,'like',sigmapsi));
J = floor(Q.*(log2(sigmapsi)-log2(sigmaphi)));
coder.internal.errorIf(any(J < 1),...
    'Wavelet:scattering:negativeresolution');
%-----------------------------------------------------------------------
function [sigma_psi,sigma_psi_omega] = QtoSigma(mother_omega,Q)
% 3-dB factor. Here when we take the magnitude squared of the Fourier
% transform of the psi filters, we want the point where the
% magnitude-squared falls off by 3-db.
factor = 1./sqrt(3/10*log(10));
% frequency standard deviation for wavelets
sigma_psi_omega = mother_omega.*(1-2.^(-1./Q))./(1+2.^(-1./Q)).*factor;
% Time standard deviation
sigma_psi = 1./sigma_psi_omega;
%-------------------------------------------------------------------------
function [sigma_phi,freqsupport] = phi_invariant(T,prob)
% Frequency standard deviation
cv = wavelet.internal.gaussianCriticalValue(prob);
timesigmaphi = T/(2*cv);
% frequency standard deviation
sigma_phi = 1/timesigmaphi;
% frequency support of scaling filter
freqsupport = 2*cv*sigma_phi;
%-------------------------------------------------------------------
function cf = mwavcf(Q)
% The highest wavelet center frequency (\omega_{\psi}) is the geometric
% mean of the next lower frequency, 2^{-1/Q}\omega_{\psi}, for a given Q
% factor and the mirror image across the Nyquist (2\pi-omega_{\psi}).
cf = 2*pi./(1+2.^(1./Q));





