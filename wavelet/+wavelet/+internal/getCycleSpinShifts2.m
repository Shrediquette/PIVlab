function shifts = getCycleSpinShifts2(numshifts)
% This function is for internal use only. It may change or be removed in a
% future release.
% shifts = getCycleSpinShifts2(numshifts);

%   Copyright 2018-2020 The MathWorks, Inc.

%#codegen

numshifts = numshifts+1;
[dX,dY,dZ] = meshgrid(0:numshifts-1,0:numshifts-1,0);
shifts = [dX(:) dY(:) dZ(:)]';
