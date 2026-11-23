%% Tests of two cameras for a larger field of view (+fov, pivlab.combineCameras) without the PIVlab window
%
% Automatic choice stereo-PIV / larger field of view, output grid covering both views, owner map (seam),
% frame reading with cam.fov (combined images, background, ensemble), scale, and a small synthetic
% recording of two cameras side by side with known displacement (about a minute).
% Plan: dev_notes/two_camera_fov_plan.md
%
% Run with:
%   runtests('unittests/test_fov_cameras.m')

function tests = test_fov_cameras
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
addpath(helper_root());
testCase.TestData.folder = tempname;
mkdir(testCase.TestData.folder);
c = helper_fov_synthetic_case(fullfile(testCase.TestData.folder, 'side'), 3);
testCase.TestData.c = c;
testCase.TestData.imgs = lens_images(c);
testCase.TestData.out = pivlab.combineCameras(testCase.TestData.imgs, c.boards, c.board, Verbose=false);
end

function teardownOnce(testCase)
if isfolder(testCase.TestData.folder)
    rmdir(testCase.TestData.folder, 's');
end
end

% -------------------------------------------------------------------------
% Automatic choice (geometry only)
% -------------------------------------------------------------------------

function test_choice_side_by_side_is_fov(testCase)
% two perpendicular cameras 80 mm apart, 250 mm from the sheet, views 91 mm wide: small overlap, lines of
% sight to the seam at opposite angles (about 9 deg each): the overlap decides, not the angle
views = {rect(2, 93, 4, 96), rect(82, 173, 4, 96)};
u = stereo.camera_use([47.5 50 -250; 127.5 50 -250], views);
verifyEqual(testCase, u.use, "fov");
verifyEqual(testCase, u.overlap, 100 * 11 / 91, 'AbsTol', 0.1);
verifyGreaterThan(testCase, u.angle, 10, 'the angle alone would say stereo');
end

function test_choice_without_overlap_is_fov(testCase)
u = stereo.camera_use([0 0 -500; 300 0 -500], {rect(0, 90, 0, 90), rect(100, 190, 0, 90)});
verifyEqual(testCase, u.use, "fov");
verifyEqual(testCase, u.overlap, 0);
verifyTrue(testCase, isnan(u.angle));
end

function test_choice_angled_cameras_is_stereo(testCase)
% stereo set-up at about +-35 deg looking at the same region
u = stereo.camera_use([-307 140 -428; 567 138 -426], {rect(0, 300, 0, 280), rect(20, 320, 5, 285)});
verifyEqual(testCase, u.use, "stereo");
verifyGreaterThan(testCase, u.angle, 60);
end

function test_choice_translation_stereo_is_stereo(testCase)
% parallel cameras shifted by 300 mm with lens shift: large overlap, 33 deg between the lines of sight
u = stereo.camera_use([-150 50 -500; 150 50 -500], {rect(-50, 50, 0, 100), rect(-45, 55, 0, 100)});
verifyEqual(testCase, u.use, "stereo");
end

function test_choice_parallel_large_overlap_is_fov(testCase)
% parallel cameras 10 mm apart: large overlap, but no useful w
u = stereo.camera_use([0 50 -500; 10 50 -500], {rect(-45, 45, 0, 90), rect(-35, 55, 0, 90)});
verifyEqual(testCase, u.use, "fov");
end

function test_stereo_recording_still_chooses_stereo(testCase)
% the synthetic stereo set-up of the stereo tests (cameras at about +-35 deg)
folder = fullfile(testCase.TestData.folder, 'stereo');
c = helper_stereo_synthetic_case(folder, 1, 0);
imgs = lens_images(c);
calib = stereo.calibrate({imgs{1}.cam, imgs{2}.cam}, c.boards, c.board);
verifyEqual(testCase, calib.use, "stereo", calib.use_info.reason);
verifyEqual(testCase, calib.grid_info.region, "overlap");
end

% -------------------------------------------------------------------------
% Grid and owner map
% -------------------------------------------------------------------------

function test_union_grid_without_overlap(testCase)
% views of two cameras with a gap: "overlap" fails, "union" covers both views
t = {projtform2d([0.1 0 0; 0 0.1 0; 0 0 1]), projtform2d([0.1 0 120; 0 0.1 0; 0 0 1])};
sizes = {[900 1000], [900 1000]};
verifyError(testCase, @() stereo.square_grid(t, sizes, [], [], "overlap"), 'stereo:square_grid');
[R, info] = stereo.square_grid(t, sizes, [], [], "union");
verifyEqual(testCase, info.pixel_size, 0.1, 'AbsTol', 1e-9);
verifyEqual(testCase, R.XWorldLimits, [0.05 220.05], 'AbsTol', 0.11);
verifyEqual(testCase, info.overlap.NumRegions, 0);
end

