function tests = test_gui_shortcuts
%TEST_GUI_SHORTCUTS The Ctrl+Shift keyboard shortcuts of the PIVlab window (gui.key_press).
%   Every shortcut must open the same panel as the menu entry whose label announces it, must not
%   get past the locks (busy, 2D mode) and must be the same set that the manual documents.
%   The expected panel comes from the menu LABEL, not from a list in this file: a key that is
%   wired to the wrong entry is then a failure as well.
%   NEVER send Ctrl+Shift+O (import stereo images) or Ctrl+Shift+H (web browser) as a key in a
%   test: O opens the file dialog, which PIVlabTestMode does not answer, and the run then waits
%   until someone clicks Cancel by hand. Both are checked through their target instead.
%   Run with: results = runtests('unittests/test_gui_shortcuts.m')
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
helper_setup_once(testCase);
end

function teardownOnce(testCase)
helper_teardown_once(testCase);
end

function setup(testCase)
testCase.TestData.hgui = helper_start_pivlab();
end

%% ---------------------------------------------------------------- behaviour

function test_key_opens_the_panel_of_its_menu_entry(testCase)
hgui = testCase.TestData.hgui;
helper_gui_load_images(helper_files('jet', 3), 1);
keys = documented_keys(testCase);
checked = 0;
for i = 1:numel(keys)
    k = keys{i};
    item = menu_with_shortcut(hgui, k);
    if isempty(item)
        continue % no menu entry: a control or the web link, see the tests below
    end
    if strcmp(k, 'h')
        continue % opens a web browser
    end
    gui.switchui('multip01'); drawnow;
    callback = get(item, 'Callback');
    feval(callback, item, []);
    drawnow;
    by_mouse = visible_panel(hgui);
    gui.switchui('multip01'); drawnow;
    gui.key_press([], key_event(k));
    drawnow;
    by_key = visible_panel(hgui);
    verifyNotEmpty(testCase, by_mouse, sprintf('Ctrl+Shift+%s: the menu entry opens no panel', upper(k)));
    verifyEqual(testCase, by_key, by_mouse, sprintf( ...
        'Ctrl+Shift+%s: the menu entry opens "%s", the key opens "%s"', upper(k), by_mouse, by_key));
    checked = checked + 1;
end
verifyGreaterThan(testCase, checked, 15, 'far fewer panel shortcuts than expected');
end

function test_shortcut_is_ignored_while_busy(testCase)
hgui = testCase.TestData.hgui;
gui.switchui('multip01'); drawnow;
gui.toolsavailable(0, 'test_gui_shortcuts');
gui.key_press([], key_event('a'));
drawnow;
still_there = visible_panel(hgui);
gui.toolsavailable(1);
drawnow;
verifyEqual(testCase, still_there, 'multip01', 'a shortcut got past the busy lock');
% and works again afterwards
gui.key_press([], key_event('a'));
drawnow;
verifyNotEqual(testCase, visible_panel(hgui), 'multip01', 'shortcuts dead after the busy lock');
end

function test_other_modifiers_do_nothing(testCase)
hgui = testCase.TestData.hgui;
events = {struct('Modifier', {{'control'}}, 'Key', 'a'), ...
          struct('Modifier', {{'shift'}}, 'Key', 'a'), ...
          struct('Modifier', {{}}, 'Key', 'a'), ...
          struct('Modifier', {{'alt', 'control'}}, 'Key', 'a')};
for i = 1:numel(events)
    gui.switchui('multip01'); drawnow;
    gui.key_press([], events{i});
    drawnow;
    verifyEqual(testCase, visible_panel(hgui), 'multip01', ...
        'a key without Ctrl+Shift triggered a shortcut');
end
end

function test_camera_keys_do_nothing_in_2d(testCase)
% The two camera keys need stereo mode. Ctrl+Shift+O is NOT tested here: it is reachable in 2D
% on purpose (it is how a stereo session starts) and opens the file dialog, which PIVlabTestMode
% does not answer - pressing it in a test blocks the run until someone clicks Cancel.
hgui = testCase.TestData.hgui;
helper_gui_load_images(helper_files('jet', 2), 1);
gui.switchui('multip01'); drawnow;
keys = {'1', '2'};
for i = 1:numel(keys)
    gui.key_press([], key_event(keys{i}));
    drawnow;
    verifyEqual(testCase, visible_panel(hgui), 'multip01', sprintf( ...
        'Ctrl+Shift+%s did something outside stereo mode', upper(keys{i})));
