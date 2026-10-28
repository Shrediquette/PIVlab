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

% The PIVlab window stays open between the tests: helper_start_pivlab resets it ("Reset PIVlab GUI")
% and checks that it is the same as after a new start; helper_teardown_once closes it.

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
label =findobj(gui.retr('pivlab_axis'), 'Tag', 'stereo_camera_label');
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
% the calibration menu entries keep the active camera (no camera sub menus)
hgui = getappdata(0, 'hgui');
verifyEmpty(testCase, findall(hgui, 'Type', 'uimenu', 'Text', 'Camera 1'), 'camera sub menu still there');
menu = findall(hgui, 'Type', 'uimenu', 'Text', 'Camera calibration (undistortion)');
verifyNumElements(testCase, menu, 1);
feval(menu.MenuSelectedFcn, menu, []);
verifyEqual(testCase, gui.retr('stereo_active_camera'), 2);
verifyEqual(testCase, char(get(handles.multip26, 'Visible')), 'on');
verifyEqual(testCase, get(handles.calib_undist_cam_label, 'String'), 'Current camera: CAMERA 2');
menu = findall(hgui, 'Type', 'uimenu', 'Text', 'Image rectification / alignment');
feval(menu.MenuSelectedFcn, menu, []);
verifyEqual(testCase, gui.retr('stereo_active_camera'), 2);
verifyEqual(testCase, char(get(handles.multip27, 'Visible')), 'on');
verifyEqual(testCase, get(handles.calib_rect_cam_label, 'String'), 'Current camera: CAMERA 2');
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

function test_image_import_dialog(testCase)
% the image import dialog (gui.image_import_dialog), driven by a timer while it waits: filter, Add all twice
% (duplicates stay, order of adding), pairwise suggested for names ending with A / B, preview, Cancel; stereo:
% one list per camera, warning for different numbers of files; the "Import images" and "Import stereo images"
% buttons use it
helper_start_pivlab();
folder = fileparts(testCase.TestData.cam1{1});
gui.set_preference('sequencer', 0); % time resolved: the dialog should suggest pairwise
if isappdata(0, 'dialog_test_error')
    rmappdata(0, 'dialog_test_error');
end
% 2D: cam1 images twice
files = run_dialog('single', folder, @dialog_steps_single);
info = getappdata(0, 'dialog_test');
verifyEqual(testCase, info.shown, 6, 'filter "cam1": 6 images');
verifyEqual(testCase, info.wildcard_star, 3, 'filter "cam1*a": the 3 A images');
verifyEqual(testCase, info.wildcard_question, 3, 'filter "CAM1_000?B.tif": the 3 B images');
verifyEqual(testCase, files, [testCase.TestData.cam1; testCase.TestData.cam1; testCase.TestData.cam1(1:2)], 'added twice + 2 selected, in the order of adding');
verifyEqual(testCase, info.sequencing, 2, 'pairwise not suggested');
verifyTrue(testCase, info.preview, 'no preview image');
verifyEqual(testCase, gui.retr('sequencer'), 1);
% Cancel
files = run_dialog('single', folder, @dialog_steps_cancel);
verifyEmpty(testCase, files, 'cancel');
% stereo: one list per camera
files = run_dialog('stereo', folder, @dialog_steps_stereo);
info = getappdata(0, 'dialog_test');
verifyTrue(testCase, contains(strjoin(info.count, ' '), 'same number'), 'no warning for different numbers of files');
verifyEqual(testCase, files, {testCase.TestData.cam1, testCase.TestData.cam2});
% the buttons of the Input data panel
setappdata(0, 'dialog_test_folder', folder);
start_dialog_timer(@dialog_steps_plain);
import.loadimgsbutton_Callback([], [], 1);
verifyEqual(testCase, gui.retr('filepath'), testCase.TestData.plain, '2D import');
start_dialog_timer(@dialog_steps_stereo);
import.stereo_import_Callback([], [], []);
verifyEqual(testCase, gui.retr('stereomode'), 1, 'stereo import');
state = gui.retr('stereo_cam_state');
verifyEqual(testCase, numel(gui.retr('filepath')) + numel(state{2}.filepath), 12);
rmappdata(0, 'dialog_test');
rmappdata(0, 'dialog_test_folder');
stop_dialog_timers();
verifyFalse(testCase, isappdata(0, 'dialog_test_error'), 'error in a dialog step');
end

function files = run_dialog(mode, folder, steps)
start_dialog_timer(steps);
files = gui.image_import_dialog(mode, folder);
end

function start_dialog_timer(steps)
stop_dialog_timers();
t = timer('StartDelay', 1, 'TimerFcn', {@run_steps, steps}, 'Tag', 'image_import_dialog_test');
start(t);
end

function stop_dialog_timers()
t = timerfind('Tag', 'image_import_dialog_test');
if ~isempty(t)
    stop(t);
    delete(t);
end
end

function run_steps(~, ~, steps)
% the steps in the open dialog; on an error the dialog is closed (the test would wait for ever otherwise)
try
    if isappdata(0, 'dialog_test_folder') % the buttons open the dialog in the last image folder
        set(findall(0, 'Tag', 'import_folder'), 'String', getappdata(0, 'dialog_test_folder'));
        press('import_folder');
    end
    feval(steps);
    if ~isempty(findall(0, 'Tag', 'image_import_dialog')) % still open (e.g. Import refused): close it
        setappdata(0, 'dialog_test_error', 'the dialog was still open after the steps');
        press('import_cancel');
    end
catch err
    setappdata(0, 'dialog_test_error', err.message);
    dialog = findall(0, 'Tag', 'image_import_dialog');
    if ~isempty(dialog)
        press('import_cancel');
    end
end
end

function press(tag)
% runs the callback of a control of the import dialog (lists from MATLAB 2025 on: tables, ClickedFcn)
h = findall(0, 'Tag', tag);
if isprop(h(1), 'ClickedFcn')
    callback = get(h(1), 'ClickedFcn');
else
    callback = get(h(1), 'Callback');
end
if iscell(callback)
    feval(callback{1}, h(1), [], callback{2:end});
else
    feval(callback, h(1), []);
end
end

