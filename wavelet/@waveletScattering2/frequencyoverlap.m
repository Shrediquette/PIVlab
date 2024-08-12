function tf = frequencyoverlap(res,gparams)
% This function is for internal use only. It may change or be removed in a
% future release. gparams is a structure array and we assume that it has
% fields psiftsupport and omegpsi.
% tf = waveletScattering.frequencyoverlap(res,gparams)
%
% Reference:
% Sathe, V.P. & Vaidyanathan, P.P. (1993) Effects of multirate systems
% on the statistical properties of random signals, IEEE Transactions on 
% Signal Processing, 41,1,pp.131-146

% For a discrete-time filter, $H(e^{j\omega})$, if the filter response has
% frequency support limited to an interval of width $\frac{2\pi}{M}$, you
% can downsample the filter impulse response by M without aliasing.
% In convdown, we will periodize the filter in the Fourier domain to
% downsample in time. We want to ensure that we don't have aliasing in the
% filter response. Because the signal has been downsampled by 2^res, if the
% frequency support multiplied by 2^(-res) does not exceed 2\pi, we can
% downsample

%   Copyright 2018-2020 The MathWorks, Inc.

psiftsupport = repelem(gparams.psiftsupport,numel(gparams.rotations));
tf = find(psiftsupport*2^(-res) < 2*pi);
