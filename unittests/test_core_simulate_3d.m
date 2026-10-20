%% Tests for the 3D / stereo particle image generator (simulate.setup_3d, geometry_3d, recording_3d)
%
% A small recording (low resolution) is generated: files, ground truth, true lens files and the
% printed-board decoration. The board corners are found in the board image and in the
% calibration images. (The whole stereo-PIV workflow on such data: test_stereo_core.)
%
% Run with:
%   runtests('unittests/test_core_simulate_3d.m')

function tests = test_core_simulate_3d
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
addpath(helper_root());
s = simulate.setup_3d();
s.sensor.PixelPitch = s.sensor.PixelPitch * s.sensor.ImageSize(2) / 640; % same field of view as the default camera
s.sensor.ImageSize = [480 640];
s.output.Pairs = 1;
s.output.CalibrationImages = 3;
testCase.TestData.Setup = s;
testCase.TestData.Dir = tempname;
testCase.TestData.Result = simulate.recording_3d(s, testCase.TestData.Dir);
end

function teardownOnce(testCase)
if isfolder(testCase.TestData.Dir)
    rmdir(testCase.TestData.Dir, 's');
end
end

function test_files(testCase)
D = testCase.TestData.Dir;
s = testCase.TestData.Setup;
for k = 1:2
    c = fullfile(D, sprintf('camera%d', k));
    testCase.verifyTrue(isfile(fullfile(c, sprintf('board_in_light_sheet_cam%d.tif', k))));
    testCase.verifyTrue(isfile(fullfile(c, sprintf('true_lens_cam%d.mat', k))));
    testCase.verifyNumElements(dir(fullfile(c, 'calibration_images', '*.tif')), s.output.CalibrationImages);
    testCase.verifyNumElements(dir(fullfile(c, 'particle_images', '*.tif')), 2 * s.output.Pairs);
    I = imread(fullfile(c, 'particle_images', sprintf('cam%d_0001_A.tif', k)));
    testCase.verifySize(I, s.sensor.ImageSize);
    density = nnz(imregionalmax(I) & I > 30) / numel(I);
    testCase.verifyGreaterThan(density, 0.3 * s.particles.Density, 'too few particles');
end
testCase.verifyTrue(isfile(fullfile(D, 'ground_truth.mat')));
testCase.verifyTrue(isfile(fullfile(D, 'README.txt')));
end

function test_true_lens_file(testCase)
% the file of "Load camera parameters" holds the true lens of the camera
L = load(fullfile(testCase.TestData.Dir, 'camera2', 'true_lens_cam2.mat'));
testCase.verifyClass(L.cameraParams, 'cameraParameters');
testCase.verifyEqual(L.cameraParams.RadialDistortion, testCase.TestData.Setup.cameras(2).RadialDistortion);
testCase.verifyFalse(L.cam_use_tilted_model);
testCase.verifyNumElements(L.cam_selected_target_images, testCase.TestData.Setup.output.CalibrationImages);
end

function test_board_images_are_detected(testCase)
s = testCase.TestData.Setup;
b = s.board;
g = simulate.geometry_3d(s);
for k = 1:2
    I = imread(fullfile(testCase.TestData.Dir, sprintf('camera%d', k), sprintf('board_in_light_sheet_cam%d.tif', k)));
    p = detectCharucoBoardPoints(I, b.PatternDims, b.MarkerFamily, b.CheckerSize, b.MarkerSize);
    wp = patternWorldPoints("charuco-board", b.PatternDims, b.CheckerSize);
    truth = simulate.project(g.cams{k}, [wp, zeros(size(wp, 1), 1)]);
    ok = ~isnan(p(:, 1));
    testCase.verifyGreaterThan(nnz(ok), 30, sprintf('camera %d: board corners found', k));
    % detectCharucoBoardPoints reports corners +0.5 px off MATLAB's pixel centre convention (test_core_simulate)
    testCase.verifyLessThan(median(vecnorm(p(ok, :) - 0.5 - truth(ok, :), 2, 2)), 0.3, 'corner positions [px]');
end
% every calibration image shows a good part of the board
files = dir(fullfile(testCase.TestData.Dir, 'camera1', 'calibration_images', '*.tif'));
for n = 1:numel(files)
    I = imread(fullfile(files(n).folder, files(n).name));
    p = detectCharucoBoardPoints(I, b.PatternDims, b.MarkerFamily, b.CheckerSize, b.MarkerSize);
    testCase.verifyGreaterThan(nnz(~isnan(p(:, 1))), 20, files(n).name);
end
end

