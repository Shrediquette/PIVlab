function [phidft,phi,idx] = bumpscalingfunction(omega,idxNonzero)
% This function is for internal use only. It may change or be removed in a
% future release.
% [phidft,phi] = bumpscalingfunction(omega,scale)
%   Copyright 2021 The MathWorks, Inc.

%#codegen
coder.internal.assert(isscalar(idxNonzero),'Wavelet:codegeneration:SingleIdx');
coder.internal.assert(isrow(omega),'Wavelet:codegeneration:OmegaRowVector');
% For code generation
One = ones(1,1,'like',omega);
epsilon = eps(underlyingType(omega));
upperlim = min(omega(idxNonzero),1);
scaleFactor = exp(One);
expfctr = coder.nullcopy(zeros(size(omega),'like',omega));
if coder.target('matlab')
    idx = abs(omega) < upperlim-epsilon;
    expfctr(idx) = exp(-One./(One-omega(idx).^2));
else
    idx = idetermineIndices(omega,upperlim,epsilon);
    expfctr = idetermineScaling(expfctr,omega,idx,One);
end
phidft = scaleFactor*expfctr.*idx;
coder.internal.assert(all(isfinite(phidft)),'Wavelet:codegeneration:NoNanPhiDFT');
phi = ifftshift(ifft(phidft));

%--------------------------------------------------------------------------
function idx = idetermineIndices(omega,upperlim,epsilon)
% For code generation
N = numel(omega);
idx = coder.nullcopy(zeros(size(omega),'like',omega));
for ii = 1:N
    if abs(omega(ii)) < upperlim-epsilon
        idx(ii) = 1;
    else
        idx(ii) = 0;
    end
end

%--------------------------------------------------------------------------
function expfctr = idetermineScaling(expfctr,omega,idx,One)
% For code generation
N = numel(omega);
for ii = 1:N
    if idx(ii) > 0
        expfctr(ii) = exp(-One./(One-omega(ii)*omega(ii)));    
    end
end






