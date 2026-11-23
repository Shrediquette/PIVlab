function [lines, info] = report(calib)
%REPORT Short description of two cameras combined into a larger field of view.
%   [lines, info] = fov.report(calib)
%   calib  stereo.calibrate (calib.use = "fov")
%   lines  cellstr; info: the numbers
%   info.view_angle(k)   angle between the line of sight of camera k to the centre of its view and the
%                        board normal [deg] (0 = camera looks perpendicular onto the sheet)
%   info.coverage(k)     part of the view of camera k that its board corners cover [%] (convex hull)
%   info.n_corners(k), info.n_rejected(k)
%   info.overlap_mm      width of the overlap along the line between both view centres [mm]
%   info.overlap_px(k)   the same in pixels of camera k; info.overlap_pct(k): in % of the image width/height
%   info.size_mm         [width height] of the combined field of view [mm]; info.grid [rows cols]
%   info.mm_per_px       output pixel [mm]; info.footprint(k): camera pixel on the sheet [mm]
deg = char(176);
views = calib.grid_info.views;
info.view_angle = [0 0];
info.coverage = [0 0];
info.n_corners = [size(calib.image_points{1}, 1), size(calib.image_points{2}, 1)];
info.n_rejected = calib.n_rejected;
c = zeros(2, 2);
for k = 1:2
    [c(k, 1), c(k, 2)] = centroid(views{k});
    v = [c(k, :) 0] - calib.centre(k, :);
    info.view_angle(k) = acosd(abs(v(3)) / norm(v));
    wp = calib.world_points{k};
    if size(wp, 1) >= 3
        h = convhull(wp(:, 1), wp(:, 2), 'Simplify', true); % no collinear points (rows of corners)
        h = h(1:end - 1); % convhull closes the loop
        info.coverage(k) = 100 * min(1, area(intersect(polyshape(wp(h, 1), wp(h, 2)), views{k})) / area(views{k}));
    end
end
[info.overlap_mm, along_x, overlap_warnings] = fov.overlap_width(views, calib.grid_info.overlap, ...
    1 / max(calib.grid_info.footprint)); % the coarser camera: its pixels decide whether the overlap is small
info.overlap_px = info.overlap_mm ./ calib.grid_info.footprint;
info.overlap_pct = [0 0];
for k = 1:2
    n = calib.image_size{k}(2 - ~along_x); % image width for cameras side by side, else height
    info.overlap_pct(k) = 100 * info.overlap_px(k) / n;
end
info.grid = calib.Ravg.ImageSize;
info.mm_per_px = calib.Ravg.PixelExtentInWorldX;
info.footprint = calib.grid_info.footprint;
[xl, yl] = boundingbox(union(views{1}, views{2}));
info.size_mm = [diff(xl), diff(yl)];
lines = {};
if isfield(calib, 'use_info')
    lines{end + 1} = calib.use_info.reason;
end
lines{end + 1} = sprintf('Viewing angle: camera 1 %.0f%s, camera 2 %.0f%s', info.view_angle(1), deg, info.view_angle(2), deg);
lines{end + 1} = sprintf('Combined image: %d x %d px, %.4f mm/px, field of view %.0f x %.0f mm', ...
    info.grid(2), info.grid(1), info.mm_per_px, info.size_mm(1), info.size_mm(2));
lines{end + 1} = sprintf('Camera pixel on the sheet: %.4f / %.4f mm', info.footprint(1), info.footprint(2));
if info.overlap_mm > 0
    lines{end + 1} = sprintf('Overlap: %.1f mm (%.0f / %.0f px, %.0f / %.0f %% of the image)', info.overlap_mm, ...
        info.overlap_px(1), info.overlap_px(2), info.overlap_pct(1), info.overlap_pct(2));
end
lines = [lines, overlap_warnings];
lines{end + 1} = sprintf('Board corners: %d / %d (rejected %d / %d), covering %.0f / %.0f %% of the views', ...
    info.n_corners(1), info.n_corners(2), info.n_rejected(1), info.n_rejected(2), info.coverage(1), info.coverage(2));
for k = 1:2
    if info.coverage(k) < 30
        lines{end + 1} = sprintf(['Warning: the board covers only %.0f %% of the view of camera %d: the mapping is ' ...
            'extrapolated far beyond the corners (a board over about a third of each view or more is recommended).'], ...
            info.coverage(k), k);
    end
end
lines = [lines, fov.sheet_report(calib)];
end
