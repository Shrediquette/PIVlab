function tests = test_camera_calibration_gui_api
%TEST_CAMERA_CALIBRATION_GUI_API A camera calibration made in the PIVlab GUI (ChArUco board images,
%standard and tilted camera model, rectification) and used by the command-line API.
%   The board images are made with simulate.charuco_image (pinhole camera with lens distortion).
%   Run with: results = runtests('unittests/test_camera_calibration_gui_api.m')
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
root = fileparts(fileparts(mfilename('fullpath')));
addpath(root);
addpath(fullfile(root, 'unittests', 'parity', 'mocks'), '-begin');
testCase.TestData.Root = root;
testCase.TestData.Dir = tempname(tempdir);
mkdir(testCase.TestData.Dir);
setappdata(0, 'PIVlabTestMode', true);
setappdata(0, 'pivlab_test_warning_state', warning);
testCase.TestData.Preferences = clear_preferences();
% PIV images (fisheye example) and board images of the same size
files = cell(6,1);
for i = 1:3
    files{2*i-1} = fullfile(root,'Example_data','worst_case_distortion',sprintf('PIVlab_%04d_A.jpg',i-1));
    files{2*i}   = fullfile(root,'Example_data','worst_case_distortion',sprintf('PIVlab_%04d_B.jpg',i-1));
end
testCase.TestData.Files = files;
sz = size(imread(files{1}), [1 2]);
[testCase.TestData.Boards, testCase.TestData.RectBoard, testCase.TestData.TrueK] = board_images(testCase.TestData.Dir, sz);
end

function teardownOnce(testCase)
close_pivlab();
restore_preferences(testCase.TestData.Preferences);
rmpath(fullfile(testCase.TestData.Root, 'unittests', 'parity', 'mocks'));
if isappdata(0, 'PIVlabTestMode'), rmappdata(0, 'PIVlabTestMode'); end
if isappdata(0, 'parity_mock_file'), rmappdata(0, 'parity_mock_file'); end
try, delete(gcp('nocreate')); catch, end
try, rmdir(testCase.TestData.Dir, 's'); catch, end
close all force
end

%% ------------------------------------------------------------------ standard camera model
function test_standard_model_gui_to_api(testCase)
calibration_gui_to_api(testCase, false);
end

function test_tilted_model_gui_to_api(testCase)
calibration_gui_to_api(testCase, true);
end

function calibration_gui_to_api(testCase, tilted)
D = testCase.TestData.Dir;
name = 'standard';
if tilted, name = 'tilted'; end
start_pivlab(1);
load_images(testCase.TestData.Files);
calibrate_in_gui(testCase.TestData.Boards, tilted);
cp = gui.retr('cameraParams');
testCase.assertNotEmpty(cp, 'no camera parameters estimated');
testCase.verifyEqual(logical(gui.retr('cam_use_tilted_model')), tilted);
% the estimated focal length is close to the true one (synthetic camera)
testCase.verifyEqual(cp.Intrinsics.FocalLength, testCase.TestData.TrueK, 'RelTol', 0.02);
% "Save camera parameters"
setappdata(0,'parity_mock_file',{D, ['camera_' name '.mat']});
preproc.cam_saveparams_Callback([],[],[]);
testCase.verifyTrue(isfile(fullfile(D, ['camera_' name '.mat'])));
% undistortion on, view "same size as input", rectification with the oblique board image
enable_undistortion(2);
enable_rectification(testCase.TestData.RectBoard);
testCase.verifyEqual(gui.retr('cam_use_rectification'), 1);
% the rectified board is a regular grid (rectification computed from this camera model)
[rms_px, scale_ratio, checker_px, rms_ref] = rectified_grid_quality(testCase.TestData.RectBoard, testCase.TestData.Boards{1});
fprintf(['%s model: rectified board: residual of a similarity fit %.2f px = %.3f checkers (checker %.1f px), ' ...
    'x/y scale ratio %.4f; front view, undistorted only: %.3f checkers\n'], name, rms_px, rms_px/checker_px, checker_px, scale_ratio, rms_ref);
