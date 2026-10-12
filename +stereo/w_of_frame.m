function w = w_of_frame(frame, smoothed, resultslist)
%W_OF_FRAME Out-of-plane component W of one frame of the result list (stereo-PIV).
%   w = stereo.w_of_frame(frame)            W of the frame [px per image pair, like u and v]
%   w = stereo.w_of_frame(frame, true)      the smoothed W if data smoothing made one, else W
%   w = stereo.w_of_frame(frame, smoothed, resultslist)   for a result list that is not in the GUI yet
% W is row 16 of the result list (stereo.update_result, mean frames: plot.temporal_operation_Callback),
% the smoothed W row 17 (plot.derivative_calc), like the smoothed u, v in rows 10 and 11.
% W is positive away from the cameras. Returns [] outside stereo mode or if the frame has no W.
w = [];
if nargin < 2
    smoothed = false;
end
if nargin < 3
    if ~isequal(gui.retr('stereomode'), 1)
        return
    end
    resultslist = gui.retr('resultslist');
end
if frame > size(resultslist, 2) || size(resultslist, 1) < 16
    return
end
if smoothed && size(resultslist, 1) >= 17 && ~isempty(resultslist{17, frame})
    w = resultslist{17, frame};
else
    w = resultslist{16, frame};
end
end