function test_calibration_of_side_by_side_cameras(testCase)
out = testCase.TestData.out;
calib = out.fov_calib;
verifyEqual(testCase, calib.use, "fov");
verifyEqual(testCase, calib.grid_info.region, "union");
verifyEqual(testCase, calib.Ravg.PixelExtentInWorldX, 500 / 5600, 'RelTol', 0.01, 'mm per px');
verifyEqual(testCase, out.imageSize, calib.Ravg.ImageSize);
% the combined grid covers both views (about 171 x 91 mm)
verifyEqual(testCase, calib.Ravg.ImageSize(2) * calib.Ravg.PixelExtentInWorldX, 80 + 1024 * 500 / 5600, 'RelTol', 0.03);
% mask: only the part no camera sees (lens distortion: a thin border)
verifyLessThan(testCase, nnz(calib.mask) / numel(calib.mask), 0.01);
end

function test_owner_seam_in_middle_of_overlap(testCase)
out = testCase.TestData.out;
calib = out.fov_calib;
own = out.cam.fov.owner;
row = round(size(own, 1) / 2);
seam = find(own(row, 1:end - 1) == 1 & own(row, 2:end) == 2);
verifyNumElements(testCase, seam, 1, 'one seam, camera 1 left of camera 2');
[x0, y0] = intrinsicToWorld(calib.Ravg, seam + 0.5, row);
ov = calib.grid_info.overlap;
[xl, ~] = boundingbox(intersect(ov, polyshape([xl_of(ov) fliplr(xl_of(ov))], [y0 - 0.1 y0 - 0.1 y0 + 0.1 y0 + 0.1])));
verifyEqual(testCase, x0, mean(xl), 'AbsTol', 2 * calib.Ravg.PixelExtentInWorldX, 'seam in the middle of the overlap');
verifyEqual(testCase, nnz(own == 0), nnz(calib.mask));
end

% -------------------------------------------------------------------------
% Reading combined frames
% -------------------------------------------------------------------------

function test_read_frame_combines_both_cameras(testCase)
out = testCase.TestData.out;
img = import.read_frame(out, 3, out.cam, []);
raw1 = imread(testCase.TestData.c.files{1}(3));
raw2 = imread(testCase.TestData.c.files{2}(3));
verifyEqual(testCase, img, fov.compose(raw1, raw2, out.cam.fov));
verifyEqual(testCase, size(img), out.imageSize);
verifyClass(testCase, img, 'uint16');
% camera 2 only changes its own pixels
img2 = fov.compose(raw1, zeros(size(raw2), 'like', raw2), out.cam.fov);
verifyEqual(testCase, img2(out.cam.fov.owner == 1), img(out.cam.fov.owner == 1));
verifyTrue(testCase, all(img2(out.cam.fov.owner == 2) == 0));
end

function test_subset_follows_camera_1(testCase)
out = testCase.TestData.out;
cam = fov.subset(out.cam, [3 4]);
verifyEqual(testCase, cam.fov.src.filepath, out.cam.fov.src.filepath([3 4]));
src = struct('filepath', {out.filepath([3 4])}, 'framenum', out.framenum([3 4]), 'framepart', out.framepart([3 4], :));
verifyEqual(testCase, import.read_frame(src, 1, cam, []), import.read_frame(out, 3, out.cam, []));
plain = import.cam_settings();
verifyEqual(testCase, fov.subset(plain, [1 2]), plain);
end

function test_preprocess_keeps_cameras_and_sets_roi(testCase)
% default: region of interest inside the part the cameras see, no mask; Roi="none": the whole image
out = testCase.TestData.out;
im = pivlab.preprocess(out, Verbose=false);
verifyEqual(testCase, im.cam, out.cam);
verifyEqual(testCase, im.imageSize, out.imageSize);
verifyEmpty(testCase, im.mask);
r = im.preprocess.Roi;
verifyEqual(testCase, r, fov.auto_roi(out.cam.fov.owner));
seen = out.cam.fov.owner(r(2):r(2) + r(4), r(1):r(1) + r(3)) > 0;
verifyTrue(testCase, all(seen(:)), 'region of interest outside the views');
verifyGreaterThan(testCase, r(3) * r(4), 0.8 * nnz(out.cam.fov.owner > 0), 'region of interest too small');
im = pivlab.preprocess(out, Roi="none", Verbose=false);
verifyEmpty(testCase, im.preprocess.Roi);
end

