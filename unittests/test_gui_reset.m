function tests = test_gui_reset
%TEST_GUI_RESET "Reset PIVlab GUI" (Input data panel): the button, and that a reset PIVlab is the same as
%   a newly started one, also after a session with everything (2D and stereo-PIV).
%   The other GUI tests use the reset between their tests (helper_start_pivlab).
%   Run with: results = runtests('unittests/test_gui_reset.m')
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
helper_setup_once(testCase);
end

function teardownOnce(testCase)
helper_teardown_once(testCase);
end

function test_reset_button_below_acquire(testCase)
hgui = helper_start_pivlab();
h = gui.gethand;
b = findall(hgui, 'Tag', 'reset_gui');
verifyNumElements(testCase, b, 1, 'reset button missing');
verifyEqual(testCase, b.String, 'Reset PIVlab GUI');
verifyEqual(testCase, b.Parent, h.multip01, 'the button belongs to the Input data panel');
acquire = findall(h.multip01, 'Type', 'uicontrol', 'String', 'Acquire images'); % has no Tag
verifyNumElements(testCase, acquire, 1);
pa = getpixelposition(acquire);
pb = getpixelposition(b);
verifyEqual(testCase, pb([1 3 4]), pa([1 3 4]), 'AbsTol', 1, 'same x position and size as "Acquire images"');
verifyLessThan(testCase, pb(2), pa(2), 'below "Acquire images"');
verifyLessThan(testCase, pa(2) - (pb(2) + pb(4)), pa(4) / 2, 'directly below "Acquire images"');
% the rest of the panel still fits
children = findall(h.multip01, 'Type', 'uicontrol');
for k = 1:numel(children)
    p = getpixelposition(children(k));
    verifyGreaterThanOrEqual(testCase, p(2), 0, sprintf('"%s" leaves the panel at the bottom', text_of(children(k))));
end
% also in Basic mode
gui.apply_ui_mode('basic');
verifyEqual(testCase, char(b.Visible), 'on', 'reset button hidden in Basic mode');
gui.apply_ui_mode('advanced');
end

function test_reset_asks_first(testCase)
helper_start_pivlab();
helper_gui_load_images(helper_files('jet', 2));
verifyNotEmpty(testCase, gui.retr('filepath'));
gui.put('batchModeActive', 0); % interactive: the question is answered with its default answer "Cancel"
gui.reset_gui_Callback();
gui.put('batchModeActive', 1);
verifyNotEmpty(testCase, gui.retr('filepath'), 'reset without asking');
end

function test_reset_equals_new_start(testCase)
% new start, PIV result with the default settings; then everything is used (2D and stereo), reset after each:
% the window must be the same as after the new start, and the PIV result with the defaults the same again
helper_close_pivlab();
hgui = helper_start_pivlab();
fresh = helper_gui_snapshot(hgui);
jet = helper_files('jet', 2);
helper_gui_load_images(jet);
helper_gui_analyze();
reference = gui.retr('resultslist');

