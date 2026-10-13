function tests = test_gui_settings
%TEST_GUI_SETTINGS The settings of the PIVlab window: default values (gui.default_settings), the setting
%   controls and their dependent controls, settings files (save / load, also from a session), the
%   camera settings, and the translation to the command-line API.
%   File dialogs are replaced by unittests/parity/mocks.
%   Run with: results = runtests('unittests/test_gui_settings.m')
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
helper_setup_once(testCase);
addpath(fullfile(testCase.TestData.Root, 'unittests', 'parity', 'mocks'), '-begin');   % uigetfile / uiputfile
end

function teardownOnce(testCase)
rmpath(fullfile(testCase.TestData.Root, 'unittests', 'parity', 'mocks'));
helper_teardown_once(testCase);
end

% The PIVlab window stays open between the tests: helper_start_pivlab resets it ("Reset PIVlab GUI")
% and checks that it is the same as after a new start; helper_teardown_once closes it.

%% ================================================================== default values and controls

function test_every_setting_has_one_default(testCase)
% every setting control has exactly one entry in gui.default_settings, and every entry a control
hgui = helper_start_pivlab();
[~, tags] = gui.setting_controls(hgui);
testCase.verifyEqual(numel(unique(tags)), numel(tags), 'Two setting controls have the same Tag.');
default = gui.default_settings;
groups = fieldnames(default);
default_tags = {};
for g = 1:numel(groups)
    default_tags = [default_tags; fieldnames(default.(groups{g}))]; %#ok<AGROW>
end
testCase.verifyEqual(numel(unique(default_tags)), numel(default_tags), 'A Tag is in more than one group of gui.default_settings.');
no_default = setdiff(tags, default_tags);
testCase.verifyEmpty(no_default, ['Setting controls without a default value: ' strjoin(no_default, ', ')]);
no_control = setdiff(default_tags, tags);
testCase.verifyEmpty(no_control, ['Default values without a control: ' strjoin(no_control, ', ')]);
end

function test_controls_start_with_their_default(testCase)
hgui = helper_start_pivlab();
[controls, ~] = gui.setting_controls(hgui);
default = gui.default_settings;
groups = fieldnames(default);
for k = 1:numel(controls)
    c = controls(k);
    for g = 1:numel(groups)
        if isfield(default.(groups{g}), c.Tag)
            value = default.(groups{g}).(c.Tag);
            testCase.verifyEqual(gui.setting_value(c, value), value, ['Start value of ' c.Tag]);
            if strcmp(c.Style, 'edit') && isnumeric(value)
                % the number shown in the field gives back exactly the default
                testCase.verifyEqual(str2double(c.String), value, ['Text of ' c.Tag]);
            end
        end
    end
end
end

function test_startup_state_is_consistent(testCase)
% after the start, gui.update_dependent_controls changes nothing
hgui = helper_start_pivlab();
before = helper_states(hgui);
gui.update_dependent_controls;
after = helper_states(hgui);
helper_verify_same_states(testCase, before, after, 'after gui.update_dependent_controls at startup');
end

function test_hand_set_equals_update(testCase)
% settings changed by hand (with the callbacks of the controls) give the same Enable / Visible
% states as the values set directly followed by one gui.update_dependent_controls
cases = {
    {'algorithm_selection', 2}
    {'algorithm_selection', 3}
    {'algorithm_selection', 4}
    {'pass4_enable', 1}
    {'pass2_enable', 0}
    {'pass3_enable', 1, 'repeat_last_enable', 1}
    {'autoscaler', 0}
    {'autoscale_vec', 1}
    {'smooth_mode', 3}
    {'mask_basic_expert', 2, 'mask_bright_or_dark', 2, 'binarize_enable_2', 1}
    {'mask_basic_expert', 2, 'mask_bright_or_dark', 3, 'low_contrast_mask_enable', 1}
    {'flow_sim', 2, 'singledoubleoseen', 2}
    {'singledoublerankine', 2}
    {'draw_what', 3}
    {'pass2_size', '48'}
    };
