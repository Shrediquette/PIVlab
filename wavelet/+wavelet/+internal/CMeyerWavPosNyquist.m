function psif = CMeyerWavPosNyquist(w1,gamma,w)
% Complex-valued Meyer Wavelet
% This function is for internal use only. It may change or be removed in a
% future release.
%
% psif = CMeyerWavPosNyquist(w1,gamma,w) 

% Copyright 2020 The MathWorks, Inc.

%#codegen

coder.internal.assert(w1 < pi,'Wavelet:ewt:LessthanPosPi');
N = length(w);
psif = zeros(N,1,'like',w1);
aw = abs(w);
sinfac = 1/(2*gamma*abs(w1));
% gamma is positive
sinL = (1-gamma)*w1;
sinU = (1+gamma)*w1;
unitR = w >= sinU & w <= pi;
sinR = w >= sinL & w < sinU;
psif(unitR) = 1;
psif(sinR) = sin(pi/2*meyeraux(sinfac*(aw(sinR)-sinL)));
psif = ifftshift(psif);

