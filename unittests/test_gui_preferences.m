function tests = test_gui_preferences
%TEST_GUI_PREFERENCES What PIVlab remembers for the next start (preferences: last folder, mode, panel
%   width, theme, last acquisition settings), rebuilding the window (Preferences -> Apply, theme), and
%   what PIVlab must leave as it was (MATLAB warnings, files in the PIVlab folder).
%   File dialogs are replaced by unittests/parity/mocks.
%   Run with: results = runtests('unittests/test_gui_preferences.m')
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

function setup(~)
helper_close_pivlab();
end

function teardown(~)
helper_close_pivlab();
end

%% ================================================================== remembered for the next start

function test_first_start_without_preferences(testCase)
if ispref('PIVlab'), rmpref('PIVlab'); end
helper_start_pivlab();
testCase.verifyEqual(gui.retr('pathname'), fullfile(testCase.TestData.Root, 'Example_data'));
testCase.verifyEqual(gui.retr('ui_mode'), 'advanced');
testCase.verifyEqual(gui.retr('panelwidth'), default_panelwidth());
% dark / light follows MATLAB (an old PIVlab_ad preference is not used)
hgui = getappdata(0,'hgui');
testCase.verifyEqual(isequal(gui.retr('darkmode'), 1), strcmpi(hgui.Theme.BaseColorStyle,'dark'));
helper_close_pivlab();
testCase.verifyFalse(ispref('PIVlab','ui_mode'), 'nothing stored without a change');
end

function test_colours_follow_the_matlab_theme(testCase)
% without a theme chosen in PIVlab, the PIVlab colours follow a change of the MATLAB theme (as the
% system theme, which the first window of a MATLAB session without desktop gets only some seconds
% after it was made): the controls are built again, the open panel and the images stay, nothing is stored
if ispref('PIVlab'), rmpref('PIVlab'); end
testCase.addTeardown(@clear_temporary_matlab_theme);
testCase.addTeardown(@helper_close_pivlab);   % runs first: PIVlab is closed before the MATLAB theme goes back
helper_start_pivlab();
helper_gui_load_images(helper_files('jet', 3));
gui.switchui('multip04');
dark_before = isequal(gui.retr('darkmode'), 1);
set_temporary_matlab_theme(~dark_before);
testCase.verifyTrue(wait_for(@() isequal(gui.retr('darkmode'), 1) == ~dark_before), 'PIVlab colours follow the MATLAB theme');
hgui = getappdata(0,'hgui');
h = gui.gethand;
testCase.verifyEqual(strcmpi(hgui.Theme.BaseColorStyle,'dark'), ~dark_before, 'window theme');
testCase.verifyEqual(get(h.zoomon,'CData'), zoom_icon(~dark_before), 'controls built again in the new colours');
testCase.verifyEqual(char(get(findobj(hgui,'Tag','multip04'),'Visible')), 'on', 'the open panel stays open');
testCase.verifyEqual(get(h.filenamebox,'String'), gui.retr('filename'), 'images still loaded');
testCase.verifyFalse(ispref('PIVlab','dark_mode_theme'), 'the theme is not stored');
set_temporary_matlab_theme(dark_before);
testCase.verifyTrue(wait_for(@() isequal(gui.retr('darkmode'), 1) == dark_before), 'and back');
% controls that are disabled after the start stay disabled after the next busy phase (gui.toolsavailable)
helper_gui_load_images(helper_files('jet', 3));
testCase.verifyEqual(char(get(findobj(getappdata(0,'hgui'),'Tag','ac_calibsave'),'Enable')), 'off', 'Save button of the camera calibration');
end