end
verifyFalse(testCase, isequal(gui.retr('stereomode'), 1), 'stereo mode switched on by a key');
verifyNotEqual(testCase, gui.retr('stereo_active_camera'), 2, 'camera 2 selected outside stereo mode');
end

function test_stereo_import_is_reachable_in_2d(testCase)
% Ctrl+Shift+O must work before stereo mode exists, otherwise a stereo session cannot be started.
% Only the target of the shortcut is checked (see the note in the test above).
hgui = testCase.TestData.hgui;
helper_gui_load_images(helper_files('jet', 2), 1);
h = findall(hgui, 'Tag', 'stereo_import');
verifyNotEmpty(testCase, h, 'the "Import stereo images" control is gone');
verifyEqual(testCase, char(get(h(1), 'Visible')), 'on', 'Ctrl+Shift+O has no visible target in 2D mode');
verifyEqual(testCase, char(get(h(1), 'Enable')), 'on', 'Ctrl+Shift+O has no enabled target in 2D mode');
verifyNotEmpty(testCase, get(h(1), 'Callback'));
end

function test_camera_switch_keys(testCase)
enter_stereo_mode();
verifyTrue(testCase, isequal(gui.retr('stereomode'), 1), 'stereo mode not active');
stereo.switch_camera(1); drawnow;

gui.key_press([], key_event('2')); drawnow;
verifyEqual(testCase, gui.retr('stereo_active_camera'), 2, 'Ctrl+Shift+2 did not select camera 2');
gui.key_press([], key_event('1')); drawnow;
verifyEqual(testCase, gui.retr('stereo_active_camera'), 1, 'Ctrl+Shift+1 did not select camera 1');
% the key of the camera that is already active changes nothing
gui.key_press([], key_event('1')); drawnow;
verifyEqual(testCase, gui.retr('stereo_active_camera'), 1);

% the CAM button of the Tools panel and the keys must agree
stereo.switch_camera(1); drawnow;
stereo.camera_toggle_Callback([], [], []); drawnow;
by_button = gui.retr('stereo_active_camera');
stereo.switch_camera(1); drawnow;
gui.key_press([], key_event('2')); drawnow;
verifyEqual(testCase, gui.retr('stereo_active_camera'), by_button, ...
    'CAM button and Ctrl+Shift+2 end on different cameras');

% the busy lock also holds for the camera keys
stereo.switch_camera(1); drawnow;
gui.toolsavailable(0, 'test_gui_shortcuts');
gui.key_press([], key_event('2'));
drawnow;
active_while_busy = gui.retr('stereo_active_camera');
gui.toolsavailable(1); drawnow;
verifyEqual(testCase, active_while_busy, 1, 'camera switched while PIVlab was busy');
end

%% ------------------------------------------------------- code stays in sync

function test_no_ctrl_only_accelerators(testCase)
% Matlab's Accelerator can only do Ctrl+key, which collides with the operating system and with
% the text fields. All shortcuts belong in gui.key_press.
src = fileread(fullfile(testCase.TestData.Root, '+gui', 'generateMenu.m'));
src = erase_comments(src);
verifyEmpty(testCase, regexp(src, 'Accelerator', 'once'), ...
    'generateMenu.m uses Accelerator again - the shortcuts belong in gui.key_press');
end

function test_every_announced_key_is_handled(testCase)
% a menu label that announces a shortcut must have a case in gui.key_press
hgui = testCase.TestData.hgui;
handled = documented_keys(testCase);
items = findall(hgui, 'Type', 'uimenu');
announced = 0;
for i = 1:numel(items)
    label = get(items(i), 'Label');
    token = regexp(label, '\(Ctrl\+Shift\+(\w)\)', 'tokens', 'once');
    if isempty(token)
        continue
    end
    announced = announced + 1;
    k = lower(token{1});
    verifyTrue(testCase, any(strcmp(handled, k)), sprintf( ...
        'the menu promises Ctrl+Shift+%s ("%s") but gui.key_press has no case for it', ...
        upper(k), strtrim(label)));
end
verifyGreaterThan(testCase, announced, 15, 'the menu labels no longer announce the shortcuts');
end

function test_every_handled_key_is_reachable(testCase)
% every case of gui.key_press must have a menu entry announcing it or a control it drives
hgui = testCase.TestData.hgui;
by_control = {'o', '1', '2'}; % stereo_import, stereo_camera_toggle
keys = documented_keys(testCase);
for i = 1:numel(keys)
    k = keys{i};
    if any(strcmp(by_control, k))
        continue
    end
    verifyNotEmpty(testCase, menu_with_shortcut(hgui, k), sprintf( ...
        'gui.key_press handles Ctrl+Shift+%s but no menu label announces it', upper(k)));
