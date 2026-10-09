function tests = test_settings
% Tests of the settings system: default values (gui.default_settings) and the setting controls
% of the PIVlab window (gui.setting_controls).
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
testCase.TestData.ProjectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(testCase.TestData.ProjectRoot);
testCase.TestData.Preferences = clear_preferences(); % start like a first start of PIVlab
end

function teardownOnce(testCase)
close_pivlab();
restore_preferences(testCase.TestData.Preferences);
end

function setup(~)
close_pivlab();
end

function teardown(~)
close_pivlab();
end

function test_every_setting_has_one_default(testCase)
% every setting control has exactly one entry in gui.default_settings, and every entry a control
hgui = start_pivlab();
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
hgui = start_pivlab();
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
hgui = start_pivlab();
before = enable_visible_states(hgui);
gui.update_dependent_controls;
after = enable_visible_states(hgui);
verify_same_states(testCase, before, after, 'after gui.update_dependent_controls at startup');
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
    hgui = start_pivlab();
    h = gui.gethand;
    for i = 1:2:numel(c)
        set_value(h.(c{i}), c{i+1});
        feval(callbacks.(c{i}), h.(c{i}), [], []);
    end
    by_hand = enable_visible_states(hgui);
    values_by_hand = setting_values(hgui);
    close_pivlab();
    % set directly (the values after the clicks, incl. value couplings), then one update
    hgui = start_pivlab();
    [controls, tags] = gui.setting_controls(hgui);
    for i = 1:numel(controls)
        set_value(controls(i), values_by_hand.(tags{i}));
    end
    gui.update_dependent_controls;
    direct = enable_visible_states(hgui);
    close_pivlab();
    verify_same_states(testCase, by_hand, direct, sprintf('case %d (%s)', k, c{1}));
end
end

function test_settings_file_roundtrip(testCase)
% every setting gets a value different from its default, is saved, and loaded in a fresh window:
% all values (with their types) and all Enable / Visible states are the same
hgui = start_pivlab();
change_all_settings(hgui);
saved = gui.collect_settings(hgui);
states = enable_visible_states(hgui);
file = [tempname '.mat'];
export.write_settings_file(file, saved);
close_pivlab();
hgui = start_pivlab();
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
verify_same_states(testCase, states, enable_visible_states(hgui), 'after loading the settings file');
end

function test_load_settings_changes_only_its_groups(testCase)
hgui = start_pivlab();
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
testCase.verifyEqual(after.analysis.stereocheckbox, changed.analysis.stereocheckbox);
end

function test_old_settings_file_gives_a_message(testCase)
file = [tempname '.mat'];
intarea = '64'; clahe_enable = 1; %#ok<NASGU>
save(file, 'intarea', 'clahe_enable');
[settings, message] = import.read_settings_file(file);
delete(file);
testCase.verifyEmpty(settings);
testCase.verifySubstring(message, 'older PIVlab version');
end

function test_session_roundtrip(testCase)
% a session brings PIVlab back to exactly where it was: settings (with types), session data,
% view and the Enable / Visible states
hgui = start_pivlab();
root = testCase.TestData.ProjectRoot;
files = {fullfile(root,'Example_data','Jet_0001A.jpg'); fullfile(root,'Example_data','Jet_0001B.jpg'); ...
    fullfile(root,'Example_data','Jet_0002A.jpg'); fullfile(root,'Example_data','Jet_0002B.jpg')};
gui.put('sequencer', 1);
import.loadimgsbutton_Callback([], [], 0, struct('name', files, 'isdir', num2cell(false(4,1))));
h = gui.gethand;
set(h.pass1_size, 'String', '48'); set(h.pass1_step, 'String', '24');
gui.update_dependent_controls;
gui.put('roirect', [20 20 300 200]);
set(h.update_display_checkbox, 'Value', 0);
piv.AnalyzeAll_Callback([], [], []);
gui.put('pointscali', [10 10; 110 10]);
set(h.realdist, 'String', '10'); set(h.time_inp, 'String', '100');
calibrate.apply_cali_Callback([], [], []);
set(h.colormap_choice, 'Value', 3); set(h.smooth_mode, 'Value', 2); set(h.mask_basic_expert, 'Value', 2);
set(h.fileselector, 'Value', 2); gui.fileselector_Callback(h.fileselector, [], []);
plot.derivs_Callback; % fills the list of derived parameters
gui.update_dependent_controls;
gui.switchui('multip06');
saved_settings = gui.collect_settings(hgui);
keys = gui.session_data_keys;
saved_data = struct();
for k = 1:numel(keys)
    saved_data.(keys{k}) = gui.retr(keys{k});
