function initiate_straddling_graph
handles=gui.gethand;
selected_fps_value = get(handles.ac_fps,'Value');
selected_fps_string = get(handles.ac_fps,'String');
selected_fps=str2double(selected_fps_string{selected_fps_value});
if get(handles.ac_enable_straddling_figure, 'Value')==1
	blind_time=gui.retr('blind_time');
	if isempty(blind_time)
		blind_time=1;
	end
	camera_type=gui.retr('camera_type');

	if strcmp(camera_type,'pco_panda') || strcmp(camera_type,'pco_pixelfly')
		is_dbl_shutter = 1;
	else
		is_dbl_shutter = 0;
	end
	pco_first_frame_exposure = floor(str2double(get(handles.ac_interpuls,'String'))*str2double(get(handles.ac_power,'String'))/100)+1;
	straddling_graph(blind_time,selected_fps,str2double(get(handles.ac_interpuls,'String')),str2double(get(handles.ac_power,'String')),4,is_dbl_shutter,pco_first_frame_exposure)
else
	straddling_figure=findobj('tag','straddling_figure');
	if ~isempty(straddling_figure)
		close(straddling_figure)
	end
end

