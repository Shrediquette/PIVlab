function plot_setup(ax, calib, disparity)
%PLOT_SETUP Both cameras, the board, the views of the cameras and the light sheet in 3D.
%   stereo.plot_setup(ax, calib)
%   stereo.plot_setup(ax, calib, disparity)
%   ax         scene of scene3d.window (stereo.show_3d_Callback)
%   calib      stereo.calibrate (stereo-PIV, or calib.use = "fov": two cameras combined into a larger field of view)
%   disparity  stereo.measure_disparity (optional): the light sheet position (stereo.sheet_position)
% World coordinates of calib = board coordinates in mm of patternWorldPoints (x right, y down, z into the
% board, away from camera 1; turned by 180 degrees about y if camera 1 sees the board from behind). The
% scene shows them on the board as printed, in the axes of the results (scene3d, Frame).
combined = isfield(calib, 'use') && calib.use == "fov";
wp = calib.world_points{1};
if combined
    wp = unique([calib.world_points{1}; calib.world_points{2}], 'rows'); % each camera sees a part of the board
end
board = [];
if isfield(calib, 'board')
    board = calib.board;
end
frame = rigidtform3d;
if ~isempty(board)
    % world coordinates of stereo.calibrate -> board as printed: patternWorldPoints (turned by 90 degrees for
    % boards with more rows than columns), mirrored if camera 1 sees the board from behind
    fp = patternWorldPoints("charuco-board", board.PatternDims, board.CheckerSize);
    if isfield(calib, 'board_from_behind') && calib.board_from_behind(1)
        fp(:, 1) = -fp(:, 1);
    end
    frame = scene3d.frame_transform(fp, preproc.cam_board_corners(board.PatternDims, board.CheckerSize));
end
scene3d.board(ax, board, Points=wp, Frame=frame);
lift = 0.3; % mm in front of the board (towards camera 1): drawn on top of it
if calib.grid_info.overlap.NumRegions > 0
    [ox, oy] = boundary(calib.grid_info.overlap);
    P = scene3d.result(ax, [ox, oy, -lift * ones(size(ox))]);
    patch(ax, P(:, 1), P(:, 2), P(:, 3), [0.35 0.8 0.35], 'FaceAlpha', 0.3, 'EdgeColor', [0.2 0.6 0.2], ...
        'HitTest', 'off', 'PickableParts', 'none', 'DisplayName', 'overlap of both views');
end
if combined % centre of both views together; each camera looks at the centre of its own view
    [cx, cy] = centroid(union(calib.grid_info.views{1}, calib.grid_info.views{2}));
else
    [cx, cy] = centroid(calib.grid_info.overlap);
end
for k = 1:2
    [vx, vy] = boundary(calib.grid_info.views{k});
    sx = cx;
    sy = cy;
    if combined
        [sx, sy] = centroid(calib.grid_info.views{k});
    end
    scene3d.camera(ax, calib.extrinsics{k}, stereo.camera_colors(k), sprintf('%d', k), ...
        View=[vx, vy, -lift * ones(size(vx))], Sight=[sx sy 0], ViewName=sprintf('view of camera %d', k));
end
if nargin >= 3 && ~isempty(disparity)
    sheet = stereo.sheet_position(calib, disparity);
    P = scene3d.result(ax, [sheet.x(:), sheet.y(:), sheet.z(:)]);
    sz = size(sheet.x);
    surf(ax, reshape(P(:, 1), sz), reshape(P(:, 2), sz), reshape(P(:, 3), sz), 'FaceColor', [1 0.85 0.2], 'FaceAlpha', 0.45, ...
        'EdgeColor', 'none', 'HitTest', 'off', 'PickableParts', 'none', 'Tag', 'scene3d_sheet', ...
        'DisplayName', sprintf('light sheet (%+.2f mm, from the disparity)', sheet.offset));
    scene3d.add_points(ax, P(all(isfinite(P), 2), :));
end
legend(ax, 'Location', 'northeast', 'TextColor', ax.XColor, 'Color', 'none', 'EdgeColor', 'none', 'AutoUpdate', 'off');
if combined
    scene3d.caption(ax, 'Two cameras combined: larger field of view');
else
    [~, info] = stereo.geometry_report(calib);
    scene3d.caption(ax, sprintf('Angle between the cameras: %.0f%s', info.stereo_angle, char(176)));
end
end
