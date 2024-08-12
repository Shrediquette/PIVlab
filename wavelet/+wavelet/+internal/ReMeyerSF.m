function phif = ReMeyerSF(w1,gamma,w)
% Symmetric Meyer Scaling Function
% This function is for internal use only. It may change or be removed 
% phif = ReMeyerSF(w1,gamma,N)

%   Copyright 2020 The MathWorks, Inc.

%#codegen

% For even N, [-\pi, \pi)
N = length(w);
coder.internal.assert(w1(1) > 0 && w1(1) < pi,'Wavelet:ewt:ScalFreq');
% Work off absolute value of \omega for the real-valued case.
aw = abs(w);
phif = zeros(N,1,'like',w1);


% The following is \dfrac{1}{2\tau_n} for the \omega_n
cosL = (1-gamma)*w1;
cosU = (1+gamma)*w1;
mfac = 1/(2*gamma*w1);
% Provide hint for MATLAB coder to understand cosL and cosU are scalars.
cosw = (aw >= cosL(1) & aw <= cosU(1));
phif(aw <= cosL(1)) = 1;
phif(cosw) = cos(pi/2*meyeraux(mfac(1)*(aw(cosw)-cosL(1))));
phif = ifftshift(phif);