%% 2D: images with camera model, ROI, masks, background, 3 passes, calibration, validation, derived, mean, view
files = helper_files('distortion', 3);
helper_gui_load_images(files);
h = gui.gethand;
sz = gui.retr('expected_image_size');
gui.put('cameraParams', helper_camera_model(sz));
gui.put('cam_use_calibration', 1);
gui.put('roirect', [40 40 sz(2)-100 sz(1)-90]);
gui.put('masks_in_frame', {{'ROI_object_rectangle', [200 150 80 60]}, {}, {'ROI_object_polygon', [300 300; 380 310; 370 380; 290 370]}});
gui.quick3_Callback([], []);
set(h.bg_subtract, 'Value', 2); preproc.generate_BG_img(); drawnow;
set(h.highpass_enable, 'Value', 1);
gui.quick4_Callback([], []);
set(h.pass3_enable, 'Value', 1); set(h.pass3_size, 'String', '24'); piv.pass3_checkbox_Callback(h.pass3_enable, [], []);
helper_gui_analyze();
gui.put('pointscali', [10 10; 110 10]);
set(h.realdist, 'String', '10'); set(h.time_inp, 'String', '100');
set(h.x_axis_direction, 'Value', 2); set(h.y_axis_direction, 'Value', 2);
calibrate.apply_cali_Callback([], [], []);
gui.put('velrect', [-0.002 -0.002 0.004 0.004]);
set(h.stdev_thresh, 'String', '6');
validate.apply_filter_all_Callback([], [], []);
set(h.smooth_mode, 'Value', 2); plot.smooth_mode_Callback(h.smooth_mode);
plot.derivs_Callback([], [], []);
set(h.derivchoice, 'Value', 2); plot.derivchoice_Callback(h.derivchoice);
plot.apply_deriv_all_Callback([], [], []);
set(h.selectedFramesMean, 'String', '1:3'); set(h.append_replace, 'Value', 1);
plot.temporal_operation_Callback([], [], 1); drawnow;
gui.put('streamlinesX', [100 200 300]); gui.put('streamlinesY', [150 150 150]);
set(h.fileselector, 'Value', 2); gui.fileselector_Callback(h.fileselector, [], []);
gui.put('toggler', 1);
gui.put('xzoomlimit', [100 400]); gui.put('yzoomlimit', [80 300]);
gui.apply_ui_mode('basic');
gui.switchui('multip08');
gui.update_dependent_controls;
gui.sliderdisp(gui.retr('pivlab_axis')); drawnow;
% image acquisition panel: the reset gives its defaults too (not the settings a new start would restore)
set(h.ac_interpuls, 'String', '1234');
set(h.ac_config, 'Value', 2);
gui.put('selected_com_port', 'COM9');
gui.reset_gui_Callback();
d = helper_snapshot_differences(fresh, helper_gui_snapshot(hgui));
verifyEmpty(testCase, d, ['after 2D: ' strjoin(d, newline)]);

%% stereo-PIV: import, lens + board per camera, calibration, disparity, 3D view
c = helper_stereo_synthetic_case(fullfile(testCase.TestData.Dir, 'stereo'), 2, 0);
gui.put('sequencer', 1);
import.stereo_import_Callback([], [], {c.files{1}, c.files{2}});
for k = 1:2
    stereo.switch_camera(k);
    gui.put('cameraParams', c.lens{k});
    gui.put('cam_selected_rectification_image', c.boards{k});
end
stereo.switch_camera(1);
h = gui.gethand;
set(h.calib_rows, 'String', int2str(c.board.PatternDims(1)));
set(h.calib_columns, 'String', int2str(c.board.PatternDims(2)));
set(h.calib_checkersize, 'String', num2str(c.board.CheckerSize));
set(h.calib_markersize, 'String', num2str(c.board.MarkerSize));
set(h.calib_origincolor, 'Value', 1);
stereo.panel_Callback;
stereo.calibrate_Callback;
verifyNotEmpty(testCase, gui.retr('stereo_calib'), 'stereo calibration failed');
stereo.measure_disparity_Callback;
stereo.show_3d_Callback;
gui.sliderdisp(gui.retr('pivlab_axis')); drawnow;
gui.reset_gui_Callback();
d = helper_snapshot_differences(fresh, helper_gui_snapshot(hgui));
verifyEmpty(testCase, d, ['after stereo: ' strjoin(d, newline)]);

%% the reset PIVlab works like a new one: same PIV result with the default settings
helper_gui_load_images(jet);
helper_gui_analyze();
after = gui.retr('resultslist');
verifyEqual(testCase, after(1:5, :), reference(1:5, :), 'PIV result after the reset differs from the one after the new start');
end

function t = text_of(control)
t = control.String;
if iscell(t)
    t = strjoin(t, ' ');
end
if isempty(t)
    t = control.Tag;
end
end
