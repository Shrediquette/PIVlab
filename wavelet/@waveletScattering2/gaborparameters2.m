function gparams2 = gaborparameters2(self)
% This function is for internal use only. It may be changed or removed in a
% future release. This hidden method constructs the parameters to design a
% 2D Morlet wavelet filter bank for the scattering transform.

%   Copyright 2018-2020 The MathWorks, Inc.

% Quality factors as a vector
Q = self.QualityFactors;
% Number of filter banks is equal to the number of Q factors
nfb = numel(Q);
% T is the invariant in terms of samples. The invariant is square in the
% spatial domain since we are using symmetric scaling functions
T = self.InvarianceScale;
% Occupied BW for Gaussian as a probability.
OBW = self.OBW;
precision = self.Precision;
% Frequency support is symmetric in the spatial domain. The scaling
% function is symmetric
[freqsigmaphi,sigma_phi_ftsupport] = phi_invariant(T,OBW);
% Center frequency of highest-spatial frequency wavelet. Depends on Q
mother_omega = mwavcf(Q);
[~,freqsigmapsi] = QtoSigma(mother_omega,Q);
% Determine maximum J so that the wavelets do not exceed the spatial
% support of the scaling filter
J = convertTtoJ(Q,freqsigmapsi,freqsigmaphi);
self.J = J;

if self.EqualFB
    % If all the Q values are indentical, do not loop through again
    reptimes = nfb;
    nfb = 1;
    gparams2 = cell(nfb,1);
else
    gparams2 = cell(nfb,1);
end

for nl = 1:nfb
    gparams2{nl}.Q = Q(nl);
    gparams2{nl}.J = J(nl);
    gparams2{nl}.precision = precision;
    resolutions = 2.^((0:-1:1-J(nl))./Q(nl));
    gparams2{nl}.omegapsi = mother_omega(nl).*resolutions;
    % Frequency standard deviations
    gparams2{nl}.freqsigmapsi = ...
        freqsigmapsi(nl).*resolutions;
    gparams2{nl}.slant = freqsigmaphi/gparams2{nl}.freqsigmapsi(end);
    % Spatial standard deviations
    gparams2{nl}.spatialsigmapsi = 1./gparams2{nl}.freqsigmapsi;
    % Spatial standard deviation of scaling function
    gparams2{nl}.spatialsigmaphi = 1/freqsigmaphi;
    gparams2{nl}.freqsigmaphi = freqsigmaphi;
    % This gives the 3-dB bandwidth along one axis of the ellipse. In
    % frequency, the \omega_x is the most concentrated
    gparams2{nl}.psi3dBbw = 2*sqrt(3/10*log(10))*gparams2{nl}.freqsigmapsi;
    gparams2{nl}.psiftsupport = ...
        2*wavelet.internal.gaussianCriticalValue(OBW)*gparams2{nl}.freqsigmapsi;
    gparams2{nl} = linfreq(gparams2{nl});
    gparams2{nl}.phiftsupport = sigma_phi_ftsupport;
    gparams2{nl}.phi3dBbw = gparams2{nl}.psi3dBbw(end);
    gparams2{nl}.rotations = self.Theta{nl};
    
    
end

if self.EqualFB
    % For all identical Q values, replicate parameters the required number
    % of times
    gparams2 = repelem(gparams2,reptimes);
end

gparams2 = convert2table(gparams2);

%-------------------------------------------------------------------------
function gparams = linfreq(gparams)
% Return linearly spaced frequencies. These are used to ensure that the
% scale of the wavelet does not exceed the InvarianceScale

% The lowest frequency has a peak value 1/2 of its frequency
% support above DC

lowfreq = gparams.psiftsupport(end)/2;
df = gparams.psi3dBbw(end);
lowWav = gparams.omegapsi(end);
numlinfreq = floor((lowWav-lowfreq)/df);
if numlinfreq > 0
    linf = linspace(lowfreq,lowWav-df,numlinfreq);
    Nf = numel(linf);
    linf = flip(linf);
    gparams.omegapsi(end+1:end+Nf) = linf;
    gparams.spatialsigmapsi(end+1:end+Nf) = ...
        repelem(gparams.spatialsigmapsi(end),Nf);
    gparams.freqsigmapsi(end+1:end+numlinfreq) = ...
        repelem(gparams.freqsigmapsi(end),Nf);
    gparams.psi3dBbw(end+1:end+Nf) = ...
        repelem(gparams.psi3dBbw(end),Nf);
    gparams.psiftsupport(end+1:end+Nf) = ...
        repelem(gparams.psiftsupport(end),Nf);
end


%-------------------------------------------------------------------------
function [freqsigmaphi,freqsupport] = phi_invariant(T,prob)

% prob is currently fixed at 0.995, this will yield 0.99 probability on
% the N(0,1) density for $P(-z_\tfrac{\alpha/2} \leq Z \leq
% z_\tfrac{\alpha/2})$

% Frequency standard deviation
cv = wavelet.internal.gaussianCriticalValue(prob);
spsigmaphi = T/(2*cv);
% frequency standard deviation
freqsigmaphi = 1/spsigmaphi;
% frequency support of scaling filter
freqsupport = 2*cv*freqsigmaphi;

%-----------------------------------------------------------------------
function [sigma_psi,sigma_psi_omega] = QtoSigma(mother_omega,Q)
% 3-dB factor
factor = 1./sqrt(3/10*log(10));
% frequency standard deviation for wavelets
sigma_psi_omega = mother_omega.*(1-2.^(-1./Q))./(1+2.^(-1./Q)).*factor;
% spatial standard deviation
sigma_psi = 1./sigma_psi_omega;

%-------------------------------------------------------------------------
function cf = mwavcf(Q)
% When Q = 1, we obtain a center frequency which is the arithmetic mean of
% pi/2 and pi.

% As Q \rightarrow \infty, the center frequency of the wavelet will tend to
% \pi.
cf = 1/2*(1+2.^(-1./Q))*pi;

%-------------------------------------------------------------------------
function J = convertTtoJ(Q,sigmapsi,sigmaphi)
% Convert T which is the scale of the invariance to a J.
% sigmapsi and sigmaphi here are frequential sigmas.

% Initialize J
J = zeros(size(Q));
qdyad = find(Q == 1);
if ~isempty(qdyad)
    % Q in the following should be unity, so we can omit Q
    % ceil() is appropriate here because the resolutions are going to J-1.
    J(qdyad) = ceil(log2(sigmapsi(qdyad))-log2(sigmaphi));
end
J(Q>1) = ...
    floor(Q(Q>1).*(log2(sigmapsi(Q>1))-log2(sigmaphi)));

% Prevent negative resolution. This could be expressed as J < 1 but because
% J is forced to be an integer here, J < 1 and J<=0 are equivalent
% conditions
if any(J <= 0)
    error(message('Wavelet:scattering:negativeresolution'));
    
end

%--------------------------------------------------------------------------
function tables = convert2table(cell_of_structures)
% Create MATLAB tables from structure arrays
tables = cell(numel(cell_of_structures),1);
for nL = 1:numel(cell_of_structures)
    tables{nL} = struct2table(cell_of_structures{nL});
end
