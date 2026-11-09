function tests = test_gui_busy_menus
%TEST_GUI_BUSY_MENUS gui.toolsavailable also locks the menu bar while PIVlab is busy, and afterwards
%   enables exactly the entries it disabled (Basic/Advanced mode, context menus and entries that were
%   disabled before stay as they are).
%   Run with: results = runtests('unittests/test_gui_busy_menus.m')
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

function test_lock_and_unlock(testCase)
items = menu_items(testCase.TestData.hgui);
verifyGreaterThan(testCase, numel(items), 50, 'menu bar not found');
verify_enabled(testCase, items, 'on', 'menus not enabled after the start');
gui.toolsavailable(0);
verify_enabled(testCase, items, 'off', 'menu entry still enabled while busy');
gui.toolsavailable(1);
verify_enabled(testCase, items, 'on', 'menu entry not enabled again');
verify_no_marks(testCase, items);
end

function test_nested_lock(testCase)
items = menu_items(testCase.TestData.hgui);
gui.toolsavailable(0, 'first');
gui.toolsavailable(0, 'second');
gui.toolsavailable(1);
verify_enabled(testCase, items, 'on', 'menu entry stays locked after a nested lock');
verify_no_marks(testCase, items);
end

function test_disabled_entry_stays_disabled(testCase)
hgui = testCase.TestData.hgui;
m = findall(hgui, 'Type', 'uimenu', 'Tag', 'menu_statistics');
verifyNumElements(testCase, m, 1);
m.Enable = 'off';
gui.toolsavailable(0);
gui.toolsavailable(1);
verifyEqual(testCase, char(m.Enable), 'off', 'entry that was disabled before got enabled');
items = menu_items(hgui);
verify_enabled(testCase, items(items ~= m), 'on', 'menu entry not enabled again');
end

function test_basic_mode(testCase)
hgui = testCase.TestData.hgui;
hidden = findall(hgui, 'Tag', 'menu_partgen');
gui.apply_ui_mode('basic');
gui.toolsavailable(0);
gui.toolsavailable(1);
verifyEqual(testCase, char(hidden.Visible), 'off', 'Basic mode menu visible again');
verifyEqual(testCase, char(findall(hgui, 'Tag', 'menu_mode_basic').Checked), 'on');
verify_enabled(testCase, menu_items(hgui), 'on', 'menu entry not enabled again');
% mode switch while busy (as in the reset of PIVlab)
gui.toolsavailable(0);
gui.apply_ui_mode('advanced');
verifyEqual(testCase, char(hidden.Visible), 'on', 'Advanced mode menu not visible');
gui.toolsavailable(1);
verify_enabled(testCase, menu_items(hgui), 'on', 'menu entry not enabled again');
gui.toolsavailable(0);
gui.apply_ui_mode('basic');
gui.toolsavailable(1);
verifyEqual(testCase, char(hidden.Visible), 'off');
verify_enabled(testCase, menu_items(hgui), 'on', 'menu entry not enabled again');
gui.apply_ui_mode('advanced');
end

function test_context_menus_untouched(testCase)
hgui = testCase.TestData.hgui;
c = uicontextmenu(hgui);
testCase.addTeardown(@() delete(c));
on = uimenu(c, 'Label', 'on');
off = uimenu(c, 'Label', 'off', 'Enable', 'off');
gui.toolsavailable(0);
verifyEqual(testCase, char(on.Enable), 'on', 'context menu disabled');
gui.toolsavailable(1);
verifyEqual(testCase, char(on.Enable), 'on');
verifyEqual(testCase, char(off.Enable), 'off', 'context menu enabled');
end

function test_unlock_button_and_reset(testCase)
hgui = testCase.TestData.hgui;
items = menu_items(hgui);
gui.toolsavailable(0);
gui.busy_unlock_Callback();
verify_enabled(testCase, items, 'on', '"Unlock controls" leaves menus locked');
gui.reset_gui_Callback([], [], false);
verify_enabled(testCase, menu_items(hgui), 'on', 'menu entry locked after the reset');
verify_no_marks(testCase, menu_items(hgui));
end

function items = menu_items(hgui)
items = findall(findall(hgui, '-depth', 1, 'Type', 'uimenu'), 'Type', 'uimenu');
end

function verify_enabled(testCase, items, state, msg)
for k = 1:numel(items)
    verifyEqual(testCase, char(items(k).Enable), state, sprintf('%s: "%s"', msg, items(k).Text));
end
end

function verify_no_marks(testCase, items)
marked = arrayfun(@(m) isappdata(m, 'disabled_while_busy'), items);
verifyFalse(testCase, any(marked), 'menu entries still marked as disabled while busy');
end
