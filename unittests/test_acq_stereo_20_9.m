%% Tests of the stereo acquisition with two OPTOcam 20/9, without hardware
%
% Simulated cameras (unittests/mocks_imaq) with 20/9 device names (vendor ID VID164C). Every frame carries its
% trigger number and the device number in its first pixels (see test_acq_stereo_capture). The 20/9 delivers
% two frames (A, B) per trigger; the simulated camera makes one frame per "trigger", so frame 2i-1 is A and
% frame 2i is B of image pair i. The device listed first has the higher serial number: camera 1 is device 2.
%
% Run with:
%   runtests('unittests/test_acq_stereo_20_9.m')

function tests = test_acq_stereo_20_9
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
helper_setup_once(testCase);
testCase.TestData.Mocks = fullfile(testCase.TestData.Root, 'unittests', 'mocks_imaq');
addpath(testCase.TestData.Mocks); % in front of the Image Acquisition Toolbox
end

function teardownOnce(testCase)
imaqreset(); % the simulated cameras (still on the path)
rmpath(testCase.TestData.Mocks);
helper_teardown_once(testCase);
end

function test_stereo_checkbox(testCase)
% "Stereo (2 cameras)" is available for the 20/9 and needs two connected 20/9
folder = new_folder(testCase, 'checkbox');
h = start_capture_gui(folder, 1, 1);
verifyEqual(testCase, gui.retr('camera_type'), 'OPTOcam_20_9');
verifyEqual(testCase, get(h.ac_stereo, 'Enable'), 'on', 'OPTOcam 20/9: checkbox enabled');
set(h.ac_stereo, 'Value', 1);
acquisition.stereo_Callback;
verifyEqual(testCase, get(h.ac_stereo, 'Value'), 0, 'one camera connected: unticked again');
set_20_9_devices(2);
set(h.ac_stereo, 'Value', 1);
acquisition.stereo_Callback;
verifyEqual(testCase, get(h.ac_stereo, 'Value'), 1, 'two cameras connected');
verifyEqual(testCase, acquisition.capture_cameras, 2);
end

function test_stereo_recording(testCase)
% PIV capture with two 20/9: A/B pairs of camera 1 / 2 in cam1 / cam2, opened in stereo mode, both cameras in
% double-frame mode on the Line4 trigger
folder = new_folder(testCase, 'recording');
h = start_capture_gui(folder, 2, 2);
set(h.ac_pivcapture_save, 'Value', 1);
set(h.ac_imgamount, 'String', '10');
acquisition.piv_capture_Callback;
for k = 1:2
    for i = 1:10
        A = imread(fullfile(folder, sprintf('cam%d', k), sprintf('PIVlab_%04d_A.tif', i - 1)));
        B = imread(fullfile(folder, sprintf('cam%d', k), sprintf('PIVlab_%04d_B.tif', i - 1)));
        verifyEqual(testCase, [trigger_of(A) trigger_of(B)], [2 * i - 1, 2 * i], sprintf('camera %d, pair %d: frames', k, i));
        verifyEqual(testCase, double(A(1, 3)), 3 - k, sprintf('camera %d: device', k)); % camera 1 = device 2
    end
end
verifyEqual(testCase, gui.retr('stereomode'), 1, 'opened in stereo mode');
state = gui.retr('stereo_cam_state');
verifyEqual(testCase, numel(state{2}.filepath), 20, 'camera 2: 10 pairs');
for k = 1:2
    vid = imaqfind('Tag', sprintf('OPTOcam_20_9_cam%d', k));
    src = vid{1}.Source;
    verifyEqual(testCase, {src.mvShutterMode, src.TriggerMode, src.TriggerSource}, {'mvPivShutter', 'On', 'Line4'}, sprintf('camera %d: double frame, trigger', k));
