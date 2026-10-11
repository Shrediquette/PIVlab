function plot_setup(ax, calib, disparity)
%PLOT_SETUP Both cameras, the board corners, the views of the cameras and the light sheet in 3D.
%   stereo.plot_setup(ax, calib)
%   stereo.plot_setup(ax, calib, disparity)
%   ax         axes to draw into
%   calib      stereo.calibrate
%   disparity  stereo.measure_disparity (optional): the light sheet position (stereo.sheet_position)
% World coordinates = board coordinates in mm (x right, y down, z into the board). The view looks from
% behind the cameras onto the board; rotate it with the mouse (cameratoolbar 'orbit').
hold(ax, 'on');
wp = calib.world_points{1};
plot3(ax, wp(:, 1), wp(:, 2), zeros(size(wp, 1), 1), '.', 'Color', [0.55 0.55 0.55], 'DisplayName', 'board corners');
[ox, oy] = boundary(calib.grid_info.overlap);
fill3(ax, ox, oy, zeros(size(ox)), [0.35 0.8 0.35], 'FaceAlpha', 0.35, 'EdgeColor', [0.2 0.6 0.2], 'DisplayName', 'overlap of both views');
[cx, cy] = centroid(calib.grid_info.overlap);
target = [cx cy 0];
distance = mean([norm(calib.centre(1, :) - target), norm(calib.centre(2, :) - target)]);
for k = 1:2
    [cam_color, ~] = stereo.camera_colors(k);
    [vx, vy] = boundary(calib.grid_info.views{k});
    plot3(ax, vx, vy, zeros(size(vx)), '-', 'Color', cam_color, 'LineWidth', 1.5, 'DisplayName', sprintf('view of camera %d', k));
    plot3(ax, [calib.centre(k, 1) cx], [calib.centre(k, 2) cy], [calib.centre(k, 3) 0], '--', 'Color', cam_color, 'HandleVisibility', 'off');
    plotCamera(AbsolutePose=extr2pose(calib.extrinsics{k}), Size=0.05 * distance, Color=cam_color, ...
        Label=sprintf('Camera %d', k), AxesVisible=false, Parent=ax);
end
plot3(ax, 0, 0, 0, 'g*', 'DisplayName', 'board origin');
if nargin >= 3 && ~isempty(disparity)
    sheet = stereo.sheet_position(calib, disparity);
    surf(ax, sheet.x, sheet.y, sheet.z, 'FaceColor', [1 0.85 0.2], 'FaceAlpha', 0.45, 'EdgeColor', 'none', ...
        'DisplayName', sprintf('light sheet (%+.2f mm, from the disparity)', sheet.offset));
end
axis(ax, 'equal');
axis(ax, 'tight');
grid(ax, 'on');
xlabel(ax, 'X (mm)');
ylabel(ax, 'Y (mm)');
zlabel(ax, 'Z (mm)');
legend(ax, 'Location', 'northeast');
v1 = target - calib.centre(1, :);
v2 = target - calib.centre(2, :);
title(ax, sprintf('Angle between the cameras: %.0f%s', acosd(dot(v1, v2) / (norm(v1) * norm(v2))), char(176)));
% look from behind and slightly above the cameras onto the centre of the overlap
behind = mean(calib.centre, 1) - target;
camproj(ax, 'perspective');
set(ax, 'CameraTarget', target, 'CameraPosition', target + 2.2 * behind + [0 -0.9 * distance 0], 'CameraUpVector', [0 -1 0]);
end