callbacks = struct('algorithm_selection', 'piv.algorithm_selection_Callback', 'pass2_enable', 'piv.pass2_checkbox_Callback', ...
    'pass3_enable', 'piv.pass3_checkbox_Callback', 'pass4_enable', 'piv.pass4_checkbox_Callback', ...
    'repeat_last_enable', 'piv.repeat_last_Callback', 'autoscaler', 'plot.autoscaler_Callback', ...
    'autoscale_vec', 'plot.autoscale_vec_Callback', 'smooth_mode', 'plot.smooth_mode_Callback', ...
    'mask_basic_expert', 'mask.basic_expert_Callback', 'mask_bright_or_dark', 'mask.bright_or_dark_Callback', ...
    'binarize_enable_2', 'mask.binarize_enable_2_Callback', 'low_contrast_mask_enable', 'mask.low_contrast_mask_enable_Callback', ...
    'flow_sim', 'simulate.flow_sim_Callback', 'singledoubleoseen', 'simulate.singledoubleoseen_Callback', ...
    'singledoublerankine', 'simulate.singledoublerankine_Callback', 'draw_what', 'extract.draw_what_Callback', ...
    'pass2_size', 'piv.pass2_size_Callback');
for k = 1:numel(cases)
    c = cases{k};
    % by hand
    hgui = helper_start_pivlab();
    h = gui.gethand;
    for i = 1:2:numel(c)
        set_value(h.(c{i}), c{i+1});
        feval(callbacks.(c{i}), h.(c{i}), [], []);
    end
    by_hand = helper_states(hgui);
    values_by_hand = setting_values(hgui);
    helper_close_pivlab();
    % set directly (the values after the clicks, incl. value couplings), then one update
    hgui = helper_start_pivlab();
    [controls, tags] = gui.setting_controls(hgui);
    for i = 1:numel(controls)
        set_value(controls(i), values_by_hand.(tags{i}));
    end
    gui.update_dependent_controls;
    direct = helper_states(hgui);
    helper_close_pivlab();
    helper_verify_same_states(testCase, by_hand, direct, sprintf('case %d (%s)', k, c{1}));
end
end