function test_display_resolution(testCase)
% combined frames drawn at screen resolution (import.read_frame_display) without making the full combined image:
% the same as the full combined image averaged over the display pixels; zoomed in 1:1 its pixels; background;
% the raw frames of both cameras are returned and used again
out = testCase.TestData.out;
fig = figure('Visible', 'off', 'Units', 'pixels', 'Position', [10 10 600 500]);
ax = axes(fig, 'Units', 'pixels', 'Position', [10 10 500 400]);
full = import.read_frame(out, 1, out.cam, []);
[img, g, out_size, raw_read, whole] = import.read_frame_display(out, 1, out.cam, [], ax, []);
verifyEqual(testCase, out_size, size(full));
verifyNotEmpty(testCase, g, 'large enough for the display grid');
verifyClass(testCase, img, class(full));
verifyEqual(testCase, size(img), [numel(g.yc) numel(g.xc)]);
verifyEqual(testCase, size(whole), size(img), 'point samples of the whole frame');
% sparse particle images: blocks in the raw frames and in the combined image are not aligned (as with one camera
% and a lens model), so the comparison is made after a slight smoothing; no shift, same grey values
ref = helper_ideal_display(full, g);
range = double(max(full(:)));
verifyEqual(testCase, mean(double(img(:))), mean(ref(:)), 'RelTol', 0.01, 'mean grey value');
a = imgaussfilt(double(img), 1);
b = imgaussfilt(ref, 1);
verifyLessThan(testCase, mean(abs(a(:) - b(:))) / range, 0.01, 'grey values');
cc = corrcoef(a(:), b(:));
verifyGreaterThan(testCase, cc(1, 2), 0.97, 'correlation with the full combined image');
cc_shift = corrcoef(reshape(a(:, 2:end), [], 1), reshape(b(:, 1:end - 1), [], 1));
verifyGreaterThan(testCase, cc(1, 2), cc_shift(1, 2), 'shifted by a display pixel');
% zoomed in at the seam: the display pixels are the pixels of the combined image
[~, seam] = max(sum(out.cam.fov.owner == 1, 1) .* (sum(out.cam.fov.owner == 2, 1) > 0));
limits = [seam - 150.5, seam + 149.5, 300.5, 540.5];
[img, g] = import.read_frame_display(out, 1, out.cam, [], ax, limits);
verifyEqual(testCase, g.n, 1);
ref = double(full(round(g.yc), round(g.xc)));
verifyLessThan(testCase, max(abs(double(img(:)) - ref(:))) / range, 0.02, 'zoomed: pixels of the combined image');
% background (combined images), subtracted as in import.read_frame
b = cast(double(full) * 0.4, class(full));
bg = struct('A', b, 'B', b);
full_bg = import.read_frame(out, 1, out.cam, bg);
[img, g] = import.read_frame_display(out, 1, out.cam, bg, ax, []);
verifyClass(testCase, img, class(full_bg));
ref = helper_ideal_display(full_bg, g);
a = imgaussfilt(double(img), 1);
b = imgaussfilt(ref, 1);
verifyLessThan(testCase, mean(abs(a(:) - b(:))) / range, 0.01, 'with background');
% the raw frames of both cameras: import.read_frame gives the same image with them
verifyTrue(testCase, iscell(raw_read) && numel(raw_read) == 2);
verifyEqual(testCase, import.read_frame(out, 1, out.cam, [], raw_read), full);
close(fig)
end

function test_auto_roi_views_with_gap(testCase)
% two views with a gap between them: the rectangle of the larger part, not across the gap
owner = zeros(200, 400);
owner(20:180, 10:180) = 1;
owner(30:170, 200:390) = 2;
r = fov.auto_roi(owner);
seen = owner(r(2):r(2) + r(4), r(1):r(1) + r(3));
verifyTrue(testCase, all(seen(:) == 1), 'inside camera 1 only');
verifyGreaterThan(testCase, r(3) * r(4), 0.9 * 157 * 167);
end

% -------------------------------------------------------------------------
% PIV of the combined images (ground truth)
% -------------------------------------------------------------------------

