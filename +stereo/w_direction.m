function [away, toward] = w_direction(calib)
%W_DIRECTION Direction of positive W in words (reports, W display, exports).
%   [away, toward] = stereo.w_direction(calib)
% W is positive away from camera 1 (into the board as seen from camera 1). With both cameras on the
% same side of the light sheet this is "away from the cameras". calib = [] gives the same-side text.
if ~isempty(calib) && stereo.opposite_sides(calib)
    away = 'away from camera 1';
    toward = 'toward camera 1';
else
    away = 'away from the cameras';
    toward = 'toward the cameras';
end
end
