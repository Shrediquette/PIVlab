%% Tests of the stereo-PIV mode of the PIVlab window
%
% Stereo import, camera switch (per-camera data, shared settings), stereo calibration, disparity,
% analysis against the ground truth, session save / load, return to 2D.
%
% Run with:
%   runtests('unittests/test_stereo_gui.m')

function tests = test_stereo_gui
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
helper_setup_once(testCase);
testCase.TestData.folder = testCase.TestData.Dir;
% two cameras with different image sizes, 3 image pairs each, plus a 2D set
testCase.TestData.cam1 = write_images(testCase.TestData.folder, 'cam1', [200 240], 3);
testCase.TestData.cam2 = write_images(testCase.TestData.folder, 'cam2', [220 260], 3);
testCase.TestData.cam2_short = testCase.TestData.cam2(1:4);
testCase.TestData.plain = write_images(testCase.TestData.folder, 'plain', [180 200], 2);
end

function teardownOnce(testCase)
helper_teardown_once(testCase);
end

function setup(~)
helper_close_pivlab();
end

function teardown(~)
helper_close_pivlab();
end

% -------------------------------------------------------------------------
% Import, cameras, sessions
% -------------------------------------------------------------------------

function test_camera_data_keys_are_session_data(testCase)
keys = stereo.camera_data_keys;
missing = setdiff(keys, gui.session_data_keys);
verifyEmpty(testCase, missing, 'per-camera keys that a session would not save');
hgui = helper_start_pivlab();
[~, tags] = gui.setting_controls(hgui);
verifyEmpty(testCase, intersect(keys, tags), 'a setting control must not be per-camera data');
session_only = {};
controls = stereo.camera_controls;
for k = 1:numel(controls)
    h = findobj(hgui, 'Tag', controls{k});
    verifyNumElements(testCase, h, 1);
    if ischar(h.UserData) && strcmp(h.UserData, 'session_only')
        session_only{end + 1} = controls{k}; %#ok<AGROW>
    end
end
verifyEqual(testCase, session_only, controls, 'per-camera controls must be session_only (not in settings files)');
end

function test_import_stereo_images(testCase)
helper_start_pivlab();
handles = gui.gethand;
verifyEqual(testCase, char(get(handles.stereo_camera_toggle, 'Visible')), 'off', 'camera switch visible in 2D');
import_stereo(testCase);
verifyEqual(testCase, gui.retr('stereomode'), 1);
verifyEqual(testCase, gui.retr('stereo_active_camera'), 1);
verifyEqual(testCase, gui.retr('filepath'), testCase.TestData.cam1(:));
verifyEqual(testCase, gui.retr('expected_image_size'), [200 240]);
state = gui.retr('stereo_cam_state');
verifyEqual(testCase, state{2}.filepath, testCase.TestData.cam2(:));
verifyEqual(testCase, state{2}.expected_image_size, [220 260]);
verifyEqual(testCase, char(get(handles.stereo_camera_toggle, 'Visible')), 'on');
verifyEqual(testCase, get(handles.stereo_camera_toggle, 'String'), 'CAM 1');
verifyEqual(testCase, char(get(findall(getappdata(0, 'hgui'), 'Tag', 'menu_camcalib_cam2'), 'Enable')), 'on');
verifyEqual(testCase, char(get(findall(getappdata(0, 'hgui'), 'Tag', 'menu_stereo_switch'), 'Enable')), 'on');
label = findobj(gui.retr('pivlab_axis'), 'Tag', 'stereo_camera_label');
verifyNumElements(testCase, label, 1, 'camera label missing');
verifyEqual(testCase, strtrim(label.String), 'CAMERA 1');
end

function test_switch_camera_keeps_data_per_camera(testCase)
helper_start_pivlab();
import_stereo(testCase);
handles = gui.gethand;
stereo.camera_toggle_Callback; % camera 2
verifyEqual(testCase, gui.retr('stereo_active_camera'), 2);
verifyEqual(testCase, gui.retr('filepath'), testCase.TestData.cam2(:));
verifyEqual(testCase, gui.retr('expected_image_size'), [220 260]);
verifyEqual(testCase, get(handles.stereo_camera_toggle, 'String'), 'CAM 2');
verifyEqual(testCase, strtrim(get(findobj(gui.retr('pivlab_axis'), 'Tag', 'stereo_camera_label'), 'String')), 'CAMERA 2');
verifyEqual(testCase, get(handles.calib_undist_cam_label, 'String'), 'Current camera: CAMERA 2');
% data of camera 2: a mask, a background image, the lens calibration switch; a shared setting
masks = {{'ROI_object_rectangle', [10 10 40 30]}, cell(0), cell(0)};
gui.put('masks_in_frame', masks);
gui.put('bg_img_A', zeros(220, 260, 'uint8') + 3);
set(handles.calib_usecalibration, 'Value', 1);
set(handles.clahe_size, 'String', '33');
stereo.switch_camera(1);
verifyEmpty(testCase, gui.retr('masks_in_frame'), 'camera 1 got the mask of camera 2');
verifyEmpty(testCase, gui.retr('bg_img_A'));
verifyEqual(testCase, get(handles.calib_usecalibration, 'Value'), 0);
verifyEqual(testCase, get(handles.clahe_size, 'String'), '33', 'settings are shared by both cameras');
verifyEqual(testCase, gui.retr('filepath'), testCase.TestData.cam1(:));
stereo.switch_camera(2);
verifyEqual(testCase, gui.retr('masks_in_frame'), masks);
verifyEqual(testCase, gui.retr('bg_img_A'), zeros(220, 260, 'uint8') + 3);
verifyEqual(testCase, get(handles.calib_usecalibration, 'Value'), 1);
% the calibration menu entries select the camera
menu = findall(getappdata(0, 'hgui'), 'Tag', 'menu_camcalib_cam2');
parent_items = findall(get(menu, 'Parent'), 'Label', 'Camera 1');
preproc.cam_calibration_Callback(parent_items(1));
verifyEqual(testCase, gui.retr('stereo_active_camera'), 1);
verifyEqual(testCase, char(get(handles.multip26, 'Visible')), 'on');
end

