function calibrate_clear_cali_Callback(~, ~, ~)
handles=gui.gui_gethand;
gui.gui_put('pointscali',[]);
gui.gui_put('points_offsetx',[]);
gui.gui_put('points_offsety',[]);
gui.gui_put('calu',1);
gui.gui_put('calv',1);
gui.gui_put('calxy',1);
gui.gui_put('offset_x_true',0);
gui.gui_put('offset_y_true',0);
gui.gui_put('caliimg', []);
filepath=gui.gui_retr('filepath');
set(handles.calidisp, 'string', ['inactive'], 'backgroundcolor', [0.9411764705882353 0.9411764705882353 0.9411764705882353]);
delete(findobj('tag', 'caliline'));
set(handles.realdist, 'String','1');
set(handles.time_inp, 'String','1');
set(handles.x_axis_direction,'value',1);
set(handles.y_axis_direction,'value',1);
set(findobj(handles.uipanel_offsets,'Type','uicontrol'),'Enable','off')
calibrate.calibrate_pixeldist_changed_Callback
if size(filepath,1) >1 || gui.gui_retr('video_selection_done') == 1
	gui.gui_sliderdisp(gui.gui_retr('pivlab_axis'))
else
	gui.gui_displogo(0)
end