function test_board_decoration(testCase)
% the simulated board carries the QR code of the printed board
b = testCase.TestData.Setup.board;
tex = simulate.board_texture(b, 40, Decorated=true);
qr = tex.image(1:tex.m, 1:tex.m);
testCase.verifyGreaterThan(mean(qr(:) < 128), 0.2, 'QR code in the top left corner');
testCase.verifyEqual(tex.m, 3 * tex.c, 'margin of three checkers');
cam = simulate.camera(ImageSize=[900 1500], FocalLength=1400, Position=[96 48 -400], Target=[96 48 0]);
I = simulate.charuco_image(cam, Texture=tex);
info = preproc.cam_get_charuco_info_from_QRcode(I);
testCase.verifyNotEmpty(info, 'QR code readable in a front view');
end

function test_ground_truth(testCase)
load(fullfile(testCase.TestData.Dir, 'ground_truth.mat'), 'truth');
s = testCase.TestData.Setup;
testCase.verifyEqual(max(truth.W(:)), s.flow.OutOfPlane, 'RelTol', 0.02, 'jet peak');
testCase.verifyLessThanOrEqual(max(hypot(truth.U(:), truth.V(:))), s.flow.InPlane * 1.001);
% world coordinates: the sheet is offset towards camera 1 (z < 0) and tilted about x
g = simulate.geometry_3d(s);
testCase.verifyEqual(transformPointsForward(truth.sheet_pose, g.pivot), g.pivot + [0 0 -s.sheet.Offset], 'AbsTol', 1e-9);
R = truth.sheet_pose.R;
testCase.verifyEqual(truth.Ww, R(3, 1) * truth.U + R(3, 2) * truth.V + R(3, 3) * truth.W, 'AbsTol', 1e-12, 'W in board axes');
testCase.verifyNotEqual(truth.Ww, truth.W, 'the tilt of the sheet mixes V into W');
% truth_at_board: without offset and tilt, the board position is the sheet position
t0 = truth;
t0.sheet_pose = rigidtform3d;
[U, V, W] = simulate.truth_at_board(t0, [80 100], [40 60]);
testCase.verifyEqual(U, interp2(t0.X, t0.Y, t0.U, [80 100], [40 60]), 'AbsTol', 1e-12);
testCase.verifyEqual(V, interp2(t0.X, t0.Y, t0.V, [80 100], [40 60]), 'AbsTol', 1e-12);
testCase.verifyEqual(W, interp2(t0.X, t0.Y, t0.W, [80 100], [40 60]), 'AbsTol', 1e-12);
end

function test_flow_types(testCase)
% every flow type of the panel gives a field with the requested maximum displacement
s = testCase.TestData.Setup;
types = simulate.flow_types_3d;
g = simulate.geometry_3d(s);
for k = 1:numel(types)
    if strcmp(types{k}, 'sphere') % flow simulation, faster than the free stream around the sphere: test_sphere_recording
        continue
    end
    s.flow.Type = types{k};
    s.output.Pairs = 0;
    s.output.CalibrationImages = 0;
    D = tempname;
    cleanup = onCleanup(@() rmdir(D, 's'));
    r = simulate.recording_3d(s, D);
    inplane = hypot(r.truth.U, r.truth.V);
    [ox, oy] = boundary(g.overlap);
    inside = inpolygon(r.truth.X, r.truth.Y, ox, oy);
    % (rotation: InPlane at half the larger side of the overlap, a little more in its corners)
    testCase.verifyLessThan(abs(max(inplane(inside)) - s.flow.InPlane), 0.2 * s.flow.InPlane, types{k});
    clear cleanup
end
end

function test_sphere_wake_solver(testCase)
% simulate.sphere_wake on a small grid: free stream upstream, no flow in the sphere, a velocity
% deficit behind it, an unsteady wake after the spin-up, snapshots at the requested times
o = simulate.sphere_wake(Cells=[64 32 32], Diameter=8, Inlet=2, Count=3, Spacing=0.5, SpinUp=20, SlabCells=2);
testCase.verifySize(o.U, [32 64 4 3]);
testCase.verifyEqual(o.t, 20 + [0 0.5 1], 'AbsTol', 1e-9);
testCase.verifyFalse(any(isnan(o.U(:))));
[~, iy] = min(abs(o.y));
[~, ix_up] = min(abs(o.x + 1.5));
[~, ix_c] = min(abs(o.x));
[~, ix_wake] = min(abs(o.x - 1));
U = mean(o.U(:, :, 2:3, :), 3); % the two planes next to the sphere centre
testCase.verifyEqual(double(U(iy, ix_up, 1)), 1, 'AbsTol', 0.1, 'free stream upstream');
testCase.verifyEqual(double(U(iy, ix_c, 1)), 0, 'AbsTol', 1e-12, 'inside the sphere');
testCase.verifyLessThan(double(U(iy, ix_wake, 1)), 0.6, 'velocity deficit behind the sphere');
change = abs(o.V(:, :, :, 3) - o.V(:, :, :, 1));
testCase.verifyGreaterThan(max(change(:)), 0.02, 'the wake changes in time');
end

