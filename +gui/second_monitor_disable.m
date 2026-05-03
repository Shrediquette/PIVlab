function second_monitor_disable
% Restore pivlab_axis to the original axis, clean up second-monitor state,
% update the menu item check mark, and delete the second figure.
% Safe to call even when the second monitor is not active.

second_monitor_fig = gui.retr('second_monitor_fig');

% Restore original axis
original_pivlab_axis = gui.retr('original_pivlab_axis');
if ~isempty(original_pivlab_axis) && isvalid(original_pivlab_axis)
	gui.put('pivlab_axis', original_pivlab_axis);
end

% Clear state keys
gui.put('original_pivlab_axis', []);
gui.put('second_monitor_fig',   []);
gui.put('second_monitor_axis',  []);

% Uncheck menu item
try
	menu_item = findall(getappdata(0,'hgui'), 'Type', 'uimenu', 'Tag', '2ndmonitor');
	if ~isempty(menu_item)
		set(menu_item, 'Checked', 'off');
	end
catch
end

% Delete the figure (safe even if already deleted)
if ~isempty(second_monitor_fig) && isvalid(second_monitor_fig)
	delete(second_monitor_fig);
end

% Re-render the main axis
try
	gui.sliderdisp(gui.retr('pivlab_axis'));
catch
end