function n = list_count(tag)
% number of entries of a list of the import dialog (table or list box)
h = findall(0, 'Tag', tag);
if isprop(h(1), 'Data')
    n = numel(h(1).Data);
else
    n = numel(get(h(1), 'String'));
end
end

function select_rows(tag, rows)
h = findall(0, 'Tag', tag);
if isprop(h(1), 'Selection')
    h(1).Selection = [rows(:), ones(numel(rows), 1)]; % cell selection
else
    set(h(1), 'Value', rows);
end
end

function set_filter(text)
set(findall(0, 'Tag', 'import_filter'), 'String', text);
press('import_filter');
end

function dialog_steps_single
set_filter('cam1*a'); % placeholders: whole name, with or without the extension
info.wildcard_star = list_count('import_files');
set_filter('CAM1_000?B.tif');
info.wildcard_question = list_count('import_files');
set_filter('cam1');
info.shown = list_count('import_files');
press('import_addall1');
press('import_addall1');
select_rows('import_files', [1 2]); % like a click and drag over the first two files
press('import_add1');
select_rows('import_list1', 1);
press('import_list1');
fig = findall(0, 'Tag', 'image_import_dialog');
info.preview = ~isempty(findobj(fig, 'Type', 'image'));
info.sequencing = get(findall(0, 'Tag', 'import_sequencing'), 'Value');
setappdata(0, 'dialog_test', info);
press('import_ok');
end

function dialog_steps_cancel
press('import_cancel');
end

function dialog_steps_stereo
set_filter('cam1');
press('import_addall1');
set_filter('cam2');
press('import_addall2');
press('import_addall2'); % 12 files for camera 2: warning
info.count = get(findall(0, 'Tag', 'import_count'), 'String');
press('import_clear2');
press('import_addall2');
setappdata(0, 'dialog_test', info);
press('import_ok');
end

function dialog_steps_plain
set_filter('plain');
press('import_addall1');
press('import_ok');
end

function test_image_import_dialog_double_click(testCase)
% double clicks in the folder list of the import dialog, sent like mouse double clicks: a folder opens, also when
% it has fewer entries than the number of the clicked row (the list was replaced on the second click, before the
% table had processed the double click: "Index exceeds the number of array elements"); a file is added (2D)
assumeFalse(testCase, verLessThan('matlab', '25'), 'the lists are list boxes before MATLAB 2025');
root = [testCase.TestData.Dir '_double_click']; % not in the image folder of test_image_import_dialog
mkdir(root);
addTeardown(testCase, @rmdir, root, 's');
for i = 1:25
    mkdir(fullfile(root, sprintf('sub%02d', i)));
end
copyfile(testCase.TestData.plain{1}, fullfile(root, 'sub25'));
copyfile(testCase.TestData.plain{2}, fullfile(root, 'sub25'));
if isappdata(0, 'dialog_test_error')
    rmappdata(0, 'dialog_test_error');
end
setappdata(0, 'dialog_test_root', root);
setappdata(0, 'dialog_test', struct());
state.step = 1;
state.ticks = 0;
state.all_ticks = 0;
setappdata(0, 'dialog_test_step', state);
% the steps in a timer, every 0.5 s: the callbacks of a double click run after the timer callback
stop_dialog_timers();
t = timer('StartDelay', 1, 'Period', 0.5, 'ExecutionMode', 'fixedSpacing', 'TasksToExecute', 200, ...
    'TimerFcn', @double_click_step, 'Tag', 'image_import_dialog_test');
start(t);
files = [];
output = evalc('files = gui.image_import_dialog(''single'', root);'); % the table prints its errors only
stop_dialog_timers();
rmappdata(0, 'dialog_test_root');
assertFalse(testCase, isappdata(0, 'dialog_test_error'), 'error in a dialog step');
verifyFalse(testCase, contains(output, 'Error'), output);
info = getappdata(0, 'dialog_test');
rmappdata(0, 'dialog_test');
rmappdata(0, 'dialog_test_step');
verifyEqual(testCase, info.folder, fullfile(root, 'sub25'), 'double click on the last of 25 folders');
verifyEqual(testCase, info.entries, 2);
verifyEqual(testCase, info.added, 1, 'double click on a file');
verifyEqual(testCase, info.folder_again, fullfile(root, 'sub03'), 'second double click on a folder');
verifyEqual(testCase, info.entries_again, 0);
verifyEmpty(testCase, files, 'cancel');
end

function double_click_step(~, ~)
% one step of test_image_import_dialog_double_click. A step is repeated at the next timer callback until it
% is ready: a double click 1 s after the last step (the table shows the new rows), the result of a double click
% when it is there (at most 20 s)
state = getappdata(0, 'dialog_test_step');
state.ticks = state.ticks + 1;
state.all_ticks = state.all_ticks + 1;
info = getappdata(0, 'dialog_test');
root = getappdata(0, 'dialog_test_root');
dialog_open = ~isempty(findall(0, 'Tag', 'image_import_dialog'));
folder = '';
if dialog_open
    folder = get(findall(0, 'Tag', 'import_folder'), 'String');
end
waited = state.ticks >= 2;
timed_out = state.ticks > 40;
try
    ready = false;
    switch state.step
        case 1
            h = findall(0, 'Tag', 'import_files');
            scroll(h(1), 'cell', [25 1]); % in view for the double click
            ready = true;
        case 2
            ready = waited;
            if ready
                double_click('import_files', 25); % folder sub25 (2 files)
            end
        case 3
            ready = strcmp(folder, fullfile(root, 'sub25')) || timed_out;
            if ready
                info.folder = folder;
                info.entries = list_count('import_files');
            end
        case 4
            ready = waited;
            if ready
                double_click('import_files', 2); % the second file
            end
        case 5
            ready = list_count('import_list1') > 0 || timed_out;
            if ready
                info.added = list_count('import_list1');
                set(findall(0, 'Tag', 'import_folder'), 'String', root);
                press('import_folder');
            end
        case 6
            ready = waited;
            if ready
                double_click('import_files', 3); % folder sub03 (empty)
            end
        case 7
            ready = strcmp(folder, fullfile(root, 'sub03')) || timed_out;
            if ready
                info.folder_again = folder;
                info.entries_again = list_count('import_files');
                press('import_cancel');
            end
    end
    if ready
        state.step = state.step + 1;
        state.ticks = 0;
    end
    setappdata(0, 'dialog_test_step', state);
    setappdata(0, 'dialog_test', info);
    if dialog_open && state.step <= 7 && state.all_ticks > 180 % the test would wait for ever
        setappdata(0, 'dialog_test_error', sprintf('step %d not finished', state.step));
        press('import_cancel');
    end