function test_session_round_trip(testCase)
helper_start_pivlab();
import_stereo(testCase);
stereo.switch_camera(2);
masks = {{'ROI_object_rectangle', [12 14 30 20]}, cell(0), cell(0)};
gui.put('masks_in_frame', masks);
file = fullfile(testCase.TestData.folder, 'stereo_session.mat');
export.save_session_function(testCase.TestData.folder, 'stereo_session.mat');
helper_close_pivlab();
helper_start_pivlab();
import.load_session_Callback(1, file);
drawnow;
handles = gui.gethand;
verifyEqual(testCase, gui.retr('stereomode'), 1);
verifyEqual(testCase, gui.retr('stereo_active_camera'), 2, 'the session opens with the camera that was shown');
verifyEqual(testCase, gui.retr('filepath'), testCase.TestData.cam2(:));
verifyEqual(testCase, gui.retr('masks_in_frame'), masks);
verifyEqual(testCase, char(get(handles.stereo_camera_toggle, 'Visible')), 'on');
verifyEqual(testCase, get(handles.stereo_camera_toggle, 'String'), 'CAM 2');
stereo.switch_camera(1);
verifyEqual(testCase, gui.retr('filepath'), testCase.TestData.cam1(:));
verifyEmpty(testCase, gui.retr('masks_in_frame'));
end

function test_different_number_of_images_is_refused(testCase)
helper_start_pivlab();
import.stereo_import_Callback([], [], {testCase.TestData.cam1, testCase.TestData.cam2_short});
verifyEqual(testCase, gui.retr('stereomode'), 0);
verifyEmpty(testCase, gui.retr('filepath'));
end

function test_2d_import_leaves_stereo_mode(testCase)
helper_start_pivlab();
import_stereo(testCase);
paths = testCase.TestData.plain;
import.loadimgsbutton_Callback([], [], 0, struct('name', paths(:), 'isdir', num2cell(false(numel(paths), 1))));
handles = gui.gethand;
verifyEqual(testCase, gui.retr('stereomode'), 0);
verifyEmpty(testCase, gui.retr('stereo_cam_state'));
verifyEqual(testCase, gui.retr('filepath'), paths(:));
verifyEqual(testCase, char(get(handles.stereo_camera_toggle, 'Visible')), 'off');
verifyEqual(testCase, char(get(findall(getappdata(0, 'hgui'), 'Tag', 'menu_camcalib_cam2'), 'Enable')), 'off');
verifyEmpty(testCase, findobj(gui.retr('pivlab_axis'), 'Tag', 'stereo_camera_label'));
% rectification panel as in 2D again
verifyEqual(testCase, char(get(handles.calib_userectification, 'Visible')), 'on');
verifyEqual(testCase, char(get(handles.calib_upscale, 'Visible')), 'on');
verifyEqual(testCase, char(get(handles.stereo_rect_note, 'Visible')), 'off');
end

function test_remove_images_is_blocked_in_stereo_mode(testCase)
helper_start_pivlab();
import_stereo(testCase);
import.remove_images_from_list;
verifyEqual(testCase, gui.retr('filepath'), testCase.TestData.cam1(:));
end

function test_background_made_for_the_other_camera(testCase)
% background subtraction is a setting of both cameras: switching makes the missing background images
helper_start_pivlab();
import_stereo(testCase);
handles = gui.gethand;
set(handles.bg_subtract, 'Value', 3); % minimum intensity
preproc.generate_BG_img;
verifyNotEmpty(testCase, gui.retr('bg_img_A'));
stereo.switch_camera(2);
verifyEqual(testCase, get(handles.bg_subtract, 'Value'), 3, 'the setting must stay on');
verifyEqual(testCase, size(gui.retr('bg_img_A')), [220 260], 'background of camera 2 not made');
end

% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Check analysis, calibration, disparity, stereo analysis
% -------------------------------------------------------------------------

