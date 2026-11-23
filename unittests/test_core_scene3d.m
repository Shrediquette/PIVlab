function tests = test_core_scene3d
%TEST_CORE_SCENE3D The 3D views of cameras and board (+scene3d): axes of the results, camera poses on the
% printed board (mirrored, turned), floor below / behind the board, the calibration view.
%   Run with: results = runtests('unittests/test_core_scene3d.m')
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
addpath(helper_root());
testCase.TestData.prefs = helper_save_preferences();
end

function teardownOnce(testCase)
helper_restore_preferences(testCase.TestData.prefs);
end

function teardown(~)
delete(findall(groot, 'Type', 'figure', 'Tag', 'scene3d_test'));
end

%% conversions
function test_result_axes(testCase)
board = sample_board();
y0 = (board.PatternDims(1) - 2) * board.CheckerSize;
P = [10 20 -30; 0 y0 0];
R = scene3d.to_result(P, y0);
verifyEqual(testCase, R(2, :), [0 0 0], 'the ''0'' of the board is the origin of the results');
verifyEqual(testCase, R(1, :), [10 y0 - 20 30], 'y up, z out of the board');
verifyEqual(testCase, scene3d.to_result(R, y0), P, 'its own inverse');
verifyEqual(testCase, R, simulate.result_axes(P, board), 'as simulate.result_axes');
cam = simulate.camera(ImageSize=[800 1000], FocalLength=3000, Position=[-150 60 -500], Target=[100 80 0]);
pose = scene3d.to_result(cam.pose, y0, 'pose');
verifyEqual(testCase, det(pose.R), 1, 'AbsTol', 1e-12, 'a proper rotation');
verifyEqual(testCase, pose.Translation, scene3d.to_result([-150 60 -500], y0), 'AbsTol', 1e-9);
end

function test_frame_mirrored_and_turned(testCase)
% data in another frame than the printed board (mirrored, turned): the scene shows them on the printed board
board = sample_board();
y0 = (board.PatternDims(1) - 2) * board.CheckerSize;
P = preproc.cam_board_corners(board.PatternDims, board.CheckerSize);
cam = simulate.camera(ImageSize=[800 1000], FocalLength=3000, Position=[-150 60 -500], Target=[100 80 0]);
E = cam.pose; % board as printed -> camera
cases = {diag([-1 1 -1]), 'mirrored (board seen from behind)'; [0 1 0; -1 0 0; 0 0 1], 'turned by 90 deg (tall board)'; ...
    [0 1 0; 1 0 0; 0 0 -1], 'turned and mirrored'};