catch err
    setappdata(0, 'dialog_test_error', err.message);
    if ~isempty(findall(0, 'Tag', 'image_import_dialog'))
        press('import_cancel');
    end
end
end

function double_click(tag, row)
% a double click on a row of a list of the import dialog, like with the mouse: the gesture of
% matlab.uitest.TestCase/doublePress (undocumented internals of R2026b), sent without waiting for it. doublePress
% waits, and inside a timer callback the table then processes the double click before the ClickedFcn runs,
% the other way round than with the mouse.
h = findall(0, 'Tag', tag);
fig = ancestor(h(1), 'figure');
fig_id = matlab.uiautomation.internal.IDService.getId(fig);
gesture.Channel = matlab.ui.internal.FigureServices.getUniqueChannelId(fig);
gesture.figID = fig_id;
gesture.Name = 'uidoublepress';
gesture.PeerNodeID = matlab.uiautomation.internal.IDService.getId(h(1));
gesture.Options = struct('ctrlKey', false, 'shiftKey', false, 'altKey', false, 'metaKey', false, 'button', uint8(0));
gesture.Data = struct('row', row, 'col', 1);
connector.ensureServiceOn;
message.publish(['/uitest/' fig_id], gesture);
end

function test_calibration_dialog_folders(testCase)
% start folders of the calibration file dialogs (preproc.calibration_dialog_folder): last pick of this
% dialog, then the other camera's pick, then (target image) the lens calibration images, then the PIV images
helper_start_pivlab();
import_stereo(testCase);
base = fullfile(testCase.TestData.folder, 'dialog_folders');
names = {'lens1', 'lens2', 'target1'};
for k = 1:numel(names)
    if ~isfolder(fullfile(base, names{k}))
        mkdir(fullfile(base, names{k}));
    end
end
image_folder = fileparts(testCase.TestData.cam1{1});
% nothing picked yet: the folder of the PIV images
verifyEqual(testCase, preproc.calibration_dialog_folder('lens'), image_folder);
verifyEqual(testCase, preproc.calibration_dialog_folder('target'), image_folder);
% camera 1 picks lens images and the target image
gui.put('cam_selected_target_images', {fullfile(base, 'lens1', 'a.tif'); fullfile(base, 'lens1', 'b.tif')});
verifyEqual(testCase, preproc.calibration_dialog_folder('lens'), fullfile(base, 'lens1'));
verifyEqual(testCase, preproc.calibration_dialog_folder('target'), fullfile(base, 'lens1'), 'target image: lens images of the camera');
gui.put('cam_selected_rectification_image', fullfile(base, 'target1', 'board.tif'));
verifyEqual(testCase, preproc.calibration_dialog_folder('target'), fullfile(base, 'target1'));
% camera 2: starts where camera 1's were
stereo.switch_camera(2);
verifyEqual(testCase, preproc.calibration_dialog_folder('lens'), fullfile(base, 'lens1'), 'camera 2: lens images of camera 1');
verifyEqual(testCase, preproc.calibration_dialog_folder('target'), fullfile(base, 'target1'), 'camera 2: target image of camera 1');
% camera 2 picks its own: its own folder from then on
gui.put('cam_selected_target_images', fullfile(base, 'lens2', 'c.tif')); % one file: char
verifyEqual(testCase, preproc.calibration_dialog_folder('lens'), fullfile(base, 'lens2'));
stereo.switch_camera(1);
verifyEqual(testCase, preproc.calibration_dialog_folder('lens'), fullfile(base, 'lens1'));
% 2D: last pick, then lens images (target), then the PIV images
stereo.leave_stereo_mode;
verifyEqual(testCase, preproc.calibration_dialog_folder('target'), fullfile(base, 'target1'));
gui.put('cam_selected_rectification_image', []);
verifyEqual(testCase, preproc.calibration_dialog_folder('target'), fullfile(base, 'lens1'));
gui.put('cam_selected_target_images', []);
verifyEqual(testCase, preproc.calibration_dialog_folder('lens'), image_folder);
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
verifyEmpty(testCase, findobj(gui.retr('pivlab_axis'), 'Tag', 'stereo_camera_label'));
% rectification panel as in 2D again
verifyEqual(testCase, char(get(handles.calib_userectification, 'Visible')), 'on');
verifyEqual(testCase, char(get(handles.calib_upscale, 'Visible')), 'on');
verifyEqual(testCase, char(get(handles.stereo_rect_note, 'Visible')), 'off');
verifyEqual(testCase, char(get(handles.calib_usecalibration, 'String')), 'Enable camera calibration');
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
% lens calibration switch: display only in stereo mode (stereo-PIV always undistorts)
verifyEqual(testCase, char(get(handles.calib_usecalibration, 'String')), 'Show undistorted image');
% ticking it resets nothing (no "Masks, ROI, ... will be reset") and keeps the common grid
gui.put('cam_selected_target_images', {'lens calibration images'});
gui.put('resultslist', cell(9, 1));
roirect = gui.retr('roirect');
set(handles.calib_usecalibration, 'Value', 1);
preproc.cam_enable_cam_calib_Callback(handles.calib_usecalibration);
verifyEqual(testCase, get(handles.calib_usecalibration, 'Value'), 1, 'switch unticked again in stereo mode');
verifyEqual(testCase, gui.retr('cam_use_calibration'), 1);
verifyNotEmpty(testCase, gui.retr('resultslist'), 'results reset by the display switch');
verifyEqual(testCase, gui.retr('roirect'), roirect, 'ROI reset by the display switch');
verifyEqual(testCase, gui.retr('expected_image_size'), sz);
set(handles.calib_usecalibration, 'Value', 0);
preproc.cam_enable_cam_calib_Callback(handles.calib_usecalibration);
verifyEqual(testCase, gui.retr('cam_use_calibration'), 0);
verifyNotEmpty(testCase, gui.retr('resultslist'));
gui.put('resultslist', []);
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
% measured remaining disparity (what the correction leaves): small on synthetic data, in the report
remaining = gui.retr('stereo_disparity').remaining;
verifyLessThan(testCase, remaining.rms, 0.3, 'measured remaining disparity [px]');
verifyNotEmpty(testCase, strfind(strjoin(get(handles.stereo_disp_report, 'String'), ' '), 'Remaining (measured)'));
roirect = gui.retr('roirect');
verifyEqual(testCase, roirect, gui.retr('stereo_calib').auto_roi, 'automatic ROI not adapted');
for mode = 2:7 % 7: reconstruction residual, before ANALYZE only a note
    set(handles.stereo_disp_show, 'Value', mode);
    gui.sliderdisp(gui.retr('pivlab_axis'));
    verifyNotEmpty(testCase, findobj(gui.retr('pivlab_axis'), 'Tag', 'stereo_disparity_display'), sprintf('display %d', mode));
