function tests = test_truth_camera
%TEST_TRUTH_CAMERA One tilted camera with lens distortion (300 x 300 px): pivlab.preprocess with the true
%   lens (Camera) and a rectification from known sheet points (Rectification) -> pivlab.analyze ->
%   pivlab.toMetric -> pivlab.derive. The displacements in mm, their signs for all axis settings and the
%   vorticity match the truth of the light sheet (measured rms error 2.7 % of the largest displacement,
%   tolerance 5 %); without the correction the error is 3 times larger.
%   No PIVlab window (about 15 s).
%   Run with: run_pivlab_tests('test_truth_camera')
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
helper_setup_once(testCase);
sz = [300 300];
cam = simulate.camera(ImageSize=sz, FocalLength=1500, Position=[-250 20 -380], Target=[0 0 0], ...
    RadialDistortion=[-0.15 0.05]);
lens = cameraParameters(K=cam.intrinsics.K, RadialDistortion=cam.intrinsics.RadialDistortion, ...
    TangentialDistortion=cam.intrinsics.TangentialDistortion, ImageSize=sz);
fp = simulate.footprint(cam, rigidtform3d);
box = [min(fp(:, 1)) max(fp(:, 1)) min(fp(:, 2)) max(fp(:, 2))];
[X, Y] = meshgrid(box(1) - 5:0.5:box(2) + 5, box(3) - 5:0.5:box(4) + 5);
% linear flow on the light sheet (z = 0), mm per image pair. World (board) axes: x right, y down;
% the flow is written with Yup = -y (up on the screen)
F.u0 = 0.25; F.v0 = 0.15; F.omega = 0.006; F.a = 0.002; F.s = 0.003;
Yup = -Y;
U = F.u0 + (F.a + F.s) * X - F.omega * Yup;
Vup = F.v0 + F.omega * X + (F.a - F.s) * Yup;
n_particles = round(0.06 * prod(sz) * (box(2) - box(1)) * (box(4) - box(3)) / polyarea(fp(:, 1), fp(:, 2)));
files = strings(1, 6);
for n = 1:3
    out = simulate.particle_images(Cameras={cam}, Region=box, X=X, Y=Y, U=U, V=-Vup, Particles=n_particles, ...
        SheetThickness=1, Diameter=3, DiameterVariation=0.5, Seed=n);
    files(2 * n - 1) = fullfile(testCase.TestData.Dir, sprintf('cam_%dA.tif', n));
    files(2 * n) = fullfile(testCase.TestData.Dir, sprintf('cam_%dB.tif', n));
    imwrite(out.A{1}, files(2 * n - 1));
    imwrite(out.B{1}, files(2 * n));
end
% rectification as the GUI makes it from a board: undistorted image points -> sheet points in px
mmpp = (box(2) - box(1)) / sz(2);
[gx, gy] = meshgrid(linspace(box(1) + 3, box(2) - 3, 8), linspace(box(3) + 3, box(4) - 3, 8));
P = [gx(:) gy(:) zeros(numel(gx), 1)];
undistorted = undistortPoints(simulate.project(cam, P), lens.Intrinsics);
tform = fitgeotform2d(undistorted, P(:, 1:2) / mmpp, 'projective');
imgs = pivlab.readImages(files, "pairwise");
corrected = pivlab.preprocess(imgs, Camera=lens, CameraView="same", Rectification=tform, Verbose=false);
D.res = pivlab.analyze(corrected, InterrogationArea=48, Step=16, Passes=2, PassSizes=24, Verbose=false);
D.raw = pivlab.analyze(pivlab.preprocess(imgs, Verbose=false), InterrogationArea=48, Step=16, Passes=2, ...
    PassSizes=24, Verbose=false);
[~, RB] = imwarp(zeros(sz), tform);   % the rectified image of pivlab.preprocess (imwarp, default view)
D.RB = RB;
D.mmpp = mmpp;
D.box = box;
D.X = X; D.Y = Y; D.U = U; D.Vup = Vup;
D.F = F;
testCase.TestData.D = D;
end

function teardownOnce(testCase)
helper_teardown_once(testCase);
end

function setup(testCase)
helper_truth_log(testCase, 'start');
end

function teardown(testCase)
helper_truth_log(testCase, 'end');
end

