function [calib, disparity] = measure_sheet(imgs, calib, opts, verbose, progress_target)
%MEASURE_SHEET Light sheet position from the disparity in the overlap of two combined cameras; both cameras
%are then mapped onto the sheet, so the particle images match at the seam.
%   [calib, disparity] = fov.measure_sheet(imgs, calib, opts)
%   [calib, disparity] = fov.measure_sheet(imgs, calib, opts, verbose, progress_target)
%   imgs   1x2 cell, image sets of camera 1 and 2 (raw images with the lens calibration, as for
%          stereo.measure_disparity). imgs{1}.mask (optional): masks of the combined images, one entry per image
%          pair (logical image or PIVlab mask objects, combined image coordinates)
%   calib  stereo.calibrate with calib.use = "fov" (also one moved onto a sheet before: measured again from the board)
%   opts   stereo.defaults() (groups disparity and Parallel). disparity.Passes: corrections after the first
%          measurement; each one is checked by measuring again.
%   verbose (default true), progress_target (GUI text control for the progress, stereo.measure_disparity)
%   calib      fov.on_sheet(calib, plane) with calib.sheet (fov.sheet_report):
%     sheet.plane       [a b c]: z = a + b x + c y [mm], z > 0 behind the board (away from the cameras)
%     sheet.offset      z [mm] at the centre of the overlap; sheet.tilt [deg] along the overlap (sheet.along: its
%                       direction, unit vector); across a narrow overlap the tilt can not be measured (sheet.across_measured)
%     sheet.history     [rms max] disparity [px] inside the overlap of each measurement (first: on the board,
%                       last: on the final sheet); sheet.pairs: image pairs used
%   disparity  the last measurement (stereo.measure_disparity on the overlap; x, y in pixels of the combined image)
% The disparity is measured only on the bounding box of the overlap. A particle in the sheet at height z appears
% in both cameras at board positions that differ by z times the difference of their lines of sight
% (stereo.sheet_position); a plane is fitted to z. In a narrow overlap (cameras side by side) only the tilt along
% the overlap is measured; the tilt across it is assumed 0.
if nargin < 4
    verbose = true;
end
if nargin < 5
    progress_target = [];
end
if isfield(calib, 'board_tform') && ~isempty(calib.board_tform)
    calib.tform = calib.board_tform; % always measured from the board
end
calib = fov.on_sheet(calib, [0 0 0]);
F_size = calib.Ravg.ImageSize;
d = opts.disparity;
n_corrections = max(d.Passes, 1);
one = opts;
one.disparity.Passes = 1; % the corrections are sheet planes here, not disparity maps
for k = 1:2
    if ~isempty(imgs{k}.preprocess)
        imgs{k}.preprocess.Roi = []; % the measurement area is the overlap
    end
end
combined_masks = {};
if isfield(imgs{1}, 'mask') && ~isempty(imgs{1}.mask)
    combined_masks = imgs{1}.mask;
end
imgs{2}.mask = {};
plane = [0 0 0];
backgrounds = {};
history = zeros(0, 2);
cs = calib;
for it = 1:n_corrections + 1
    cs = fov.on_sheet(calib, plane);
    [sub, rows, cols] = overlap_calib(cs);
    imgs{1}.mask = cropped_masks(combined_masks, F_size, rows, cols);
    disparity = stereo.measure_disparity(imgs, sub, one, verbose, backgrounds, progress_target);
    backgrounds = disparity.background;
    sheet = stereo.sheet_position(sub, disparity);
    inside = isinterior(sub.grid_info.overlap, sheet.x(:), sheet.y(:)) & isfinite(sheet.z(:));
    m = hypot(double(disparity.u_mean_smooth(inside)), double(disparity.v_mean_smooth(inside)));
    if isempty(m)
        error('fov:measure_sheet', 'No disparity vectors inside the overlap of both cameras.');
    end
    history(end + 1, :) = [sqrt(mean(m .^ 2)), max(m)]; %#ok<AGROW>
    if verbose
        fprintf('Disparity in the overlap (measurement %d): %.2f px rms, %.2f px max\n', it, history(end, 1), history(end, 2));
    end
    % done: matched, last correction, or the last correction did not help any more (noise of the measurement)
    if it == n_corrections + 1 || history(end, 2) < d.StopThreshold || (it > 1 && history(end, 1) > 0.7 * history(end - 1, 1))
        break
    end
    [dplane, along, across] = fit_plane(sheet.x(inside), sheet.y(inside), sheet.z(inside));
    plane = plane + dplane;
