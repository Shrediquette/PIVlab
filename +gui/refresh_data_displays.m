function refresh_data_displays(handles)
% Shows the session data in the controls that display it: the green calibration box, the
% reference distance, the ROI information, the velocity limits and the list of derived
% parameters. Used after loading a session and after the controls were rebuilt
% (gui.show_data_after_rebuild: Preferences -> Apply, theme change).
if nargin < 1
	handles = gui.gethand;
end
calxy=gui.retr('calxy'); calu=gui.retr('calu');
if ~isempty(gui.retr('pointscali'))
	calibrate.update_green_calibration_box(calxy, calu, gui.retr('offset_x_true'), gui.retr('offset_y_true'), handles)
end
calibrate.pixeldist_changed_Callback()
roirect=gui.retr('roirect');
if ~isempty(roirect)
	roi.updateROIinfo
end
if ~isempty(gui.retr('velrect')) || ~isempty(gui.retr('velrect_freehand'))
	try
		validate.update_velocity_limits_information
	catch
	end
end
plot.update_derivchoice_list(handles)
end