end
label = findobj(gui.retr('pivlab_axis'), 'Tag', 'stereo_disparity_display', 'Type', 'text');
verifyTrue(testCase, contains(label.String, 'run ANALYZE first'), label.String);
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

function test_disparity_pairs_automatic(testCase)
% "Pairs" 0 (default) = automatic: batches of five pairs until the map is accurate to 0.5 px (clean synthetic
% data: after the first estimate, i.e. ten pairs); a fixed number uses linspace as before
c = helper_stereo_synthetic_case(fullfile(testCase.TestData.folder, 'auto_pairs_case'), 12, 0);
helper_start_pivlab();
handles = gui.gethand;
calibrate_in_gui(c);
verifyEqual(testCase, get(handles.stereo_disp_pairs, 'String'), '0', 'default is not automatic');
stereo.measure_disparity_Callback;
d = gui.retr('stereo_disparity');
verifyTrue(testCase, d.auto);
verifyEqual(testCase, numel(d.pairs), 10, 'clean data: ten pairs');
verifyLessThan(testCase, d.accuracy_estimate, 0.5);
verifyEqual(testCase, d.pairs, sort(d.pairs), 'pairs not in the order of their numbers');
verifyTrue(testCase, startsWith(d.report{1}, '10 pairs (automatic), map accurate to ~'), d.report{1});
verifyEqual(testCase, size(d.raw.u_frames, 3), 10);
% fixed number: the same choice as before (spread with linspace)
set(handles.stereo_disp_pairs, 'String', '3');
stereo.measure_disparity_Callback;
d = gui.retr('stereo_disparity');
verifyFalse(testCase, d.auto);
verifyEqual(testCase, d.pairs, unique(round(linspace(1, 12, 3))));
verifyTrue(testCase, startsWith(d.report{1}, '3 pairs'), d.report{1});
set(handles.stereo_disp_pairs, 'String', '0');
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
% display as in 2D: vectors on the image, no W colour map under them (W: derived parameter "w component")
gui.sliderdisp(gui.retr('pivlab_axis'));
verifyNumElements(testCase, findobj(gui.retr('pivlab_axis'), 'Type', 'image'), 1, 'more than the particle image under the vectors');
% Stereo-PIV panel, Show "Reconstruction residual": map of |residual| of the image pair shown, rms and max
gui.switchui('multip30');
set(handles.fileselector, 'Value', 2); gui.fileselector_Callback(handles.fileselector, [], []);
set(handles.stereo_disp_show, 'Value', 7);
gui.sliderdisp(gui.retr('pivlab_axis'));
residual = abs(double(gui.retr('stereo_vel').residual(:, :, 2)));
label = findobj(gui.retr('pivlab_axis'), 'Tag', 'stereo_disparity_display', 'Type', 'text');
verifyEqual(testCase, label.String, sprintf(' Reconstruction residual: rms %.2f px, max %.2f px ', ...
    sqrt(mean(residual(:) .^ 2, 'omitnan')), max(residual(:), [], 'omitnan')));
verifyNotEmpty(testCase, findobj(gui.retr('pivlab_axis'), 'Tag', 'stereo_disparity_display', 'Type', 'image'), 'residual map');
set(handles.stereo_disp_show, 'Value', 1);
set(handles.fileselector, 'Value', 1); gui.fileselector_Callback(handles.fileselector, [], []);
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
verifyNumElements(testCase, findobj(gui.retr('pivlab_axis'), 'Type', 'image'), 1);
% click on a vector: the label next to it shows the 3D magnitude
check_click_label(testCase, after, 3, 4);
end

function check_click_label(testCase, resultslist, row, col)
% Clicks on vector (row, col) of the image pair shown (gui.veclick) and compares the label next to the
% vector with sqrt(u^2 + v^2 + w^2) in px/frame (no smoothing, no spatial calibration).
target_axis = gui.retr('pivlab_axis');
handles = gui.gethand;
frame = floor(get(handles.fileselector, 'Value'));
x = resultslist{1, frame};
y = resultslist{2, frame};
click_vector(x(row, col), y(row, col));
label = findobj(target_axis, 'Tag', 'infopoint', 'Type', 'text');
verifyNumElements(testCase, label, 1, 'no label next to the clicked vector');
marker = findobj(target_axis, 'Tag', 'infopoint', 'Type', 'line');
verifyEqual(testCase, [marker.XData marker.YData], [x(row, col) y(row, col)], 'a different vector was clicked');
if ~isempty(resultslist{7, frame}) % validated
    u = resultslist{7, frame}(row, col);
    v = resultslist{8, frame}(row, col);
else
    u = resultslist{3, frame}(row, col);
    v = resultslist{4, frame}(row, col);
end
w = resultslist{16, frame}(row, col);
expected = [' 3D: ' sprintf('%0.2g', sqrt(u^2 + v^2 + w^2)) ' px/fr'];
verifyEqual(testCase, label.String, expected, 'label of the clicked vector');
end

