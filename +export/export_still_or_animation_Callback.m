function export_still_or_animation_Callback(~,~,~)
handles=gui.gui_gethand;
str=get(handles.export_still_or_animation,'String');
value=get(handles.export_still_or_animation,'Value');
selected_format=str{value};

switch selected_format
	case 'PNG'
		set(handles.quality_setting,'Enable','Off')
		set(handles.fps_setting,'Enable','Off')
		set(handles.resolution_setting,'Enable','On')
	case 'JPG'
		set(handles.quality_setting,'Enable','Off')
		set(handles.fps_setting,'Enable','Off')
		set(handles.resolution_setting,'Enable','On')
	case 'PDF'
		set(handles.quality_setting,'Enable','Off')
		set(handles.fps_setting,'Enable','Off')
		set(handles.resolution_setting,'Enable','On')
	case 'Archival AVI'
		set(handles.quality_setting,'Enable','Off')
		set(handles.fps_setting,'Enable','On')
		set(handles.resolution_setting,'Enable','Off')
	case 'MPEG-4'
		set(handles.quality_setting,'Enable','On')
		set(handles.fps_setting,'Enable','On')
		set(handles.resolution_setting,'Enable','Off')
end