end
states = enable_visible_states(hgui);
file = [tempname '.mat'];
[p, f, e] = fileparts(file);
export.save_session_function(p, [f e]);
close_pivlab();
hgui = start_pivlab();
import.load_session_Callback(1, file);
delete(file);
testCase.verifyEqual(gui.collect_settings(hgui), saved_settings, 'settings after loading the session');
for k = 1:numel(keys)
    testCase.verifyEqual(gui.retr(keys{k}), saved_data.(keys{k}), ['session data ' keys{k}]);
end
h = gui.gethand;
testCase.verifyEqual(get(h.fileselector, 'Value'), 2, 'displayed frame');
testCase.verifyEqual(char(get(h.multip06, 'Visible')), 'on', 'open panel');
verify_same_states(testCase, states, enable_visible_states(hgui), 'after loading the session');
end

function test_old_session_gives_a_message(testCase)
file = [tempname '.mat'];
resultslist = {}; wasdisabled = []; sequencer = 1; %#ok<NASGU>
save(file, 'resultslist', 'wasdisabled', 'sequencer');
[session, message] = import.read_session_file(file);
delete(file);
testCase.verifyEmpty(session);
testCase.verifySubstring(message, 'older PIVlab version');
end

function test_last_acquisition_settings_at_next_start(testCase)
% the image acquisition panel starts as it was at the last close, everything else with defaults
hgui = start_pivlab();
h = gui.gethand;
set(h.ac_interpuls, 'String', '1234');
set(h.ac_expo, 'String', '77');
set(h.pass1_size, 'String', '96');
gui.store_last_acquisition_settings;
close_pivlab();
hgui = start_pivlab();
settings = gui.collect_settings(hgui);
testCase.verifyEqual(settings.acquisition.ac_interpuls, 1234);
testCase.verifyEqual(settings.acquisition.ac_expo, 77);
default = gui.default_settings;
testCase.verifyEqual(settings.analysis.pass1_size, default.analysis.pass1_size, 'only acquisition is remembered');
rmpref('PIVlab', 'last_acquisition_settings');
end

function test_mode_and_panel_width_are_remembered(testCase)
gui.set_preference('ui_mode', 'basic');
gui.set_preference('panelwidth', 60);
start_pivlab();
testCase.verifyEqual(gui.retr('ui_mode'), 'basic');
testCase.verifyEqual(gui.retr('panelwidth'), 60);
close_pivlab();
rmpref('PIVlab', 'ui_mode');
rmpref('PIVlab', 'panelwidth');
end

function test_rebuilding_the_window_keeps_the_settings(testCase)
% changing the panel width rebuilds all controls: the settings stay
hgui = start_pivlab();
h = gui.gethand;
set(h.pass1_size, 'String', '96'); set(h.colormap_choice, 'Value', 3);
gui.update_dependent_controls;
before = gui.collect_settings(hgui);
set(h.panelslider, 'Value', 55);
gui.pref_apply_Callback;
testCase.verifyEqual(gui.collect_settings(hgui), before);
testCase.verifyEqual(gui.get_preference('panelwidth', []), 55);
close_pivlab();
rmpref('PIVlab', 'panelwidth');
end

function test_no_file_is_written_into_the_pivlab_folder(testCase)
before = dir(testCase.TestData.ProjectRoot);
hgui = start_pivlab();
gui.store_last_acquisition_settings;
gui.set_preference('pathname', gui.retr('pathname'));
close_pivlab();
after = dir(testCase.TestData.ProjectRoot);
testCase.verifyEqual(sort({after.name}), sort({before.name}));
testCase.verifyFalse(isfile(fullfile(testCase.TestData.ProjectRoot, 'PIVlab_settings_default.mat')));
end