function test_opposite_sides_in_gui(testCase)
% camera 2 on the other side of the light sheet (sees the board mirrored): calibration, report, 3D view,
% ANALYZE, accuracy, MAT export says "camera 1"
c = helper_stereo_synthetic_case(fullfile(testCase.TestData.folder, 'opposite_case'), 4, 0, 'opposite');
helper_start_pivlab();
handles = gui.gethand;
calibrate_in_gui(c);
calib = gui.retr('stereo_calib');
verifyNotEmpty(testCase, calib, 'no stereo calibration');
verifyEqual(testCase, calib.board_from_behind, [false true]);
verifyTrue(testCase, calib.opposite_sides);
report = strjoin(calib.report, ' ');
verifyNotEmpty(testCase, strfind(report, 'Cameras on opposite sides of the light sheet'));
verifyNotEmpty(testCase, strfind(report, 'Camera 2 sees the board from behind'));
verifyNotEmpty(testCase, strfind(report, 'W is positive away from camera 1'));
stereo.show_3d_Callback;
fig = findall(0, 'Type', 'figure', 'Name', 'Stereo-PIV setup in 3D');
verifyNumElements(testCase, fig, 1);
close(fig);
set(handles.pass1_size, 'String', '64'); piv.intarea_Callback(handles.pass1_size, [], []);
set(handles.pass1_step, 'String', '32'); piv.step_Callback(handles.pass1_step, [], []);
set(handles.pass2_enable, 'Value', 1); set(handles.pass2_size, 'String', '32'); piv.pass2_checkbox_Callback(handles.pass2_enable, [], []);
set(handles.pass3_enable, 'Value', 1); set(handles.pass3_size, 'String', '16'); piv.pass3_checkbox_Callback(handles.pass3_enable, [], []);
set(handles.update_display_checkbox, 'Value', 0);
piv.AnalyzeAll_Callback;
check_accuracy(testCase, result_error(c), [0.008 0.008 0.01]);
folder = testCase.TestData.folder;
export.mat_file_save(1, 'w_opposite.mat', folder, 2);
M = load(fullfile(folder, 'w_opposite.mat'));
verifyEqual(testCase, M.stereo.w_sign, 'w is positive away from camera 1');
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
verifyNumElements(testCase, findobj(gui.retr('pivlab_axis'), 'Type', 'image'), 1, 'W colour map under the vectors');
end

function test_w_in_statistics_and_extraction(testCase)
% W in the Statistics panel (values, histogram, 3D scatter plot), in the info when clicking a vector and
% in the poly-line / area extraction; back to 2D: the lists and the panel as before
folder = testCase.TestData.folder;
c = helper_stereo_synthetic_case(fullfile(folder, 'statistics_case'), 3, 0);
helper_start_pivlab();
h = gui.gethand;
calibrate_in_gui(c);
set(h.pass1_size, 'String', '64'); piv.intarea_Callback(h.pass1_size, [], []);
set(h.pass1_step, 'String', '32'); piv.step_Callback(h.pass1_step, [], []);
set(h.pass2_enable, 'Value', 1); set(h.pass2_size, 'String', '32'); piv.pass2_checkbox_Callback(h.pass2_enable, [], []);
set(h.update_display_checkbox, 'Value', 0);
piv.AnalyzeAll_Callback;
validate.apply_filter_all_Callback;
set(h.fileselector, 'Value', 1); gui.fileselector_Callback(h.fileselector, [], []); % image pair 1
rl = gui.retr('resultslist');
calu = gui.retr('calu');
calv = gui.retr('calv');
verifyTrue(testCase, (calu == 1 || calu == -1) && gui.retr('calxy') == 1, 'expected px/frame');
U = rl{7, 1} * calu;
V = rl{8, 1} * calv;
W = rl{16, 1} * abs(calu);
verifyTrue(testCase, any(isfinite(W(:))), 'no W');

% statistics values: mean, min, max, std of u, v, w
plot.statistics_Callback;
expect_stats(testCase, h, 'u', U);
expect_stats(testCase, h, 'v', V);
expect_stats(testCase, h, 'w', W);
% smoothed data: the w values follow the smoothed W (row 17)
set(h.smooth_mode, 'Value', 2);
set(h.smooth_param, 'String', '0.5');
plot.derivative_calc(1, 4, 0);
plot.statistics_Callback;
rl_smoothed = gui.retr('resultslist');
expect_stats(testCase, h, 'w', rl_smoothed{17, 1} * abs(calu));
set(h.smooth_mode, 'Value', 1);
plot.derivative_calc(1, 4, 0);
rl = gui.retr('resultslist');
verifyTrue(testCase, size(rl, 1) < 17 || isempty(rl{17, 1}), 'smoothed W not removed');
plot.statistics_Callback;
expect_stats(testCase, h, 'w', W);

% histogram list: w velocity as item 5; w, 3D magnitude
verifyEqual(testCase, get(h.hist_select, 'String'), {'u velocity'; 'v velocity'; 'velocity magnitude'; 'sub-pixels'; 'w velocity'});
nrofbins = str2double(get(h.nrofbins, 'String'));
set(h.hist_select, 'Value', 5);
counts = histogram_counts();
verifyEqual(testCase, counts, hist(W(:), nrofbins), 'histogram of w'); %#ok<HIST>
set(h.hist_select, 'Value', 3);
[counts, label] = histogram_counts();
verifyEqual(testCase, counts, hist(sqrt(U(:) .^ 2 + V(:) .^ 2 + W(:) .^ 2), nrofbins), 'histogram of the 3D magnitude'); %#ok<HIST>
verifyTrue(testCase, contains(label, '(3D)'), label);
% sub-pixels: the 2D result of the camera shown
set(h.hist_select, 'Value', 4);
for camera = [1 2]
    stereo.switch_camera(camera);
    R = gui.retr('stereo_result');
    cu = R{7, 1}; cv = R{8, 1};
    cu(R{9, 1} == 0) = NaN; cv(R{9, 1} == 0) = NaN;
    [counts, label, name] = histogram_counts();
    verifyEqual(testCase, counts, hist(mod(abs([cu(:); cv(:)]), 1), nrofbins), sprintf('sub-pixels of camera %d', camera)); %#ok<HIST>
    verifyEqual(testCase, label, 'sub-pixel [px]');
    verifyTrue(testCase, contains(name, sprintf('camera %d', camera)), name);