% (the synthetic board images limit the accuracy: the front view, only undistorted, is the reference)
testCase.verifyLessThan(rms_px/checker_px, 2*rms_ref, 'rectified board is not a regular grid');
testCase.verifyEqual(scale_ratio, 1, 'AbsTol', 0.01);
% ROI and mask, analysis
sz = gui.retr('expected_image_size');
roi = [round(sz(2)*0.2) round(sz(1)*0.2) round(sz(2)*0.6) round(sz(1)*0.6)];
gui.put('roirect', roi);
gui.put('masks_in_frame', {{'ROI_object_rectangle',[roi(1)+50 roi(2)+50 100 80]}, {}, {}});
analyze();
rl = gui.retr('resultslist');
gui_img = import.get_img(1);
export.save_session_function(D, ['session_' name '.mat']);
close_pivlab();

% API with the session as camera source: same corrected image, same result
raw = pivlab.readImages(testCase.TestData.Files, "pairwise");
s = pivlab.loadSettings(fullfile(D, ['session_' name '.mat']));
r = pivlab.loadSession(fullfile(D, ['session_' name '.mat']));
imgs = pivlab.preprocess(raw, Camera=fullfile(D, ['session_' name '.mat']), Settings=s, Mask=r.images.mask, Verbose=false);
testCase.verifyEqual(imgs.cam.use_rectification, 1);
testCase.verifyEqual(imgs.imageSize, sz);
api_img = pivlab.getImage(imgs, 1, Preprocessed=false);
testCase.verifyEqual(api_img, gui_img(:,:,1), 'corrected image API vs GUI');
res = pivlab.analyze(imgs, Settings=s, Verbose=false);
for k = 1:3
    testCase.verifyEqual(res.px.u_raw(:,:,k), rl{3,k}, sprintf('%s: raw u pair %d API vs GUI', name, k));
end
testCase.verifyEqual(res.typevector_raw(:,:,1), rl{5,1}, 'mask from the GUI fits');
% API with the "Save camera parameters" file: undistortion without rectification
p = pivlab.preprocess(raw, Camera=fullfile(D, ['camera_' name '.mat']), CameraView="same", Verbose=false);
testCase.verifyEqual(logical(p.cam.use_tilted_model), tilted);
testCase.verifyEqual(p.cam.use_rectification, 0);
q = pivlab.preprocess(raw, Camera=fullfile(D, ['session_' name '.mat']), Rectification=false, Verbose=false);
testCase.verifyEqual(pivlab.getImage(p, 1, Preprocessed=false), pivlab.getImage(q, 1, Preprocessed=false), ...
    'parameter file and session give the same undistortion');
% the API result saved as a session opens in the GUI with undistortion + rectification switched on
pivlab.saveSession(res, fullfile(D, ['api_' name '.mat']), Verbose=false);
start_pivlab(1);
import.load_session_Callback(1, fullfile(D, ['api_' name '.mat'])); drawnow;
h = gui.gethand;
testCase.verifyEqual(gui.retr('cam_use_calibration'), 1);
testCase.verifyEqual(gui.retr('cam_use_rectification'), 1);
testCase.verifyEqual(h.calib_usecalibration.Value, 1);
testCase.verifyEqual(logical(gui.retr('cam_use_tilted_model')), tilted);
img2 = import.get_img(1);
testCase.verifyEqual(img2(:,:,1), gui_img(:,:,1), 'image in the GUI after loading the API session');
close_pivlab();
end

function test_tilted_model_background_and_parallel(testCase)
% tilted model: the mean background is made from the corrected images (not shifted against them),
% serial GUI = API serial, parallel GUI = API parallel
D = testCase.TestData.Dir;
start_pivlab(1);
load_images(testCase.TestData.Files);
calibrate_in_gui(testCase.TestData.Boards, true);
enable_undistortion(2);
h = gui.gethand;
gui.quick3_Callback([],[]);
set(h.bg_subtract,'Value',2); preproc.generate_BG_img(); drawnow;
bgA = gui.retr('bg_img_A');
cam = import.cam_settings(FromGUI=true);
testCase.verifyTrue(logical(cam.use_tilted_model));
% mean of the corrected A images, computed here
acc = zeros(size(bgA));
files = testCase.TestData.Files;
for k = 1:2:numel(files)
    acc = acc + double(preproc.cam_undistort_with(imread(files{k}), cam));
