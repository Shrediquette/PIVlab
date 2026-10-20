%% Tests of stereo-PIV (+stereo) without the PIVlab window
%
% Formulas of the reconstruction, the disparity models, the output grid, the lens models, the
% corner filter and the automatic region of interest without image data (seconds), plus small
% synthetic stereo recordings with known ground truth that go through stereo.run (about a minute).
%
% Run with:
%   runtests('unittests/test_stereo_core.m')

function tests = test_stereo_core
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
addpath(helper_root());
testCase.TestData.folder = tempname;
mkdir(testCase.TestData.folder);
end

function teardownOnce(testCase)
if isfolder(testCase.TestData.folder)
    rmdir(testCase.TestData.folder, 's');
end
end

% -------------------------------------------------------------------------
% Reconstruction
% -------------------------------------------------------------------------

function test_pervector_inverts_linear_model(testCase)
% u_k = U - Wz*ta_k, v_k = V - Wz*tb_k must be inverted exactly
[calib, x, y] = geometry();
[xw, yw] = intrinsicToWorld(calib.Ravg, x, y);
[U, V, Wz] = flow(xw, yw);
res = cell(1, 2);
for k = 1:2
    C = calib.centre(k, :);
    ta = (xw - C(1)) / (-C(3));
    tb = (yw - C(2)) / (-C(3));
    res{k} = result_struct(x, y, U - Wz .* ta, V - Wz .* tb);
end
vel = stereo.reconstruct(res{1}, res{2}, calib, []);
verifyEqual(testCase, vel.U, U, 'AbsTol', 1e-12);
verifyEqual(testCase, vel.V, V, 'AbsTol', 1e-12);
verifyEqual(testCase, vel.W, Wz, 'AbsTol', 1e-12); % W positive away from the cameras (+z)
end

function test_pervector_exact_projection(testCase)
% displacements from exact ray geometry (particle at z = Wz projected back onto the sheet z = 0)
[calib, x, y] = geometry();
[xw, yw] = intrinsicToWorld(calib.Ravg, x, y);
[U, V, Wz] = flow(xw, yw);
px = calib.Ravg.PixelExtentInWorldX;
res = cell(1, 2);
for k = 1:2
    C = calib.centre(k, :);
    s = -C(3) ./ (Wz - C(3)); % ray from C through the moved particle hits z = 0 at C + s*(P - C)
    xp = C(1) + s .* (xw + U - C(1));
    yp = C(2) + s .* (yw + V - C(2));
    res{k} = result_struct(x, y, (xp - xw) / px, (yp - yw) / px);
end
vel = stereo.reconstruct(res{1}, res{2}, calib, []);
% first-order model: error of order Wz/D (here < 0.2 %)
tol = 2e-3 * max(abs(Wz(:)));
verifyEqual(testCase, vel.W * px, Wz, 'RelTol', 2e-3);
verifyEqual(testCase, vel.U * px, U, 'AbsTol', tol);
verifyEqual(testCase, vel.V * px, V, 'AbsTol', tol);
end

function test_pervector_with_sheet_position(testCase)
% sheet 2-3.5 mm behind the board and tilted; exact ray geometry. The vector at board position (xw, yw)
% shows the sheet point whose two projections have (xw, yw) as midpoint. The sheet position comes
% from the disparity map (disparity.u_full).
[calib, x, y] = geometry();
H = calib.Ravg.ImageSize(1);
W = calib.Ravg.ImageSize(2);
[xf, yf] = meshgrid(1:W, 1:H);
[~, ~, ~, du_full, dv_full] = sheet_points(calib, xf, yf, 2, 0, 0.005);
disparity.u_full = du_full;
disparity.v_full = dv_full;
[xs, ys, zs] = sheet_points(calib, x, y, 2, 0, 0.005);
C = calib.centre;
px = calib.Ravg.PixelExtentInWorldX;
p0 = project_both(C, xs, ys, zs);
[U, V, Wz] = flow(xs, ys);
p1 = project_both(C, xs + U, ys + V, zs + Wz);
res = cell(1, 2);
for k = 1:2
    res{k} = result_struct(x, y, (p1{k}(:,:,1) - p0{k}(:,:,1)) / px, (p1{k}(:,:,2) - p0{k}(:,:,2)) / px);
