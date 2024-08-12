function validwav = optimizePath(validwav,current3dB,gparams)
% This function is for internal use only. It may change or be removed in a 
% a future release.
% validwav = optimizePath(validwav,current3dB,gparams)

%  Copyright 2018-2020 The MathWorks, Inc.



if gparams.Q == 1
    halfpsi3db = repelem(gparams.omegapsi-gparams.psi3dBbw/2,numel(gparams.rotations));
    tf = find(halfpsi3db < current3dB);
elseif gparams.Q ~= 1
       psi3db = repelem(gparams.omegapsi-gparams.psi3dBbw,numel(gparams.rotations));
    tf = find(psi3db < current3dB);
end
validwav = intersect(validwav,tf);