function test_combined_piv_accuracy_and_seam(testCase)
c = testCase.TestData.c;
out = testCase.TestData.out;
S = piv_settings();
res = pivlab.analyze(pivlab.preprocess(out, Settings=S, Verbose=false), Settings=S, Verbose=false);
res = pivlab.filter(res, Settings=S, Verbose=false);
err = truth_error(res, out, c);
verifyLessThan(testCase, [err.rms_U err.rms_V], [0.006 0.006], 'rms error [mm] of U, V');
verifyLessThan(testCase, abs([err.bias_U err.bias_V]), [0.001 0.001], 'bias [mm] of U, V');
verifyLessThan(testCase, err.rms_seam, 1.5 * err.rms_rest + 0.001, 'larger error at the seam');
% scale from the calibration
res = pivlab.toMetric(res, DeltaT=1, Verbose=false);
verifyEqual(testCase, res.calibration.calxy, out.cam.fov.mm_per_px / 1000, 'RelTol', 1e-3);
end

function test_background_and_ensemble(testCase)
% static reflections in both cameras: removed by the minimum background (computed per camera, combined);
% ensemble correlation reads the combined images too
folder = fullfile(testCase.TestData.folder, 'static');
c = helper_fov_synthetic_case(folder, 4, Static=true);
out = pivlab.combineCameras(lens_images(c), c.boards, c.board, Verbose=false);
S = piv_settings();
S.preprocess.Background = "min";
im = pivlab.preprocess(out, Settings=S, Verbose=false);
verifyEqual(testCase, size(im.background.A), out.imageSize);
verifyClass(testCase, im.background.A, 'uint16');
res = pivlab.filter(pivlab.analyze(im, Settings=S, Verbose=false), Settings=S, Verbose=false);
err = truth_error(res, out, c);
verifyLessThan(testCase, [err.rms_U err.rms_V], [0.008 0.008], 'rms error [mm] with background');
S.analysis.Algorithm = "ensemble";
res = pivlab.analyze(im, Settings=S, Verbose=false);
err = truth_error(res, out, c);
verifyLessThan(testCase, [err.rms_U err.rms_V], [0.008 0.008], 'rms error [mm] of the ensemble correlation');
end

% -------------------------------------------------------------------------
% Light sheet position from the disparity in the overlap
% -------------------------------------------------------------------------

function test_on_sheet_flat_is_the_board(testCase)
calib = testCase.TestData.out.fov_calib;
flat = fov.on_sheet(calib, [0 0 0]);
p = [10 20; 90 50; 170 80];
for k = 1:2
    verifyEqual(testCase, transformPointsInverse(flat.tform{k}, p), transformPointsInverse(flat.board_tform{k}, p), 'AbsTol', 1e-6);
end
verifyEqual(testCase, flat.mask, calib.mask);
end

function test_on_sheet_matches_the_camera_projection(testCase)
% a point of a tilted plane in front of the board: seen by each (true) camera where fov.on_sheet maps it
c = testCase.TestData.c;
calib = testCase.TestData.out.fov_calib;
plane = [-4 0.004 -0.02];
s = fov.on_sheet(calib, plane);
for k = 1:2
    xc = 90 + 40 * (2 * k - 3); % points in the view of camera k (helper_fov_synthetic_case: x = 50 / 130, y = 50)
    [x, y] = meshgrid(xc + (-36:12:36), 50 + (-36:12:36));
    P = [x(:), y(:), plane(1) + plane(2) * x(:) + plane(3) * y(:)];
    truth = simulate.project(c.cams{k}, P);
    mapped = stereo.distort_points(transformPointsInverse(s.tform{k}, P(:, 1:2)), s.cams{k});
    board = stereo.distort_points(transformPointsInverse(s.board_tform{k}, P(:, 1:2)), s.cams{k});
    % the same points on the board (z = 0): what the calibration itself gives (incl. the pixel origin of
    % simulate.project, about 0.5 px); the sheet mapping must not add to it
    P0 = [P(:, 1:2), zeros(size(P, 1), 1)];
    e0 = board - simulate.project(c.cams{k}, P0);
    verifyLessThan(testCase, max(vecnorm(mapped - truth - e0, 2, 2)), 0.1, sprintf('camera %d [px]', k));
    verifyGreaterThan(testCase, max(vecnorm(board - truth - e0, 2, 2)), 3, 'the board mapping would be wrong');
end
end

