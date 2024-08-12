function psif = CMeyerWav(w1,w2,gamma,w)
% Real-valued Meyer Wavelet
% This function is for internal use only. It may change or be removed in a
% future release.
%
% psif = CMeyerWav(w1,w2,gamma,w) returns the real-valued Meyer wavelet

% Copyright 2020 The MathWorks, Inc.

%#codegen

coder.internal.assert(w2 > w1,'Wavelet:ewt:IncreasingFreq');
assert(w2 > w1);
N = length(w);
psif = zeros(N,1,'like',w1);
aw = abs(w);
sinfac = 1/(2*gamma*abs(w1));
cosfac = 1/(2*gamma*abs(w2));
sinU = (1+gamma)*w1;
sinL = (1-gamma)*w1;
cosU = (1+gamma)*w2;
cosL = (1-gamma)*w2;
if w1 < 0 && w2 <0
    unitR = w >= sinL & w <= cosU;
    sinR = w >= sinU & w < sinL;
    cosR = w > cosU & w <= cosL;
    meyerSine = abs(sinfac*(aw(sinR)-abs(sinU(1))));
    meyerCos = abs(cosfac*(aw(cosR)-abs(cosU(1))));
elseif w1 < 0 && w2 > 0
    unitR = w>= sinL & w <= cosL;
    sinR = w >= sinU & w < sinL;
    cosR = w > cosL & w <= cosU;
    meyerSine = abs(sinfac*(aw(sinR)-abs(sinU(1))));
    meyerCos = cosfac*(aw(cosR)-cosL(1));
else
    unitR = w >= sinU & w <= cosL;
    sinR = w >= sinL & w < sinU;
    cosR = w > cosL & w <= cosU;
    meyerSine = sinfac*(aw(sinR)-sinL(1));
    meyerCos = cosfac*(aw(cosR)-cosL(1));
end
psif(unitR) = 1;
psif(sinR) = sin(pi/2*meyeraux(meyerSine));
psif(cosR) = cos(pi/2*meyeraux(meyerCos));
psif = ifftshift(psif);



