%% Tests of the image acquisition with the OPTOcam 2/80, one camera and stereo (two cameras), without hardware
%
% Simulated cameras (unittests/mocks_imaq: videoinput, imaqhwinfo, imaqfind, imaqreset) replace the Image
% Acquisition Toolbox. They make frames at the trigger rate (hardware trigger) or the live frame rate; every
% frame carries its trigger number and the device number in its first pixels, so the tests can check which
% camera and which trigger ended up in which file. Without a synchronizer connection, the laser commands of
% PIVlab do nothing. While the live image or the capture loop runs, a hidden timer checks the display and
% then stops it (like the Stop / Abort buttons).
% The device listed first has the higher serial number: camera 1 of a stereo setup is device 2.
%
% Run with:
%   runtests('unittests/test_acq_stereo_capture.m')

function tests = test_acq_stereo_capture
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
% "Stereo (2 cameras)": only for the OPTOcam 2/80, only with two cameras connected; RAM check for both
folder = new_folder(testCase, 'checkbox');
h = start_capture_gui(folder, 1, 1);
verifyEqual(testCase, get(h.ac_stereo, 'Enable'), 'on', 'OPTOcam 2/80: checkbox enabled');
set(h.ac_stereo, 'Value', 1);
acquisition.stereo_Callback;
verifyEqual(testCase, get(h.ac_stereo, 'Value'), 0, 'one camera connected: unticked again');
mock_imaq_setup(2, 80);
set(h.ac_stereo, 'Value', 1);
acquisition.stereo_Callback;
verifyEqual(testCase, get(h.ac_stereo, 'Value'), 1, 'two cameras connected');
verifyEqual(testCase, acquisition.capture_cameras, 2);
% RAM: an image amount that fits for one camera, but not for two
set(h.ac_pivcapture_save, 'Value', 1);
max_pairs = PIVlab_capture_max_possible_images(gui.retr('ac_ROI_general'), [], 8);
set(h.ac_imgamount, 'String', int2str(round(0.75 * max_pairs)));
acquisition.image_amount_Callback;
stereo_color = get(h.ac_imgamount, 'BackgroundColor');
set(h.ac_stereo, 'Value', 0);
acquisition.image_amount_Callback;
mono_color = get(h.ac_imgamount, 'BackgroundColor');
verifyNotEqual(testCase, stereo_color, mono_color, 'stereo: the image amount is marked (RAM of two cameras)');
% another camera: unticked and disabled
set(h.ac_stereo, 'Value', 1);
set(h.ac_config, 'Value', 2); % OPTOcam 20/9
acquisition.select_capture_config_Callback;
verifyEqual(testCase, get(h.ac_stereo, 'Value'), 0);
verifyEqual(testCase, get(h.ac_stereo, 'Enable'), 'off');
verifyEqual(testCase, acquisition.capture_cameras, 1);
end

function test_stereo_live_image(testCase)
% live image of both cameras side by side: camera order by serial number, overlays per camera, display rate,
% snapshot and Save into cam1 / cam2
folder = new_folder(testCase, 'live');
h = start_capture_gui(folder, 2, 2);
set(h.ac_displ_sharp, 'Value', 1); % the live image takes the overlays from these checkboxes
set(h.ac_displ_grid, 'Value', 1);
set(h.calib_dolivedetect, 'Value', 1);
run_with_check(@check_live, 2);
acquisition.calibcapture_Callback;
r = getappdata(0, 'stereo_capture_test');
verifyEqual(testCase, r.n_images, 2, 'two camera images');
verifyEqual(testCase, r.cameras, [1 2]);
verifyEqual(testCase, r.x_offset, [0 320 + round(0.03 * 320)], 'camera 2 right of camera 1');
verifyEqual(testCase, r.cdata_size, [240 320; 240 320], 'live image: full resolution');
verifyEqual(testCase, r.device_shown, [2 1], 'camera 1 = lower serial number (device 2)');
verifyEqual(testCase, r.labels, 2, 'labels Camera 1 / Camera 2');
verifyEqual(testCase, r.sharpness_texts, 2);
verifyEqual(testCase, r.grid_lines, 12);
verifyTrue(testCase, r.charuco_cam1 && r.charuco_cam2, 'ChArUco markers per camera');
verifyLessThanOrEqual(testCase, r.display_rate, 10);
verifyEqual(testCase, r.frame_rate_limit, {'True', 20}, 'live image: at most 20 frames/s from the camera');
verifyTrue(testCase, isfile(fullfile(folder, 'cam1', 'PIVlab_snapshot (0).tif')), 'snapshot camera 1');
verifyTrue(testCase, isfile(fullfile(folder, 'cam2', 'PIVlab_snapshot (0).tif')), 'snapshot camera 2');
caliimg = gui.retr('caliimg');
verifyTrue(testCase, iscell(caliimg) && numel(caliimg) == 2, 'last images of both cameras');
evt.Source.Tag = 'ac_calibsave';
acquisition.camera_stop_Callback([], evt);
I1 = imread(fullfile(folder, 'cam1', 'PIVlab_calibration (0).tif'));
I2 = imread(fullfile(folder, 'cam2', 'PIVlab_calibration (0).tif'));
verifyEqual(testCase, double([I1(1, 3) I2(1, 3)]), [2 1] * 16, 'Save: camera 1 / 2 in cam1 / cam2 (12 bit stretched to 16 bit)');
verifyEqual(testCase, r.lens_control, 'off', 'no lens control in stereo mode');
end