function test_check_analysis_before_calibration(testCase)
% before the stereo calibration, ANALYZE is a normal 2D analysis of the camera that is shown; the result
% goes with the camera
helper_start_pivlab();
import_stereo(testCase);
handles = gui.gethand;
set(handles.update_display_checkbox, 'Value', 0);
piv.AnalyzeAll_Callback;
r1 = gui.retr('resultslist');
verifyEqual(testCase, size(r1, 2), 3, '2D result of camera 1 missing');
verifyEmpty(testCase, gui.retr('stereo_vel'), 'no 3C result without the stereo calibration');
stereo.switch_camera(2);
verifyEmpty(testCase, gui.retr('resultslist'), 'camera 2 must not show the result of camera 1');
piv.AnalyzeSingle_Callback;
r2 = gui.retr('resultslist');
verifyNotEmpty(testCase, r2, '2D result of camera 2 missing');
piv.AnalyzeAll_Callback;
r2 = gui.retr('resultslist');
verifyNotEqual(testCase, size(r2{1, 1}), size(r1{1, 1}), 'camera 2 has other images (other size)');
validate.apply_filter_all_Callback; % vector validation of the camera that is shown
r2 = gui.retr('resultslist');
verifyNotEmpty(testCase, r2{7, 1}, 'not validated');
stereo.switch_camera(1);
verifyEqual(testCase, gui.retr('resultslist'), r1, 'result of camera 1 not back');
% session: the check results of both cameras are kept
export.save_session_function(testCase.TestData.folder, 'check_session.mat');
helper_close_pivlab();
helper_start_pivlab();
import.load_session_Callback(1, fullfile(testCase.TestData.folder, 'check_session.mat'));
verifyEqual(testCase, gui.retr('resultslist'), r1);
stereo.switch_camera(2);
r = gui.retr('resultslist');
verifyEqual(testCase, r, r2, 'result of camera 2 not in the session');
end

function test_stereo_calibration_discards_check_results(testCase)
c = helper_stereo_synthetic_case(fullfile(testCase.TestData.folder, 'check_case'), 2, 0);
helper_start_pivlab();
handles = gui.gethand;
gui.put('sequencer', 1);
import.stereo_import_Callback([], [], {c.files{1}, c.files{2}});
set(handles.update_display_checkbox, 'Value', 0);
piv.AnalyzeSingle_Callback;
verifyNotEmpty(testCase, gui.retr('resultslist'));
calibrate_in_gui(c, false);
verifyNotEmpty(testCase, gui.retr('stereo_calib'));
verifyEmpty(testCase, gui.retr('resultslist'), 'check result not removed by the stereo calibration');
state = gui.retr('stereo_cam_state');
verifyEmpty(testCase, gui.retr('stereo_check'));
verifyEmpty(testCase, state{2}.stereo_check);
end

function test_new_images_keep_the_calibration(testCase)
% the next recording with the same setup: calibrations, disparity and ROI stay; results, masks and
% backgrounds go. Images of another size: the calibrations go.
c = helper_stereo_synthetic_case(fullfile(testCase.TestData.folder, 'next_case'), 4, 0);
helper_start_pivlab();
handles = gui.gethand;
calibrate_in_gui(c);
stereo.measure_disparity_Callback;
verifyEmpty(testCase, timerfind('Name', 'pivprogress'), 'progress timer of the disparity left over');
calib = gui.retr('stereo_calib');
disparity = gui.retr('stereo_disparity');
roirect = gui.retr('roirect');
maps = gui.retr('stereo_maps');
state = gui.retr('stereo_cam_state');
lens = {gui.retr('cameraParams'), state{2}.cameraParams};
gui.put('masks_in_frame', {{'dummy'}});
gui.put('resultslist', cell(9, 1));
gui.put('stereo_vel', struct('W', 1));
import.stereo_import_Callback([], [], {c.files{1}(5:8), c.files{2}(5:8)});
verifyEqual(testCase, gui.retr('stereomode'), 1);
verifyEqual(testCase, numel(gui.retr('filepath')), 4, 'new images not loaded');
verifyEqual(testCase, gui.retr('stereo_calib'), calib, 'stereo calibration not kept');
kept = gui.retr('stereo_disparity');
verifyEqual(testCase, kept.u_mean_smooth, disparity.u_mean_smooth, 'disparity not kept');
verifyEqual(testCase, kept.background, {[], []}, 'minimum backgrounds of the old images must go');
verifyEqual(testCase, gui.retr('roirect'), roirect, 'ROI not kept');
verifyEqual(testCase, gui.retr('stereo_maps'), maps, 'maps differ');
verifyEqual(testCase, gui.retr('cameraParams'), lens{1});
state = gui.retr('stereo_cam_state');
verifyEqual(testCase, state{2}.cameraParams, lens{2});
verifyEqual(testCase, state{2}.cam_selected_rectification_image, c.boards{2});
verifyEmpty(testCase, gui.retr('masks_in_frame'), 'masks must go (as in 2D)');
verifyEmpty(testCase, gui.retr('resultslist'));
verifyEmpty(testCase, gui.retr('stereo_vel'));
verifyEqual(testCase, size(import.get_img(1), 1, 2), calib.Ravg.ImageSize, 'new images not rectified');
% another image size: a new setup, the calibrations go
import_stereo(testCase);
verifyEmpty(testCase, gui.retr('stereo_calib'));
verifyEmpty(testCase, gui.retr('stereo_disparity'));
verifyEmpty(testCase, gui.retr('cameraParams'));
verifyEqual(testCase, size(import.get_img(1), 1, 2), [200 240]);
end

