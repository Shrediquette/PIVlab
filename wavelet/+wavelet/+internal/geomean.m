function gm = geomean(x,dim)
% This function is for internal use only. It may change or be removed in a
% future release.
% gm = wavelet.internal.geomean(x,2);

%   Copyright 2020 The MathWorks, Inc.

%#codegen 
gm = exp(mean(log(x),dim));