end
opts.SheetFromDisparity = true;
opts.DisparityGradient = false;
vel = stereo.reconstruct(res{1}, res{2}, calib, disparity, opts);
err_sheet = max(abs([vel.U(:) * px - U(:); vel.V(:) * px - V(:); vel.W(:) * px - Wz(:)]));
vel0 = stereo.reconstruct(res{1}, res{2}, calib, []);
err_board = max(abs([vel0.U(:) * px - U(:); vel0.V(:) * px - V(:); vel0.W(:) * px - Wz(:)]));
verifyEqual(testCase, vel.sheet_z_mm, zs, 'AbsTol', 0.01, 'sheet position from the disparity');
verifyLessThan(testCase, err_sheet, 2e-3 * max(abs(Wz(:))), 'error with the sheet position');
verifyLessThan(testCase, err_sheet, err_board / 5, 'the sheet position should clearly help');
end

function test_disparity_gradient_correction(testCase)
% displacements measured in disparity-corrected images (shift -/+ d/2 with a linearly varying d) must be
% mapped back exactly: reconstruct(u', disparity) == reconstruct(u) for the rectified-image displacements u
[calib, x, y] = geometry();
H = calib.Ravg.ImageSize(1);
W = calib.Ravg.ImageSize(2);
[xf, yf] = meshgrid(1:W, 1:H);
J = [0.03 -0.02; 0.004 0.01]; % [dux duy; dvx dvy] of the disparity map
disparity.u_full = J(1, 1) * xf + J(1, 2) * yf;
disparity.v_full = J(2, 1) * xf + J(2, 2) * yf;
rng(4)
uk = {randn(size(x)), randn(size(x))};
vk = {randn(size(x)), randn(size(x))};
ref = cell(1, 2);
cor = cell(1, 2);
for k = 1:2
    sgn = 2 * k - 3; % camera 1: -d/2, camera 2: +d/2
    M = inv(eye(2) + sgn * J / 2); % rectified -> corrected displacement
    ref{k} = result_struct(x, y, uk{k}, vk{k});
    cor{k} = result_struct(x, y, M(1, 1) * uk{k} + M(1, 2) * vk{k}, M(2, 1) * uk{k} + M(2, 2) * vk{k});
end
opts.SheetFromDisparity = false;
opts.DisparityGradient = true;
v_ref = stereo.reconstruct(ref{1}, ref{2}, calib, []);
v_cor = stereo.reconstruct(cor{1}, cor{2}, calib, disparity, opts);
verifyEqual(testCase, v_cor.U, v_ref.U, 'AbsTol', 1e-12);
verifyEqual(testCase, v_cor.V, v_ref.V, 'AbsTol', 1e-12);
verifyEqual(testCase, v_cor.W, v_ref.W, 'AbsTol', 1e-12);
end

function test_camera_layouts_invert_linear_model(testCase)
% cameras above each other, diagonal, and on opposite sides of the sheet: the reconstruction must not
% assume cameras side by side
for layout = {'vertical', 'diagonal', 'opposite'}
    [calib, x, y] = geometry(layout{1});
    [xw, yw] = intrinsicToWorld(calib.Ravg, x, y);
    [U, V, Wz] = flow(xw, yw);
    res = cell(1, 2);
    for k = 1:2
        C = calib.centre(k, :);
        ta = (xw - C(1)) / (-C(3));
        tb = (yw - C(2)) / (-C(3));
        res{k} = result_struct(x, y, U - Wz .* ta, V - Wz .* tb);
    end
    vel = stereo.reconstruct(res{1}, res{2}, calib, []);
    verifyEqual(testCase, vel.U, U, 'AbsTol', 1e-12, layout{1});
    verifyEqual(testCase, vel.V, V, 'AbsTol', 1e-12, layout{1});
    verifyEqual(testCase, vel.W, Wz, 'AbsTol', 1e-12, layout{1});
    verifyEqual(testCase, vel.residual, zeros(size(x)), 'AbsTol', 1e-12, layout{1});
end
end

function test_camera_layouts_exact_projection(testCase)
% exact ray geometry for all camera arrangements (camera behind the board: negative distance)
for layout = {'side', 'vertical', 'diagonal', 'opposite'}
    [calib, x, y] = geometry(layout{1});
    [xw, yw] = intrinsicToWorld(calib.Ravg, x, y);
    [U, V, Wz] = flow(xw, yw);
    px = calib.Ravg.PixelExtentInWorldX;
    res = cell(1, 2);
    p0 = project_both(calib.centre, xw, yw, zeros(size(xw)));
    p1 = project_both(calib.centre, xw + U, yw + V, Wz);
    for k = 1:2
        res{k} = result_struct(x, y, (p1{k}(:,:,1) - p0{k}(:,:,1)) / px, (p1{k}(:,:,2) - p0{k}(:,:,2)) / px);
    end
    vel = stereo.reconstruct(res{1}, res{2}, calib, []);
    tol = 2e-3 * max(abs(Wz(:)));
    verifyEqual(testCase, vel.W * px, Wz, 'AbsTol', tol, layout{1});
    verifyEqual(testCase, vel.U * px, U, 'AbsTol', tol, layout{1});
    verifyEqual(testCase, vel.V * px, V, 'AbsTol', tol, layout{1});
end
end

function test_camera_layouts_sheet_position(testCase)
% tilted sheet 2 mm behind the board: position from both disparity components (stereo.reconstruct and
% stereo.sheet_position), for all camera arrangements
for layout = {'side', 'vertical', 'diagonal', 'opposite'}
    [calib, x, y] = geometry(layout{1});
    H = calib.Ravg.ImageSize(1);
    W = calib.Ravg.ImageSize(2);
    [xf, yf] = meshgrid(1:W, 1:H);
    [~, ~, ~, du_full, dv_full] = sheet_points(calib, xf, yf, 2, 0.004, 0.005);
    disparity.u_full = du_full;
    disparity.v_full = dv_full;
    [xs, ys, zs, du, dv] = sheet_points(calib, x, y, 2, 0.004, 0.005);
    C = calib.centre;
    px = calib.Ravg.PixelExtentInWorldX;
    p0 = project_both(C, xs, ys, zs);
    [U, V, Wz] = flow(xs, ys);
    p1 = project_both(C, xs + U, ys + V, zs + Wz);
    res = cell(1, 2);
    for k = 1:2
        res{k} = result_struct(x, y, (p1{k}(:,:,1) - p0{k}(:,:,1)) / px, (p1{k}(:,:,2) - p0{k}(:,:,2)) / px);
    end
    opts.SheetFromDisparity = true;
    opts.DisparityGradient = false;
    vel = stereo.reconstruct(res{1}, res{2}, calib, disparity, opts);
    verifyEqual(testCase, vel.sheet_z_mm, zs, 'AbsTol', 0.01, [layout{1} ': sheet position from the disparity']);
    err = max(abs([vel.U(:) * px - U(:); vel.V(:) * px - V(:); vel.W(:) * px - Wz(:)]));
    verifyLessThan(testCase, err, 2e-3 * max(abs(Wz(:))), [layout{1} ': error with the sheet position']);
    d.x = x; d.y = y; d.u_mean_smooth = du; d.v_mean_smooth = dv;
    sheet = stereo.sheet_position(calib, d);
    verifyEqual(testCase, sheet.z, zs, 'AbsTol', 0.01, [layout{1} ': stereo.sheet_position']);
    verifyLessThan(testCase, sheet.unexplained_mm, 1e-3, [layout{1} ': a flat sheet explains the whole disparity']);
end
end

function test_geometry_report_layouts(testCase)
% symmetric +-45 deg: angle 90 deg, W error = U/V error, also with the cameras on opposite sides; cameras
% that face each other along one line can not measure W
[calib, ~, ~] = geometry('side');
calib.grid_info.overlap = polyshape([0 200 200 0], [0 0 200 200]);
calib.grid_info.views = {calib.grid_info.overlap, calib.grid_info.overlap};
calib.n_rejected = [0 0];
calib.image_points = {zeros(10, 2), zeros(10, 2)};
cases = {[-400 100 -500; 600 100 -500], [-400 100 -500; -400 100 500], [-400 100 -500; 600 100 500]};
angles = [90 90 0];
opposite = [false true true];
for n = 1:3
    calib.centre = cases{n};
    [lines, info] = stereo.geometry_report(calib);
    verifyEqual(testCase, info.stereo_angle, angles(n), 'AbsTol', 1e-3, sprintf('case %d: angle', n)); % acosd near 1: round-off
    verifyEqual(testCase, info.opposite_sides, opposite(n), sprintf('case %d: opposite sides', n));
    verifyEqual(testCase, any(contains(lines, 'Warning: small angle')), angles(n) < 20, sprintf('case %d: warning', n));
    if angles(n) > 0
        verifyEqual(testCase, info.w_error_ratio, 1, 'AbsTol', 1e-9, sprintf('case %d: W error ratio', n));
    end
end
calib.centre = cases{2};
verifyEqual(testCase, stereo.w_direction(calib), 'away from camera 1');
calib.centre = cases{1};
verifyEqual(testCase, stereo.w_direction(calib), 'away from the cameras');
end

% -------------------------------------------------------------------------
% Disparity models, output grid, corner filter, region of interest
% -------------------------------------------------------------------------

function test_disparity_models_recover_sheet(testCase)
% exact disparity of a tilted flat sheet (central projection), plus 5 % outliers
[calib, x, y] = geometry();
calib.mask = false(calib.Ravg.ImageSize);
[~, ~, ~, du, dv] = sheet_points(calib, x, y, 1.6, 0.004, -0.006);
raw.x = x; raw.y = y; raw.n_valid = 10 * ones(size(x));
rng(3)
bad = randperm(numel(x), round(0.05 * numel(x)));
raw.u = du; raw.v = dv;
raw.u(bad) = raw.u(bad) + 20 * sign(randn(size(bad)));
raw.v(bad) = raw.v(bad) - 15;
models = {'poly1', 'poly2', 'projective'};
limits = [0.3 0.05 0.05]; % [px]
for k = 1:numel(models)
    fit = stereo.fit_disparity(calib, raw, models{k});
    e = max(abs([fit.u(:) - du(:); fit.v(:) - dv(:)]));
    verifyLessThan(testCase, e, limits(k), [models{k} ': model error']);
    verifyTrue(testCase, all(fit.weight(bad) == 0), [models{k} ': outliers not rejected']);
end
identifier = '';
try
    stereo.fit_disparity(calib, raw, 'free'); % prototype-only model, removed
catch err
    identifier = err.identifier;
end
verifyEqual(testCase, identifier, 'stereo:fit_disparity');
end

function test_disparity_pair_order(testCase)
% automatic number of disparity pairs: every beginning of the order is spread over the series
for n = [1 2 3 7 12 70 86]
    order = stereo.disparity_pair_order(n);
    verifyEqual(testCase, sort(order), 1:n, sprintf('n = %d: not all pairs once', n));
end
order = stereo.disparity_pair_order(70);
verifyLessThanOrEqual(testCase, abs(sort(order(1:5)) - linspace(1, 70, 5)), ones(1, 5), 'first batch like linspace');
for N = [5 10 20 40]
    gaps = diff(sort(order(1:N)));
    verifyLessThanOrEqual(testCase, max(gaps), 2 * 69 / (N - 1) + 1, sprintf('first %d pairs leave a large gap', N));
end
end

function test_disparity_uncertainty_estimate(testCase)
% the half-split estimate of stereo.disparity_uncertainty is close to the real error of the fitted map and
% falls like 1/sqrt(N). One case is noisy (the estimate and the real error both come from a few fit
% parameters), so the mean over 20 random cases is compared.
rng(3, 'twister');
calib.mask = false(1000, 1000);
[x, y] = meshgrid(25:50:975, 25:50:975);
xn = (x - 500) / 500;
yn = (y - 500) / 500;
u_true = 3 + 2 * xn - 1.5 * yn + 1.0 * xn .^ 2 + 0.5 * xn .* yn;
v_true = -2 + 0.5 * xn + 1.0 * yn - 0.8 * yn .^ 2;
sigma = 2; % px noise of one validated vector of one pair
n = 40;
counts = [10 40];
repetitions = 20;
estimate = zeros(repetitions, 2);
real_error = zeros(repetitions, 2);
for rep = 1:repetitions
    raw.x = x;
    raw.y = y;
    raw.u_frames = u_true + sigma * randn([size(x) n]);
    raw.v_frames = v_true + sigma * randn([size(x) n]);
    for k = 1:2
        part.x = x;
        part.y = y;
        part.u_frames = raw.u_frames(:, :, 1:counts(k));
        part.v_frames = raw.v_frames(:, :, 1:counts(k));
        estimate(rep, k) = stereo.disparity_uncertainty(calib, part, "poly2");
        all.x = x; all.y = y;
        all.u = mean(part.u_frames, 3); all.v = mean(part.v_frames, 3);
        all.n_valid = counts(k) * ones(size(x));
        fit = stereo.fit_disparity(calib, all, "poly2");
        real_error(rep, k) = sqrt(mean((fit.u(:) - u_true(:)) .^ 2 + (fit.v(:) - v_true(:)) .^ 2));
    end
end
ratio = mean(estimate) ./ mean(real_error);
verifyGreaterThan(testCase, ratio, 0.8 * ones(1, 2), 'estimate too small');
verifyLessThan(testCase, ratio, 1.25 * ones(1, 2), 'estimate too large');
verifyGreaterThan(testCase, mean(estimate(:, 1)) / mean(estimate(:, 2)), 1.6, 'estimate does not fall like 1/sqrt(N)');
verifyLessThan(testCase, mean(estimate(:, 1)) / mean(estimate(:, 2)), 2.5, 'estimate does not fall like 1/sqrt(N)');
verifyTrue(testCase, isnan(stereo.disparity_uncertainty(calib, struct('x', x, 'y', y, 'u_frames', raw.u_frames(:, :, 1:3), ...
    'v_frames', raw.v_frames(:, :, 1:3)), "poly2")), 'fewer than 4 pairs: no estimate');
end

function test_disparity_remaining(testCase)
% stereo.disparity_remaining: a local structure the model does not follow (a stripe of 5 px) is reported with its
% rms, without the noise of the measurement; the noise is estimated from two halves of the image pairs
rng(5, 'twister');
[x, ~] = meshgrid(1:40, 1:30);
model_u = zeros(size(x));
model_v = zeros(size(x));
stripe = 5 * (x >= 20 & x <= 25); % horizontal disparity in a vertical stripe
n = 20;
sigma = 2;
measured.u_frames = stripe + sigma * randn([size(x) n]);
measured.v_frames = sigma * randn([size(x) n]);
measured.u = mean(measured.u_frames, 3);
measured.v = mean(measured.v_frames, 3);
used = true(size(x));
used(1, :) = false;
remaining = stereo.disparity_remaining(measured, model_u, model_v, used);
expected_rms = sqrt(mean(stripe(used) .^ 2));
verifyEqual(testCase, remaining.rms, expected_rms, 'RelTol', 0.05, 'rms of the stripe');
verifyEqual(testCase, remaining.noise, sigma * sqrt(2) / sqrt(n), 'RelTol', 0.1, 'noise of the mean');
verifyGreaterThan(testCase, remaining.p95, 4.5, 'up to: the stripe');
verifyTrue(testCase, all(isnan(remaining.u(1, :))), 'unused points are NaN');
end

function test_square_grid_covers_overlap(testCase)
% two oblique views (projective, image -> world); camera 2 has the coarser pixels
T1 = projtform2d([1.30 0.05 -100; 0.02 1.00 50; 1.5e-4 0 1]);
T2 = projtform2d([1.45 -0.04 200; -0.03 1.10 30; -1.2e-4 0 1]);
sz = {[500 600], [500 600]};
[R, info] = stereo.square_grid({T1, T2}, sz, []);
verifyEqual(testCase, R.PixelExtentInWorldX, R.PixelExtentInWorldY, 'RelTol', 1e-12, 'pixels not square');
verifyEqual(testCase, info.pixel_size, min(info.footprint), 'pixel size is not the finer camera');
verifyLessThan(testCase, info.footprint(1), info.footprint(2), 'camera 1 should be the finer one here');
[xl, yl] = boundingbox(info.overlap);
verifyLessThanOrEqual(testCase, R.XWorldLimits(1), xl(1) + 1e-9);
verifyGreaterThanOrEqual(testCase, R.XWorldLimits(2), xl(2) - 1e-9);
verifyLessThanOrEqual(testCase, R.YWorldLimits(1), yl(1) + 1e-9);
verifyGreaterThanOrEqual(testCase, R.YWorldLimits(2), yl(2) - 1e-9);
verifyLessThan(testCase, R.XWorldLimits(2) - xl(2), 2 * info.pixel_size, 'grid much larger than the overlap');
verifyEqual(testCase, numel(info.views), 2);
end

function test_corner_filter_removes_wrong_ids(testCase)
rng(2)
[gx, gy] = meshgrid(0:10:200, 0:10:180); % mm, checker 10 mm
wp = [gx(:) gy(:)];
T = projtform2d([22 2 300; -1 18 200; 4e-4 -2e-4 1]); % world -> image
ip = transformPointsForward(T, wp) + 0.1 * randn(size(wp)); % 0.1 px corner noise
bad = randperm(size(wp, 1), 15)';
wp_wrong = wp;
wp_wrong(bad, :) = wp(bad, :) + [30, -20]; % wrong marker ID: corner assigned 3 and 2 checkers off
[ip_f, wp_f, n_rejected] = stereo.filter_corners(ip, wp_wrong, 1);
verifyEqual(testCase, n_rejected, 15);
good = setdiff((1:size(wp, 1))', bad);
verifyEqual(testCase, ip_f, ip(good, :));
verifyEqual(testCase, wp_f, wp(good, :));
end

function test_auto_roi_inside_overlap(testCase)
valid = poly2mask([60 560 520 90], [40 80 460 420], 500, 600);
roi = stereo.auto_roi(valid, 5);
rect = false(size(valid));
rect(roi(2):roi(2) + roi(4), roi(1):roi(1) + roi(3)) = true;
verifyTrue(testCase, all(valid(rect)), 'ROI leaves the valid area');
shrunk = imerode(valid, true(11));
verifyTrue(testCase, all(shrunk(rect)), 'ROI ignores the margin');
verifyGreaterThan(testCase, nnz(rect), 0.6 * nnz(valid), 'ROI much smaller than the overlap');
end

% -------------------------------------------------------------------------
% Lens models, image transform, reading
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Lens models, image transform, reading
% -------------------------------------------------------------------------

function test_lens_distortion_round_trip(testCase)
% MATLAB lens model: stereo.distort_points must be the exact inverse of undistortPoints
intr = cameraIntrinsics([14000 14100], [2600 2500], [5120 5120], RadialDistortion=[-0.15 0.4 -0.2], ...
    TangentialDistortion=[1e-3 -5e-4], Skew=2);
cam = import.cam_settings(use_calibration=1, cameraParams=intr, view='same');
[gx, gy] = meshgrid(linspace(1, 5120, 30), linspace(1, 5120, 30));
pu = [gx(:), gy(:)];
back = undistortPoints(stereo.distort_points(pu, cam), intr);
verifyEqual(testCase, back, pu, 'AbsTol', 1e-4);
cam.use_calibration = 0;
verifyEqual(testCase, stereo.distort_points(pu, cam), pu);
end

function test_tilted_lens_model_matches_opencv(testCase)
% OpenCV model with tilted sensor (Scheimpflug): the map of stereo.distort_points applied to the raw
% image must give the image of opencv_undistort (view 'same'), incl. its pixel convention
assumeNotEmpty(testCase, which('opencv.opencv_undistort'), 'opencv_undistort mex not available');
sz = [400 500];
[xx, yy] = meshgrid(1:sz(2), 1:sz(1));
raw = uint16(30000 + 12000 * sin(xx / 9) .* cos(yy / 13) + 8000 * sin((xx + yy) / 17));
K = [900 0 260; 0 905 190; 0 0 1];
D = [0.08 -0.05 1e-3 -8e-4 0.01 0 0 0 1e-3 0 -1e-3 0 0.03 -0.02]; % k1 k2 p1 p2 k3 k4 k5 k6 s1-s4 tauX tauY
reference = opencv.opencv_undistort(raw, K, D, 'same');
cam = import.cam_settings(use_calibration=1, use_tilted_model=true, tilted_D=D, K_opencv=K, view='same');
pd = stereo.distort_points([xx(:), yy(:)], cam);
map.x = reshape(single(pd(:, 1)), sz);
map.y = reshape(single(pd(:, 2)), sz);
out = stereo.rectify_map(raw, map); % uint16
inner = false(sz);
inner(30:end - 30, 30:end - 30) = true;
e = abs(double(out(inner)) - double(reference(inner)));
verifyLessThan(testCase, max(e), 0.005 * 65535, 'map differs from opencv_undistort');
% the remaining difference is the interpolation kernel (OpenCV fixed-point bicubic); a map shifted by
% 0.05 px must fit clearly worse, so the positions agree to better than that
shifts = [0.05 0; -0.05 0; 0 0.05; 0 -0.05];
for k = 1:size(shifts, 1)
    shifted.x = map.x + shifts(k, 1);
    shifted.y = map.y + shifts(k, 2);
    out_shifted = stereo.rectify_map(raw, shifted);
    e_shifted = abs(double(out_shifted(inner)) - double(reference(inner)));
    verifyLessThan(testCase, mean(e), 0.85 * mean(e_shifted), 'map position differs from opencv_undistort');
end
end

function test_rectify_map_classes(testCase)
img8 = uint8(magic(20) * 0.6);
map.x = single(repmat(1:20, 20, 1));
map.y = single(repmat((1:20)', 1, 20));
out = stereo.rectify_map(img8, map);
verifyClass(testCase, out, 'uint16');
verifyEqual(testCase, out, im2uint16(img8)); % identity map
outd = stereo.rectify_map(double(img8), map);
verifyClass(testCase, outd, 'double');
verifyEqual(testCase, outd, double(img8), 'AbsTol', 1e-4);
map.x(1, 1) = -5; % outside the raw image -> 0
out = stereo.rectify_map(img8, map);
verifyEqual(testCase, out(1, 1), uint16(0));
end

function test_read_frame_subtracts_background_before_stereo_map(testCase)
% stereo camera: the (raw) background is subtracted before the transform; 2D camera: unchanged order
folder = testCase.TestData.folder;
raw = uint8(100 + 50 * rand(40, 50));
bg = uint8(20 + 10 * rand(40, 50));
file = fullfile(folder, 'read_frame_A.tif');
imwrite(raw, file);
src.filepath = {file; file};
src.framenum = [1; 1];
src.framepart = [1 40; 1 40];
[xx, yy] = meshgrid(1:50, 1:40);
cam = import.cam_settings();
cam.stereo_map.x = single(xx + 0.3); % shifted: the transform is not the identity
cam.stereo_map.y = single(yy - 0.2);
[current, rawimage] = import.read_frame(src, 1, cam, struct('A', bg, 'B', bg));
verifyEqual(testCase, current, stereo.rectify_map(raw - bg, cam.stereo_map));
verifyEqual(testCase, rawimage, stereo.rectify_map(raw, cam.stereo_map));
plain = import.read_frame(src, 1, import.cam_settings(), struct('A', bg, 'B', bg));
verifyEqual(testCase, plain, raw - bg);
end

function test_min_background_needs_enough_images(testCase)
d = stereo.defaults();
imgs.filepath = repmat({'x.tif'}, 8, 1);
imgs.sequencer = 1;
imgs.background = [];
imgs.cam = import.cam_settings();
verifyEmpty(testCase, stereo.min_background(imgs, d.disparity, false), 'only 4 A images');
d.disparity.MinBackground = false;
imgs.filepath = repmat({'x.tif'}, 40, 1);
verifyEmpty(testCase, stereo.min_background(imgs, d.disparity, false), 'switched off');
end

% -------------------------------------------------------------------------
% Complete stereo-PIV evaluation of synthetic recordings (ground truth)
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Complete stereo-PIV evaluation of synthetic recordings (ground truth)
% -------------------------------------------------------------------------

function test_synthetic_recording(testCase)
% two cameras at about +-35 deg, vortex with an out-of-plane jet, light sheet 1 mm in front of the
% board and tilted by 1 deg (disparity of several pixels), lens distortion
folder = fullfile(testCase.TestData.folder, 'case4');
c = helper_stereo_synthetic_case(folder, 4, 0);
[result, err] = run_case(c);
check_accuracy(testCase, err);
verifyEqual(testCase, result.calib.n_rejected, [0 0]);
verifyLessThan(testCase, result.disparity.residual_history(end, 1), 0.2, 'disparity correction did not converge');
verifyEmpty(testCase, result.disparity.background{1}, 'no minimum background with 4 image pairs');
end

function test_synthetic_recording_static_background(testCase)
% bright static pattern (reflections) in both cameras: removed by the minimum-intensity background
% of the disparity measurement and by the PIV background subtraction
folder = fullfile(testCase.TestData.folder, 'case12');
c = helper_stereo_synthetic_case(folder, 12, 1);
[result, err] = run_case(c, "min");
check_accuracy(testCase, err);
verifyNotEmpty(testCase, result.disparity.background{1}, 'minimum background not used');
verifyLessThan(testCase, result.disparity.residual_history(end, 1), 0.2, 'disparity correction did not converge');
end

function test_synthetic_recording_vertical(testCase)
% camera 1 above camera 2: W comes from the vertical displacements, the disparity is mainly vertical
folder = fullfile(testCase.TestData.folder, 'case_vertical');
c = helper_stereo_synthetic_case(folder, 4, 0, 'vertical');
[result, err] = run_case(c);
check_accuracy(testCase, err);
verifyEqual(testCase, result.calib.board_from_behind, [false false]);
verifyFalse(testCase, result.calib.opposite_sides);
verifyLessThan(testCase, result.disparity.residual_history(end, 1), 0.3, 'disparity correction did not converge'); % max [px], 4 pairs
end

function test_synthetic_recording_opposite_sides(testCase)
% camera 2 on the other side of the light sheet: it sees the (transparent) board mirrored. Run again with
% the cameras swapped: camera 1 behind the board turns the board coordinates (x -> -x, W away from camera 1)
folder = fullfile(testCase.TestData.folder, 'case_opposite');
c = helper_stereo_synthetic_case(folder, 4, 0, 'opposite');
[result, err] = run_case(c);
check_accuracy(testCase, err);
verifyEqual(testCase, result.calib.board_from_behind, [false true]);
verifyTrue(testCase, result.calib.opposite_sides);
verifyLessThan(testCase, result.calib.centre(1, 3), 0, 'camera 1 must be in front of the board');
verifyGreaterThan(testCase, result.calib.centre(2, 3), 0, 'camera 2 must be behind the board');
verifyLessThan(testCase, result.disparity.residual_history(end, 1), 0.3, 'disparity correction did not converge'); % max [px], 4 pairs
swapped = c;
swapped.files = c.files([2 1]);
swapped.boards = c.boards([2 1]);
swapped.lens = c.lens([2 1]);
swapped.cams = c.cams([2 1]);
[result2, err2] = run_case(swapped);
check_accuracy(testCase, err2);
verifyEqual(testCase, result2.calib.board_from_behind, [true false]);
verifyLessThan(testCase, result2.calib.centre(1, 3), 0, 'camera 1 must be in front of the turned board');
end

% -------------------------------------------------------------------------
% Helpers
% -------------------------------------------------------------------------

function [calib, x, y] = geometry(layout)
% cameras like the real setup (world = board coordinates in mm), square output pixels of 5 mm.
% layout: 'side' (default, real setup), 'vertical' (camera 1 above camera 2), 'diagonal',
% 'opposite' (camera 2 behind the board, on the other side of the light sheet)
if nargin < 1
    layout = 'side';
end
calib.Ravg = imref2d([60 70], [-60 -60 + 70 * 5], [-8 -8 + 60 * 5]);
switch layout
    case 'side'
        calib.centre = [-307 140 -428; 567 138 -426];
    case 'vertical'
        calib.centre = [120 -330 -430; 110 560 -428];
    case 'diagonal'
        calib.centre = [-200 -150 -430; 450 400 -428];
    case 'opposite'
        calib.centre = [-307 140 -428; -250 138 426];
end
[xo, yo] = intrinsicToWorld(calib.Ravg, [0.5 70.5 70.5 0.5], [0.5 0.5 60.5 60.5]);
calib.grid_info.overlap = polyshape(xo, yo);
[x, y] = meshgrid(5:5:65, 5:5:55);
end

function res = result_struct(x, y, u, v)
% the fields of a pivlab result that stereo.reconstruct uses
res.px.x = x;
res.px.y = y;
res.px.u = u;
res.px.v = v;
res.px.u_smoothed = [];
res.px.v_smoothed = [];
end

function p = project_both(C, X, Y, Z)
% central projection of points (X, Y, Z) onto the board plane z = 0 for both cameras
p = cell(1, 2);
for k = 1:2
    f = -C(k, 3) ./ (Z - C(k, 3));
    p{k} = cat(3, C(k, 1) + (X - C(k, 1)) .* f, C(k, 2) + (Y - C(k, 2)) .* f);
end
end

function [xs, ys, zs, du, dv] = sheet_points(calib, x, y, a, b, c)
% sheet points z = a + b*x + c*y [mm] seen at the output pixels (x, y) (midpoint of both projections),
% and the disparity there [px]
[xw, yw] = intrinsicToWorld(calib.Ravg, x, y);
C = calib.centre;
xs = xw; ys = yw;
for it = 1:30
    zs = a + b * xs + c * ys;
    p = project_both(C, xs, ys, zs);
    xs = xs + (xw - (p{1}(:,:,1) + p{2}(:,:,1)) / 2);
    ys = ys + (yw - (p{1}(:,:,2) + p{2}(:,:,2)) / 2);
end
zs = a + b * xs + c * ys;
p = project_both(C, xs, ys, zs);
du = (p{2}(:,:,1) - p{1}(:,:,1)) / calib.Ravg.PixelExtentInWorldX;
dv = (p{2}(:,:,2) - p{1}(:,:,2)) / calib.Ravg.PixelExtentInWorldY;
end

function [U, V, Wz] = flow(xw, yw)
% smooth test field [mm per pair]
U = 0.1 * sin(xw / 100) + 0.05;
V = 0.08 * cos(yw / 80) - 0.03;
Wz = 0.2 * exp(-((xw - 100) .^ 2 + (yw - 130) .^ 2) / 80 ^ 2) - 0.05;
end

function [result, err] = run_case(c, background)
if nargin < 2
    background = "none";
end
imgs = cell(1, 2);
for k = 1:2
    imgs{k} = pivlab.readImages(c.files{k}, "pairwise");
    imgs{k} = pivlab.preprocess(imgs{k}, Camera=c.lens{k}, CameraView="same", Verbose=false);
end
S = pivlab.defaults();
S.preprocess.Background = background;
S.analysis.InterrogationArea = 64;
S.analysis.Step = 32;
S.analysis.Passes = 3;
S.analysis.PassSizes = [32 16 16];
st = stereo.defaults();
st.disparity.InterrogationArea = 128;
st.disparity.PassSize2 = 64;
result = stereo.run(imgs, c.boards, c.board, Settings=S, Stereo=st, Verbose=false);
err = helper_stereo_truth_error(result.vel, c, result.calib);
end

function check_accuracy(testCase, err)
% mean field over the pairs [mm per pair], displacements up to 0.4 mm (4 px)
verifyLessThan(testCase, [err.rms_U err.rms_V err.rms_W], [0.008 0.008 0.01], 'rms error [mm] of U, V, W');
verifyLessThan(testCase, abs([err.bias_U err.bias_V err.bias_W]), [0.002 0.002 0.002], 'bias [mm] of U, V, W');
verifyLessThan(testCase, abs(err.W_slope - 1), 0.02, 'W scaled wrongly');
end
