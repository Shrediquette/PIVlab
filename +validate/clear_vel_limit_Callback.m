function clear_vel_limit_Callback(~, action, ~)
handles=gui.gethand;
if gui.retr('darkmode')
	bg_col=[35/255 35/255 35/255];
else
	bg_col=[0.9411764705882353 0.9411764705882353 0.9411764705882353];
end
if strcmpi(action,'rectangle_delete')
	gui.put('velrect', []);
	delete(findobj('tag', 'vel_limit_ROI'))
elseif strcmpi(action,'freehand_delete')
	gui.put('velrect_freehand', []);
	delete(findobj('tag', 'vel_limit_ROI_freehand'))
else %called from PIVlab Mainwindow, request to delete velocity limits
	gui.put('velrect', []);
	gui.put('velrect_freehand', []);
	set (handles.vel_limit_active, 'String', 'Limit inactive', 'backgroundcolor', bg_col);
	set (handles.limittext, 'String', '');
	delete(findobj('tag', 'vel_limit_ROI'))
	delete(findobj('tag', 'vel_limit_ROI_freehand'))
end
validate.update_velocity_limits_information
close(findobj('Tag', 'limit_figure'))
