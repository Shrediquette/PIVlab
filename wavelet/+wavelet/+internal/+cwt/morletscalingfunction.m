function [phidft,phi] = morletscalingfunction(omega,scale)
% MATLAB scales incomplete gamma function by 1/\gamma(\alpha)
% phidft = morsescalingfunction(ga,be,omega,scale)

%   Copyright 2017-2020 The MathWorks, Inc.

%#codegen

coder.internal.assert(isscalar(scale),'Wavelet:codegeneration:SingleScale');
coder.internal.assert(isrow(omega),'Wavelet:codegeneration:OmegaRowVector');
fun = @(om)exp(-(om-6).^2)./om;
phidft = zeros(size(omega));
posfreq = scale.*omega(omega>0);
for kk = 1:numel(posfreq)
    phidft(kk) = morletintegral(fun,posfreq(kk));
end
ampdc = phidft(1);
phidft = phidft./ampdc;

phi = ifftshift(ifft(phidft));




%-------------------------------------------------------------------------
function val = morletintegral(fun,omega)
% integral() not supported for codegen
%val = integral(fun,omega,Inf);
val = quadgk(fun,omega,Inf);