function test_theme_change_waits_while_pivlab_is_busy(testCase)
% the controls are not built again while PIVlab is busy, but when it is done
if ispref('PIVlab'), rmpref('PIVlab'); end
testCase.addTeardown(@clear_temporary_matlab_theme);
testCase.addTeardown(@helper_close_pivlab);   % runs first: PIVlab is closed before the MATLAB theme goes back
helper_start_pivlab();
dark_before = isequal(gui.retr('darkmode'), 1);
gui.toolsavailable(0, [], true);
set_temporary_matlab_theme(~dark_before);
testCase.verifyFalse(wait_for(@() isequal(gui.retr('darkmode'), 1) == ~dark_before, 3), 'nothing built again while busy');
gui.toolsavailable(1);
testCase.verifyTrue(wait_for(@() isequal(gui.retr('darkmode'), 1) == ~dark_before), 'colours follow when PIVlab is done');
testCase.verifyEmpty(timerfindall('Tag','PIVlab_theme_follow'), 'no timer left');
end

function test_chosen_theme_does_not_follow_matlab(testCase)
% a theme chosen in PIVlab (stored in the preferences) stays when the MATLAB theme changes
if ispref('PIVlab'), rmpref('PIVlab'); end
testCase.addTeardown(@clear_temporary_matlab_theme);
testCase.addTeardown(@helper_close_pivlab);   % runs first: PIVlab is closed before the MATLAB theme goes back
gui.set_preference('dark_mode_theme', 1);
helper_start_pivlab();
set_temporary_matlab_theme(false);
pause(3);
hgui = getappdata(0,'hgui');
testCase.verifyEqual(gui.retr('darkmode'), 1);
testCase.verifyEqual(hgui.Theme.BaseColorStyle, 'dark');
end

function test_preferences_are_remembered(testCase)
root = testCase.TestData.Root;
if ispref('PIVlab'), rmpref('PIVlab'); end
helper_start_pivlab();
h = gui.gethand;
% last folder (stored when PIVlab is closed) and sequencing style of the file dialog
helper_gui_load_images(helper_files('distortion', 1), 1);
folder = gui.retr('pathname');
close_with_menu();
helper_start_pivlab();
testCase.verifyEqual(gui.retr('pathname'), folder, 'last folder');
h = gui.gethand;
% Basic mode, panel width, theme
gui.request_mode_switch('basic');
set(h.panelslider,'Value',55); gui.pref_apply_Callback;
h = gui.gethand;
dark_now = double(isequal(gui.retr('darkmode'), 1));   % empty = light (MATLAB theme)
set(h.matlab_theme,'Value', 1 + double(dark_now == 1));   % 1 = dark, 2 = light: the other one
gui.change_theme();
close_with_menu();
helper_start_pivlab();
testCase.verifyEqual(gui.retr('ui_mode'), 'basic');
testCase.verifyEqual(gui.retr('panelwidth'), 55);
testCase.verifyEqual(double(isequal(gui.retr('darkmode'), 1)), 1 - dark_now, 'theme');
hgui = getappdata(0,'hgui');
testCase.verifyEqual(strcmpi(hgui.Theme.BaseColorStyle,'dark'), dark_now == 0);
end

function test_last_acquisition_settings_at_next_start(testCase)
% the image acquisition panel starts as it was at the last close, everything else with defaults
hgui = helper_start_pivlab();
h = gui.gethand;
set(h.ac_interpuls, 'String', '1234');
set(h.ac_expo, 'String', '77');
set(h.pass1_size, 'String', '96');
gui.store_last_acquisition_settings;
helper_close_pivlab();
hgui = helper_start_pivlab();
settings = gui.collect_settings(hgui);
testCase.verifyEqual(settings.acquisition.ac_interpuls, 1234);
testCase.verifyEqual(settings.acquisition.ac_expo, 77);
default = gui.default_settings;
testCase.verifyEqual(settings.analysis.pass1_size, default.analysis.pass1_size, 'only acquisition is remembered');
rmpref('PIVlab', 'last_acquisition_settings');
end

%% ================================================================== rebuilding the window

