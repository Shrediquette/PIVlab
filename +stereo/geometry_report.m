function [lines, info] = geometry_report(calib)
%GEOMETRY_REPORT Short description of the stereo set-up (for "Show 3D setup" of the Stereo-PIV panel).
%   [lines, info] = stereo.geometry_report(calib)
%   lines  cellstr for the GUI; info: the numbers (angles [deg], distances [mm], overlap [%])
% Viewing angle of camera k: angle between its line of sight to the centre of the overlap and the
% board normal. The out-of-plane component W is measured through the angle between both lines of
% sight (as lines, 0..90 deg: cameras on opposite sides of the sheet that look along the same line
% can not measure W). info.w_error_ratio: random error of W relative to that of U and V at the centre
% of the overlap (least-squares solution of stereo.reconstruct, same error in all four camera components).
[cx, cy] = centroid(calib.grid_info.overlap);
centre = [cx, cy, 0];
sight = zeros(2, 3);
info.view_angle = [0 0];
info.distance = [0 0];
A = zeros(4, 3);
for k = 1:2
    v = centre - calib.centre(k, :);
    info.distance(k) = norm(v);
    sight(k, :) = v / norm(v);
    info.view_angle(k) = acosd(abs(sight(k, 3)));
    D = -calib.centre(k, 3);
    ta = (cx - calib.centre(k, 1)) / D;
    tb = (cy - calib.centre(k, 2)) / D;
    A(2 * k - 1, :) = [1 0 -ta];
    A(2 * k, :) = [0 1 -tb];
end
info.stereo_angle = acosd(min(1, abs(dot(sight(1, :), sight(2, :)))));
N = A' * A;
if rcond(N) < 1e-12
    info.w_error_ratio = Inf; % both lines of sight along one line: W can not be measured
else
    covariance = inv(N);
    info.w_error_ratio = sqrt(covariance(3, 3) / mean([covariance(1, 1), covariance(2, 2)]));
end
info.opposite_sides = stereo.opposite_sides(calib);
areas = [area(calib.grid_info.views{1}), area(calib.grid_info.views{2})];
info.overlap = 100 * area(calib.grid_info.overlap) / min(areas);
info.mm_per_px = calib.Ravg.PixelExtentInWorldX;
info.grid = calib.Ravg.ImageSize;
info.n_rejected = calib.n_rejected;
info.n_corners = [size(calib.image_points{1}, 1), size(calib.image_points{2}, 1)];
lines = {};
lines{end + 1} = sprintf('Viewing angle: camera 1 %.0f%s, camera 2 %.0f%s', info.view_angle(1), char(176), info.view_angle(2), char(176));
lines{end + 1} = sprintf('Angle between the cameras: %.0f%s', info.stereo_angle, char(176));
if info.opposite_sides
    lines{end + 1} = 'Cameras on opposite sides of the light sheet';
end
if isfield(calib, 'board_from_behind') && any(calib.board_from_behind)
    behind = find(calib.board_from_behind);
    if numel(behind) == 2
        lines{end + 1} = 'Both cameras see the board from behind (mirrored)';
    else
        lines{end + 1} = sprintf('Camera %d sees the board from behind (mirrored)', behind);
    end
end
lines{end + 1} = sprintf('Distance to the sheet: %.0f mm / %.0f mm', info.distance(1), info.distance(2));
lines{end + 1} = sprintf('Common image: %d x %d px, %.4f mm/px', info.grid(2), info.grid(1), info.mm_per_px);
lines{end + 1} = sprintf('Overlap of the views: %.0f %%', info.overlap);
lines{end + 1} = sprintf('Board corners: %d / %d (rejected %d / %d)', info.n_corners(1), info.n_corners(2), info.n_rejected(1), info.n_rejected(2));
if isfinite(info.w_error_ratio)
    lines{end + 1} = sprintf('Random error of W: about %.1f x that of U and V', info.w_error_ratio);
end
lines{end + 1} = sprintf('W is positive %s', stereo.w_direction(calib));
if info.stereo_angle < 20
    lines{end + 1} = 'Warning: small angle between the cameras, W will be inaccurate.';
end
end
