function [log2_phi_os, log2_psi_os] = ...
    log2DecimationFactor(gparams,resolution,overSampleFactor,validwav)
% This function is for internal use only. It may change or be removed in a
% future release.

%   Copyright 2018-2022 The MathWorks, Inc.

% Total bandwidth of discrete-time signal. For us this will always be 2\pi
% because downsampling a discrete-time signal always creates a full-band
% signal.

%#codegen
totbw = 2*pi;
full = overSampleFactor == -Inf;
if full && nargin > 3
    log2_psi_os = zeros(size(validwav));
    log2_phi_os = 0;
    return;
end    
log2_phi_os = ...
        round(log2(totbw/gparams.phiftsupport)) + ...
        resolution - overSampleFactor;
log2_phi_os = max(log2_phi_os,0);

if nargin == 4    
    log2_psi_os = ...
        round(log2(totbw./(gparams.psiftsupport(:,validwav)))) ...
        + resolution - overSampleFactor;
    log2_psi_os = max(log2_psi_os,0);
end