end
mean_here = acc / (numel(files)/2);
% The background is the mean of the raw images, undistorted once: the same as the mean of the
% undistorted images, except next to the black fill area of the undistortion
dev = abs(double(bgA) - mean_here);
inner = imerode(mean_here > 0 & double(bgA) > 0, strel('square', 7));
fprintf(['tilted model: background vs mean of the corrected images: max %.2f counts (next to the fill area), ' ...
    'elsewhere max %.2f\n'], max(dev(:)), max(dev(inner)));
testCase.verifyLessThanOrEqual(max(dev(inner)), 1, 'background is not the mean of the corrected images');
analyze();
rl_serial = gui.retr('resultslist');
export.save_session_function(D, 'tilted_bg.mat');
close_pivlab();
s = pivlab.loadSettings(fullfile(D, 'tilted_bg.mat'));
imgs = pivlab.preprocess(pivlab.readImages(files, "pairwise"), Camera=fullfile(D, 'tilted_bg.mat'), Settings=s, Verbose=false);
testCase.verifyEqual(double(imgs.background.A), double(bgA), 'AbsTol', 1);
res = pivlab.analyze(imgs, Settings=s, Verbose=false);
testCase.verifyEqual(res.px.u_raw(:,:,1), rl_serial{3,1}, 'serial: API vs GUI');
% parallel
testCase.assumeTrue(~isempty(ver('parallel')), 'no Parallel Computing Toolbox');
start_pivlab(2);
import.load_session_Callback(1, fullfile(D, 'tilted_bg.mat')); drawnow;
analyze();
rl_par = gui.retr('resultslist');
close_pivlab();
resp = pivlab.analyze(imgs, Settings=s, Parallel=true, Verbose=false);
for k = 1:3
    testCase.verifyEqual(resp.px.u_raw(:,:,k), rl_par{3,k}, sprintf('parallel: API vs GUI pair %d', k));
end
d = abs(double(rl_par{3,1}(:)) - double(rl_serial{3,1}(:)));
fprintf('tilted model: GUI parallel vs serial: max difference %.2g px, %d of %d vectors differ by more than 0.01 px\n', ...
    max(d), nnz(d > 0.01), numel(d));
testCase.verifyLessThan(mean(d > 0.01), 0.01);
end

%% ------------------------------------------------------------------ helpers
function [boards, rect, K] = board_images(D, sz)
% 12 views of a ChArUco board through a lens with barrel distortion, and one oblique view of the
% board in the measurement plane (for the rectification)
f = 0.8*sz(2);
dims = [17 22]; checker = 10; marker = 7;
board_center = [(dims(2)-2)*checker/2, (dims(1)-2)*checker/2, 0];
cam = simulate.camera(ImageSize=sz, FocalLength=f, RadialDistortion=[-0.12 0.02], ...
    Position=board_center + [0 0 -330], Target=board_center);