function check_live(~, ~)
% runs while the live image is shown
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
r.cameras = sort(cams);
for k = 1:numel(imgs)
    r.x_offset(k) = getappdata(imgs(k), 'x_offset');
    r.cdata_size(k, :) = size(imgs(k).CData);
    frame = getappdata(imgs(k), 'frame');
    r.device_shown(k) = double(frame(1, 3));
end
r.display_rate = getappdata(imgs(1), 'max_display_rate');
r.labels = numel(findobj(ax, 'Tag', 'capture_camera_label'));
r.sharpness_texts = numel(findobj(ax, 'tag', 'sharpness_display_text'));
r.grid_lines = numel(findobj(ax, 'tag', 'capture_grid'));
r.charuco_cam1 = ~isempty(findobj(ax, 'tag', 'charucolabel_cam1'));
r.charuco_cam2 = ~isempty(findobj(ax, 'tag', 'charucolabel_cam2'));
vids = imaqfind('Tag', 'OPTOcam_cam1');
r.frame_rate_limit = {vids(1).Source.AcquisitionFrameRateEnable, vids(1).Source.AcquisitionFrameRate};
h = gui.gethand;
r.lens_control = get(h.ac_lensctrl, 'Enable');
acquisition.camera_snapshot_Callback;
setappdata(0, 'stereo_capture_test', r);
gui.put('cancel_capture', 1); % Stop
end

function test_stereo_recording(testCase)
% PIV capture with two cameras: images of camera 1 / 2 in cam1 / cam2 (A/B in trigger order), then opened in
% stereo mode, session saved; camera settings as for one camera
folder = new_folder(testCase, 'recording');
h = start_capture_gui(folder, 2, 2);
set(h.ac_pivcapture_save, 'Value', 1);
set(h.ac_imgamount, 'String', '10');
acquisition.piv_capture_Callback;
for k = 1:2
    for i = 1:10
        A = imread(fullfile(folder, sprintf('cam%d', k), sprintf('PIVlab_%04d_A.tif', i - 1)));
        B = imread(fullfile(folder, sprintf('cam%d', k), sprintf('PIVlab_%04d_B.tif', i - 1)));
        verifyEqual(testCase, [trigger_of(A) trigger_of(B)], [2 * i - 1, 2 * i], sprintf('camera %d, pair %d: triggers', k, i));
        verifyEqual(testCase, double(A(1, 3)), 3 - k, sprintf('camera %d: device', k)); % camera 1 = device 2
    end
end
verifyEqual(testCase, gui.retr('stereomode'), 1, 'opened in stereo mode');
verifyEqual(testCase, numel(gui.retr('filepath')), 20, 'camera 1: 10 pairs');
state = gui.retr('stereo_cam_state');
verifyEqual(testCase, numel(state{2}.filepath), 20, 'camera 2: 10 pairs');
verifyTrue(testCase, contains(state{2}.filepath{1}, [filesep 'cam2' filesep]), 'camera 2 from cam2');
verifyTrue(testCase, isfile(fullfile(folder, 'PIVlab_Capture_Session.mat')), 'session saved');
for k = 1:2
    vid = imaqfind('Tag', sprintf('OPTOcam_cam%d', k));
    src = vid(1).Source;
    verifyEqual(testCase, {src.TriggerMode, src.TriggerSource, src.LineSelector, src.LineSource, src.LineMode, src.AcquisitionFrameRateEnable}, ...
        {'On', 'Line2', 'Line4', 'ExposureActive', 'Output', 'False'}, sprintf('camera %d: trigger and exposure output', k));
end
verifyEqual(testCase, gui.camera_setting('OPTOcam_stereo_serials'), {'40000001', '40000002'}, 'camera order saved');
end

function test_stereo_recording_missed_trigger(testCase)
% one camera misses a trigger: the frame times differ, a message tells the user
folder = new_folder(testCase, 'missed');
h = start_capture_gui(folder, 2, 2);
reg = getappdata(0, 'mock_imaq');
reg.drop{2} = 7; % device 2 = camera 1
setappdata(0, 'mock_imaq', reg);
set(h.ac_pivcapture_save, 'Value', 1);
set(h.ac_imgamount, 'String', '10');
output = evalc('acquisition.piv_capture_Callback');
verifyTrue(testCase, contains(output, 'out of step from image pair 4'), output);
A = imread(fullfile(folder, 'cam1', 'PIVlab_0003_A.tif'));
verifyEqual(testCase, trigger_of(A), 8, 'camera 1 skipped trigger 7');
end

