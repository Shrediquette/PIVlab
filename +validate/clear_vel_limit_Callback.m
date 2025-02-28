function clear_vel_limit_Callback(~, ~, ~)
gui.put('velrect', []);
handles=gui.gethand;
if gui.retr('darkmode')
	bg_col=[35/255 35/255 35/255];
else
	bg_col=[0.9411764705882353 0.9411764705882353 0.9411764705882353];
end
set (handles.vel_limit_active, 'String', 'Limit inactive', 'backgroundcolor', bg_col);
set (handles.limittext, 'String', '');
set (handles.vel_limit, 'String', 'Select rectangle');
delete(findobj('tag', 'vel_limit_ROI'))