function test_displacement_in_mm(testCase)
D = testCase.TestData.D;
res = D.res;
testCase.verifyEqual(res.images.imageSize, D.RB.ImageSize, 'size of the rectified image');
[T, ok] = truth_on_grid(D, res);
um = mean(res.px.u, 3);
vm = mean(res.px.v, 3);
vmax = max(abs([T.U(ok); T.V(ok)])) * D.mmpp;
eu = rms_error(um(ok) * D.mmpp, T.U(ok) * D.mmpp);
ev = rms_error(-vm(ok) * D.mmpp, T.V(ok) * D.mmpp);
testCase.verifyLessThan(eu, 0.05 * vmax, sprintf('rms error of u %.4f mm (tolerance %.4f)', eu, 0.05 * vmax));
testCase.verifyLessThan(ev, 0.05 * vmax, sprintf('rms error of v %.4f mm (tolerance %.4f)', ev, 0.05 * vmax));
% without lens correction and rectification (pixels taken as mm on the sheet) the error is much larger
raw = D.raw;
xw = D.box(1) + (double(raw.px.x) - 0.5) * D.mmpp;
yw = D.box(3) + (double(raw.px.y) - 0.5) * D.mmpp;
Ut = interp2(D.X, D.Y, D.U, xw, yw);
ur = mean(raw.px.u, 3) * D.mmpp;
okr = ~isnan(Ut) & ~isnan(ur);
er = rms_error(ur(okr), Ut(okr));
testCase.verifyGreaterThan(er, 2 * eu, sprintf('test sensitivity: without the correction the error is %.4f mm', er));
end

function test_axis_settings_and_vorticity(testCase)
D = testCase.TestData.D;
res = pivlab.filter(D.res, Verbose=false);
[T, ok] = truth_on_grid(D, res);
x = double(res.px.x);
y = double(res.px.y);
C = helper_truth_cases('short');
for k = 5:8   % m/s with the scale of the rectified image, all axis settings
    c = C(k);
    c.kind = 'ms';
    c.origin = [];
    c.px_per_m = 1000 / D.mmpp;
    c.calxy = D.mmpp / 1000;
    c.name = strrep(c.name, 'orig', 'rectified');
    r = helper_truth_calibrate(res, c);
    E = helper_truth_expected(T, c, x, y, res.images.imageSize);
    um = mean(r.u, 3);
    vm = mean(r.v, 3);
    vmax = max(abs([E.u(ok); E.v(ok)]));
    testCase.verifyLessThan(rms_error(um(ok), E.u(ok)), 0.05 * vmax, [c.name ': u in m/s']);
    testCase.verifyLessThan(rms_error(vm(ok), E.v(ok)), 0.05 * vmax, [c.name ': v in m/s']);
    [~, m] = pivlab.derive(r, "vorticity");
    m = mean(m, 3);
    inner = ok;
    inner([1 end], :) = false;
    inner(:, [1 end]) = false;
    truth = E.vorticity(1);   % constant (linear flow)
    testCase.verifyLessThan(abs(median(m(inner), 'omitnan') - truth), 0.1 * abs(truth), ...
        sprintf('%s: median vorticity %.4g, truth %.4g', c.name, median(m(inner), 'omitnan'), truth));
end
end

%% ------------------------------------------------------------------ local functions

function [T, ok] = truth_on_grid(D, res)
% truth at the vector positions of the rectified image, in px per pair of the rectified image,
% in the form of helper_truth_field (U right, V up on the screen)
RB = D.RB;
xw = (RB.XWorldLimits(1) + (double(res.px.x) - 0.5) * RB.PixelExtentInWorldX) * D.mmpp;
yw = (RB.YWorldLimits(1) + (double(res.px.y) - 0.5) * RB.PixelExtentInWorldY) * D.mmpp;
T.U = interp2(D.X, D.Y, D.U, xw, yw) / D.mmpp;
T.V = interp2(D.X, D.Y, D.Vup, xw, yw) / D.mmpp;
T.u = T.U;
T.v = -T.V;
T.w = zeros(size(T.U));
F = D.F;
T.ux = (F.a + F.s) + zeros(size(T.U));
T.uy = -F.omega + zeros(size(T.U));
T.vx = F.omega + zeros(size(T.U));
T.vy = (F.a - F.s) + zeros(size(T.U));
m = 3;   % mm away from the edge of the seeded area
ok = ~isnan(T.U) & xw > D.box(1) + m & xw < D.box(2) - m & yw > D.box(3) + m & yw < D.box(4) - m;
ok = ok & ~isnan(mean(res.px.u, 3));
end

function e = rms_error(a, b)
valid = ~isnan(a) & ~isnan(b);
e = sqrt(mean((double(a(valid)) - double(b(valid))).^2));
end