end
verifyEqual(testCase, gui.camera_setting('OPTOcam_20_9_stereo_serials'), {'FF000001', 'FF000002'}, 'camera order saved');
verifyEqual(testCase, gui.retr('capture_missing_frames'), [0 0], 'no missing frames');
end

function test_stereo_missed_trigger(testCase)
% one camera misses a trigger (a whole image pair): reported after saving
folder = new_folder(testCase, 'missed');
h = start_capture_gui(folder, 2, 2);
reg = getappdata(0, 'mock_imaq');
reg.drop{2} = [7 8]; % device 2 = camera 1: frames A and B of pair 4
setappdata(0, 'mock_imaq', reg);
set(h.ac_pivcapture_save, 'Value', 1);
set(h.ac_imgamount, 'String', '10');
output = evalc('acquisition.piv_capture_Callback');
verifyTrue(testCase, contains(output, 'Camera 1: 1 image pair(s) missing, the first one before image pair 4'), output);
verifyFalse(testCase, contains(output, 'Camera 2:'), output);
end

function test_stereo_live_image(testCase)
% live image of both cameras side by side, camera 1 = lower serial number
folder = new_folder(testCase, 'live');
start_capture_gui(folder, 2, 2);
run_with_check(@check_live, 2);
acquisition.calibcapture_Callback;
r = getappdata(0, 'stereo_capture_test');
verifyEqual(testCase, r.n_images, 2, 'two camera images');
verifyEqual(testCase, r.device_shown, [2 1], 'camera 1 = lower serial number (device 2)');
verifyEqual(testCase, r.shutter, 'mvGlobalShutter', 'live image: single frames');
caliimg = gui.retr('caliimg');
verifyTrue(testCase, iscell(caliimg) && numel(caliimg) == 2, 'last images of both cameras');
end

function check_live(~, ~)
r = struct();
ax = gui.retr('pivlab_axis');
imgs = findobj(ax, 'Type', 'image');
r.n_images = numel(imgs);
cams = zeros(1, numel(imgs));
for i = 1:numel(imgs)
    cams(i) = getappdata(imgs(i), 'camera');
end
[~, order] = sort(cams);
imgs = imgs(order);
for k = 1:numel(imgs)
    frame = getappdata(imgs(k), 'frame');
    r.device_shown(k) = double(frame(1, 3));
end
vids = imaqfind('Tag', 'OPTOcam_20_9_cam2');
src = vids{1}.Source;
r.shutter = src.mvShutterMode;
setappdata(0, 'stereo_capture_test', r);
gui.put('cancel_capture', 1); % Stop
end

function test_one_camera_recording(testCase)
% two connected, stereo off: one camera, images in the project folder
folder = new_folder(testCase, 'mono');
h = start_capture_gui(folder, 2, 1);
set(h.ac_pivcapture_save, 'Value', 1);
set(h.ac_imgamount, 'String', '5');
acquisition.piv_capture_Callback;
A = imread(fullfile(folder, 'PIVlab_0004_A.tif'));
verifyEqual(testCase, trigger_of(A), 9);
verifyFalse(testCase, isfolder(fullfile(folder, 'cam1')), 'no camera folders in 2D');
verifyEqual(testCase, numel(imaqfind), 1, 'one camera opened');
end

function test_swap_cameras(testCase)
% OPTOcam 20/9 settings window: "Swap cameras" changes the order of the next start
folder = new_folder(testCase, 'swap');
start_capture_gui(folder, 2, 2);
gui.set_camera_setting('OPTOcam_20_9_stereo_serials', {'FF000001', 'FF000002'});
PIVlab_capture_OPTOcam_20_9_settings_GUI;
fh = findobj('tag', 'OPTOcam_20_9_control_window');
verifyEqual(testCase, get(findobj(fh, 'tag', 'stereo_cam1_txt'), 'String'), 'Camera 1: serial nr. FF000001');
btn = findobj(fh, 'tag', 'swap_btn');
callback = get(btn, 'Callback');
callback(btn, []);
verifyEqual(testCase, gui.camera_setting('OPTOcam_20_9_stereo_serials'), {'FF000002', 'FF000001'});
close(fh);
[vids, err] = PIVlab_capture_OPTOcam_20_9_open(8, 2);
verifyEqual(testCase, err, 0);
src = vids{1}.Source;
verifyEqual(testCase, src.DeviceSerialNumber, 'FF000002', 'camera 1 after the swap');
end

