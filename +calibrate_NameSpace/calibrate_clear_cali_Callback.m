function calibrate_clear_cali_Callback(~, ~, ~)
handles=gui_NameSpace.gui_gethand;
gui_NameSpace.gui_put('pointscali',[]);
gui_NameSpace.gui_put('points_offsetx',[]);
gui_NameSpace.gui_put('points_offsety',[]);
gui_NameSpace.gui_put('calu',1);
gui_NameSpace.gui_put('calv',1);
gui_NameSpace.gui_put('calxy',1);
gui_NameSpace.gui_put('offset_x_true',0);
gui_NameSpace.gui_put('offset_y_true',0);
gui_NameSpace.gui_put('caliimg', []);
filepath=gui_NameSpace.gui_retr('filepath');
set(handles.calidisp, 'string', ['inactive'], 'backgroundcolor', [0.9411764705882353 0.9411764705882353 0.9411764705882353]);
delete(findobj('tag', 'caliline'));
set(handles.realdist, 'String','1');
set(handles.time_inp, 'String','1');
set(handles.x_axis_direction,'value',1);
set(handles.y_axis_direction,'value',1);
set(findobj(handles.uipanel_offsets,'Type','uicontrol'),'Enable','off')
calibrate_NameSpace.calibrate_pixeldist_changed_Callback
if size(filepath,1) >1 || gui_NameSpace.gui_retr('video_selection_done') == 1
	gui_NameSpace.gui_sliderdisp(gui_NameSpace.gui_retr('pivlab_axis'))
else
	gui_NameSpace.gui_displogo(0)
end
