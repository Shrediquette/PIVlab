function cfs = complexToScalogram(cfs,type)
% This function is for internal use only. It may change or be removed in a
% future release.

%   Copyright 2021 The MathWorks, Inc.

if startsWith(type,'m')
    cfs = abs(cfs);
else
    cfs = conj(cfs).*cfs;
end