end
end

function test_manual_lists_exactly_the_handled_keys(testCase)
page = fullfile(testCase.TestData.Root, 'docs', 'manual', 'pages', 'shortcuts.html');
assumeTrue(testCase, isfile(page), 'manual page not in this copy of PIVlab');
html = fileread(page);
found = regexp(html, '<kbd>Ctrl</kbd>\+<kbd>Shift</kbd>\+<kbd>(\w)</kbd>', 'tokens');
documented = cell(numel(found), 1);
for i = 1:numel(found)
    documented{i} = lower(found{i}{1});
end
documented = unique(documented);
handled = unique(documented_keys(testCase));
% both lists are parsed: if a parser silently found nothing, the comparison below would pass
verifyGreaterThan(testCase, numel(documented), 15, 'no shortcut tables found in the manual page');
verifyEqual(testCase, documented, handled, ...
    'docs/manual/pages/shortcuts.html and gui.key_press list different shortcuts');
end

function test_learn_menu_opens_the_manual_page(testCase)
hgui = testCase.TestData.hgui;
entry = [];
items = findall(hgui, 'Type', 'uimenu');
for i = 1:numel(items)
    if strcmp(get(items(i), 'Label'), 'List keyboard shortcuts')
        entry = items(i);
    end
end
verifyNotEmpty(testCase, entry, 'the "List keyboard shortcuts" entry is gone');
callback = get(entry, 'Callback');
verifyClass(testCase, callback, 'function_handle');
name = strrep(func2str(callback), '@', '');
verifyEqual(testCase, name, 'gui.shortcuts_Callback');
verifyNotEmpty(testCase, which('gui.shortcuts_Callback'), 'gui.shortcuts_Callback is not on the path');
% it must point at the shortcut page of the manual, not at a file that can go stale
src = fileread(fullfile(testCase.TestData.Root, '+gui', 'shortcuts_Callback.m'));
verifyNotEmpty(testCase, regexp(src, 'manual/pages/shortcuts\.html', 'once'), ...
    'the menu entry no longer opens the shortcut page of the manual');
end

%% ------------------------------------------------------------------ helpers

function e = key_event(k)
e = struct('Modifier', {{'shift', 'control'}}, 'Key', k);
end

function keys = documented_keys(testCase)
%The keys of the documented block of gui.key_press (the hidden display helpers below it are
%deliberately not part of the manual).
src = fileread(fullfile(testCase.TestData.Root, '+gui', 'key_press.m'));
first = strfind(src, '%% Documented shortcuts');
last = strfind(src, '%% Hidden display helpers');
assert(~isempty(first) && ~isempty(last) && last(1) > first(1), ...
    'the section markers of gui.key_press are gone - update test_gui_shortcuts');
block = src(first(1):last(1));
found = regexp(block, 'case\s+''(\w)''', 'tokens');
keys = cell(numel(found), 1);
for i = 1:numel(found)
    keys{i} = found{i}{1};
end
end

function item = menu_with_shortcut(hgui, k)
item = [];
wanted = ['(Ctrl+Shift+' upper(k) ')'];
items = findall(hgui, 'Type', 'uimenu');
for i = 1:numel(items)
    if contains(get(items(i), 'Label'), wanted)
        item = items(i);
        return
    end
end
end

function p = visible_panel(hgui)
p = '';
panels = findall(hgui, '-regexp', 'Tag', '^multip\d', 'Visible', 'on');
if ~isempty(panels)
    p = get(panels(1), 'Tag');
end
end

function enter_stereo_mode()
%The jet images are used for both cameras: the camera switch does not need a calibration, and
%this is much faster than a synthetic stereo case.
f = helper_files('jet', 2);
gui.put('sequencer', 1);
import.stereo_import_Callback([], [], {f, f});
drawnow;
end

function out = erase_comments(src)
%Comment lines of a Matlab file (so that a word in a comment is not taken for code).
lines = splitlines(string(src));
keep = strings(0, 1);
for i = 1:numel(lines)
    if ~startsWith(strtrim(lines(i)), '%')
        keep(end+1, 1) = lines(i); %#ok<AGROW>
    end
end
out = char(strjoin(keep, newline));
end
