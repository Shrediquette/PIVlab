%% Tests for the filter of wrongly decoded ChArUco markers (preproc.cam_filter_charuco_corners)
%
% A marker decoded with a wrong ID puts its corners at a wrong board position. The filter
% must remove such corners and keep all correct ones, also with strong lens distortion.
%
% Run with:
%   runtests('unittests/test_core_charuco_filter.m')

function tests = test_core_charuco_filter
tests = functiontests(localfunctions);
end

function setupOnce(~)
addpath(helper_root());
end

% -------------------------------------------------------------------------
% Corner lists (exact corner positions, no image)
% -------------------------------------------------------------------------

function test_correct_corners_kept(testCase)
% oblique view, strong barrel distortion, part of the board missing: nothing is removed
dims = [17 23];
P = board_corners(dims, [-0.3 0.08]);
rng(3);
P(rand(size(P, 1), 1) < 0.1, :) = NaN; % random corners not detected
P(corner_index(dims, 1:16, 1:4), :) = NaN; % one side of the board not detected
[Q, n_rejected] = preproc.cam_filter_charuco_corners(P, dims);
testCase.verifyEqual(n_rejected, 0);
testCase.verifyEqual(Q, P);
end

function test_wrong_markers_removed(testCase)
% three single wrong markers and a group of four neighbouring wrong markers that fit each other
dims = [17 23];
P = board_corners(dims, [-0.3 0.08]);
wrong = false(size(P, 1), 1);
moves = [3 4 12 18; 10 15 2 6; 14 2 7 20]; % [row col] of the true marker -> [row col] of the wrong ID
for m = 1:size(moves, 1)
    from = corner_index(dims, moves(m, 1) + [0 1], moves(m, 2) + [0 1]);
    to = corner_index(dims, moves(m, 3) + [0 1], moves(m, 4) + [0 1]);
    P(to, :) = P(from, :);
    wrong(to) = true;
end
from = corner_index(dims, 5:7, 5:7);
to = corner_index(dims, 11:13, 16:18);
P(to, :) = P(from, :);
wrong(to) = true;
[Q, n_rejected] = preproc.cam_filter_charuco_corners(P, dims);
removed = isnan(Q(:, 1)) & ~isnan(P(:, 1));
testCase.verifyTrue(all(removed(wrong)), 'Not all wrong corners removed.');
testCase.verifyLessThanOrEqual(nnz(removed & ~wrong), 2, 'Too many correct corners removed.');
testCase.verifyEqual(n_rejected, nnz(removed));
end

function test_duplicate_corner_one_checker_off(testCase)
% a marker read with the ID of its neighbour: its corners sit on the corners one row up, which
% are also detected. The wrong ones are removed, the correct ones at the same place stay.
dims = [17 23];
P = board_corners(dims, [-0.3 0.08]);
to = corner_index(dims, [9 10], [12 13]);
P(to, :) = P(corner_index(dims, [8 9], [12 13]), :);
[Q, n_rejected] = preproc.cam_filter_charuco_corners(P, dims);
correct = setdiff(find(~isnan(P(:, 1))), to);
testCase.verifyTrue(all(isnan(Q(to, 1))), 'Wrong corners kept.');
testCase.verifyEqual(Q(correct, :), P(correct, :), 'Correct corners removed.');
testCase.verifyEqual(n_rejected, numel(to));
end

function test_isolated_wrong_corners_removed(testCase)
% only part of the board detected, plus two wrong corners in an empty area of the image
dims = [17 23];
truth = board_corners(dims, [-0.3 0.08]);
P = nan(size(truth));
detected = corner_index(dims, 1:8, 1:10);
P(detected, :) = truth(detected, :);
P(corner_index(dims, 2, [15 16]), :) = truth(corner_index(dims, 12, [18 19]), :);
Q = preproc.cam_filter_charuco_corners(P, dims);
testCase.verifyTrue(all(isnan(Q(corner_index(dims, 2, [15 16]), 1))), 'Wrong corners kept.');
testCase.verifyEqual(Q(detected, :), P(detected, :), 'Correct corners removed.');
end

function test_scattered_corners_rejected(testCase)
% a few scattered corners can not be verified: the view is not used
dims = [17 23];
truth = board_corners(dims, [0 0]);
P = nan(size(truth));
some = corner_index(dims, [2 9 14], [3 12 20]);
P(some, :) = truth(some, :);
[Q, n_rejected] = preproc.cam_filter_charuco_corners(P, dims);
testCase.verifyTrue(all(isnan(Q(:))));
testCase.verifyEqual(n_rejected, numel(some));
end

% -------------------------------------------------------------------------
% Detection in images
% -------------------------------------------------------------------------

function test_detection_keeps_all_corners(testCase)
% PIVlab's detection (with the filter) finds the same corners as detectCharucoBoardPoints
dims = [11 14];
center = [(dims(2) - 2) / 2, (dims(1) - 2) / 2, 0] * 10;
cam = simulate.camera(ImageSize=[1000 1200], FocalLength=3000, Position=center + [-280 0 -300], Target=center, RadialDistortion=[0.15 -0.04]);
I = simulate.charuco_image(cam, PatternDims=dims, CheckerSize=10, MarkerSize=7, Blur=0.7);
plain = detectCharucoBoardPoints(I, dims, "DICT_4X4_1000", 10, 7, 'MinMarkerID', 0, 'OriginCheckerColor', 'black');
filtered = preproc.cam_detectCharucoBoardPoints_scaled(I, dims, 'DICT_4X4_1000', 10, 7, 'MinMarkerID', 0, 'OriginCheckerColor', 'black');
testCase.verifyEqual(filtered, plain);
end

function test_board_with_2000_checkers(testCase)
% the board generator allows rows x columns <= 2000 (DICT_4X4_1000: 1000 markers)
dims = [40 50];
c = 24; % px per checker
I = generateCharucoBoard(dims * c + 2 * c, dims, 'DICT_4X4_1000', c, round(0.7 * c), MarginSize=c);
P = preproc.cam_detectCharucoBoardPoints_scaled(I, dims, 'DICT_4X4_1000', 10, 7, 'MinMarkerID', 0, 'OriginCheckerColor', 'black');
testCase.verifyEqual(nnz(isnan(P(:, 1))), 0, 'Not all corners of the 2000-checker board found.');
end

% -------------------------------------------------------------------------
% Helpers
% -------------------------------------------------------------------------

function P = board_corners(dims, radial_distortion)
% exact image positions of the corners of an oblique board (order of patternWorldPoints)
center = [(dims(2) - 2) / 2, (dims(1) - 2) / 2, 0] * 10;
cam = simulate.camera(ImageSize=[1200 1600], FocalLength=1100, Position=center + [-150 60 -260], ...
    Target=center, RadialDistortion=radial_distortion);
wp = patternWorldPoints("charuco-board", dims, 10);
P = simulate.project(cam, [wp, zeros(size(wp, 1), 1)]);
end

function k = corner_index(dims, rows, cols)
% indices (order of patternWorldPoints) of the corners in the given board rows / columns (1-based)
grid = patternWorldPoints("charuco-board", dims, 1);
k = find(ismember(round(grid(:, 2)) + 1, rows) & ismember(round(grid(:, 1)) + 1, cols));
end