end
% a mean frame has no 2D result of the cameras: message, no histogram
set(h.selectedFramesMean, 'String', '1:3');
set(h.append_replace, 'Value', 1);
plot.temporal_operation_Callback([], [], 1);
set(h.fileselector, 'Value', 4); gui.fileselector_Callback(h.fileselector, [], []);
close(findall(0, 'Type', 'figure', 'Tag', 'derivplotwindow'));
plot.histdraw_Callback;
verifyEmpty(testCase, findall(0, 'Type', 'figure', 'Tag', 'derivplotwindow'), 'sub-pixel histogram of a mean frame');
remove_mean_frame();
set(h.fileselector, 'Value', 1); gui.fileselector_Callback(h.fileselector, [], []);

% 3D scatter plot of u, v, w
verifyEqual(testCase, get(h.scatterplotter, 'String'), 'Scatter plot u, v, w');
plot.scatterplotter_Callback;
fig = findall(0, 'Type', 'figure', 'Tag', 'derivplotwindow');
verifyNumElements(testCase, fig, 1);
points = findobj(fig, 'Type', 'scatter');
verifyEqual(testCase, [points.XData(:) points.YData(:) points.ZData(:)], [U(:) V(:) W(:)], 'AbsTol', 1e-12, '3D scatter plot');
close(fig);

% click on a vector (vectors shown): w in the info line
gui.put('displaywhat', 1);
gui.sliderdisp(gui.retr('pivlab_axis'));
x = double(rl{1, 1}); % the coordinates of a drawn line / area are double
y = double(rl{2, 1});
click_vector(x(3, 4), y(3, 4));
verifyEqual(testCase, get(h.scalar_cp, 'String'), ['w:' num2str(round(W(3, 4) * 100000) / 100000) ' px/fr']);

% poly-line: w component as item 14
extract.poly_extract_Callback([], [], []);
items = get(h.extraction_choice, 'String');
verifyEqual(testCase, numel(items), 14);
verifyEqual(testCase, items{14}, 'w component in px/frame');
xs = [x(2, 2); x(2, end - 1); x(end - 1, end - 1)];
ys = [y(2, 2); y(2, end - 1); y(end - 1, end - 1)];
gui.put('xposition', xs); gui.put('yposition', ys); gui.put('extract_type', 'extract_poly');
set(h.extraction_choice, 'Value', 14);
extract.plot_data_Callback(h.plot_data, [], []);
fig = findall(0, 'Type', 'figure', 'Tag', 'derivplotwindow');
ax = findobj(fig, 'Type', 'axes');
label = ax.XLabel.String;
verifyTrue(testCase, contains(label(end, :), 'Integral of w component = '), 'name of the quantity in the integral');
close(fig);
line_length = sqrt(diff(xs) .^ 2 + diff(ys) .^ 2);
nrpoints = round(sum(line_length) / ceil(x(1, 2) - x(1, 1)) * 3);
[~, ~, expected] = improfile(plot.rescale_maps_nan(W, 0, 1), xs, ys, nrpoints, 'bicubic');
verifyEqual(testCase, gui.retr('c'), expected, 'AbsTol', 1e-12, 'w along the poly-line');
% circle series: tangent velocity (item 12) is chosen and stays chosen
set(h.draw_what, 'Value', 3); extract.draw_what_Callback(h.draw_what);
verifyEqual(testCase, get(h.extraction_choice, 'Value'), 12);
extract.extraction_choice_Callback(h.extraction_choice);
verifyEqual(testCase, get(h.draw_what, 'Value'), 3, 'tangent velocity switched the circle series off');
set(h.draw_what, 'Value', 1); extract.draw_what_Callback(h.draw_what);

% area: w component as item 12
extract.area_panel_activation_Callback([], [], []);
items = get(h.extraction_choice_area, 'String');
verifyEqual(testCase, numel(items), 12);
verifyEqual(testCase, items{12}, 'w component in px/frame');
xs = [x(2, 2); x(2, end - 2); x(end - 2, end - 2); x(end - 2, 2)];
ys = [y(2, 2); y(2, end - 2); y(end - 2, end - 2); y(end - 2, 2)];
gui.put('xposition', xs); gui.put('yposition', ys); gui.put('extract_type', 'extract_poly_area');
set(h.extraction_choice_area, 'Value', 12);
[data, header] = extract.plot_data_area(1, 0);
map = plot.rescale_maps_nan(W, 0, 1);
BW = extract.convert_roi_to_binary(xs, ys, 'extract_poly_area', size(map));
verifyEqual(testCase, data{2}, extract.get_mean_of_selection(BW, map, 0), 'AbsTol', 1e-12, 'mean of w in the area');
verifyEqual(testCase, header{2}, 'Mean (px/frame)');
inside = W(inpolygon(x, y, xs, ys) & isfinite(W)); % the vectors in the area
verifyLessThan(testCase, abs(data{2} - mean(inside)), 0.2 * max(abs(W(:))), 'mean of w far from the vectors in the area');

% back to 2D (area panel shown): lists, histogram, scatter button and the w lines as in 2D
stereo.leave_stereo_mode;
verifyEqual(testCase, numel(get(h.extraction_choice_area, 'String')), 11);
verifyEqual(testCase, get(h.extraction_choice_area, 'Value'), 1);
verifyEqual(testCase, numel(get(h.extraction_choice, 'String')), 13);
verifyEqual(testCase, get(h.hist_select, 'String'), {'u velocity'; 'v velocity'; 'velocity magnitude'; 'sub-pixels'});
verifyEqual(testCase, get(h.scatterplotter, 'String'), 'Scatter plot u & v');
plot.statistics_Callback;
expect_stats(testCase, h, 'u', U);
verifyEqual(testCase, get(h.meanw, 'String'), 'N/A');
verifyEqual(testCase, get(h.stdw, 'String'), 'N/A');
end