function test_camera_settings_with_acquisition(testCase)
% the settings of the camera windows are stored with the group acquisition: in sessions and in
% the last acquisition settings; the OPTOcam 2/80 bit depth is not changed by loading (it is also
% set in the synchronizer)
start_pivlab();
gui.set_camera_setting('OPTRONIS_gain', 4);
gui.set_camera_setting('panda_filetype', 'tif');
gui.set_camera_setting('OPTOcam_bits', 12);
saved = gui.collect_settings;
testCase.verifyEqual(saved.camera_settings.OPTRONIS_gain, 4);
gui.store_last_acquisition_settings;
close_pivlab();
start_pivlab();
testCase.verifyEqual(gui.camera_setting('OPTRONIS_gain'), 4, 'remembered at the next start');
testCase.verifyEqual(gui.camera_setting('panda_filetype'), 'tif');
testCase.verifyEmpty(gui.camera_setting('OPTOcam_bits'), 'OPTOcam 2/80 bit depth must not be restored');
gui.set_camera_setting('OPTOcam_bits', 8);
gui.apply_settings(saved, {'acquisition'}, true);
testCase.verifyEqual(gui.camera_setting('OPTOcam_bits'), 8, 'loading keeps the current bit depth');
testCase.verifyEqual(gui.camera_setting('OPTRONIS_gain'), 4);
gui.apply_settings(gui.default_settings, {'analysis'}, false);
testCase.verifyEqual(gui.camera_setting('OPTRONIS_gain'), 4, 'only the group acquisition changes them');
close_pivlab();
rmpref('PIVlab', 'last_acquisition_settings');
end

function test_api_translation_is_complete(testCase)
% every setting of the groups analysis and calibration is used by the command-line API or is
% listed as GUI only in +pivlab/private/gui_settings_to_api.m
text = fileread(fullfile(testCase.TestData.ProjectRoot, '+pivlab', 'private', 'gui_settings_to_api.m'));
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

%% helpers
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

function S = enable_visible_states(hgui)
% Enable and Visible of every tagged uicontrol and uipanel
h = [findall(hgui, 'Type', 'uicontrol'); findall(hgui, 'Type', 'uipanel')];
S = struct();
for k = 1:numel(h)
    t = h(k).Tag;
    if isempty(t) || ~isvarname(t)
        continue
    end
    e = '';
    if isprop(h(k), 'Enable')
        e = char(h(k).Enable);
    end
    S.(t) = [e '/' char(h(k).Visible)];
end
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

function verify_same_states(testCase, A, B, what)
f = fieldnames(A);
different = {};
for k = 1:numel(f)
    if ~isfield(B, f{k}) || ~strcmp(A.(f{k}), B.(f{k}))
        b = '(missing)';
        if isfield(B, f{k})
            b = B.(f{k});
        end
        different{end+1} = sprintf('%s: %s -> %s', f{k}, A.(f{k}), b); %#ok<AGROW>
    end
end
testCase.verifyEmpty(different, sprintf('Enable/Visible differ %s:\n%s', what, strjoin(different, newline)));
end

function hgui = start_pivlab()
PIVlab_GUI(1);
drawnow;
gui.put('batchModeActive', 1);
hgui = getappdata(0, 'hgui');
end

function close_pivlab()
hgui = getappdata(0, 'hgui');
if ~isempty(hgui) && ishghandle(hgui)
    try
        gui.put('batchModeActive', 1);
    catch
    end
    try
        delete(hgui);
    catch
        close(hgui, 'force');
    end
end
setappdata(0, 'hgui', []);
end

function prefs = clear_preferences()
% the user's PIVlab preferences (gui.set_preference): saved, then removed, so the tests start
% like a first start of PIVlab. Also saved in a file: if a test run is stopped before its end,
% load(fullfile(tempdir,'PIVlab_preferences_backup.mat')) and restore_preferences(prefs) bring
% them back.
prefs = struct();
if ispref('PIVlab')
    prefs = getpref('PIVlab');
    rmpref('PIVlab');
end
backup = fullfile(tempdir, 'PIVlab_preferences_backup.mat');
if ~isfile(backup)   % a backup of a stopped run is not overwritten with the cleared preferences
    save(backup, 'prefs');
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
backup = fullfile(tempdir, 'PIVlab_preferences_backup.mat');
if isfile(backup)
    delete(backup);
end
end
