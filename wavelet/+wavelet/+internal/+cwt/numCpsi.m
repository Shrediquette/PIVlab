function cpsi = numCpsi(wname,varargin)
% This function is for internal use only. It may change or be removed in a
% future release.
%
% This computes an approximation to the integral 
% \int_{0}^{\infty} \dfrac{|\hat{\psi}(\omega)|^2}{\omega}
% quadgk needed here because integral() does not support code generation.

%   Copyright 2020 The MathWorks, Inc.

% Copyright, The MathWorks, 2020

%#codegen
validwav = {'morse','amor','bump'};
wavname = validatestring(wname,validwav,'numCpsi','wname');
ga = varargin{1};
be = varargin{2};
anorm = wavelet.internal.cwt.morsenormconstant(ga,be);
if strcmpi(wavname,'morse')
    cpsi = anorm^2/(2*ga).*(1/2)^(2*(be/ga)-1)*gamma(2*be/ga);
elseif strcmpi(wavname,'amor')
    fc = 6;
    psidft = @(om)2*exp(-(om-fc).^2)./om;
    cpsi = quadgk(psidft,0,Inf);
else
    mu = 5;
    sigma = 0.6;
    bumpwav = @(w)abs(2*exp(2)*exp(-2*(1./(1-((w-mu)/sigma).^2))))./w;
    cpsi = quadgk(bumpwav,mu-sigma,mu+sigma);

end