function test_stereo_calibration(testCase)
% synthetic recording with board images and known lens parameters: stereo calibration in the GUI
c = helper_stereo_synthetic_case(fullfile(testCase.TestData.folder, 'calib_case'), 2, 0);
helper_start_pivlab();
handles = gui.gethand;
gui.put('sequencer', 1);
import.stereo_import_Callback([], [], {c.files{1}, c.files{2}});
verifyEqual(testCase, char(get(handles.stereo_calibrate, 'Enable')), 'on');
% without lens calibration and board images: refused, nothing changes
stereo.calibrate_Callback;
verifyEmpty(testCase, gui.retr('stereo_calib'));
for k = 1:2
    stereo.switch_camera(k);
    gui.put('cameraParams', c.lens{k});
    gui.put('cam_selected_rectification_image', c.boards{k});
end
set(handles.calib_rows, 'String', int2str(c.board.PatternDims(1)));
set(handles.calib_columns, 'String', int2str(c.board.PatternDims(2)));
set(handles.calib_checkersize, 'String', num2str(c.board.CheckerSize));
set(handles.calib_markersize, 'String', num2str(c.board.MarkerSize));
set(handles.calib_origincolor, 'Value', 1); % black
stereo.panel_Callback;
verifyEqual(testCase, char(get(handles.multip30, 'Visible')), 'on');
stereo.calibrate_Callback;
calib = gui.retr('stereo_calib');
verifyNotEmpty(testCase, calib, 'no stereo calibration');
sz = calib.Ravg.ImageSize;
verifyEqual(testCase, calib.n_rejected, [0 0]);
verifyEqual(testCase, calib.Ravg.PixelExtentInWorldX, 0.1, 'RelTol', 0.15, 'pixel size of the common grid [mm]');
% both cameras show their images on the common grid
verifyEqual(testCase, size(import.get_img(1), 1, 2), sz);
verifyEqual(testCase, gui.retr('expected_image_size'), sz);
stereo.switch_camera(1);
verifyEqual(testCase, size(import.get_img(1), 1, 2), sz);
maps = gui.retr('stereo_maps');
verifyNumElements(testCase, maps, 2);
% region of interest inside the overlap, spatial calibration filled in
roirect = gui.retr('roirect');
verifyNotEmpty(testCase, roirect);
inside = ~calib.mask(roirect(2):roirect(2) + roirect(4), roirect(1):roirect(1) + roirect(3));
verifyTrue(testCase, all(inside(:)), 'ROI leaves the overlap');
pointscali = gui.retr('pointscali');
verifyEqual(testCase, str2double(get(handles.realdist, 'String')) / abs(diff(pointscali(:, 1))), ...
    calib.Ravg.PixelExtentInWorldX, 'RelTol', 1e-4, 'mm per px of the spatial calibration');
steps = get(handles.stereo_steps, 'String');
verifyTrue(testCase, startsWith(steps{4}, char(10003)), 'checklist: stereo calibration not ticked');
verifyTrue(testCase, startsWith(steps{7}, char(10007)), 'checklist: time step ticked before it was applied');
% time step applied in the calibration panel: ticked in the checklist
set(handles.time_inp, 'String', '2');
calibrate.apply_cali_Callback;
stereo.panel_Callback;
steps = get(handles.stereo_steps, 'String');
verifyTrue(testCase, startsWith(steps{7}, char(10003)), 'checklist: time step not ticked after applying it');
% rectification panel: no 2D rectification and upscaling in stereo mode, a note instead
verifyEqual(testCase, char(get(handles.calib_userectification, 'Visible')), 'off', '2D rectification must be hidden in stereo mode');
verifyEqual(testCase, char(get(handles.calib_upscale, 'Visible')), 'off');
verifyEqual(testCase, char(get(handles.calib_upscale_label, 'Visible')), 'off');
verifyEqual(testCase, char(get(handles.stereo_rect_note, 'Visible')), 'on');
% "Show rectified board": the board of the camera that is shown on the common grid
preproc.cam_rectification_show_rectified_Callback;
board = findobj(gui.retr('pivlab_axis'), 'Type', 'image');
verifyNumElements(testCase, board, 1);
verifyEqual(testCase, size(board.CData, 1, 2), sz, 'board not shown on the common grid');
% 3D view
stereo.show_3d_Callback;
fig = findall(0, 'Type', 'figure', 'Name', 'Stereo-PIV setup in 3D');
verifyNumElements(testCase, fig, 1);
report = findall(fig, 'Tag', 'stereo_calib_report');
verifyNumElements(testCase, report, 1, 'calibration report missing in the 3D view');
verifyNotEmpty(testCase, strfind(strjoin(cellstr(report.String), ' '), 'Angle between the cameras'));
close(fig);
% session: the maps are made again after loading
file = fullfile(testCase.TestData.folder, 'calib_session.mat');
export.save_session_function(testCase.TestData.folder, 'calib_session.mat');
helper_close_pivlab();
helper_start_pivlab();
import.load_session_Callback(1, file);
verifyNotEmpty(testCase, gui.retr('stereo_calib'));
verifyNumElements(testCase, gui.retr('stereo_maps'), 2);
verifyEqual(testCase, size(import.get_img(1), 1, 2), sz);
stereo.switch_camera(2);
verifyEqual(testCase, size(import.get_img(2), 1, 2), sz);
end

