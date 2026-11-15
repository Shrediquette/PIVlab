function [positive, negative] = w_direction(calib, calw)
%W_DIRECTION Direction of positive w in words (reports, W display, exports).
%   [positive, negative] = stereo.w_direction(calib, calw)
%   calw: factor from W in px to w in the user's units (calibrate.w_factor). w is positive along
%   z = x cross y. Without calw: the W of the reconstruction (image coordinates x right, y down, z away
%   from camera 1). With both cameras on the same side of the light sheet "camera 1" is "the cameras".
% calib = [] gives the same-side text.
if ~isempty(calib) && stereo.opposite_sides(calib)
    away = 'away from camera 1';
    toward = 'toward camera 1';
else
    away = 'away from the cameras';
    toward = 'toward the cameras';
end
if nargin < 2 || calw > 0
    positive = away;
    negative = toward;
else
    positive = toward;
    negative = away;
end
end
