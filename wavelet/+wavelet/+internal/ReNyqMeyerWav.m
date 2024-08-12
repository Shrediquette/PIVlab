function psif = ReNyqMeyerWav(wn,gamma,w)
% Real-valued Meyer Wavelet to Nyquist
% This function is for internal use only. It may change or be removed in a
% future release.
%
% psif = ReNyqMeyerWav(wn,gamma,N) returns the EWT Meyer wavelet which is
% equal to 1 from (1+\gamma) wn to the Nyquist. The wavelet increases
% toward 1 from (1-\gamma) wn. wn should be strictly less than \pi.

% Copyright 2020 The MathWorks, Inc.

%#codegen 

coder.internal.assert(wn < pi,'Wavelet:ewt:LessthanPosPi');
N = length(w);
aw = abs(w);
psif = zeros(N,1);
unitreg = (1+gamma)*wn;
sL = (1-gamma)*wn;
sinR = aw >= sL & aw < unitreg;
sinfac = 1/(2*gamma*wn);
psif(aw >= unitreg) = 1;
psif(sinR) = sin(pi/2*meyeraux(sinfac*(aw(sinR)-sL(1))));
psif = fftshift(psif);