end
calib = cs;
[cx, cy] = centroid(calib.grid_info.overlap);
calib.sheet.plane = plane;
calib.sheet.offset = plane(1) + plane(2) * cx + plane(3) * cy;
if it == 1 % no correction (already matched): no direction measured
    [~, along, across] = fit_plane(sheet.x(inside), sheet.y(inside), sheet.z(inside));
end
calib.sheet.along = along;
calib.sheet.tilt = atand(plane(2:3) * along(:));
calib.sheet.across_measured = across;
calib.sheet.history = history;
calib.sheet.pairs = disparity.pairs;
% disparity on the grid of the combined image (for displays)
disparity.x = disparity.x + cols(1) - 1;
disparity.y = disparity.y + rows(1) - 1;
disparity = rmfield(disparity, intersect(fieldnames(disparity), {'u_full', 'v_full', 'xq', 'yq', 'background'}));
end

function [sub, rows, cols] = overlap_calib(calib)
% calib on the bounding box of the overlap (+ margin): same pixels as calib.Ravg, mask = outside the overlap
H = calib.Ravg.ImageSize(1);
W = calib.Ravg.ImageSize(2);
if calib.grid_info.overlap.NumRegions == 0
    error('fov:measure_sheet', 'The views of the two cameras do not overlap: the disparity can not be measured.');
end
[vx, vy] = boundary(calib.grid_info.overlap);
[ix, iy] = worldToIntrinsic(calib.Ravg, vx, vy);
margin = 8;
cols = max(1, floor(min(ix)) - margin):min(W, ceil(max(ix)) + margin);
rows = max(1, floor(min(iy)) - margin):min(H, ceil(max(iy)) + margin);
dx = calib.Ravg.PixelExtentInWorldX;
dy = calib.Ravg.PixelExtentInWorldY;
x0 = calib.Ravg.XWorldLimits(1);
y0 = calib.Ravg.YWorldLimits(1);
sub = calib;
sub.Ravg = imref2d([numel(rows) numel(cols)], x0 + [cols(1) - 1, cols(end)] * dx, y0 + [rows(1) - 1, rows(end)] * dy);
sub.mask = ~poly2mask(ix - cols(1) + 1, iy - rows(1) + 1, numel(rows), numel(cols));
end

function out = cropped_masks(masks, full_size, rows, cols)
% masks of the combined images (one entry per image pair) on the bounding box of the overlap (logical images);
% identical entries (e.g. the part no camera sees, the same in every frame) are converted once
out = cell(size(masks));
last_entry = [];
last_mask = [];
for i = 1:numel(masks)
    entry = masks{i};
    if isempty(entry)
        continue
    end
    if ~isempty(last_mask) && isequal(entry, last_entry)
        out{i} = last_mask;
        continue
    end
    if islogical(entry) || isnumeric(entry)
        m = logical(entry);
    else
        m = mask.convert_masks_to_binary(full_size, entry);
    end
    out{i} = m(rows, cols);
    last_entry = entry;
    last_mask = out{i};
end
end

function [plane, along, across] = fit_plane(x, y, z)
% plane z = a + b x + c y through the sheet heights; across a narrow overlap (short side < 35 % of the long one)
% only the slope along the overlap
x = double(x(:));
y = double(y(:));
z = double(z(:));
m = [mean(x), mean(y)];
P = [x - m(1), y - m(2)];
[V, E] = eig(cov(P));
[e, order] = sort(diag(E), 'descend');
along = V(:, order(1))';
across = numel(z) >= 3 && sqrt(max(e(2), 0) / max(e(1), eps)) >= 0.35;
if across
    coef = [ones(numel(z), 1), P] \ z;
    plane = [coef(1) - coef(2:3)' * m(:), coef(2), coef(3)];
else
    t = P * along(:);
    coef = [ones(numel(z), 1), t] \ z;
    g = coef(2) * along; % gradient along the overlap only
    plane = [coef(1) - g * m(:), g(1), g(2)];
end
end