function test_sphere_recording(testCase)
% flow 'sphere': a time series (one truth page per image pair), the sphere has no particles,
% the free stream displacement and the truth at the board of a given pair
s = testCase.TestData.Setup;
s.flow.Type = 'sphere';
s.flow.Spacing = 0.5;
s.output.Pairs = 2;
s.output.CalibrationImages = 0;
D = tempname;
r = simulate.recording_3d(s, D);
t = r.truth;
testCase.verifySize(t.U, [size(t.X) 2]);
testCase.verifyEqual(t.sphere.Diameter, s.flow.Diameter);
testCase.verifyEqual(diff(t.sphere.Time), 0.5, 'AbsTol', 1e-9);
% free stream displacement upstream of the sphere, nothing inside
c = t.sphere.Centre;
up = interp2(t.X, t.Y, t.U(:, :, 1), c(1) - 1.2 * s.flow.Diameter, c(2));
testCase.verifyEqual(up, s.flow.InPlane, 'RelTol', 0.1);
testCase.verifyEqual(interp2(t.X, t.Y, t.U(:, :, 1), c(1), c(2)), 0, 'AbsTol', 1e-9);
testCase.verifyGreaterThan(max(abs(t.V(:, :, 2) - t.V(:, :, 1)), [], 'all'), 0.005 * s.flow.InPlane, 'time series');
% truth at the board of pair 2 (without sheet offset and tilt: the sheet position)
t0 = t;
t0.sheet_pose = rigidtform3d;
[U2, V2] = simulate.truth_at_board(t0, c(1) + [40 60], c(2) + [5 -5], Pair=2);
testCase.verifyEqual(U2, interp2(t.X, t.Y, t.U(:, :, 2), c(1) + [40 60], c(2) + [5 -5]), 'AbsTol', 1e-12);
testCase.verifyEqual(V2, interp2(t.X, t.Y, t.V(:, :, 2), c(1) + [40 60], c(2) + [5 -5]), 'AbsTol', 1e-12);
% no particles in the sphere: its image is dark in both cameras
g = simulate.geometry_3d(s);
for k = 1:2
    I = double(imread(fullfile(D, sprintf('camera%d', k), 'particle_images', sprintf('cam%d_0001_A.tif', k))));
    centre = simulate.project(g.cams{k}, transformPointsForward(g.sheet_pose, c));
    [xx, yy] = meshgrid(1:size(I, 2), 1:size(I, 1));
    radius_px = 0.3 * s.flow.Diameter / (g.region(2) - g.region(1)) * size(I, 2);
    in_sphere = hypot(xx - centre(1), yy - centre(2)) < radius_px;
    bright = I > 60; % particle images (sensor noise stays far below)
    testCase.verifyLessThan(mean(bright(in_sphere)), 0.05 * mean(bright(~in_sphere)), sprintf('camera %d: particles in the sphere', k));
end
testCase.verifySubstring(fileread(fullfile(D, 'README.txt')), 'sphere wake');
rmdir(D, 's');
end

function test_geometry_problems(testCase)
% a camera that looks past the light sheet, and cameras without a common view
s = testCase.TestData.Setup;
s.cameras(1).Position = [96 48 -10];
s.cameras(1).Target = [2000 48];
g = simulate.geometry_3d(s);
testCase.verifyFalse(g.ok);
s = testCase.TestData.Setup;
s.cameras(2).Target = [800 48];
s.cameras(2).Position = [800 48 -560];
g = simulate.geometry_3d(s);
testCase.verifyFalse(g.ok);
testCase.verifySubstring(g.message, 'overlap');
testCase.verifyError(@() simulate.recording_3d(s, tempname), 'simulate:recording_3d:geometry');
end

function test_single_camera(testCase)
s = testCase.TestData.Setup;
s.cameras = s.cameras(1);
s.output.CalibrationImages = 1;
g = simulate.geometry_3d(s);
testCase.verifyTrue(g.ok);
D = tempname;
cleanup = onCleanup(@() rmdir(D, 's'));
r = simulate.recording_3d(s, D);
testCase.verifyNumElements(r.particle_images, 1);
testCase.verifyFalse(isfolder(fullfile(D, 'camera2')));
end