function test_disparity_in_gui(testCase)
% synthetic recording, light sheet 1 mm in front of the board and tilted by 1 deg: disparity in the GUI
c = helper_stereo_synthetic_case(fullfile(testCase.TestData.folder, 'disparity_case'), 4, 0);
helper_start_pivlab();
handles = gui.gethand;
calibrate_in_gui(c);
calib = gui.retr('stereo_calib');
verifyEqual(testCase, char(get(handles.stereo_measure_disparity, 'Enable')), 'on');
stereo.panel_Callback;
set(handles.stereo_disp_show, 'Value', 6); % overlay without disparity correction
gui.sliderdisp(gui.retr('pivlab_axis'));
verifyNotEmpty(testCase, findobj(gui.retr('pivlab_axis'), 'Tag', 'stereo_disparity_display'));
before = images_agree(1);
stereo.measure_disparity_Callback;
disparity = gui.retr('stereo_disparity');
verifyNotEmpty(testCase, disparity, 'no disparity');
verifyFalse(testCase, isfield(disparity, 'u_full'), 'the full-size maps must not be stored');
verifyLessThan(testCase, disparity.residual_history(end, 1), 0.3, 'remaining disparity [px]');
sheet = stereo.sheet_position(calib, disparity);
% true sheet plane: through c.sheet_pose.Translation with the normal c.sheet_pose.R(:, 3)
n = c.sheet_pose.R(:, 3);
t = c.sheet_pose.Translation;
[cx, cy] = centroid(calib.grid_info.overlap);
z_true = t(3) - (n(1) * (cx - t(1)) + n(2) * (cy - t(2))) / n(3);
verifyEqual(testCase, sheet.offset, z_true, 'AbsTol', 0.1, 'light sheet position at the centre [mm]');
verifyEqual(testCase, sheet.tilt, [atand(-n(1) / n(3)), atand(-n(2) / n(3))], 'AbsTol', 0.15, 'light sheet tilt [deg]');
after = images_agree(1);
verifyGreaterThan(testCase, after, 1.5 * before, 'the correction should clearly improve the agreement');
verifyGreaterThan(testCase, after, before + 0.1, 'the correction should clearly improve the agreement');
fprintf('agreement of camera 1 and camera 2 images: %.2f without, %.2f with the disparity correction\n', before, after);
% panel, displays, automatic ROI
steps = get(handles.stereo_steps, 'String');
verifyTrue(testCase, startsWith(steps{5}, char(10003)), 'checklist: disparity not ticked');
verifyNotEmpty(testCase, strfind(strjoin(get(handles.stereo_disp_report, 'String'), ' '), 'Light sheet'));
roirect = gui.retr('roirect');
verifyEqual(testCase, roirect, gui.retr('stereo_calib').auto_roi, 'automatic ROI not adapted');
for mode = 2:6
    set(handles.stereo_disp_show, 'Value', mode);
    gui.sliderdisp(gui.retr('pivlab_axis'));
    verifyNotEmpty(testCase, findobj(gui.retr('pivlab_axis'), 'Tag', 'stereo_disparity_display'), sprintf('display %d', mode));
end
stereo.show_3d_Callback;
fig = findall(0, 'Type', 'figure', 'Name', 'Stereo-PIV setup in 3D');
verifyNotEmpty(testCase, findobj(fig, 'Type', 'surface'), 'light sheet missing in the 3D view');
close(fig);
% session: disparity stored, maps made again identically
maps = gui.retr('stereo_maps');
export.save_session_function(testCase.TestData.folder, 'disparity_session.mat');
helper_close_pivlab();
helper_start_pivlab();
import.load_session_Callback(1, fullfile(testCase.TestData.folder, 'disparity_session.mat'));
verifyEqual(testCase, gui.retr('stereo_maps'), maps, 'maps after loading the session differ');
end

