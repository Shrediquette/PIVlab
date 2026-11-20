function tests = test_core_camcal
%TEST_CORE_CAMCAL Camera calibration and undistortion without OpenCV (+camcal).
%   camcal.estimate_camera_parameters and camcal.undistort_image replace the OpenCV MEX files of
%   PIVlab. unittests/camcal_reference.mat holds the results of the OpenCV MEX files (OpenCV 4.12,
%   made before they were removed): two board sets (real Scheimpflug camera, synthetic camera with
%   strong distortion) and undistorted images of all classes and views.
%   Run with: results = runtests('unittests/test_core_camcal.m')
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
addpath(helper_root());
S = load(fullfile(helper_root(), 'unittests', 'camcal_reference.mat'), 'ref');
testCase.TestData.ref = S.ref;
end

%% calibration: the results of OpenCV
function test_calibration_matches_opencv(testCase)
ref = testCase.TestData.ref;
for k = 1:numel(ref.boards)
	b = ref.boards(k);
	ip = double(b.imagePoints);
	cases = {'standard', 'standard_start', 'tilted', 'tilted_start', 'fixed_tilt'};
	first = [];
	first_t = [];
	for c = 1:numel(cases)
		switch cases{c}
			case 'standard'
				args = {};
			case 'standard_start'
				args = {first};
			case 'tilted'
				args = {'use_tilted_model', true};
			case 'tilted_start'
				args = {first_t, 'use_tilted_model', true};
			case 'fixed_tilt'
				args = {'use_tilted_model', true, 'tilt_angle_y', 5};
		end
		[~, cp, used, st] = evalc_estimate(ip, b, args);
		if strcmp(cases{c}, 'standard')
			first = cp;
		end
		if strcmp(cases{c}, 'tilted')
			first_t = cp;
		end
		r = b.(cases{c});
		label = [b.name ' ' cases{c}];
		verifyEqual(testCase, used, r.imagesUsed, label);
		verifyEqual(testCase, numel(st.D_full), numel(r.D_full), [label ': length of D']);
		verifyEqual(testCase, st.MeanReprojectionError, r.MeanReprojectionError, 'RelTol', 1e-4, [label ': reprojection error']);
		% the undistortion maps: identical, except the free tilt of the synthetic camera (true tilt
		% 0: very flat error valley, OpenCV stops after 30 iterations; the maps differ by a projective
		% transform that the rectification takes up)
		limit = 0.01;
		if contains(b.name, 'synthetic') && any(strcmp(cases{c}, {'tilted', 'tilted_start'}))
			limit = 0.5;
		end
		verifyLessThan(testCase, map_difference(r.K_opencv, r.D_full, st.K_opencv, st.D_full, b.imageSize), limit, [label ': undistortion map (px)']);
		if strcmp(cases{c}, 'fixed_tilt')
			verifyEqual(testCase, [st.tilt_candidates.tilt_angle_y], [r.tilt_candidates.tilt_angle_y], label);
			verifyEqual(testCase, rad2deg(st.D_full(14)), rad2deg(r.D_full(14)), 'AbsTol', 1e-9, [label ': sign chosen']);
		end
		if any(strcmp(cases{c}, {'standard', 'standard_start'}))
			verifyEqual(testCase, cp.RotationVectors, r.RotationVectors, 'AbsTol', 1e-5, [label ': board poses']);
			verifyEqual(testCase, cp.TranslationVectors, r.TranslationVectors, 'RelTol', 1e-4, [label ': board poses']);
		end
	end
end
end

function test_noise_free_camera_is_recovered_exactly(testCase)
% standard model; tilted model with the tilt fixed to the true value. (A free tilt converges as
% slowly as in OpenCV, whose solver is reproduced: see test_calibration_matches_opencv.)
[ip, wp, sz, K, D] = synthetic_boards(0, [0 0]);
[Km, Dm, ~, ~, info] = camcal.calibrate_camera(ip, wp, sz, struct('max_iterations', 200));
verifyLessThan(testCase, info.rms, 1e-6, 'standard model');
verifyEqual(testCase, Km, K, 'RelTol', 1e-7, 'standard model');
verifyEqual(testCase, Dm(1:4), D(1:4), 'AbsTol', 1e-7, 'standard model');
[ip, wp, sz, K, D] = synthetic_boards(0, [0.6 4.5]);
start = struct('tilted', true, 'fix_tilt', true, 'K_init', K .* [1.01 1 1.02; 1 0.99 0.98; 1 1 1], 'D_init', [0 0 0 0 zeros(1, 8) D(13:14)], 'max_iterations', 200);
[Km, Dm, ~, ~, info] = camcal.calibrate_camera(ip, wp, sz, start);
verifyLessThan(testCase, info.rms, 1e-6, 'tilted model');
verifyEqual(testCase, Km, K, 'RelTol', 1e-7, 'tilted model');
verifyEqual(testCase, Dm, D, 'AbsTol', 1e-7, 'tilted model');
end