function test_preferences_apply_and_theme_keep_the_settings(testCase)
% Preferences -> Apply (panel width) and the theme change rebuild all controls: settings, images,
% results, calibration, ROI, frame and the remembered folder stay
helper_start_pivlab();
helper_gui_load_images(helper_files('jet', 3));
h = gui.gethand;
set(h.colormap_choice,'Value',3); set(h.stdev_thresh,'String','4');
set(h.ac_interpuls,'String','999');
gui.update_dependent_controls;
gui.put('roirect',[50 50 800 600]);
helper_gui_analyze();
gui.put('pointscali',[10 10; 110 10]);
set(h.realdist,'String','10'); set(h.time_inp,'String','100');
calibrate.apply_cali_Callback([],[],[]);
set(h.fileselector,'Value',2); gui.fileselector_Callback(h.fileselector,[],[]);
gui.sliderdisp(gui.retr('pivlab_axis')); drawnow;
before = gui.collect_settings;
data = session_data();
folder = gui.retr('pathname');
states = helper_states();
box = strjoin(cellstr(get(h.calidisp,'String')), ' ');
gui.preferences_Callback;
h = gui.gethand;
set(h.panelslider,'Value',55); gui.pref_apply_Callback;
testCase.verifyEqual(without_derive_list(gui.collect_settings), without_derive_list(before), 'after Apply (panel width)');
testCase.verifyEqual(session_data(), data, 'data after Apply');
testCase.verifyEqual(gui.retr('pathname'), folder, 'last folder after Apply');
h = gui.gethand;
testCase.verifyEqual(get(h.fileselector,'Value'), 2, 'frame after Apply');
testCase.verifyEqual(strjoin(cellstr(get(h.calidisp,'String')), ' '), box, 'calibration box after Apply');
testCase.verifyEqual(get(h.filenamebox,'String'), gui.retr('filename'));
set(h.matlab_theme,'Value', 1 + double(isequal(gui.retr('darkmode'), 1)));   % the other theme (1 dark, 2 light)
gui.change_theme();
testCase.verifyEqual(without_derive_list(gui.collect_settings), without_derive_list(before), 'after the theme change');
testCase.verifyEqual(session_data(), data, 'data after the theme change');
testCase.verifyEqual(gui.retr('pathname'), folder, 'last folder after the theme change');
h = gui.gethand;
testCase.verifyEqual(get(h.fileselector,'Value'), 2, 'frame after the theme change');
testCase.verifyNotEmpty(findobj(gui.retr('pivlab_axis'),'Type','quiver'), 'vectors shown after the theme change');
shot(fullfile(tempdir, 'pivlab_after_theme_change.png'));
% the PIVlab window can still be used: analysis again
helper_gui_analyze();
rl = gui.retr('resultslist');
testCase.verifyEqual(rl{3,2}, data.resultslist{3,2});
s = helper_states();
f = fieldnames(states);
diff = {};
for k = 1:numel(f)
    % (the status boxes of the acquisition panel are 'inactive' after rebuilding, 'on' after the
    % start: both look and behave the same; the frame slider without images: enabled after the
    % start, disabled after rebuilding)
    if isfield(s, f{k}) && ~strcmp(s.(f{k}), states.(f{k})) && ~startsWith(f{k}, 'multip') ...
            && ~any(strcmp(f{k}, {'ac_msgbox','ac_laserstatus','ac_serialstatus','fileselector'}))
        diff{end+1} = sprintf('%s: %s -> %s', f{k}, states.(f{k}), s.(f{k})); %#ok<AGROW>
    end
end
testCase.verifyEmpty(diff, strjoin(diff, newline));
end

%% ================================================================== PIVlab leaves MATLAB and its folder as they were

function test_warnings_stay_switched_on(testCase)
% PIVlab must not switch the MATLAB warnings off (start, analysis, display, mask tools)
state = warning;
helper_start_pivlab();
helper_gui_load_images(helper_files('jet', 2));
helper_gui_analyze();
validate.apply_filter_all_Callback([],[],[]);
gui.sliderdisp(gui.retr('pivlab_axis')); drawnow;
% closed without helper_close_pivlab (that one would switch the warnings back on)
hgui = getappdata(0, 'hgui');
gui.put('batchModeActive', 1);
delete(hgui);
setappdata(0, 'hgui', []);
testCase.verifyEqual(warning, state, 'the PIVlab GUI changed the warning state of MATLAB');
end

