function [lines, info] = geometry_report(calib)
%GEOMETRY_REPORT Short description of the stereo set-up (for the Stereo-PIV panel).
%   [lines, info] = stereo.geometry_report(calib)
%   lines  cellstr for the GUI; info: the numbers (angles [deg], distances [mm], overlap [%])
% Viewing angle of camera k: angle between its line of sight to the centre of the overlap and the
% board normal. The out-of-plane component W is measured through the angle between both lines of
% sight: its error grows like 1/tan of the half angle.
[cx, cy] = centroid(calib.grid_info.overlap);
centre = [cx, cy, 0];
sight = zeros(2, 3);
info.view_angle = [0 0];
info.distance = [0 0];
for k = 1:2
    v = centre - calib.centre(k, :);
    info.distance(k) = norm(v);
    sight(k, :) = v / norm(v);
    info.view_angle(k) = acosd(abs(sight(k, 3)));
end
info.stereo_angle = acosd(max(-1, min(1, dot(sight(1, :), sight(2, :)))));
areas = [area(calib.grid_info.views{1}), area(calib.grid_info.views{2})];
info.overlap = 100 * area(calib.grid_info.overlap) / min(areas);
info.mm_per_px = calib.Ravg.PixelExtentInWorldX;
info.grid = calib.Ravg.ImageSize;
info.n_rejected = calib.n_rejected;
info.n_corners = [size(calib.image_points{1}, 1), size(calib.image_points{2}, 1)];
lines = {};
lines{end + 1} = sprintf('Viewing angle: camera 1 %.0f%s, camera 2 %.0f%s', info.view_angle(1), char(176), info.view_angle(2), char(176));
lines{end + 1} = sprintf('Angle between the cameras: %.0f%s', info.stereo_angle, char(176));
lines{end + 1} = sprintf('Distance to the sheet: %.0f mm / %.0f mm', info.distance(1), info.distance(2));
lines{end + 1} = sprintf('Common image: %d x %d px, %.4f mm/px', info.grid(2), info.grid(1), info.mm_per_px);
lines{end + 1} = sprintf('Overlap of the views: %.0f %%', info.overlap);
lines{end + 1} = sprintf('Board corners: %d / %d (rejected %d / %d)', info.n_corners(1), info.n_corners(2), info.n_rejected(1), info.n_rejected(2));
if info.stereo_angle < 20
    lines{end + 1} = 'Warning: small angle between the cameras, W will be inaccurate.';
end
end
