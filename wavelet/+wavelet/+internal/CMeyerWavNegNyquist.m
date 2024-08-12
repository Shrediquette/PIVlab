function psif = CMeyerWavNegNyquist(w1,gamma,w)
% Complex-valued Meyer Wavelet
% This function is for internal use only. It may change or be removed in a
% future release.
%
% psif = CMeyerWavNeqNyquist(w1,gamma,w) returns the real-valued Meyer wavelet

% Copyright 2020 The MathWorks, Inc.

%#codegen

assert(w1 > -pi);
N = length(w);
psif = zeros(N,1,'like',w1);
aw = abs(w);
cosfac = 1/(2*gamma*abs(w1));
% gamma is positive
cosU = (1+gamma)*w1;
cosL = (1-gamma)*w1;
unitR = (w <= cosU(1));
cosR = (w > cosU(1) & w <= cosL(1));
psif(unitR) = 1;
meyerTerm = abs(cosfac(1)*(aw(cosR)-abs(cosU(1))));
psif(cosR) = cos(pi/2*meyeraux(meyerTerm));
psif = ifftshift(psif);