function test_stereo_analysis_in_gui(testCase)
% ANALYZE in stereo mode: both cameras, disparity measured automatically, U, V, W against the ground truth;
% validation of both cameras, undo, W display, session round trip
c = helper_stereo_synthetic_case(fullfile(testCase.TestData.folder, 'analysis_case'), 4, 0);
helper_start_pivlab();
handles = gui.gethand;
calibrate_in_gui(c);
verifyEmpty(testCase, gui.retr('stereo_disparity'));
% PIV settings (shared): 64 / 32 px windows, three passes
set(handles.pass1_size, 'String', '64'); piv.intarea_Callback(handles.pass1_size, [], []);
set(handles.pass1_step, 'String', '32'); piv.step_Callback(handles.pass1_step, [], []);
set(handles.pass2_enable, 'Value', 1); set(handles.pass2_size, 'String', '32'); piv.pass2_checkbox_Callback(handles.pass2_enable, [], []);
set(handles.pass3_enable, 'Value', 1); set(handles.pass3_size, 'String', '16'); piv.pass3_checkbox_Callback(handles.pass3_enable, [], []);
set(handles.update_display_checkbox, 'Value', 0);
piv.AnalyzeAll_Callback;
verifyNotEmpty(testCase, gui.retr('stereo_disparity'), 'the disparity is measured before the analysis');
resultslist = gui.retr('resultslist');
verifyEqual(testCase, size(resultslist, 2), 4, 'one result per image pair');
verifyGreaterThanOrEqual(testCase, size(resultslist, 1), 16, 'W (row 16) missing');
state = gui.retr('stereo_cam_state');
verifyNotEmpty(testCase, gui.retr('stereo_result'), '2D result of the active camera');
verifyNotEmpty(testCase, state{3 - gui.retr('stereo_active_camera')}.stereo_result, '2D result of the other camera');
check_accuracy(testCase, result_error(c), [0.008 0.008 0.01]);
% W display under the vectors
gui.sliderdisp(gui.retr('pivlab_axis'));
verifyNotEmpty(testCase, findobj(gui.retr('pivlab_axis'), 'Tag', 'stereo_w_display'), 'W not displayed');
% validation of both cameras, then undo
validate.apply_filter_all_Callback;
state = gui.retr('stereo_cam_state');
R = {gui.retr('stereo_result'), state{3 - gui.retr('stereo_active_camera')}.stereo_result};
verifyNotEmpty(testCase, R{1}{7, 1}, 'camera shown: not validated');
verifyNotEmpty(testCase, R{2}{7, 1}, 'other camera: not validated');
check_accuracy(testCase, result_error(c), [0.008 0.008 0.01]);
validate.restore_all_Callback;
r = gui.retr('stereo_result');
verifyTrue(testCase, size(r, 1) < 7 || isempty(r{7, 1}), 'validation not undone');
% session round trip
before = gui.retr('resultslist');
export.save_session_function(testCase.TestData.folder, 'analysis_session.mat');
helper_close_pivlab();
helper_start_pivlab();
import.load_session_Callback(1, fullfile(testCase.TestData.folder, 'analysis_session.mat'));
after = gui.retr('resultslist');
verifyEqual(testCase, after(16, :), before(16, :), 'W after loading the session');
verifyNotEmpty(testCase, findobj(gui.retr('pivlab_axis'), 'Tag', 'stereo_w_display'));
end

