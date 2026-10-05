%% Tests for the synthetic particle image generator (+simulate)
%
% The generated images are analysed with PIVlab's own PIV algorithm and the
% result is compared with the known displacement.
%
% Run with:
%   runtests('C:\...\unittests\test_simulate.m')

function tests = test_simulate
tests = functiontests(localfunctions);
end

function setupOnce(~)
addpath(fileparts(fileparts(mfilename('fullpath'))));
end

% -------------------------------------------------------------------------
% 2D flows of the GUI (orthographic camera, GUI default settings)
% -------------------------------------------------------------------------

function test_flow_shift(testCase)
flow.type = 'shift';
flow.shift = 5;
check_gui_flow(testCase, flow, 0.08);
end

function test_flow_rotation(testCase)
flow.type = 'rotation';
flow.rotation = 5;
check_gui_flow(testCase, flow, 0.08);
end

function test_flow_rankine_double(testCase)
flow.type = 'rankine';
flow.v0 = 8; flow.R0 = 100; flow.c1 = [200 300]; flow.c2 = [600 300]; flow.double = true;
check_gui_flow(testCase, flow, 0.1);
end

function test_flow_oseen(testCase)
flow.type = 'oseen';
flow.v0 = 5; flow.t = 0.05; flow.c1 = [200 300]; flow.c2 = [600 300]; flow.double = false;
check_gui_flow(testCase, flow, 0.08);
end

function test_flow_membrane(testCase)
flow.type = 'membrane';
check_gui_flow(testCase, flow, 0.08);
end

function test_displacement_sign(testCase)
% particles must move in the direction of the stored displacement
[X, Y] = meshgrid([1 256], [1 256]);
U = zeros(2, 2) + 3.3;
V = zeros(2, 2) - 2.2;
out = simulate.particle_images(ImageSize=[256 256], Particles=20000, Seed=1, X=X, Y=Y, U=U, V=V);
[u, v] = run_piv(out.A{1}, out.B{1});
testCase.verifyEqual(median(u(:), 'omitnan'), 3.3, 'AbsTol', 0.05);
testCase.verifyEqual(median(v(:), 'omitnan'), -2.2, 'AbsTol', 0.05);
end

function test_wrapper_generate_particle_image_pair(testCase)
[A, B] = simulate.generate_particle_image_pair(4.25, 0.001, img_size=256, partAm=15000);
testCase.verifyEqual(size(A), [256 256]);
testCase.verifyClass(A, 'double');
testCase.verifyLessThanOrEqual(max([A(:); B(:)]), 1);
[u, v] = run_piv(A, B);
testCase.verifyEqual(median(u(:), 'omitnan'), 0, 'AbsTol', 0.05);
testCase.verifyEqual(median(v(:), 'omitnan'), 4.25, 'AbsTol', 0.05);
end

function test_coarse_grid_field(testCase)
% any displacement field on any (uniformly spaced) grid: here a smooth
% random field on a coarse 9 x 7 grid, interpolated at the particle positions
rng(7);
[X, Y] = meshgrid(linspace(1, 512, 9), linspace(1, 384, 7));
U = 3 * rand(size(X)) - 1.5;
V = 3 * rand(size(X)) - 1.5;
out = simulate.particle_images(ImageSize=[384 512], Particles=40000, Seed=5, X=X, Y=Y, U=U, V=V);
[u, v, x, y] = run_piv(out.A{1}, out.B{1});
u_true = interp2(X, Y, U, x, y, 'cubic');
v_true = interp2(X, Y, V, x, y, 'cubic');
inner = x > 40 & x < 512 - 40 & y > 40 & y < 384 - 40;
testCase.verifyLessThan(rms([u(inner) - u_true(inner); v(inner) - v_true(inner)], 'omitnan'), 0.08);
end

% -------------------------------------------------------------------------
% Cameras
% -------------------------------------------------------------------------

function test_pinhole_magnification(testCase)
% camera 500 mm in front of the sheet, f = 2000 px: 0.5 mm -> 2 px
cam = simulate.camera(ImageSize=[384 384], FocalLength=2000, Position=[0 0 -500], Target=[0 0 0]);
[X, Y] = meshgrid([-100 100], [-100 100]);
U = zeros(2, 2) + 0.5;
V = zeros(2, 2);
out = simulate.particle_images(Cameras={cam}, Particles=8000, SheetThickness=1, Seed=2, X=X, Y=Y, U=U, V=V);
[u, v] = run_piv(out.A{1}, out.B{1});
testCase.verifyEqual(median(u(:), 'omitnan'), 2, 'AbsTol', 0.05);
testCase.verifyEqual(median(v(:), 'omitnan'), 0, 'AbsTol', 0.05);
end

