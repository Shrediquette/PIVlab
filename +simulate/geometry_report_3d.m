function [lines, info] = geometry_report_3d(g, board)
% Viewing geometry of the 3D particle image generator in words (simulate.geometry_3d).
%   [lines, info] = simulate.geometry_report_3d(g)
%   [lines, info] = simulate.geometry_report_3d(g, board)   also: board corners seen by each camera
% lines: cellstr; info: struct with the numbers (per camera: distance, angle, mm_per_px, fov, corners;
% stereo_angle, overlap_area, overlap_size)
n = numel(g.cams);
lines = {};
normal = g.sheet_pose.R(:, 3)';
[cx, cy] = centroid(g.overlap);
if isnan(cx)
    cx = mean(g.region(1:2));
    cy = mean(g.region(3:4));
end
mid = transformPointsForward(g.sheet_pose, [cx cy 0]);
sight = zeros(n, 3);
for k = 1:n
    cam = g.cams{k};
    C = g.centre(k, :);
    sight(k, :) = (mid - C) / norm(mid - C);
    info.distance(k) = norm(mid - C);
    info.angle(k) = acosd(abs(dot(sight(k, :), normal))); % between line of sight and sheet normal
    p = transformPointsForward(g.sheet_pose, [cx cy 0; cx + 1 cy 0; cx cy + 1 0]);
    px = simulate.project(cam, p);
    info.mm_per_px(k, :) = 1 ./ [norm(px(2, :) - px(1, :)), norm(px(3, :) - px(1, :))];
    [vx, vy] = boundary(g.views(k));
    if isempty(vx)
        info.fov(k, :) = [NaN NaN];
    else
        info.fov(k, :) = [max(vx) - min(vx), max(vy) - min(vy)];
    end
    side = 'in front of';
    if C(3) > 0
        side = 'behind';
    end
    % radial lens distortion at the farthest image corner [px] (approximately: r of the distorted point)
    intr = cam.intrinsics;
    corner = max(abs([0.5 0.5; cam.imageSize([2 1]) + 0.5] - intr.PrincipalPoint), [], 1) ./ intr.FocalLength;
    r2 = sum(corner .^ 2);
    kr = [intr.RadialDistortion(:)', 0, 0];
    info.distortion_px(k) = abs(kr(1) * r2 + kr(2) * r2 ^ 2 + kr(3) * r2 ^ 3) * sqrt(r2) * mean(intr.FocalLength);
    line = sprintf('Camera %d: %s the board, %.0f mm away, %.1f%s to the sheet normal, %.3f x %.3f mm/px, view %.0f x %.0f mm, distortion %.1f px', ...
        k, side, info.distance(k), info.angle(k), char(176), info.mm_per_px(k, :), info.fov(k, :), info.distortion_px(k));
    if nargin >= 2
        dims = board.PatternDims;
        wp = patternWorldPoints("charuco-board", dims, board.CheckerSize);
        q = simulate.project(cam, [wp, zeros(size(wp, 1), 1)]);
        sz = cam.imageSize;
        info.corners(k) = sum(q(:, 1) > 1 & q(:, 1) < sz(2) & q(:, 2) > 1 & q(:, 2) < sz(1));
        line = sprintf('%s, board corners %d of %d', line, info.corners(k), size(wp, 1));
    end
    lines{end + 1} = line; %#ok<AGROW>
end
info.stereo_angle = NaN;
info.overlap_area = area(g.overlap);
[ox, oy] = boundary(g.overlap);
info.overlap_size = [NaN NaN];
if ~isempty(ox)
    info.overlap_size = [max(ox) - min(ox), max(oy) - min(oy)];
end
if n > 1
    info.stereo_angle = acosd(dot(sight(1, :), sight(2, :)));
    lines{end + 1} = sprintf('Angle between the cameras: %.1f%s; overlap of the views: %.0f x %.0f mm', ...
        info.stereo_angle, char(176), info.overlap_size);
    if info.stereo_angle < 10
        lines{end + 1} = 'Warning: the angle between the cameras is small, W will be very noisy.';
    end
end
end
