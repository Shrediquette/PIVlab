function clear_cali_Callback(~, ~, ~)
handles=gui.gethand;
gui.put('pointscali',[]);
gui.put('points_offsetx',[]);
gui.put('points_offsety',[]);
gui.put('calu',1);
gui.put('calv',1);
gui.put('calxy',1);
gui.put('offset_x_true',0);
gui.put('offset_y_true',0);
gui.put('caliimg', []);
filepath=gui.retr('filepath');
set(handles.calidisp, 'string', ['inactive'], 'backgroundcolor', [0.9411764705882353 0.9411764705882353 0.9411764705882353]);
delete(findobj('tag', 'caliline'));
set(handles.realdist, 'String','1');
set(handles.time_inp, 'String','1');
set(handles.x_axis_direction,'value',1);
set(handles.y_axis_direction,'value',1);
set(findobj(handles.uipanel_offsets,'Type','uicontrol'),'Enable','off')
calibrate.pixeldist_changed_Callback
if size(filepath,1) >1 || gui.retr('video_selection_done') == 1
	gui.sliderdisp(gui.retr('pivlab_axis'))
else
	gui.displogo(0)
end