function test_camera_view_button(testCase)
% CAM button in the Image Acquisition panel with two cameras: CAM 1+2 -> CAM 1 -> CAM 2 -> CAM 1+2; hidden with one camera
folder = new_folder(testCase, 'view_button');
h = start_capture_gui(folder, 2, 2);
gui.switchui('multip24');
verifyEqual(testCase, char(get(h.stereo_camera_toggle, 'Visible')), 'on');
labels = cell(1, 4);
labels{1} = get(h.stereo_camera_toggle, 'String');
for i = 2:4
    stereo.camera_toggle_Callback;
    labels{i} = get(h.stereo_camera_toggle, 'String');
end
verifyEqual(testCase, labels, {'CAM 1+2', 'CAM 1', 'CAM 2', 'CAM 1+2'});
set(h.ac_stereo, 'Value', 0);
acquisition.stereo_Callback;
verifyEqual(testCase, char(get(h.stereo_camera_toggle, 'Visible')), 'off', 'one camera: no CAM button');
end

function test_camera_view_live(testCase)
% live image with CAM 2 shown: only camera 2 in view and drawn, snapshot only of camera 2; switching to CAM 1+2
% while the live image runs shows both; zoom reset goes back to the view
folder = new_folder(testCase, 'view_live');
start_capture_gui(folder, 2, 2);
gui.switchui('multip24');
gui.put('capture_camera_view', 2);
acquisition.camera_view_button;
run_with_check(@check_view, 2);
acquisition.calibcapture_Callback;
r = getappdata(0, 'stereo_capture_test');
verifyEqual(testCase, r.xlim_cam2, [330.5 650.5], 'CAM 2: x range of camera 2 (offset 320 + gap 10)');
verifyEqual(testCase, r.hidden, [true false], 'camera 1 hidden');
verifyEqual(testCase, r.label_visible, [false true], 'label CAMERA 1 hidden, CAMERA 2 shown');
verifyEqual(testCase, r.xlim_both, [0.5 650.5], 'CAM 1+2: both cameras');
verifyTrue(testCase, isfile(fullfile(folder, 'cam2', 'PIVlab_snapshot (0).tif')), 'snapshot camera 2');
verifyFalse(testCase, isfile(fullfile(folder, 'cam1', 'PIVlab_snapshot (0).tif')), 'no snapshot of camera 1');
verifyTrue(testCase, isfile(fullfile(folder, 'cam1', 'PIVlab_snapshot (1).tif')) && isfile(fullfile(folder, 'cam2', 'PIVlab_snapshot (1).tif')), ...
    'pair: number 1 (0 is used by camera 2 alone)');
gui.put('capture_camera_view', 1);
gui.zoom_reset_zoom;
verifyEqual(testCase, get(gui.retr('pivlab_axis'), 'XLim'), [0.5 320.5], 'zoom reset with CAM 1: camera 1');
end

function check_view(~, ~)
ax = gui.retr('pivlab_axis');
r.xlim_cam2 = get(ax, 'XLim');
imgs = findobj(ax, 'Type', 'image');
r.hidden = [false false];
for i = 1:numel(imgs)
    r.hidden(getappdata(imgs(i), 'camera')) = isequal(getappdata(imgs(i), 'hidden'), true);
end
labels = findobj(ax, 'Tag', 'capture_camera_label');
r.label_visible = [false false];
for i = 1:numel(labels)
    r.label_visible(getappdata(labels(i), 'camera')) = strcmp(char(labels(i).Visible), 'on');
