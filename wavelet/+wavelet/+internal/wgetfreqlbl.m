function xlbl = wgetfreqlbl(xunits)
% This function is for internal use only. It may change or be removed in
% a future release.
% WGETFREQLBL Returns a label for the frequency axis.

%   Copyright 1988-2020 The MathWorks, Inc.

options = wavelet.internal.wgetfrequnitstrs;

xlbl = options{1};
for i = length(options):-1:1
    if strfind(options{i}, xunits)
        xlbl = options{i};
    end
end

% [EOF]
