function validwav = optimizePath(validwav,current3dB,gparams)
% This function is for internal use only. It may change or be removed in a 
% a future release.
% validwav = optimizePath(validwav,current3dB,gparams)

%  Copyright 2018-2022 The MathWorks, Inc.
%#codegen
halfpsi3db = gparams.omegapsi-gparams.psi3dBbw./2;
tf = find(halfpsi3db < current3dB/2);
validwav = intersect(validwav,tf);