function test_3d_result_out_of_pivlab(testCase)
% W in the exports (ASCII, Tecplot, VTK, MAT, workspace), the derived parameters (w component, 3D
% magnitude), the temporal operations (mean, TKE) and the data smoothing
folder = testCase.TestData.folder;
c = helper_stereo_synthetic_case(fullfile(folder, 'export_case'), 3, 0);
helper_start_pivlab();
h = gui.gethand;
calibrate_in_gui(c);
set(h.pass1_size, 'String', '64'); piv.intarea_Callback(h.pass1_size, [], []);
set(h.pass1_step, 'String', '32'); piv.step_Callback(h.pass1_step, [], []);
set(h.pass2_enable, 'Value', 1); set(h.pass2_size, 'String', '32'); piv.pass2_checkbox_Callback(h.pass2_enable, [], []);
set(h.update_display_checkbox, 'Value', 0);
piv.AnalyzeAll_Callback;
set(h.time_inp, 'String', '2'); % spatial calibration of the stereo calibration + time step: m/s
calibrate.apply_cali_Callback;
calu = abs(gui.retr('calu'));
verifyNotEqual(testCase, calu, 1, 'not calibrated');
rl = gui.retr('resultslist');
W = rl{16, 1};
verifyTrue(testCase, any(isfinite(W(:))), 'no W in row 16');
verifyEqual(testCase, stereo.w_of_frame(1), W);
% ASCII: x y u v w type
set(h.delimiter, 'Value', 1); set(h.add_header, 'Value', 1); set(h.addfileinfo, 'Value', 0); set(h.export_vort, 'Value', 0);
export.file_save(1, 'w.txt', folder, 1);
lines = readlines(fullfile(folder, 'w.txt'));
verifyTrue(testCase, startsWith(lines(1), "x [m],y [m],u [m/s],v [m/s],w [m/s],Vector type"), char(lines(1)));
data = readmatrix(fullfile(folder, 'w.txt'), 'NumHeaderLines', 1);
verifyEqual(testCase, size(data, 2), 6);
verifyEqual(testCase, data(:, 5), W(:) * calu, 'RelTol', 1e-6, 'ASCII: w column'); % single precision like u, v
% Tecplot: VARIABLES "x", "y", "u", "v", "w", "isNaN"
set(h.export_vort_tec, 'Value', 0);
export.file_save(1, 'w.dat', folder, 4);
lines = readlines(fullfile(folder, 'w.dat'));
verifyTrue(testCase, any(startsWith(lines, 'VARIABLES = "x", "y", "u", "v", "w", "isNaN"')), 'Tecplot: variables');
data = readmatrix(fullfile(folder, 'w.dat'), 'NumHeaderLines', 6, 'FileType', 'text', 'Delimiter', ' ');
w_tec = W(:) * calu;
w_tec(isnan(w_tec)) = 0;
verifyEqual(testCase, sort(data(:, 5)), sort(w_tec), 'RelTol', 1e-6, 'Tecplot: w column');
% VTK: the third component of the velocity is w
export.file_save(1, 'w.vtk', folder, 3);
vtk = read_vtk_vectors(fullfile(folder, 'w.vtk'), numel(W));
verifyEqual(testCase, vtk(3, :), single(W(:)' * calu), 'VTK: w component');
% MAT file of all frames, with derivatives
set(h.export_mat_derivatives, 'Value', 1);
export.mat_file_save(1, 'w.mat', folder, 2);
m = load(fullfile(folder, 'w.mat'));
verifyEqual(testCase, m.w_original{1}, W * calu, 'RelTol', 1e-12, 'MAT: w_original');
verifyEqual(testCase, m.w_filtered{3}, rl{16, 3} * calu, 'RelTol', 1e-12, 'MAT: w_filtered');
verifyTrue(testCase, isfield(m, 'w_component') && isfield(m, 'stereo') && isfield(m.stereo, 'reconstruction_residual_px'));
verifyTrue(testCase, contains(strjoin(m.information, ' '), 'Stereo-PIV'));
% export to the workspace
export.write_workspace_Callback;
w_ws = evalin('base', 'w_original');
verifyEqual(testCase, w_ws{2}, rl{16, 2} * calu, 'RelTol', 1e-12, 'workspace: w_original');
% derived parameters: the w component (only in stereo mode) and the 3D magnitude
plot.update_derivchoice_list(h);
items = get(h.derivchoice, 'String');
verifyEqual(testCase, numel(items), 14);
verifyTrue(testCase, startsWith(items{14}, 'w component'));
set(h.interpol_missing, 'Value', 0);
set(h.smooth_mode, 'Value', 1);
plot.derivative_calc(1, 14, 0);
plot.derivative_calc(1, 3, 0);
derived = gui.retr('derived');
verifyEqual(testCase, derived{13, 1}, W * calu, 'RelTol', 1e-12, 'w component');
U = rl{7, 1} * gui.retr('calu');
V = rl{8, 1} * gui.retr('calv');
verifyEqual(testCase, derived{2, 1}, sqrt(U .^ 2 + V .^ 2 + (W * calu) .^ 2), 'RelTol', 1e-12, '3D magnitude');
% temporal mean and TKE of W, mean frames for both cameras
set(h.selectedFramesMean, 'String', '1:3');
set(h.append_replace, 'Value', 1);
plot.temporal_operation_Callback([], [], 1);
plot.temporal_operation_Callback([], [], 3);
rl = gui.retr('resultslist');
verifyEqual(testCase, size(rl, 2), 5, 'mean and TKE frame not appended');
stack = cat(3, rl{16, 1:3});
mean_w = mean(stack, 3, 'omitnan');
tke_w = 0.5 * var(stack, 0, 3, 'omitnan');
ok = isfinite(rl{16, 4});
verifyTrue(testCase, any(ok(:)));
verifyEqual(testCase, rl{16, 4}(ok), mean_w(ok), 'AbsTol', 1e-12, 'mean of W');
verifyEqual(testCase, rl{16, 5}(ok), tke_w(ok), 'AbsTol', 1e-12, 'TKE part of W');
state = gui.retr('stereo_cam_state');
other = 3 - gui.retr('stereo_active_camera');
verifyEqual(testCase, numel(gui.retr('filepath')), 10);
verifyEqual(testCase, numel(state{other}.filepath), 10, 'the other camera did not get the mean frames');
verifyTrue(testCase, startsWith(state{other}.filename{7}, 'MEAN of frames'));
stereo.switch_camera(other); % shows the mean frame on the image of the other camera
set(h.fileselector, 'Value', 4); gui.fileselector_Callback(h.fileselector, [], []);
gui.sliderdisp(gui.retr('pivlab_axis'));
stereo.switch_camera(3 - other);
% the validation rebuilds the result from both cameras: the mean frames go (from both cameras)
validate.apply_filter_all_Callback;
rl = gui.retr('resultslist');
state = gui.retr('stereo_cam_state');
verifyEqual(testCase, size(rl, 2), 3, 'mean frames not removed');
verifyEqual(testCase, numel(gui.retr('filepath')), 6);
verifyEqual(testCase, numel(state{other}.filepath), 6);
verifyEmpty(testCase, gui.retr('ismean'));
% data smoothing smooths W too (row 17), the W display follows it
set(h.smooth_mode, 'Value', 2);
set(h.smooth_param, 'String', '0.5');
plot.derivative_calc(1, 4, 0);
rl = gui.retr('resultslist');
verifyNotEmpty(testCase, rl{17, 1}, 'smoothed W missing');
verifyNotEqual(testCase, rl{17, 1}, rl{16, 1}, 'smoothing changed nothing');
verifyEqual(testCase, stereo.w_of_frame(1, true), rl{17, 1});
% 2D + time: the single-frame path and "apply to all frames" give the same smoothed W (and u)
set(h.smooth_mode, 'Value', 4);
set(h.temporal_window, 'String', '1');
plot.derivative_calc(2, 4, 0);
rl = gui.retr('resultslist');
single_w = rl{17, 2};
single_u = rl{10, 2};
verifyNotEqual(testCase, single_w, rl{16, 2}, 'temporal smoothing changed nothing');
plot.temporal_smooth_all;
rl = gui.retr('resultslist');
verifyEqual(testCase, rl{17, 2}, single_w, 'AbsTol', 1e-12, 'batch and single-frame smoothing of W differ');
verifyEqual(testCase, rl{10, 2}, single_u, 'AbsTol', 1e-12, 'batch and single-frame smoothing of u differ');
gui.put('displaywhat', 1); % vectors (the MAT export with derivatives showed the last derived parameter)
set(h.fileselector, 'Value', 1); gui.fileselector_Callback(h.fileselector, [], []);
gui.sliderdisp(gui.retr('pivlab_axis'));
verifyNotEmpty(testCase, findobj(gui.retr('pivlab_axis'), 'Tag', 'stereo_w_display'));
end

% -------------------------------------------------------------------------
% Helpers
% -------------------------------------------------------------------------

function v = read_vtk_vectors(file, n)
% the 3 x n velocity vectors of a binary VTK file of PIVlab
fid = fopen(file, 'r', 'b');
content = fread(fid, inf, '*char')';
marker = sprintf('VECTORS velocity_vectors float\n');
start = strfind(content, marker);
fseek(fid, start + numel(marker) - 1, 'bof');
v = reshape(fread(fid, 3 * n, 'float=>single'), 3, n);
fclose(fid);
end

function calibrate_in_gui(c, import_images)
% stereo import, lens calibration + board image per camera, stereo calibration (no dialogs)
if nargin < 2
    import_images = true;
end
handles = gui.gethand;
if import_images
    gui.put('sequencer', 1);
    import.stereo_import_Callback([], [], {c.files{1}, c.files{2}});
end
for k = 1:2
    stereo.switch_camera(k);
    gui.put('cameraParams', c.lens{k});
    gui.put('cam_selected_rectification_image', c.boards{k});
end
stereo.switch_camera(1);
set(handles.calib_rows, 'String', int2str(c.board.PatternDims(1)));
set(handles.calib_columns, 'String', int2str(c.board.PatternDims(2)));
set(handles.calib_checkersize, 'String', num2str(c.board.CheckerSize));
set(handles.calib_markersize, 'String', num2str(c.board.MarkerSize));
set(handles.calib_origincolor, 'Value', 1);
stereo.calibrate_Callback;
end

function r = images_agree(selected)
% correlation coefficient of the images of both cameras (as shown) inside the automatic ROI. Slightly
% blurred: particles at different depths in the sheet appear at different places in the two cameras,
% only the centre of the sheet is aligned by the disparity correction.
roirect = gui.retr('roirect');
A = imgaussfilt(double(stereo.camera_image(1, selected, true)), 3);
B = imgaussfilt(double(stereo.camera_image(2, selected, true)), 3);
rows = roirect(2):roirect(2) + roirect(4);
cols = roirect(1):roirect(1) + roirect(3);
r = corr2(A(rows, cols), B(rows, cols));
end

function err = result_error(c)
% mean U, V, W of the GUI result against the ground truth
resultslist = gui.retr('resultslist');
stereo_vel = gui.retr('stereo_vel');
n = size(resultslist, 2);
vel.U = cat(3, resultslist{7, 1:n});
vel.V = cat(3, resultslist{8, 1:n});
vel.W = cat(3, resultslist{16, 1:n});
vel.x_mm = stereo_vel.x_mm;
vel.y_mm = stereo_vel.y_mm;
vel.mm_per_px = stereo_vel.mm_per_px;
err = helper_stereo_truth_error(vel, c);
end

function check_accuracy(testCase, err, rms_limit)
verifyLessThan(testCase, [err.rms_U err.rms_V err.rms_W], rms_limit, 'rms error [mm] of U, V, W');
verifyLessThan(testCase, abs([err.bias_U err.bias_V err.bias_W]), [0.002 0.002 0.002], 'bias [mm] of U, V, W');
verifyLessThan(testCase, abs(err.W_slope - 1), 0.02, 'W scaled wrongly');
end

function import_stereo(testCase)
gui.put('sequencer', 1);
import.stereo_import_Callback([], [], {testCase.TestData.cam1, testCase.TestData.cam2});
drawnow;
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