fig = figure('Visible', 'off', 'Tag', 'scene3d_test');
ax = axes(fig);
scene3d.init(ax);
for c = 1:size(cases, 1)
    Q = cases{c, 1};
    shift = [7; -40; 0];
    F = (Q(1:2, 1:2) * P' + shift(1:2))'; % the corners in the frame of the estimation
    frame = rigidtform3d(E.R * Q', (E.Translation(:) - E.R * Q' * shift)'); % frame -> camera
    verifyEqual(testCase, transformPointsForward(frame, [F zeros(size(F, 1), 1)]), ...
        transformPointsForward(E, [P zeros(size(P, 1), 1)]), 'AbsTol', 1e-9, ['test case: ' cases{c, 2}]);
    T = scene3d.frame_transform(F, P);
    verifyEqual(testCase, transformPointsForward(T, [F zeros(size(F, 1), 1)]), [P zeros(size(P, 1), 1)], 'AbsTol', 1e-9, cases{c, 2});
    scene3d.clear(ax, 'all');
    scene3d.board(ax, board, Frame=T);
    pose = scene3d.result(ax, frame, 'pose');
    truth = scene3d.to_result(E, y0, 'pose');
    verifyEqual(testCase, pose.R, truth.R, 'AbsTol', 1e-9, cases{c, 2});
    verifyEqual(testCase, pose.Translation, truth.Translation, 'AbsTol', 1e-6, cases{c, 2});
    % and back (mouse): points and directions
    Pf = [F(1:3, :), [0; 5; -9]];
    verifyEqual(testCase, scene3d.to_board(ax, scene3d.result(ax, Pf)), Pf, 'AbsTol', 1e-9, cases{c, 2});
    verifyEqual(testCase, scene3d.to_board(ax, scene3d.result(ax, [0.6 0 0.8], 'direction'), 'direction'), [0.6 0 0.8], 'AbsTol', 1e-12);
end
close(fig);
end

function test_tall_board_rectification_image(testCase)
% board with more rows than columns, seen from the front and from behind (mirrored): the camera position of
% "Show camera position" (rectification image) from the rendered and detected board, as the callback does it
dims = [21 14];
S = 12;
centre = [(dims(2) - 2) * S / 2, (dims(1) - 2) * S / 2, 0];
for position = {[-120 40 -520], [260 300 480]}
    cam = simulate.camera(ImageSize=[1200 1600], FocalLength=4200, Position=position{1}, Target=centre);
    img = simulate.charuco_image(cam, PatternDims=dims, CheckerSize=S, MarkerSize=9, Decorated=true);
    [ip, mirrored] = preproc.cam_detect_rectification_board(img, dims, 'DICT_4X4_1000', S, 9, 'black');
    verifyEqual(testCase, mirrored, position{1}(3) > 0, 'board seen from behind: mirrored');
    [~, ok, pose] = acquisition.charuco_pose(ip, dims, S, mirrored, cam.intrinsics, [false false]);
    verifyTrue(testCase, ok);
    printed = preproc.cam_board_corners(dims, S);
    T = scene3d.frame_transform(pose.world_points, printed(~any(isnan(ip), 2), :));
    found = transformPointsForward(T, extr2pose(pose.extrinsics).Translation);
    verifyEqual(testCase, found, position{1}, 'AbsTol', 1.5, ...
        sprintf('camera at %s: position on the board as printed', mat2str(position{1})));
end
end

function test_tall_board_stereo_setup(testCase)
% "Show 3D setup" with a board with more rows than columns: stereo.calibrate works in the frame of
% patternWorldPoints (turned by 90 degrees); the scene shows the cameras where they are on the printed board
board = struct('PatternDims', [24 16], 'CheckerSize', 10, 'MarkerSize', 7, 'MarkerFamily', "DICT_4X4_1000", 'OriginCheckerColor', "black");
centre = [70 110 0];
pos = [-300 120 -460; 320 90 -450];
folder = fullfile(tempdir, 'test_core_scene3d_tall_stereo');
if ~isfolder(folder)
    mkdir(folder);
end
cleanup = onCleanup(@() rmdir(folder, 's'));
boards = cell(1, 2);
settings = cell(1, 2);
for k = 1:2
    cam = simulate.camera(ImageSize=[1024 1024], FocalLength=3800, Position=pos(k, :), Target=centre, RadialDistortion=[-0.05 0.01]);
    boards{k} = fullfile(folder, sprintf('board_cam%d.tif', k));
    imwrite(simulate.charuco_image(cam, PatternDims=board.PatternDims, CheckerSize=board.CheckerSize, MarkerSize=board.MarkerSize, ...
        Blur=1, Noise=0.001), boards{k});
    intr = cam.intrinsics;
    lens = cameraParameters(K=intr.K, RadialDistortion=intr.RadialDistortion, TangentialDistortion=intr.TangentialDistortion, ImageSize=[1024 1024]);
    settings{k} = import.cam_settings(view='same', use_calibration=1, cameraParams=lens);
end
calib = stereo.calibrate(settings, boards, board);
gui.set_preference('scene3d_board_lying', false);
[fig, ax] = scene3d.window(@(ax) stereo.plot_setup(ax, calib), Visible='off');
fig.Tag = 'scene3d_test';
S = getappdata(ax, 'scene3d');
y0 = (board.PatternDims(1) - 2) * board.CheckerSize;
verifyEqual(testCase, vertcat(S.cams.centre), scene3d.to_result(pos, y0), 'AbsTol', 3, 'cameras on the printed board');
end

function test_view_outline(testCase)
cam = simulate.camera(ImageSize=[800 1000], FocalLength=3000, Position=[-150 60 -500], Target=[100 80 0]);
B = scene3d.view_outline(cam.intrinsics, cam.pose);
verifyNotEmpty(testCase, B);
verifyEqual(testCase, B(:, 3), zeros(size(B, 1), 1));
q = world2img(B, cam.pose, cam.intrinsics);
sz = cam.imageSize;
on_border = abs(q(:, 1) - 0.5) < 1e-6 | abs(q(:, 1) - sz(2) - 0.5) < 1e-6 | abs(q(:, 2) - 0.5) < 1e-6 | abs(q(:, 2) - sz(1) - 0.5) < 1e-6;
verifyTrue(testCase, all(on_border), 'the outline is the border of the image');
% looking away from the board: no outline
away = simulate.camera(ImageSize=[800 1000], FocalLength=3000, Position=[0 0 -500], Target=[0 0 -1000]);
verifyEmpty(testCase, scene3d.view_outline(away.intrinsics, away.pose));
end

%% scene: floor below / behind the board, switch
function test_floor_upright_and_lying(testCase)
board = sample_board();
cam = simulate.camera(ImageSize=[800 1000], FocalLength=3000, Position=[-150 60 -500], Target=[100 80 0]);
gui.set_preference('scene3d_board_lying', false);
[fig, ax] = scene3d.window(@(ax) draw(ax, board, cam), Visible='off');
fig.Tag = 'scene3d_test';
S = getappdata(ax, 'scene3d');
verifyEqual(testCase, scene3d.up(ax), [0 1 0], 'upright: y of the results is up');
verifyLessThan(testCase, S.floor.height, min(S.board_rect(:, 2)), 'upright: floor below the board');
verifyLessThan(testCase, S.floor.height, S.cams(1).centre(2), 'upright: floor below the camera');
verifyNotEmpty(testCase, findall(ax, 'Tag', 'scene3d_floor'));
n = numel(findall(ax, 'Tag', 'scene3d_floor'));
% switch: board lying flat (floor behind the board, the camera is above it)
c = findall(fig, 'Tag', 'scene3d_up');
c.Value = 2;
c.Callback(c, []);
S = getappdata(ax, 'scene3d');
verifyTrue(testCase, gui.get_preference('scene3d_board_lying', false), 'switch stored as preference');
verifyEqual(testCase, scene3d.up(ax), [0 0 1], 'lying: z of the results (towards the camera) is up');
verifyLessThan(testCase, S.floor.height, 0, 'lying: floor behind the board');
verifyEqual(testCase, numel(findall(ax, 'Tag', 'scene3d_board', 'Type', 'surface')), 4, 'one board (and 3 arrow tips) after drawing again');
% the view looks at the board from the camera side
f = ax.CameraPosition - ax.CameraTarget;
verifyGreaterThan(testCase, f(3), 0);
% and back: the same scene as at first (nothing added)
c.Value = 1;
c.Callback(c, []);
verifyEqual(testCase, numel(findall(ax, 'Tag', 'scene3d_floor')), n, 'the floor is replaced, not added');
verifyFalse(testCase, gui.get_preference('scene3d_board_lying', true));
end

function test_mouse_rotates_about_vertical(testCase)
board = sample_board();
cam = simulate.camera(ImageSize=[800 1000], FocalLength=3000, Position=[-150 60 -500], Target=[100 80 0]);
gui.set_preference('scene3d_board_lying', false);
[fig, ax] = scene3d.window(@(ax) draw(ax, board, cam), Visible='off');
fig.Tag = 'scene3d_test';
pos = getpixelposition(ax, true);
p0 = pos(1:2) + pos(3:4) / 2;
target = ax.CameraTarget;
height = (ax.CameraPosition - target) * [0 1 0]';
fig.SelectionType = 'normal';
fig.CurrentPoint = p0;
fig.WindowButtonDownFcn(fig, []);
fig.CurrentPoint = p0 + [30 0];
fig.WindowButtonMotionFcn(fig, []);
fig.WindowButtonUpFcn(fig, []);
verifyEqual(testCase, ax.CameraTarget, target, 'AbsTol', 1e-9, 'rotates about the target');
verifyEqual(testCase, (ax.CameraPosition - target) * [0 1 0]', height, 'RelTol', 1e-6, 'horizontal drag: same height');
end

%% calibration view
function test_calibration_view(testCase)
board = sample_board();
cams = {[-150 60 -500], [200 -40 -450], [60 200 -600]};
P = preproc.cam_board_corners(board.PatternDims, board.CheckerSize);
ext = rigidtform3d.empty;
for k = 1:numel(cams)
    c = simulate.camera(ImageSize=[800 1000], FocalLength=3000, Position=cams{k}, Target=[100 80 0]);
    ext(k) = c.pose;
end
cp = cameraParameters('K', [3000 0 500; 0 3000 400; 0 0 1], 'ImageSize', [800 1000], 'WorldPoints', P, ...
    'RotationVectors', cell2mat(arrayfun(@(e) rotmat2vec3d(e.R), ext', 'UniformOutput', false)), ...
    'TranslationVectors', vertcat(ext.Translation));
verifyEqual(testCase, cp.PatternExtrinsics(2).Translation, ext(2).Translation, 'AbsTol', 1e-9, 'test data');
for with_board = [true false]
    fig = figure('Visible', 'off', 'Tag', 'scene3d_test');
    if with_board
        camcal.show_extrinsics(cp, fig, board);
    else
        camcal.show_extrinsics(cp, fig);
    end
    ax = findall(fig, 'Tag', 'scene3d_axes');
    S = getappdata(ax, 'scene3d');
    verifyNumElements(testCase, S.cams, numel(cams));
    y0 = (board.PatternDims(1) - 2) * board.CheckerSize;
    verifyEqual(testCase, S.cams(3).centre, scene3d.to_result(cams{3}, y0), 'AbsTol', 1e-6, 'camera positions in the axes of the results');
    caption = findall(fig, 'Tag', 'scene3d_caption');
    verifyNotEmpty(testCase, strfind(caption.String, '3 calibration images'));
    close(fig);
end
end

%% helpers
function board = sample_board()
board = struct('PatternDims', [12 17], 'CheckerSize', 15, 'MarkerSize', 11, 'MarkerFamily', "DICT_4X4_1000", 'OriginCheckerColor', "black");
end

function draw(ax, board, cam)
scene3d.board(ax, board);
scene3d.camera(ax, cam.pose, stereo.camera_colors(1), '1', View=scene3d.view_outline(cam.intrinsics, cam.pose), Sight=[100 80 0]);
end