function test_fixed_tilt_keeps_principal_point_closest_to_centre(testCase)
[ip, wp, sz] = synthetic_boards(0.05);
[~, ~, ~, st] = evalc('camcal.estimate_camera_parameters(ip, wp, sz, ''use_tilted_model'', true, ''tilt_angle_y'', 4.5)');
verifyNumElements(testCase, st.tilt_candidates, 2);
d = [st.tilt_candidates.distance_to_centre];
[~, best] = min(d);
verifyEqual(testCase, rad2deg(st.D_full(14)), st.tilt_candidates(best).tilt_angle_y, 'AbsTol', 1e-9);
verifyEqual(testCase, st.D_full(13), 0);
end

%% undistortion: the images of OpenCV
function test_undistortion_matches_opencv(testCase)
u = testCase.TestData.ref.undistort;
for view = {'same', 'valid', 'full'}
	a = camcal.undistort_image(u.uint8, u.K, u.D, view{1});
	verifyEqual(testCase, a, u.(['out_uint8_' view{1}]), ['uint8 ' view{1} ': identical']);
	a = camcal.undistort_image(u.uint16, u.K, u.D, view{1});
	ref16 = u.(['out_uint16_' view{1}]);
	d = abs(double(a) - double(ref16));
	verifyLessThanOrEqual(testCase, max(d(:)), 1, ['uint16 ' view{1} ': at most one count']);
	verifyLessThan(testCase, nnz(d) / numel(d), 0.002, ['uint16 ' view{1} ': almost all identical']);
end
a = camcal.undistort_image(u.double, u.K, u.D, 'same');
verifyEqual(testCase, a, u.out_double_same, 'AbsTol', 1e-12, 'double: rounding only');
end

function test_output_class_and_size(testCase)
K = [80 0 50; 0 80 50; 0 0 1];
D = [-0.1 0.05 0 0];
rng(1);
imgs = {uint8(randi(255, 100, 100)), uint16(randi(65535, 100, 100)), rand(100, 100), single(rand(100, 100))};
for k = 1:numel(imgs)
	out = camcal.undistort_image(imgs{k}, K, D);
	verifyClass(testCase, out, class(imgs{k}));
	verifySize(testCase, out, [100 100]);
end
rgb = uint8(randi(255, 100, 100, 3));
verifySize(testCase, camcal.undistort_image(rgb, K, D), [100 100 3]);
end

function test_narrow_grey_value_range_is_kept(testCase)
% PIV images: the grey values must not be rescaled (e.g. uint16 in [65500, 65535])
K = [80 0 50; 0 80 50; 0 0 1];
D = [-0.1 0.05 0 0];
rng(2);
img = uint16(65500 + uint16(randi(36, 100, 100) - 1));
out = camcal.undistort_image(img, K, D);
crop = out(10:end-10, 10:end-10);
verifyGreaterThan(testCase, double(min(crop(:))), 60000);
img = 0.95 + 0.05 * rand(100, 100);
out = camcal.undistort_image(img, K, D);
crop = out(10:end-10, 10:end-10);
verifyGreaterThan(testCase, min(crop(:)), 0.8);
end

function test_same_geometry_as_matlab_undistortImage(testCase)
% standard model: the same lens model as MATLAB (interpolation kernels differ)
K = [80 0 50; 0 80 50; 0 0 1];
D = [-0.1 0.05 0 0];
params = cameraParameters('K', K, 'RadialDistortion', D(1:2), 'TangentialDistortion', D(3:4), 'ImageSize', [100 100]);
[xx, yy] = meshgrid(1:100, 1:100);
img = uint8(128 + 60 * sin(xx / 4) .* cos(yy / 5));
a = double(camcal.undistort_image(img, K, D));
b = double(undistortImage(img, params, 'cubic', 'OutputView', 'same'));
crop_a = a(10:end-10, 10:end-10);
crop_b = b(10:end-10, 10:end-10);
verifyLessThan(testCase, mean(abs(crop_a(:) - crop_b(:))), 2);
end

%% model functions
function test_project_and_undistort_points_are_inverse(testCase)
K = [1500 0 640; 0 1510 500; 0 0 1];
D = zeros(1, 14);
D(1:4) = [-0.2 0.1 1e-3 -5e-4];
D(13:14) = deg2rad([1 -6]);
[x, y] = meshgrid(linspace(-0.35, 0.35, 15), linspace(-0.3, 0.3, 13));
X = [x(:) y(:) ones(numel(x), 1)];
p = camcal.project_points(X, [0 0 0], [0 0 0], K, D);
xn = camcal.undistort_points(p, K, D, 50);
verifyEqual(testCase, xn, [x(:) y(:)], 'AbsTol', 1e-9);
end

