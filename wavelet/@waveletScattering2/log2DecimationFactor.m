function [log2_phi_os, log2_psi_os] = ...
    log2DecimationFactor(gparams,resolution,OSFactor,validwav)
% This function is for internal use only. It may change or be removed in a
% future release.

%   Copyright 2018-2020 The MathWorks, Inc.

% Total bandwidth of discrete-space image. For us this will always be 2\pi
% because downsampling a discrete-space image always creates a full-band
% image.
%
% The frequency support of the discrete-space image is taken along the
% \omega_1-axis because that will always be the axis of most frequency
% variance
totbw = 2*pi;

if nargin > 3 
    psiftsupport = repelem(gparams.psiftsupport,numel(gparams.rotations));
    log2_psi_os = ...
        round(log2(totbw./psiftsupport(validwav))) + resolution-OSFactor;
    log2_psi_os = max(log2_psi_os,0);

end

log2_phi_os = ...
        round(log2(totbw/gparams.phiftsupport)) + resolution-OSFactor;
log2_phi_os = max(log2_phi_os,0);
    

