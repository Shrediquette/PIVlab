function [phidft,phi] = morsescalingfunction(ga,be,omega,scale)
% MATLAB scales incomplete gamma function by 1/\gamma(\alpha)
% phidft = morsescalingfunction(ga,be,omega,scale)
%Abg = wavelet.internal.morsenormconstant(ga,be);
%cpsi = wavelet.internal.admConstant('morse',[ga be]);
%factor = Abg*gamma(2*be/ga)*1/(2*ga)*(1/2)^((2*be/ga)-1);

%   Copyright 2017-2020 The MathWorks, Inc.
%#codegen


coder.internal.prefer_const(ga);
coder.internal.prefer_const(be);
coder.internal.assert(isrow(omega),'Wavelet:codegeneration:OmegaRowVector');
coder.internal.assert(isscalar(scale),'Wavelet:codegeneration:SingleScale');
omega = 2*(scale*omega).^ga;
phidft = zeros(size(omega));
% For code generation output of gammainc is always complex
phidft(omega >= 0.0) = real(gammainc(omega(omega>=0),2*be/ga,'upper'));
phi = ifftshift(ifft(phidft));


