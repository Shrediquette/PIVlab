function coi = morseroi(N,tb,Fs)
% This function is for internal use only, it may change or be removed in a
% future release.

%   Copyright 2017-2020 The MathWorks, Inc.

ga = 3;
be = tb/3;
FourierFactor = (2*pi)/wavelet.internal.cwt.morsepeakfreq(ga,be);
[~,~,~,sigmaPsi,~] = wavelet.internal.cwt.morseproperties(ga,be);
coi = FourierFactor/sigmaPsi;