function test_sheet_offset_and_tilt_measured(testCase)
% light sheet 0.6 mm behind the board, tilted 1 deg along the seam: found from the disparity in the overlap; the
% cameras then match at the seam and the PIV has no larger error there
folder = fullfile(testCase.TestData.folder, 'tilted');
c = helper_fov_synthetic_case(folder, 4, SheetOffset=0.6, SheetTilt=1);
out = pivlab.combineCameras(lens_images(c), c.boards, c.board, Verbose=false);
s = out.fov_calib.sheet;
A = c.sheet_pose.A; % sheet (x, y, 0) -> world: z = A(3,2) / A(2,2) * y + A(3,4)
truth = [A(3, 4), 0, A(3, 2) / A(2, 2)];
[cx, cy] = centroid(out.fov_calib.grid_info.overlap);
verifyEqual(testCase, s.offset, truth(1) + truth(3) * cy, 'AbsTol', 0.05, 'offset [mm] at the seam');
verifyEqual(testCase, s.plane(3), truth(3), 'AbsTol', 0.002, 'slope along the seam');
verifyEqual(testCase, s.tilt, 1, 'AbsTol', 0.15, 'tilt [deg]');
verifyFalse(testCase, s.across_measured, 'narrow overlap: tilt across assumed 0');
verifyEqual(testCase, s.plane(2), 0, 'AbsTol', 1e-3);
verifyGreaterThan(testCase, s.history(1, 1), 1, 'mismatch on the board [px]');
verifyLessThan(testCase, s.history(end, 1), 0.2, 'mismatch on the sheet [px]');
verifyTrue(testCase, any(contains(out.fov_report, 'Light sheet at the seam')));
verifyLessThan(testCase, abs(cx - 90), 10, 'overlap in the middle');
S = piv_settings();
res = pivlab.filter(pivlab.analyze(pivlab.preprocess(out, Settings=S, Verbose=false), Settings=S, Verbose=false), ...
    Settings=S, Verbose=false);
err = truth_error(res, out, c);
verifyLessThan(testCase, [err.rms_U err.rms_V], [0.008 0.008], 'rms error [mm] of U, V');
verifyLessThan(testCase, err.rms_seam, 1.5 * err.rms_rest + 0.001, 'larger error at the seam');
end

function test_board_in_sheet_measures_no_offset(testCase)
s = testCase.TestData.out.fov_calib.sheet;
verifyLessThan(testCase, abs(s.offset), 0.05);
verifyLessThan(testCase, s.history(end, 1), 0.2);
end

% -------------------------------------------------------------------------
% Helpers
% -------------------------------------------------------------------------

function imgs = lens_images(c)
imgs = cell(1, 2);
for k = 1:2
    imgs{k} = pivlab.readImages(c.files{k}, "pairwise");
    imgs{k} = pivlab.preprocess(imgs{k}, Camera=c.lens{k}, CameraView="same", Verbose=false);
end
end

function S = piv_settings()
S = pivlab.defaults();
S.analysis.InterrogationArea = 64;
S.analysis.Step = 32;
S.analysis.Passes = 3;
S.analysis.PassSizes = [32 16 16];
end

function err = truth_error(res, out, c)
% mean displacement [mm per pair] against the truth; the combined image is on the board grid (x right,
% y down as in the images and the synthetic world)
calib = out.fov_calib;
[xw, yw] = intrinsicToWorld(calib.Ravg, res.px.x, res.px.y);
Ut = interp2(c.X, c.Y, c.U, xw, yw);
Vt = interp2(c.X, c.Y, c.V, xw, yw);
mpp = out.cam.fov.mm_per_px;
Ue = mean(res.px.u, 3) * mpp;
Ve = mean(res.px.v, 3) * mpp;
ok = ~isnan(Ut) & ~isnan(Ue);
e = Ue(ok) - Ut(ok); err.bias_U = mean(e); err.rms_U = sqrt(mean(e .^ 2));
e = Ve(ok) - Vt(ok); err.bias_V = mean(e); err.rms_V = sqrt(mean(e .^ 2));
own = out.cam.fov.owner;
[~, cols] = find(own(:, 1:end - 1) == 1 & own(:, 2:end) == 2);
band = ok & abs(res.px.x - median(cols)) < 40;
rest = ok & ~band;
d = hypot(Ue - Ut, Ve - Vt);
err.rms_seam = sqrt(mean(d(band) .^ 2));
err.rms_rest = sqrt(mean(d(rest) .^ 2));
end

function p = rect(x0, x1, y0, y1)
p = polyshape([x0 x1 x1 x0], [y0 y0 y1 y1]);
end

function xl = xl_of(p)
[xl, ~] = boundingbox(p);
end
