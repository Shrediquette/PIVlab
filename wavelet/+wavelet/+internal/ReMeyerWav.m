function psif = ReMeyerWav(w1,w2,gamma,w)
% Real-valued Meyer Wavelet
% This function is for internal use only. It may change or be removed in a
% future release.
%
% psif = ReMeyerWav(w1,w2,gamma,w) returns the real-valued Meyer wavelet

% Copyright 2020 The MathWorks, Inc.

%#codegen

coder.internal.assert(w2 > w1,'Wavelet:ewt:IncreasingFreq');
aw = abs(w);
N = length(w);
psif = zeros(N,1,'like',w1);
sinL = (1-gamma)*w1;
sinU = (1+gamma)*w1;
cosL = (1-gamma)*w2;
cosU = (1+gamma)*w2;
sinfac = 1/(2*gamma*w1);
cosfac = 1/(2*gamma*w2);
unitR = aw >= sinU & aw <= cosL;
cosR = aw > cosL & aw <= cosU;
sinR = aw >= sinL & aw < sinU;

psif(unitR) = 1;
psif(cosR) = cos(pi/2*meyeraux(cosfac*(aw(cosR)-cosL(1))));
psif(sinR) = sin(pi/2*meyeraux(sinfac*(aw(sinR)-sinL(1))));

psif = ifftshift(psif);