function test_velocity_limits_on_3d_result(testCase)
% velocity limits (rectangle, freehand) and magnitude limits are drawn on and tested on the 3D result of the
% raw camera data; the vectors outside are discarded in both cameras, the camera displacements are not tested
[raw, velrect, outside, inside_but_camera_outside] = limits_case(testCase, 'limits_case', 1);
h = gui.gethand;
calu = gui.retr('calu');
U = raw{3, 1} * calu;
W = raw{16, 1} * abs(calu);
umin = velrect(1);
umax = velrect(1) + velrect(3);
gui.put('velrect', velrect);
validate.apply_filter_all_Callback;
verify_discarded(testCase, 1, outside, inside_but_camera_outside, 'rectangle');
verifyEmpty(testCase, gui.retr('stereo_limit_discard'), 'discard maps left over');
% the limits window shows U, V of the raw 3D result, also after the validation (all frames: default)
verifyEqual(testCase, get(h.scatter_all_frames, 'Value'), 1);
caller.Tag = 'vel_limit';
validate.vel_limit_Callback(caller);
limit_figure = findobj('Tag', 'limit_figure');
points = findobj(limit_figure, 'Type', 'scatter');
U_all = cat(3, raw{3, :}) * calu;
V_all = cat(3, raw{4, :}) * gui.retr('calv');
ok = isfinite(U_all) & isfinite(V_all);
verifyEqual(testCase, sortrows([points.XData(:) points.YData(:)]), sortrows(double([U_all(ok) V_all(ok)])), 'AbsTol', 1e-9, 'limits window: raw 3D result');
verifyTrue(testCase, contains(get(get(findobj(limit_figure, 'Type', 'axes'), 'XLabel'), 'String'), '3D result'));
delete(limit_figure);
% freehand shape with the same bounds
validate.restore_all_Callback;
gui.put('velrect', []);
gui.put('velrect_freehand', [umin -1000; umax -1000; umax 1000; umin 1000]);
validate.apply_filter_all_Callback;
verify_discarded(testCase, 1, outside, inside_but_camera_outside, 'freehand');
% magnitude limits: the band is tested on the 3D magnitude
validate.restore_all_Callback;
gui.put('velrect_freehand', []);
M = sqrt(U .^ 2 + (raw{4, 1} * gui.retr('calv')) .^ 2 + W .^ 2);
low = prctile(M(:), 40);
high = prctile(M(:), 60);
set(h.notch_enable, 'Value', 1);
set(h.notch_L_thresh, 'String', num2str(low, 10));
set(h.notch_H_thresh, 'String', num2str(high, 10));
in_band = isfinite(M) & M > low & M < high;
validate.apply_filter_all_Callback;
verify_discarded(testCase, 1, in_band, isfinite(M) & ~in_band, 'magnitude limits');
set(h.notch_enable, 'Value', 0);
% current frame only
validate.restore_all_Callback;
gui.put('velrect', velrect);
set(h.fileselector, 'Value', 2); gui.fileselector_Callback(h.fileselector, [], []);
validate.apply_filter_current_Callback;
U2 = raw{3, 2} * calu;
verify_discarded(testCase, 2, isfinite(U2) & (U2 < umin | U2 > umax), false(size(U2)), 'current frame');
R = gui.retr('stereo_result');
verifyTrue(testCase, size(R, 1) < 7 || isempty(R{7, 1}), 'frame 1 validated by "apply to current frame"');
% undo
validate.restore_all_Callback;
R = gui.retr('stereo_result');
verifyTrue(testCase, size(R, 1) < 7 || isempty(R{7, 2}), 'validation not undone');
gui.put('velrect', []);
end

function test_manual_deletion(testCase)
% vectors deleted by hand (positions on the common grid, validate.rejectsingle_Callback) are removed in both
% cameras by the validation; U, V, W are rebuilt with the gaps filled
[~, ~, ~, ~] = limits_case(testCase, 'manual_case', 1);
positions = [3 4; 5 6; 7 8];
manualdeletion = cell(1, 3);
manualdeletion{1} = positions;
gui.put('manualdeletion', manualdeletion);
validate.apply_filter_all_Callback;
rl = gui.retr('resultslist');
deleted = false(size(rl{1, 1}));
deleted(sub2ind(size(deleted), positions(:, 1), positions(:, 2))) = true;
verify_discarded(testCase, 1, deleted, false(size(deleted)), 'manual deletion');
verifyTrue(testCase, all(isfinite(rl{7, 1}(deleted))) && all(isfinite(rl{16, 1}(deleted))), 'gaps not filled in U, W');
% the other frames keep these vectors
verify_discarded(testCase, 2, false(size(deleted)), deleted, 'manual deletion, frame 2');
gui.put('manualdeletion', []);
end

function test_current_frame_on_a_new_grid(testCase)
% all frames analysed, then the ROI changed and only the current frame analysed: no common grid, so
% no 3D result (before: error, and the result list kept the 2D result of camera 2) (2026-10-22)
limits_case(testCase, 'grid_case', 1);
h = gui.gethand;
gui.put('roirect', [100 100 500 400]);
evalc('piv.AnalyzeSingle_Callback');
verifyEmpty(testCase, gui.retr('resultslist'), 'a result list from different grids');
evalc('piv.AnalyzeAll_Callback');
rl = gui.retr('resultslist');
verifyNotEmpty(testCase, rl{16, 1}, 'W missing after analysing all frames again');
verifyEqual(testCase, size(rl{16, 1}), size(rl{1, 1}));
verifyEqual(testCase, get(h.AnalyzeAll, 'Enable'), 'on');
end

function test_velocity_limits_parallel(testCase)
% the parallel path of "Apply to all frames" discards the same vectors as the serial one
testCase.assumeTrue(license('test', 'Distrib_Computing_Toolbox') == 1 && ~isempty(ver('parallel')), ...
    'no Parallel Computing Toolbox');
[~, velrect, outside, inside_but_camera_outside] = limits_case(testCase, 'limits_parallel_case', 2);
testCase.assumeEqual(gui.retr('parallel'), 1, 'PIVlab did not start a parallel pool');
gui.put('velrect', velrect);
validate.apply_filter_all_Callback;
verify_discarded(testCase, 1, outside, inside_but_camera_outside, 'rectangle, parallel');
verifyEmpty(testCase, gui.retr('stereo_limit_discard'), 'discard maps left over');
gui.put('velrect', []);
end