end
acquisition.camera_snapshot_Callback;
stereo.camera_toggle_Callback; % CAM 2 -> CAM 1+2
r.xlim_both = get(ax, 'XLim');
acquisition.camera_snapshot_Callback; % both cameras: a number that is free in both folders
setappdata(0, 'stereo_capture_test', r);
gui.put('cancel_capture', 1); % Stop
end

function test_roi_camera_2(testCase)
% ROI selection with CAM 2 shown: the ROI is drawn on the image of camera 2 (only this image in the image area)
folder = new_folder(testCase, 'view_roi');
start_capture_gui(folder, 2, 2);
gui.switchui('multip24');
gui.put('capture_camera_view', 2);
gui.put('doing_roi', 0);
setappdata(0, 'stereo_capture_test', []);
t = timer('ObjectVisibility', 'off', 'ExecutionMode', 'fixedSpacing', 'Period', 0.5, 'TasksToExecute', 240, 'TimerFcn', @check_roi_image, 'StopFcn', @delete_timer);
start(t); % checks until the ROI selection waits for the double click (at most 2 min)
acquisition.calibROI_Callback;
if isvalid(t)
    stop(t);
end
r = getappdata(0, 'stereo_capture_test');
verifyEqual(testCase, r.n_images, 1, 'one image');
verifyEqual(testCase, r.camera, 2, 'image of camera 2');
verifyEqual(testCase, r.x_data, [1 4512], 'full sensor at x = 1');
end

function check_roi_image(t, ~)
if ~isequal(gui.retr('doing_roi'), 1) || isempty(findobj(gui.retr('pivlab_axis'), 'tag', 'new_ROImethod'))
    return % the ROI selection does not wait for the double click yet
end
stop(t);
imgs = findobj(gui.retr('pivlab_axis'), 'Type', 'image');
r.n_images = numel(imgs);
r.camera = getappdata(imgs(1), 'camera');
r.x_data = imgs(1).XData;
setappdata(0, 'stereo_capture_test', r);
uiresume; % = double click on the ROI
end

function test_charuco_detection_per_view(testCase)
% live ChArUco detection with a simulated board (with QR code) in both cameras: CAM 2 shown -> the full detection
% for camera 2 (QR code read, board parameters filled in, labels in camera 2); CAM 1+2 -> markers + QR per camera
folder = new_folder(testCase, 'view_charuco');
board = fullfile(folder, 'board.png');
sz = [1000 1000];
dims = [9 12];
cam = simulate.camera(ImageSize=sz, FocalLength=0.8*sz(2), Position=[110 70 -330], Target=[110 70 0]);
imwrite(simulate.charuco_image(cam, PatternDims=dims, CheckerSize=20, MarkerSize=14, Blur=0.7, Decorated=true), board); % with QR code
h = start_capture_gui(folder, 2, 2);
reg = getappdata(0, 'mock_imaq');
reg.images = {board, board};
setappdata(0, 'mock_imaq', reg);
gui.put('ac_ROI_general', [1 1 sz(2) sz(1)]);
set(h.calib_rows, 'String', '3'); % changed by the QR code
gui.switchui('multip24');
gui.put('capture_camera_view', 2);
set(h.calib_dolivedetect, 'Value', 1);
setappdata(0, 'stereo_capture_test', struct('phase', 1));
t = timer('ObjectVisibility', 'off', 'ExecutionMode', 'fixedSpacing', 'Period', 0.5, 'TasksToExecute', 240, 'TimerFcn', @check_charuco, 'StopFcn', @delete_timer);
start(t);
acquisition.calibcapture_Callback;
if isvalid(t)
    stop(t);
