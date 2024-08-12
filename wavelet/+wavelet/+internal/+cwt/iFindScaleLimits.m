function [idx1,idx2] = iFindScaleLimits(f,flim,TFfreq)
% [idxL,idxU] = iFindScaleLimits(f,flim)
% [idxL,idxU] = iFindScaleLimits(f,[0.1 0.4])
% [idxL,idxU] = iFindScaleLimits(p,[seconds(10) seconds(100)]);

%   Copyright 2020 The MathWorks, Inc.

%#codegen
if TFfreq
    idx1 = find(f >= flim(1),1,'last');
    idx2 = find(f <= flim(2),1,'first');
else
    % This will be a duration vector
    idx1 = find(f >= flim(1),1,'first');
    idx2 = find(f <= flim(2),1,'last');
end


coder.internal.assert(~isempty(idx1) && ~isempty(idx2 ),...
    'Wavelet:cwt:EmptyScaleLimits');