function test_api_translation_is_complete(testCase)
% every setting of the groups analysis and calibration is used by the command-line API or is
% listed as GUI only in +pivlab/private/gui_settings_to_api.m
text = fileread(fullfile(testCase.TestData.Root, '+pivlab', 'private', 'gui_settings_to_api.m'));
default = gui.default_settings;
missing = {};
for g = {'analysis', 'calibration'}
    names = fieldnames(default.(g{1}));
    for n = 1:numel(names)
        if ~contains(text, ['''' names{n} ''''])
            missing{end+1} = names{n}; %#ok<AGROW>
        end
    end
end
testCase.verifyEmpty(missing, ['Not in gui_settings_to_api.m: ' strjoin(missing, ', ')]);
end

%% ================================================================== settings files

function test_settings_file_roundtrip(testCase)
% every setting gets a value different from its default, is saved, and loaded in a fresh window:
% all values (with their types) and all Enable / Visible states are the same
hgui = helper_start_pivlab();
change_all_settings(hgui);
saved = gui.collect_settings(hgui);
states = helper_states(hgui);
file = [tempname '.mat'];
export.write_settings_file(file, saved);
helper_close_pivlab();
hgui = helper_start_pivlab();
[loaded, message] = import.read_settings_file(file);
delete(file);
testCase.assertNotEmpty(loaded, message);
default = gui.default_settings;
notes = gui.apply_settings(loaded, fieldnames(default), true);
testCase.verifyEmpty(notes);
after = gui.collect_settings(hgui);
groups = fieldnames(default);
for g = 1:numel(groups)
    names = fieldnames(default.(groups{g}));
    for n = 1:numel(names)
        v = after.(groups{g}).(names{n});
        testCase.verifyEqual(v, saved.(groups{g}).(names{n}), ['Loaded value of ' names{n}]);
        testCase.verifyClass(v, class(default.(groups{g}).(names{n})), ['Type of ' names{n}]);
    end
end
helper_verify_same_states(testCase, states, helper_states(hgui), 'after loading the settings file');
end

function test_load_settings_changes_only_its_groups(testCase)
hgui = helper_start_pivlab();
change_all_settings(hgui);
changed = gui.collect_settings(hgui);
gui.apply_settings(gui.default_settings, {'analysis', 'calibration', 'masks'}, false);
after = gui.collect_settings(hgui);
default = gui.default_settings;
testCase.verifyEqual(after.analysis.pass1_size, default.analysis.pass1_size);
testCase.verifyEqual(after.masks.binarize_threshold, default.masks.binarize_threshold);
testCase.verifyEqual(after.display, changed.display, 'display settings must not change');
testCase.verifyEqual(after.export, changed.export, 'export settings must not change');
testCase.verifyEqual(after.calibration.calib_usecalibration, changed.calibration.calib_usecalibration, ...
    'controls marked session_only must not change');
end

function test_settings_file_in_a_fresh_pivlab(testCase)
% save settings, load them in a fresh PIVlab: analysis, calibration and mask generator settings
% are applied, display / export / acquisition settings stay as they are
root = testCase.TestData.Root;
helper_start_pivlab();
h = gui.gethand;
set(h.clahe_enable,'Value',0); set(h.highpass_enable,'Value',1); set(h.highpass_size,'String','21');
set(h.pass1_size,'String','96'); set(h.pass1_step,'String','48');
set(h.pass3_enable,'Value',1); set(h.pass3_size,'String','24');
set(h.smooth_mode,'Value',2); set(h.smooth_param,'String','0.7');
set(h.stdev_thresh,'String','5.5'); set(h.loc_med_thresh,'String','2.2');
set(h.mask_basic_expert,'Value',2); set(h.binarize_threshold,'String','0.33');
set(h.colormap_choice,'Value',3);                 % display
set(h.ac_interpuls,'String','777');               % acquisition
helper_gui_load_images(helper_files('jet', 1));
gui.put('pointscali',[10 10; 210 10]);
set(h.realdist,'String','20'); set(h.time_inp,'String','50');
set(h.x_axis_direction,'Value',2);
calibrate.apply_cali_Callback([],[],[]);
gui.update_dependent_controls;
saved = gui.collect_settings;
saved_cal = cal_values();
f = 'settings_fresh.mat';
mock_file(testCase.TestData.Dir, f);
export.save_settings_Callback([],[],[]);
testCase.assertTrue(isfile(fullfile(testCase.TestData.Dir, f)));
helper_close_pivlab();

helper_start_pivlab();
h = gui.gethand;
set(h.colormap_choice,'Value',5); set(h.ac_interpuls,'String','1234');
set(h.export_mat_derivatives,'Value',1);
before = gui.collect_settings;
mock_file(testCase.TestData.Dir, f);
import.load_settings_Callback([],[],[]); drawnow;
after = gui.collect_settings;
for g = {'analysis','calibration','masks'}
    testCase.verifyEqual(after.(g{1}), saved.(g{1}), ['group ' g{1}]);
end
for g = {'display','export','acquisition'}
    testCase.verifyEqual(after.(g{1}), before.(g{1}), ['group ' g{1} ' must not change']);
end
% the controls show the loaded values, the dependent controls are updated
testCase.verifyEqual(get(h.pass1_size,'String'), '96');
testCase.verifyEqual(get(h.pass3_step,'String'), '12');
testCase.verifyEqual(char(get(h.pass3_size,'Enable')), 'on');
testCase.verifyEqual(char(get(h.uipanel25_2,'Visible')), 'on', 'expert mask panel');
% calibration: values and the green box
c = cal_values();
testCase.verifyEqual(c.calxy, saved_cal.calxy, 'RelTol', 1e-12);
testCase.verifyEqual(c.calu, saved_cal.calu, 'RelTol', 1e-12);
box = get(h.calidisp,'String');
box = strjoin(cellstr(box), ' ');   % char matrix, one row per line
testCase.verifySubstring(box, sprintf('%0.4e', saved_cal.calxy));
testCase.verifySubstring(box, 'm/s');
end

function test_load_settings_keeps_results_and_makes_background(testCase)
root = testCase.TestData.Root;
helper_start_pivlab();
helper_gui_load_images(helper_files('jet', 3));
h = gui.gethand;
helper_gui_analyze();
rl = gui.retr('resultslist');
testCase.verifyEmpty(gui.retr('bg_img_A'));
% a settings file with background subtraction "mean"
set(h.bg_subtract,'Value',2); set(h.stdev_thresh,'String','4.5');   % (no callbacks: nothing is computed)
G = gui.collect_settings;
G.calibration_data = calibrate.calibration_data;
set(h.bg_subtract,'Value',1); set(h.stdev_thresh,'String','7');
f = fullfile(testCase.TestData.Dir, 'with_background.mat');
export.write_settings_file(f, G);
mock_file(testCase.TestData.Dir, 'with_background.mat');
import.load_settings_Callback([],[],[]); drawnow;
testCase.verifyEqual(gui.retr('resultslist'), rl, 'results stay');
testCase.verifyEqual(get(h.bg_subtract,'Value'), 2);
testCase.verifyEqual(str2double(get(h.stdev_thresh,'String')), 4.5);
bgA = gui.retr('bg_img_A');
testCase.verifyNotEmpty(bgA, 'background images are made again');
% the same as making them with the button
gui.put('bg_img_A',[]); gui.put('bg_img_B',[]);
preproc.generate_BG_img(); drawnow;
testCase.verifyEqual(gui.retr('bg_img_A'), bgA);
% the analysis uses them
helper_gui_analyze();
rl2 = gui.retr('resultslist');
testCase.verifyNotEqual(rl2{3,1}, rl{3,1});
end

function test_load_settings_from_a_session_file(testCase)
root = testCase.TestData.Root;
% a session with other settings and other images
helper_start_pivlab();
helper_gui_load_images(helper_files('jet', 2));
h = gui.gethand;
set(h.pass1_size,'String','48'); set(h.pass1_step,'String','24');
set(h.stdev_thresh,'String','6.5');
set(h.colormap_choice,'Value',4);
helper_gui_analyze();
saved = gui.collect_settings;
export.save_session_function(testCase.TestData.Dir, 'settings_source_session.mat');
helper_close_pivlab();
% another analysis: only the settings are taken over
helper_start_pivlab();
helper_gui_load_images(helper_files('jet', 1));
helper_gui_analyze();
h = gui.gethand;
rl = gui.retr('resultslist');
files = gui.retr('filepath');
before = gui.collect_settings;
mock_file(testCase.TestData.Dir, 'settings_source_session.mat');
import.load_settings_Callback([],[],[]); drawnow;
after = gui.collect_settings;
testCase.verifyEqual(after.analysis, saved.analysis);
testCase.verifyEqual(after.display, before.display);
testCase.verifyEqual(gui.retr('resultslist'), rl);
testCase.verifyEqual(gui.retr('filepath'), files);
testCase.verifyEqual(get(h.pass1_size,'String'), '48');
end

function test_old_files_change_nothing(testCase)
helper_start_pivlab();
helper_gui_load_images(helper_files('jet', 1));
h = gui.gethand;
set(h.pass1_size,'String','80');
before = gui.collect_settings;
data_before = session_data();
% PIVlab 3.x settings file
clahe_enable = 1; intarea = '64'; step = '32'; %#ok<NASGU>
save(fullfile(testCase.TestData.Dir,'old_settings.mat'), 'clahe_enable', 'intarea', 'step');
mock_file(testCase.TestData.Dir, 'old_settings.mat');
import.load_settings_Callback([],[],[]); drawnow;
testCase.verifyEqual(gui.collect_settings, before, 'old settings file');
[s, message] = import.read_settings_file(fullfile(testCase.TestData.Dir,'old_settings.mat'));
testCase.verifyEmpty(s);
testCase.verifySubstring(message, 'older PIVlab version');
% PIVlab 3.x session
resultslist = {}; wasdisabled = []; sequencer = 1; filepath = {'a.tif';'b.tif'}; %#ok<NASGU>
old = fullfile(testCase.TestData.Dir,'old_session.mat');
save(old, 'resultslist', 'wasdisabled', 'sequencer', 'filepath');
import.load_session_Callback(1, old); drawnow;
testCase.verifyEqual(gui.collect_settings, before, 'old session: settings');
testCase.verifyEqual(session_data(), data_before, 'old session: data');
[~, message] = import.read_session_file(old);
testCase.verifySubstring(message, 'older PIVlab version');
% a PIVlab 3.x session as settings file
mock_file(testCase.TestData.Dir, 'old_session.mat');
import.load_settings_Callback([],[],[]); drawnow;
testCase.verifyEqual(gui.collect_settings, before, 'old session as settings file');
end

function test_camera_settings_with_acquisition(testCase)
% the settings of the camera windows are stored with the group acquisition: in sessions and in
% the last acquisition settings; the OPTOcam 2/80 bit depth is not changed by loading (it is also
% set in the synchronizer)
helper_start_pivlab();
gui.set_camera_setting('OPTRONIS_gain', 4);
gui.set_camera_setting('panda_filetype', 'tif');
gui.set_camera_setting('OPTOcam_bits', 12);
saved = gui.collect_settings;
testCase.verifyEqual(saved.camera_settings.OPTRONIS_gain, 4);
gui.store_last_acquisition_settings;
helper_close_pivlab();
helper_start_pivlab();
testCase.verifyEqual(gui.camera_setting('OPTRONIS_gain'), 4, 'remembered at the next start');
testCase.verifyEqual(gui.camera_setting('panda_filetype'), 'tif');
testCase.verifyEmpty(gui.camera_setting('OPTOcam_bits'), 'OPTOcam 2/80 bit depth must not be restored');
gui.set_camera_setting('OPTOcam_bits', 8);
gui.apply_settings(saved, {'acquisition'}, true);
testCase.verifyEqual(gui.camera_setting('OPTOcam_bits'), 8, 'loading keeps the current bit depth');
testCase.verifyEqual(gui.camera_setting('OPTRONIS_gain'), 4);
gui.apply_settings(gui.default_settings, {'analysis'}, false);
testCase.verifyEqual(gui.camera_setting('OPTRONIS_gain'), 4, 'only the group acquisition changes them');
helper_close_pivlab();
rmpref('PIVlab', 'last_acquisition_settings');
end

%% ------------------------------------------------------------------ helpers

function change_all_settings(hgui)
% gives every setting control a value different from its default (popup menus whose list is
% filled at runtime keep their value), then updates the dependent controls
[controls, ~] = gui.setting_controls(hgui);
for k = 1:numel(controls)
    c = controls(k);
    switch c.Style
        case 'edit'
            number = str2double(c.String);
            if isnan(number)
                c.String = [c.String 'x'];
            else
                c.String = gui.setting_text(number * 2 + 1);
            end
        case {'popupmenu', 'listbox'}
            items = c.String;
            if iscell(items) && numel(items) > 1
                c.Value = mod(c.Value, numel(items)) + 1;
            end
        case 'slider'
            c.Value = c.Min + (c.Max - c.Min) * 0.37;
        otherwise
            c.Value = 1 - c.Value;
    end
end
gui.update_dependent_controls;
end

function V = setting_values(hgui)
[controls, tags] = gui.setting_controls(hgui);
V = struct();
for k = 1:numel(controls)
    if strcmp(controls(k).Style, 'edit')
        V.(tags{k}) = controls(k).String;
    else
        V.(tags{k}) = controls(k).Value;
    end
end
end

function set_value(control, value)
if ischar(value)
    control.String = value;
else
    control.Value = value;
end
end

function D = session_data()
keys = gui.session_data_keys;
D = struct();
for k = 1:numel(keys)
    D.(keys{k}) = gui.retr(keys{k});
end
end

function c = cal_values()
c = struct();
for n = {'calu','calv','calxy','offset_x_true','offset_y_true'}
    c.(n{1}) = gui.retr(n{1});
end
end

function mock_file(p, f)
setappdata(0,'parity_mock_file',{p,f});
end