function test_tilt_matrix_and_rotation_vectors(testCase)
[T, T_inv, dTx, dTy] = camcal.tilt_matrix(0.02, -0.07);
verifyEqual(testCase, T * T_inv, eye(3), 'AbsTol', 1e-12);
h = 1e-6;
verifyEqual(testCase, dTx, (camcal.tilt_matrix(0.02 + h, -0.07) - camcal.tilt_matrix(0.02 - h, -0.07)) / (2 * h), 'AbsTol', 1e-8);
verifyEqual(testCase, dTy, (camcal.tilt_matrix(0.02, -0.07 + h) - camcal.tilt_matrix(0.02, -0.07 - h)) / (2 * h), 'AbsTol', 1e-8);
for r = {[0.3 -0.2 0.1], [0 0 0], [pi * 0.999 0 0], [1e-9 0 2e-9]}
	R = camcal.rotvec_to_matrix(r{1});
	verifyEqual(testCase, R * R', eye(3), 'AbsTol', 1e-12);
	verifyEqual(testCase, camcal.rotvec_to_matrix(camcal.matrix_to_rotvec(R)), R, 'AbsTol', 1e-9);
end
end

function test_camera_position_plot(testCase)
[ip, wp, sz] = synthetic_boards(0.05);
[~, cp] = evalc('camcal.estimate_camera_parameters(ip, wp, sz)');
f = figure('Visible', 'off');
camcal.show_extrinsics(cp, f);
verifyNotEmpty(testCase, findobj(f, 'Type', 'axes'));
close(f);
end

%% helpers
function [txt, cp, used, st] = evalc_estimate(ip, b, args)
[txt, cp, used, st] = evalc('camcal.estimate_camera_parameters(ip, b.worldPoints, b.imageSize, args{:})');
end

function md = map_difference(K1, D1, K2, D2, sz)
% largest difference of the undistortion map ('same' view) on a 41 x 41 grid (px)
[jj, ii] = meshgrid(linspace(0, sz(2) - 1, 41), linspace(0, sz(1) - 1, 41));
[x1, y1] = camcal.distort_normalized((jj - K1(1,3)) / K1(1,1), (ii - K1(2,3)) / K1(2,2), D1);
[x2, y2] = camcal.distort_normalized((jj - K2(1,3)) / K2(1,1), (ii - K2(2,3)) / K2(2,2), D2);
md = max(hypot(K1(1,1) * x1 + K1(1,3) - K2(1,1) * x2 - K2(1,3), K1(2,2) * y1 + K1(2,3) - K2(2,2) * y2 - K2(2,3)), [], 'all');
end

function [imagePoints, worldPoints, imageSize, K, D] = synthetic_boards(noise, tilt_deg)
% 25 views of a 22 x 17 point board, camera with a tilted sensor (tilt_deg [x y], default [0.6 4.5])
if nargin < 2
	tilt_deg = [0.6 4.5];
end
rng(11);
imageSize = [2048 2448];
[gx, gy] = meshgrid(0:21, 0:16);
worldPoints = [gx(:) gy(:)] * 10;
K = [6000 0 1270; 0 6010 990; 0 0 1];
D = zeros(1, 14);
D(1:4) = [-0.12 0.25 8e-4 -5e-4];
D(13:14) = deg2rad(tilt_deg);
nv = 25;
imagePoints = nan(size(worldPoints, 1), 2, nv);
centre = [mean(worldPoints) 0];
for v = 1:nv
	a = deg2rad([(rand - 0.5) * 80, (rand - 0.5) * 80, (rand - 0.5) * 60]);
	Rx = [1 0 0; 0 cos(a(1)) -sin(a(1)); 0 sin(a(1)) cos(a(1))];
	Ry = [cos(a(2)) 0 sin(a(2)); 0 1 0; -sin(a(2)) 0 cos(a(2))];
	Rz = [cos(a(3)) -sin(a(3)) 0; sin(a(3)) cos(a(3)) 0; 0 0 1];
	R = Rz * Ry * Rx;
	t = [(rand - 0.5) * 40; (rand - 0.5) * 40; 900 + rand * 600] - R * centre';
	p = camcal.project_points([worldPoints zeros(size(worldPoints, 1), 1)], camcal.matrix_to_rotvec(R), t, K, D);
	p = p + noise * randn(size(p));
	inside = p(:, 1) > 0 & p(:, 1) < imageSize(2) & p(:, 2) > 0 & p(:, 2) < imageSize(1);
	p(~inside, :) = NaN;
	imagePoints(:, :, v) = p;
end
end