function test_pivlab_folder_stays_unchanged(testCase)
% a complete GUI workflow (start, analyse, LIC, session, settings, close) writes nothing into
% the PIVlab folder (apart from the LIC MEX file compiled at the first LIC, if it was missing)
root = testCase.TestData.Root;
before = folder_listing(root);
helper_start_pivlab();
helper_gui_load_images(helper_files('jet', 2));
helper_gui_analyze();
validate.apply_filter_all_Callback([],[],[]);
h = gui.gethand;
plot.derivs_Callback([],[],[]);
set(h.derivchoice,'Value',2); plot.derivchoice_Callback(h.derivchoice);
plot.apply_deriv_all_Callback([],[],[]);
export.save_session_function(testCase.TestData.Dir, 'folder_test.mat');
mock_file(testCase.TestData.Dir, 'folder_settings.mat');
export.save_settings_Callback([],[],[]);
close_with_menu();
after = folder_listing(root);
new = setdiff(after, before);
new = new(~contains(new, 'fastLICFunction.'));
testCase.verifyEmpty(new, ['new files: ' strjoin(new, ', ')]);
end

%% ------------------------------------------------------------------ helpers

function S = without_derive_list(S)
% the list of derived parameters is filled when the data is shown again after rebuilding the
% controls (like after loading a session); before, it was still empty if the derive panel had
% not been opened. Only the stored text of the selected item differs, not a setting.
if isfield(S, 'popup_texts') && isfield(S.popup_texts, 'derivchoice')
    S.popup_texts = rmfield(S.popup_texts, 'derivchoice');
end
end

function close_with_menu()
% closing like the user (File -> Exit / window close): stores the last folder etc.
hgui = getappdata(0,'hgui');
gui.put('batchModeActive',1);
gui.MainWindow_CloseRequestFcn(hgui, []);
drawnow;
setappdata(0,'hgui',[]);
end

function set_temporary_matlab_theme(dark)
% MATLAB theme for this MATLAB session only (not stored in the MATLAB settings)
s = settings;
if dark
    s.matlab.appearance.MATLABTheme.TemporaryValue = 'Dark';
else
    s.matlab.appearance.MATLABTheme.TemporaryValue = 'Light';
end
end

function clear_temporary_matlab_theme()
s = settings;
if hasTemporaryValue(s.matlab.appearance.MATLABTheme)
    clearTemporaryValue(s.matlab.appearance.MATLABTheme);
end
end

function ok = wait_for(condition, seconds)
% true as soon as condition() is true; callbacks (ThemeChangedFcn, timers) run meanwhile
if nargin < 2, seconds = 10; end
t0 = tic;
ok = condition();
while ~ok && toc(t0) < seconds
    pause(0.2);
    ok = condition();
end
end

function c = zoom_icon(dark)
% zoom button icon as gui.generateUI makes it
load(fullfile('images','icons.mat'), 'zoompic');
c = zoompic;
if dark
    c = 1-c+35/255;
    c(c>1) = 1;
end
end

function L = folder_listing(root)
F = dir(fullfile(root, '**', '*'));
F = F(~[F.isdir]);
L = {};
for k = 1:numel(F)
    p = fullfile(F(k).folder, F(k).name);
    if contains(p, [filesep '.git' filesep]) || contains(p, [filesep 'unittests' filesep])
        continue
    end
    L{end+1} = p; %#ok<AGROW>
end
end

function w = default_panelwidth()
w = [];
txt = fileread(which('PIVlab_GUI.m'));
t = regexp(txt, 'panelwidth\s*=\s*(\d+)\s*;', 'tokens', 'once');
if ~isempty(t), w = str2double(t{1}); end
end

function D = session_data()
keys = gui.session_data_keys;
D = struct();
for k = 1:numel(keys)
    D.(keys{k}) = gui.retr(keys{k});
end
end

function shot(file)
hgui = getappdata(0,'hgui');
drawnow;
F = getframe(hgui);
imwrite(F.cdata, file);
end

function mock_file(p, f)
setappdata(0,'parity_mock_file',{p,f});
end