function test_stereo_out_of_plane_projection(testCase)
% pure out-of-plane motion seen by two oblique cameras: the PIV displacement
% in each camera must equal the projection of the 3D particle displacement
% (W is 10 % of the sheet thickness; more out-of-plane loss mainly adds random error)
W = 0.4;
cams = {simulate.camera(ImageSize=[384 384], FocalLength=2400, Position=[-350 0 -350], Target=[0 0 0], RadialDistortion=[0.1 0]), ...
    simulate.camera(ImageSize=[384 384], FocalLength=2400, Position=[350 30 -350], Target=[0 0 0], RadialDistortion=[-0.05 0])};
[X, Y] = meshgrid([-40 40], [-40 40]);
out = simulate.particle_images(Cameras=cams, Region=[-40 40 -40 40], Particles=12000, SheetThickness=4, Seed=3, ...
    X=X, Y=Y, U=zeros(2, 2), V=zeros(2, 2), W=zeros(2, 2) + W);
for k = 1:2
    [u, v, x, y] = run_piv(out.A{k}, out.B{k});
    % sheet position seen by each vector, and the image displacement of a particle there
    P = [simulate.pixel_to_plane(cams{k}, [x(:), y(:)], rigidtform3d), zeros(numel(x), 1)];
    expected = simulate.project(cams{k}, P + [0 0 W]) - [x(:), y(:)];
    inner = all(abs(P(:, 1:2)) < 30, 2) & ~isnan(u(:));
    du = u(inner) - expected(inner, 1);
    dv = v(inner) - expected(inner, 2);
    testCase.verifyGreaterThan(mean(abs(expected(inner, 1))), 1, 'test setup: expected displacement too small');
    testCase.verifyLessThan(abs([mean(du), mean(dv)]), [0.02 0.02], sprintf('camera %d: bias', k));
    testCase.verifyLessThan(rms([du; dv]), 0.06, sprintf('camera %d: rmse', k));
end
end

function test_charuco_oblique(testCase)
dims = [11 14];
center = [(dims(2) - 2) / 2, (dims(1) - 2) / 2, 0] * 10;
cam = simulate.camera(ImageSize=[1000 1200], FocalLength=3000, Position=center + [-280 0 -300], Target=center, RadialDistortion=[0.15 -0.04]);
[I, corners] = simulate.charuco_image(cam, PatternDims=dims, CheckerSize=10, MarkerSize=7, Blur=0.7);
detected = detectCharucoBoardPoints(I, dims, "DICT_4X4_1000", 10, 7, 'MinMarkerID', 0, 'OriginCheckerColor', 'black', 'RefineCorners', true);
% detectCharucoBoardPoints reports corners +0.5 px off MATLAB's pixel centre convention
err = vecnorm(detected - 0.5 - corners, 2, 2);
testCase.verifyEqual(nnz(isnan(err)), 0, 'Not all corners detected.');
testCase.verifyLessThan(mean(err), 0.15);
end

% -------------------------------------------------------------------------
% Helpers
% -------------------------------------------------------------------------

function check_gui_flow(testCase, flow, max_rmse)
% generate an image pair like the GUI does with its default settings
sizex = 800; sizey = 600;
flow.imageSize = [sizey sizex];
type = flow.type;
[X, Y] = meshgrid(1:sizex, 1:sizey);
[U, V] = simulate.flow_field(flow, X, Y);
[A, B] = simulate.gui_images(X, Y, U, V, ...
    Particles=200000, SheetThickness=0.5, OutOfPlane=10, Diameter=3, DiameterVariation=1, Noise=0.001, Seed=4);
[u, v, x, y] = run_piv(A, B);
u_true = U(sub2ind(size(U), y, x)); % PIV grid points are integer pixel positions
v_true = V(sub2ind(size(V), y, x));
inner = x > 40 & x < sizex - 40 & y > 40 & y < sizey - 40;
du = u(inner) - u_true(inner);
dv = v(inner) - v_true(inner);
testCase.verifyLessThan(mean(isnan(du)), 0.02, [type ': too many invalid vectors']);
testCase.verifyLessThan(abs(mean(du, 'omitnan')), 0.05, [type ': u bias']);
testCase.verifyLessThan(abs(mean(dv, 'omitnan')), 0.05, [type ': v bias']);
testCase.verifyLessThan(rms([du; dv], 'omitnan'), max_rmse, [type ': rmse']);
end

function [u, v, x, y] = run_piv(A, B)
[x, y, u, v] = piv.piv_FFTmulti(image1=A, image2=B, interrogationarea=64, step=16, ...
    passes=3, int2=32, int3=16, imdeform='*spline');
[u, v] = postproc.PIVlab_postproc(u=u, v=v, do_stdev_check=1, stdthresh=7, do_local_median=1, neigh_thresh=3);
u = double(u);
v = double(v);
x = double(x);
y = double(y);
end