end
r = getappdata(0, 'stereo_capture_test');
verifyEqual(testCase, r.phase, 3, 'both views checked');
verifyGreaterThan(testCase, r.cam2_qr_x, sz(2), 'CAM 2: QR label in camera 2 (right of camera 1)');
verifyEqual(testCase, r.rows, dims(1), 'board rows from the QR code');
verifyEqual(testCase, r.stereo_labels, [true true], 'CAM 1+2: markers of both cameras');
verifyTrue(testCase, r.stereo_qr, 'CAM 1+2: QR code found');
end

function check_charuco(t, ~)
% phase 1: CAM 2, wait for the QR label of the full detection; phase 2: CAM 1+2, wait for the labels of both cameras
r = getappdata(0, 'stereo_capture_test');
ax = gui.retr('pivlab_axis');
h = gui.gethand;
if t.TasksExecuted >= t.TasksToExecute - 1
    gui.put('cancel_capture', 1); % timeout: Stop, the verifications fail
    return
end
if r.phase == 1
    qr = findobj(ax, 'Type', 'text', 'Tag', 'charucolabel', 'String', 'QR');
    if isempty(qr)
        return
    end
    r.cam2_qr_x = qr(1).Position(1);
    r.rows = str2double(h.calib_rows.String);
    r.phase = 2;
    stereo.camera_toggle_Callback; % CAM 2 -> CAM 1+2
elseif r.phase == 2
    r.stereo_labels = [~isempty(findobj(ax, 'Tag', 'charucolabel_cam1')) ~isempty(findobj(ax, 'Tag', 'charucolabel_cam2'))];
    r.stereo_qr = ~isempty(findobj(ax, 'Type', 'text', 'String', 'QR'));
    if ~all(r.stereo_labels) || ~r.stereo_qr
        setappdata(0, 'stereo_capture_test', r);
        return
    end
    r.phase = 3;
    stop(t);
    gui.put('cancel_capture', 1); % Stop
end
setappdata(0, 'stereo_capture_test', r);
end

%% helpers
function folder = new_folder(testCase, name)
folder = fullfile(testCase.TestData.Dir, name);
mkdir(folder);
end

function set_20_9_devices(n_connected)
% n simulated OPTOcam 20/9 at 34 frames/s (17 image pairs/s); the first device has the higher serial number
mock_imaq_setup(n_connected, 34);
reg = getappdata(0, 'mock_imaq');
serials = {'FF000002', 'FF000001'};
for k = 1:n_connected
    reg.devices(k).name = ['MATRIX VISION GmbH VID164C_PID5533_' serials{k}];
    reg.devices(k).serial = serials{k};
    reg.devices(k).user_id = '';
end
setappdata(0, 'mock_imaq', reg);
end

function h = start_capture_gui(folder, n_connected, n_cameras)
% PIVlab with the OPTOcam configuration (detected as 20/9), 17 image pairs/s, ROI 320 x 240
set_20_9_devices(n_connected);
helper_start_pivlab();
h = gui.gethand;
set(h.ac_project, 'String', folder);
set(h.ac_config, 'Value', find(strcmp(h.ac_config.String, 'PIVlab LD-PS + OPTOcam')));
acquisition.select_capture_config_Callback;
set(h.ac_fps, 'Value', find(strcmp(h.ac_fps.String, '17')));
gui.put('ac_ROI_general', [1 1 320 240]);
set(h.ac_stereo, 'Value', double(n_cameras == 2));
gui.set_camera_setting('OPTOcam_20_9_stereo_serials', []);
gui.put('capture_camera_view', 0); % both cameras shown
end

function run_with_check(check_function, delay)
% hidden timer (control_simple_sync_serial deletes the visible ones): check_function runs once after delay seconds
setappdata(0, 'stereo_capture_test', []);
t = timer('ObjectVisibility', 'off', 'StartDelay', delay, 'TimerFcn', check_function, 'StopFcn', @delete_timer);
start(t);
end

function delete_timer(t, ~)
delete(t);
end

function n = trigger_of(frame)
n = double(frame(1, 1)) + 256 * double(frame(1, 2));
end