function test_stereo_piv_preview(testCase)
% PIV preview (save unticked) with two full-size cameras: both shown, downsampled, frames discarded, no files
folder = new_folder(testCase, 'preview');
h = start_capture_gui(folder, 2, 2);
gui.put('ac_ROI_general', [1 1 1936 1216]);
set(h.ac_pivcapture_save, 'Value', 0);
run_with_check(@check_preview, 2);
acquisition.piv_capture_Callback;
r = getappdata(0, 'stereo_capture_test');
verifyEqual(testCase, r.n_images, 2);
verifyEqual(testCase, r.cdata_size, [608 968; 608 968], 'downsampled to <= 1280 px per camera');
verifyEqual(testCase, r.extent, [1 1936; 1 1936] + [0 0; 1 1] * (1936 + round(0.03 * 1936)), 'axes in camera pixels');
verifyLessThan(testCase, r.available, 60, 'PIV preview: frames are discarded');
verifyGreaterThan(testCase, r.acquired, 30, 'cameras ran');
verifyEqual(testCase, get(h.ac_realtime_PIV, 'Value'), 0, 'no displacement view in stereo mode');
verifyFalse(testCase, isfolder(fullfile(folder, 'cam1')) && isfile(fullfile(folder, 'cam1', 'PIVlab_0000_A.tif')), 'no files in PIV preview');
end

function check_preview(~, ~)
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
    r.cdata_size(k, :) = size(imgs(k).CData);
    r.extent(k, :) = imgs(k).XData;
end
vid = imaqfind('Tag', 'OPTOcam_cam1');
r.available = vid(1).FramesAvailable;
r.acquired = vid(1).FramesAcquired;
setappdata(0, 'stereo_capture_test', r);
gui.put('cancel_capture', 1); % Abort
end

function test_one_camera_recording(testCase)
% 2D with the new driver: images in the project folder, normal (2D) session
folder = new_folder(testCase, 'mono');
h = start_capture_gui(folder, 2, 1);
set(h.ac_pivcapture_save, 'Value', 1);
set(h.ac_imgamount, 'String', '5');
acquisition.piv_capture_Callback;
A = imread(fullfile(folder, 'PIVlab_0004_A.tif'));
verifyEqual(testCase, trigger_of(A), 9);
verifyFalse(testCase, isfolder(fullfile(folder, 'cam1')), 'no camera folders in 2D');
verifyNotEqual(testCase, gui.retr('stereomode'), 1, '2D');
verifyEqual(testCase, numel(gui.retr('filepath')), 10);
verifyEqual(testCase, numel(imaqfind), 1, 'one camera opened');
end

function test_swap_cameras(testCase)
% OPTOcam settings window: serial numbers of camera 1 / 2, "Swap cameras" changes the order of the next start
folder = new_folder(testCase, 'swap');
start_capture_gui(folder, 2, 2);
gui.set_camera_setting('OPTOcam_stereo_serials', {'40000001', '40000002'});
PIVlab_capture_OPTOcam_settings_GUI;
fh = findobj('tag', 'OPTOcam_control_window');
verifyEqual(testCase, get(findobj(fh, 'tag', 'stereo_cam1_txt'), 'String'), 'Camera 1: serial nr. 40000001');
btn = findobj(fh, 'tag', 'swap_btn');
callback = get(btn, 'Callback');
callback(btn, []);
verifyEqual(testCase, gui.camera_setting('OPTOcam_stereo_serials'), {'40000002', '40000001'});
verifyEqual(testCase, get(findobj(fh, 'tag', 'stereo_cam1_txt'), 'String'), 'Camera 1: serial nr. 40000002');
close(fh);
[vids, err] = PIVlab_capture_OPTOcam_open(8, 2);
verifyEqual(testCase, err, 0);
verifyEqual(testCase, vids{1}.Source.DeviceSerialNumber, '40000002', 'camera 1 after the swap');
end

%% helpers
function folder = new_folder(testCase, name)
folder = fullfile(testCase.TestData.Dir, name);
mkdir(folder);
end

function h = start_capture_gui(folder, n_connected, n_cameras)
% PIVlab with the OPTOcam 2/80 configuration, simulated cameras at 80 frames/s, ROI 320 x 240
mock_imaq_setup(n_connected, 80);
helper_start_pivlab();
h = gui.gethand;
set(h.ac_project, 'String', folder);
set(h.ac_config, 'Value', find(strcmp(h.ac_config.String, 'PIVlab LD-PS + OPTOcam 2/80')));
acquisition.select_capture_config_Callback;
set(h.ac_fps, 'Value', find(strcmp(h.ac_fps.String, '80')));
gui.put('ac_ROI_general', [1 1 320 240]);
set(h.ac_stereo, 'Value', double(n_cameras == 2));
gui.set_camera_setting('OPTOcam_stereo_serials', []);
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