K = cam.intrinsics.FocalLength;   % true focal length [fx fy]
poses = [0 0 0; 20 0 0; -20 0 0; 0 20 0; 0 -20 0; 15 15 10; -15 15 -10; 15 -15 20; -15 -15 -20; 25 10 5; -10 25 0; 10 -25 15];
boards = cell(size(poses,1),1);
for k = 1:size(poses,1)
    a = poses(k,:);
    R = rot_z(a(3)) * rot_y(a(2)) * rot_x(a(1));
    t = board_center' - R*board_center' + [0; 0; 40*(mod(k,3)-1)];
    I = simulate.charuco_image(cam, PatternDims=dims, CheckerSize=checker, MarkerSize=marker, ...
        BoardPose=rigidtform3d(R, t'), Blur=0.7, Noise=0.0002);
    boards{k} = fullfile(D, sprintf('board_%02d.png', k));
    imwrite(I, boards{k});
end
R = rot_y(30);
I = simulate.charuco_image(cam, PatternDims=dims, CheckerSize=checker, MarkerSize=marker, ...
    BoardPose=rigidtform3d(R, (board_center' - R*board_center')'), Blur=0.7);
rect = fullfile(D, 'board_rectification.png');
imwrite(I, rect);
end

function R = rot_x(a)
R = [1 0 0; 0 cosd(a) -sind(a); 0 sind(a) cosd(a)];
end

function R = rot_y(a)
R = [cosd(a) 0 sind(a); 0 1 0; -sind(a) 0 cosd(a)];
end

function R = rot_z(a)
R = [cosd(a) -sind(a) 0; sind(a) cosd(a) 0; 0 0 1];
end

function calibrate_in_gui(boards, tilted)
h = gui.gethand;
set(h.calib_rows,'String','17'); set(h.calib_columns,'String','22');
set(h.calib_checkersize,'String','10'); set(h.calib_markersize,'String','7');
set(h.calib_origincolor,'Value',1);
set(h.calib_use_tilted_model,'Value',double(tilted));
gui.put('cam_selected_target_images', boards);
preproc.cam_estimateparams_Callback([],[],[]); drawnow;
end

function enable_undistortion(viewtype)
h = gui.gethand;
h.calib_viewtype.Value = viewtype;
h.calib_usecalibration.Value = 1;
preproc.cam_enable_cam_calib_Callback(h.calib_usecalibration,[],[]); drawnow;
end

function enable_rectification(board)
h = gui.gethand;
gui.put('cam_selected_rectification_image', board);
h.calib_userectification.Value = 1;
preproc.cam_enable_cam_rectification_Callback(h.calib_userectification,[],[]); drawnow;
end

function [rms_px, scale_ratio, checker_px, rms_ref] = rectified_grid_quality(board, front_board)
% detect the board corners in the corrected (undistorted + rectified) board image and fit a
% similarity transform (rotation, one scale, shift) to the board coordinates. Reference: the
% front view of the board, only undistorted (residual in checkers)
cam = import.cam_settings(FromGUI=true);
[rms_px, scale_ratio, checker_px] = grid_fit(preproc.cam_undistort_with(imread(board), cam));
cam.use_rectification = 0;
[r2, ~, c2] = grid_fit(preproc.cam_undistort_with(imread(front_board), cam));
rms_ref = r2/c2;
end

function [rms_px, scale_ratio, checker_px] = grid_fit(I)
h = gui.gethand;
dims = [str2double(h.calib_rows.String) str2double(h.calib_columns.String)];
pts = detectCharucoBoardPoints(I, dims, 'DICT_4X4_1000', 10, 7, 'RefineCorners', true, 'MarkerSizeRange', [0.005 1]);
wp = patternWorldPoints("charuco-board", dims, 10);
ok = all(isfinite(pts), 2);
pts = pts(ok,:); wp = wp(ok,:);
A = fitgeotform2d(wp, pts, 'affine');
M = A.A(1:2,1:2);
sx = norm(M(:,1)); sy = norm(M(:,2));
scale_ratio = sx/sy;
S = fitgeotform2d(wp, pts, 'similarity');
d = transformPointsForward(S, wp) - pts;
rms_px = sqrt(mean(sum(d.^2, 2)));
checker_px = 10 * S.Scale;
end

function analyze()
h = gui.gethand;
set(h.update_display_checkbox,'Value',0);
piv.AnalyzeAll_Callback([],[],[]); drawnow;
end

function load_images(paths)
gui.put('sequencer',1); gui.put('multitiff',0); gui.put('video_selection_done',0);
ps = struct('name',paths(:),'isdir',num2cell(false(numel(paths),1)));
import.loadimgsbutton_Callback([],[],0,ps); drawnow;
end

function start_pivlab(cores)
close_pivlab();
PIVlab_GUI(cores); drawnow;
gui.put('batchModeActive',1);
hgui = getappdata(0,'hgui');
set(hgui,'Units','pixels','Position',[20 40 1600 1000]); drawnow;
try, gui.MainWindow_ResizeFcn(hgui); catch, end
drawnow;
end

function close_pivlab()
hgui = getappdata(0,'hgui');
if ~isempty(hgui) && ishghandle(hgui)
    try, gui.put('batchModeActive',1); catch, end
    try, delete(hgui); catch, close(hgui,'force'); end
end
setappdata(0,'hgui',[]);
try, close(findall(0,'Type','figure'),'force'); catch, end
if isappdata(0, 'pivlab_test_warning_state')
    warning(getappdata(0, 'pivlab_test_warning_state'));
end
end

function prefs = clear_preferences()
prefs = struct();
if ispref('PIVlab')
    prefs = getpref('PIVlab');
    rmpref('PIVlab');
end
end

function restore_preferences(prefs)
if ispref('PIVlab')
    rmpref('PIVlab');
end
names = fieldnames(prefs);
for k = 1:numel(names)
    setpref('PIVlab', names{k}, prefs.(names{k}));
end
end
