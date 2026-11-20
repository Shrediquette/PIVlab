%% Tests of the stereo-PIV mode that follows "Stereo (2 cameras)" of the Image Acquisition panel
%
% Ticked: stereo-PIV mode without images (CAM 1 / CAM 2 in the camera calibration panel, one lens
% calibration per camera); "Import stereo images" keeps these calibrations when the image size fits.
% No camera is needed: the checkbox is set directly (stereo.acquisition_stereo_mode), not through its
% callback, which looks for connected cameras.
%
% Run with:
%   runtests('unittests/test_gui_acquisition_stereo_mode.m')

function tests = test_gui_acquisition_stereo_mode
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
helper_setup_once(testCase);
folder = testCase.TestData.Dir;
testCase.TestData.cam1 = write_images(folder, 'cam1', [200 240], 2);
testCase.TestData.cam2 = write_images(folder, 'cam2', [220 260], 2);
testCase.TestData.plain = write_images(folder, 'plain', [180 200], 2);
end

function teardownOnce(testCase)
helper_teardown_once(testCase);
end

function test_tick_gives_stereo_mode_without_images(testCase)
helper_start_pivlab();
tick_stereo(1);
verifyEqual(testCase, gui.retr('stereomode'), 1);
verifyEqual(testCase, gui.retr('stereo_active_camera'), 1);
handles = gui.gethand;
preproc.cam_calibration_Callback
drawnow
verifyEqual(testCase, char(get(handles.stereo_camera_toggle, 'Visible')), 'on', 'CAM switch in the calibration panel');
verifyEqual(testCase, get(handles.stereo_camera_toggle, 'String'), 'CAM 1');
verifyEqual(testCase, get(handles.calib_undist_cam_label, 'String'), 'Current camera: CAMERA 1');
gui.put('cameraParams', lens([200 240]));
stereo.camera_toggle_Callback % camera 2
drawnow
verifyEqual(testCase, gui.retr('stereo_active_camera'), 2);
verifyEqual(testCase, get(handles.stereo_camera_toggle, 'String'), 'CAM 2');
verifyEmpty(testCase, gui.retr('cameraParams'), 'camera 2 starts without lens calibration');
verifyEmpty(testCase, gui.retr('filepath'));
gui.put('cameraParams', lens([220 260]));
stereo.camera_toggle_Callback % camera 1
verifyEqual(testCase, gui.retr('cameraParams').ImageSize, [200 240], 'lens calibration of camera 1 kept');
state = gui.retr('stereo_cam_state');
verifyEqual(testCase, state{2}.cameraParams.ImageSize, [220 260], 'lens calibration of camera 2 kept');
end

function test_import_keeps_calibrations_made_without_images(testCase)
helper_start_pivlab();
tick_stereo(1);
gui.put('cameraParams', lens([200 240]));
stereo.camera_toggle_Callback
gui.put('cameraParams', lens([220 260]));
stereo.camera_toggle_Callback
import_stereo(testCase);
verifyEqual(testCase, gui.retr('filepath'), testCase.TestData.cam1(:));
verifyEqual(testCase, gui.retr('cameraParams').ImageSize, [200 240], 'camera 1 calibration after the import');
state = gui.retr('stereo_cam_state');
verifyEqual(testCase, state{2}.cameraParams.ImageSize, [220 260], 'camera 2 calibration after the import');
verifyEqual(testCase, state{2}.filepath, testCase.TestData.cam2(:));
end

function test_import_removes_calibration_of_other_size(testCase)
helper_start_pivlab();
tick_stereo(1);
gui.put('cameraParams', lens([300 400])); % calibrated with another image size
import_stereo(testCase);
verifyEmpty(testCase, gui.retr('cameraParams'));
end

function test_untick_back_to_2d(testCase)
helper_start_pivlab();
tick_stereo(1);
gui.put('cameraParams', lens([200 240]));
tick_stereo(0);
verifyEqual(testCase, gui.retr('stereomode'), 0, 'nothing of camera 2: back to 2D');
verifyEqual(testCase, gui.retr('cameraParams').ImageSize, [200 240], 'lens calibration stays (2D)');
verifyEqual(testCase, char(get(gui.gethand().stereo_camera_toggle, 'Visible')), 'off');
% calibration of camera 2: stereo-PIV mode stays
tick_stereo(1);
stereo.camera_toggle_Callback
gui.put('cameraParams', lens([220 260]));
tick_stereo(0);
verifyEqual(testCase, gui.retr('stereomode'), 1, 'camera 2 calibrated: stereo mode stays');
end

function test_tick_with_2d_images_removes_them(testCase)
helper_start_pivlab();
gui.put('sequencer', 1);
selection = struct('name', testCase.TestData.plain, 'isdir', false);
import.loadimgsbutton_Callback([], [], 0, selection);
verifyNotEmpty(testCase, gui.retr('filepath'));
tick_stereo(1); % PIVlabTestMode answers "Yes"
verifyEqual(testCase, gui.retr('stereomode'), 1);
verifyEmpty(testCase, gui.retr('filepath'));
verifyEmpty(testCase, gui.retr('resultslist'));
end

function test_one_camera_no_stereo_mode(testCase)
helper_start_pivlab();
tick_stereo(0);
preproc.cam_calibration_Callback
verifyEqual(testCase, gui.retr('stereomode'), 0);
verifyEqual(testCase, char(get(gui.gethand().stereo_camera_toggle, 'Visible')), 'off');
end

% -------------------------------------------------------------------------

function tick_stereo(value)
% "Stereo (2 cameras)" with a camera type that records stereo, without looking for cameras
handles = gui.gethand;
gui.put('camera_type', 'OPTOcam_20_9');
set(handles.ac_stereo, 'Value', value, 'Visible', 'on', 'Enable', 'on');
stereo.acquisition_stereo_mode
drawnow
end

function params = lens(image_size)
params = cameraParameters('IntrinsicMatrix', [500 0 0; 0 500 0; image_size(2)/2 image_size(1)/2 1], 'ImageSize', image_size);
end

function import_stereo(testCase)
gui.put('sequencer', 1);
import.stereo_import_Callback([], [], {testCase.TestData.cam1, testCase.TestData.cam2});
drawnow
end

function files = write_images(folder, name, sz, n_pairs)
files = {};
rng(7);
for n = 1:n_pairs
    for ab = 'AB'
        file = fullfile(folder, sprintf('%s_%04d%s.tif', name, n, ab));
        imwrite(uint8(255 * rand(sz)), file);
        files{end + 1, 1} = file; %#ok<AGROW>
    end
end
end