function [raw, velrect, outside, inside_but_camera_outside] = limits_case(testCase, name, cores)
% synthetic stereo case, analysed; all filters off except the limits. A rectangle around the middle 80 % of
% the raw U of image pair 1 (v unlimited): the vectors outside it, and the vectors with U inside but the
% displacement of a camera outside it (they were wrongly discarded when the limits acted on the cameras).
c = helper_stereo_synthetic_case(fullfile(testCase.TestData.folder, name), 3, 0);
if cores > 1
    try
        helper_start_pivlab(cores);
    catch err
        if contains(err.message, 'parallel pool', 'IgnoreCase', true)
            testCase.assumeFail(['parallel pool could not be started: ' err.message]);
        end
        rethrow(err);
    end
else
    helper_start_pivlab();
end
h = gui.gethand;
calibrate_in_gui(c);
set(h.pass1_size, 'String', '64'); piv.intarea_Callback(h.pass1_size, [], []);
set(h.pass1_step, 'String', '32'); piv.step_Callback(h.pass1_step, [], []);
set(h.pass2_enable, 'Value', 1); set(h.pass2_size, 'String', '32'); piv.pass2_checkbox_Callback(h.pass2_enable, [], []);
set(h.update_display_checkbox, 'Value', 0);
piv.AnalyzeAll_Callback;
set([h.stdev_enable h.loc_median_enable h.notch_enable h.corr_filter_enable h.contrast_filter_enable h.bright_filter_enable], 'Value', 0);
set(h.interpol_missing, 'Value', 1);
calu = gui.retr('calu');
raw = stereo.reconstruct_results(true);
U = raw{3, 1} * calu;
cam = camera_displacements_raw(1);
umin = prctile(U(:), 10);
umax = prctile(U(:), 90);
velrect = [umin -1000 umax - umin 2000];
outside = isfinite(U) & (U < umin | U > umax);
inside_but_camera_outside = isfinite(U) & ~outside & ((cam{1} < umin | cam{1} > umax) | (cam{2} < umin | cam{2} > umax));
verifyTrue(testCase, any(inside_but_camera_outside(:)), 'test case: no vector whose camera displacement is outside but U inside');
end

function verify_discarded(testCase, frame, discarded, kept, name)
% in both cameras: the vectors of the map "discarded" are replaced (type 2), the vectors of "kept" are valid
state = gui.retr('stereo_cam_state');
active = gui.retr('stereo_active_camera');
for k = 1:2
    if k == active
        R = gui.retr('stereo_result');
    else
        R = state{k}.stereo_result;
    end
    typevector = R{9, frame};
    verifyTrue(testCase, all(typevector(discarded) == 2), sprintf('%s: a vector outside the limits is not discarded in camera %d', name, k));
    verifyTrue(testCase, all(typevector(kept) == 1), sprintf('%s: a vector inside the limits is discarded in camera %d', name, k));
end
rl = gui.retr('resultslist');
verifyTrue(testCase, all(rl{9, frame}(discarded) == 2), [name ': 3D result']);
end

function cam = camera_displacements_raw(frame)
% raw 2D displacement u of both cameras (px/frame, times calu like the limits)
state = gui.retr('stereo_cam_state');
active = gui.retr('stereo_active_camera');
cam = cell(1, 2);
for k = 1:2
    if k == active
        R = gui.retr('stereo_result');
    else
        R = state{k}.stereo_result;
    end
    cam{k} = R{3, frame} * gui.retr('calu');
end
end

function expect_stats(testCase, h, component, values)
% the four Statistics panel values of one component (px/frame)
values = values(:);
verifyEqual(testCase, get(h.(['mean' component]), 'String'), [num2str(mean(values, 'omitnan')) ' px/frame'], ['mean ' component]);
verifyEqual(testCase, get(h.(['min' component]), 'String'), [num2str(min(values, [], 'omitnan')) ' px/frame'], ['min ' component]);
verifyEqual(testCase, get(h.(['max' component]), 'String'), [num2str(max(values, [], 'omitnan')) ' px/frame'], ['max ' component]);
verifyEqual(testCase, get(h.(['std' component]), 'String'), [num2str(std(values, 'omitnan')) ' px/frame'], ['std ' component]);
end

function [counts, label, name] = histogram_counts()
% draws the histogram of the Statistics panel, returns the bar heights, x label and window name, closes it
close(findall(0, 'Type', 'figure', 'Tag', 'derivplotwindow'));
plot.histdraw_Callback;
fig = findall(0, 'Type', 'figure', 'Tag', 'derivplotwindow');
bars = findobj(fig, 'Type', 'bar');
counts = bars.YData;
ax = findobj(fig, 'Type', 'axes');
label = ax.XLabel.String;
name = fig.Name;
close(fig);
end

function remove_mean_frame()
% removes the mean frame shown again (Plot -> temporal operations, "remove")
plot.remove_temporal_frame_Callback;
end

% -------------------------------------------------------------------------
% Helpers
% -------------------------------------------------------------------------

function click_vector(x, y)
% clicks on the vector at (x, y) of the PIVlab axes (gui.veclick). The axes CurrentPoint is read-only, it
% follows the figure CurrentPoint: the figure point is found from two probe points (linear in x and y).
target_axis = gui.retr('pivlab_axis');
fig = ancestor(target_axis, 'figure');
probe = [100 100; 300 300];
axes_point = zeros(2, 2);
for k = 1:2
    set(fig, 'CurrentPoint', probe(k, :));
    p = get(target_axis, 'CurrentPoint');
    axes_point(k, :) = p(1, 1:2);
end
scale = (probe(2, :) - probe(1, :)) ./ (axes_point(2, :) - axes_point(1, :));
set(fig, 'CurrentPoint', probe(1, :) + ([x y] - axes_point(1, :)) .* scale);
click.Button = 1;
gui.veclick([], click);
end

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
helper_stereo_gui_calibrate(c, import_images);
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
