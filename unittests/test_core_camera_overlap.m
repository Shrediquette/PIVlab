%% Tests of acquisition.camera_overlap: the view of the other camera in the live image (stereo acquisition) and
% in the camera views of the particle image generator (simulate.preview_3d)
%
% Markers of a ChArUco board at their exact positions in two simulated cameras with lens distortion. The
% overlap must be the same at every update (RANSAC samples randomly) and close to the true overlap.
%
% Run with:
%   runtests('unittests/test_core_camera_overlap.m')

function tests = test_core_camera_overlap
tests = functiontests(localfunctions);
end

function setupOnce(~)
addpath(helper_root());
end

function test_small_overlap_side_by_side(testCase)
% cameras side by side (larger field of view): the common markers are one column, a projective fit from it
% extrapolated to anything (62 % / 100 % instead of 8 % at some updates)
s = side_by_side_setup();
[markers, truth] = board_markers(s);
check_overlap(testCase, markers, truth, 0.02);
verifyLessThan(testCase, truth, 0.15, 'test case: a small overlap');
end

function test_large_overlap_stereo(testCase)
% stereo-PIV (default setup): a large overlap, projective fit
s = simulate.setup_3d(Mode='cameras');
[markers, truth] = board_markers(s);
check_overlap(testCase, markers, truth, 0.05);
verifyGreaterThan(testCase, truth, 0.5, 'test case: a large overlap');
end

function check_overlap(testCase, markers, truth, tolerance)
f = zeros(20, 2);
for r = 1:20
    ov = acquisition.camera_overlap(markers);
    verifyTrue(testCase, ov.ok);
    f(r, :) = ov.fraction;
end
verifyLessThan(testCase, max(f) - min(f), 0.002, 'the same overlap at every update');
verifyEqual(testCase, f(1, :), truth, 'AbsTol', tolerance, 'overlap close to the truth');
end

function s = side_by_side_setup()
% the settings of the generator panel (axes of the results) of the user's report
s = simulate.setup_3d(Mode='cameras');
s.board.PatternDims = [14 46];
shown = simulate.result_axes(s);
shown.cameras(1).Position = [120 75 750];
shown.cameras(1).Target = [120 75];
shown.cameras(2).Position = [399 75 750];
shown.cameras(2).Target = [400 75];
shown.cameras(1).RadialDistortion = [-0.45 0.1];
shown.cameras(2).RadialDistortion = [-0.35 0.05];
s = simulate.result_axes(shown);
end

function [markers, truth] = board_markers(s)
% markers on every checker of the board (corners in the order of readArucoMarker), as the detection finds
% them: all corners in the image. truth: part of each camera's image that the other camera sees (dense
% board points in both cameras, sampled at the pixels of each camera)
g = simulate.geometry_3d(s);
S = s.board.CheckerSize;
half = s.board.MarkerSize / 2;
[cx, cy] = meshgrid((0:s.board.PatternDims(2) - 1) - 0.5, (0:s.board.PatternDims(1) - 1) - 0.5); % checker centres / S
centres = [cx(:), cy(:)] * S;
offsets = [-1 -1; 1 -1; 1 1; -1 1] * half;
n = size(centres, 1);
P = zeros(4 * n, 3);
for c = 1:4
    P(c:4:end, 1:2) = centres + offsets(c, :);
end
[bx, by] = meshgrid(-400:2:900, -300:2:500); % board points around the board
B = [bx(:), by(:), zeros(numel(bx), 1)];
markers = cell(1, 2);
seen_b = cell(1, 2);
qb = cell(1, 2);
for k = 1:2
    cam = g.cams{k};
    [q, inside] = in_image(cam, P);
    seen = all(reshape(inside, 4, n), 1);
    locs = permute(reshape(q, 4, n, 2), [1 3 2]);
    markers{k} = struct('ids', find(seen)', 'locs', locs(:, :, seen), 'size', cam.imageSize);
    [qb{k}, seen_b{k}] = in_image(cam, B);
end
truth = zeros(1, 2);
for k = 1:2
    sz = g.cams{k}.imageSize;
    seen_by_other = scatteredInterpolant(qb{k}(seen_b{k}, :), double(seen_b{3 - k}(seen_b{k})), 'nearest');
    [px, py] = meshgrid(linspace(1, sz(2), 200), linspace(1, sz(1), 200));
    truth(k) = mean(seen_by_other(px(:), py(:)));
end
end

function [q, inside] = in_image(cam, P)
% as simulate.preview_3d: in front of the camera, in the image, not folded back by the distortion model
sz = cam.imageSize;
q = simulate.project(cam, P);
Pc = transformPointsForward(cam.pose, P);
u = world2img(P, cam.pose, cam.intrinsics);
inside = Pc(:, 3) > 0 & q(:, 1) > 0.5 & q(:, 1) < sz(2) + 0.5 & q(:, 2) > 0.5 & q(:, 2) < sz(1) + 0.5 & ...
    u(:, 1) > -0.5 * sz(2) & u(:, 1) < 1.5 * sz(2) & u(:, 2) > -0.5 * sz(1) & u(:, 2) < 1.5 * sz(1);
end
