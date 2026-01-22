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

	if strcmp(camera_type,'pco_panda') || strcmp(camera_type,'pco_pixelfly') || strcmp(camera_type,'pco_edge26')
		is_dbl_shutter = 1;
	else
		is_dbl_shutter = 0;
	end
	pco_first_frame_exposure = floor(str2double(get(handles.ac_interpuls,'String'))*str2double(get(handles.ac_power,'String'))/100)+1;
	if strcmpi(gui.retr('sync_type'),'xmSync')
		acquisition.straddling_graph_xmsync(blind_time,selected_fps,str2double(get(handles.ac_interpuls,'String')),str2double(get(handles.ac_power,'String')),4,is_dbl_shutter,pco_first_frame_exposure)
	elseif isempty(gui.retr('sync_type'))
		acquisition.straddling_graph_xmsync(blind_time,selected_fps,str2double(get(handles.ac_interpuls,'String')),str2double(get(handles.ac_power,'String')),4,is_dbl_shutter,pco_first_frame_exposure)
	elseif strcmpi(gui.retr('sync_type'),'oltSync')
		%calculate pulse timing
		pulse_sep=str2double(get(handles.ac_interpuls,'String'));
		camera_sub_type=gui.retr('camera_sub_type');
		camera_type=gui.retr('camera_type');
			bitmode =gui.retr('OPTOcam_bits');
			ac_fps_value=get(handles.ac_fps,'Value');
			ac_fps_str=get(handles.ac_fps,'String');
			framerate=str2double(ac_fps_str(ac_fps_value));
			f1exp_cam=gui.retr('f1exp_cam');
			las_percent=str2double(get(handles.ac_power,'String'));
			if strcmp(camera_type,'pco_pixelfly') || strcmp(camera_type,'pco_panda') || strcmp(camera_type,'pco_edge26')
				camera_principle='double_shutter';
			else
				camera_principle='normal_shutter';
			end
			[timing_table, ~, cam_delay,frame_time] = PIVlab_calc_oltsync_timings(camera_type,camera_sub_type,bitmode,framerate,f1exp_cam,pulse_sep,las_percent);


	acquisition.straddling_graph_oltsync(timing_table,frame_time,cam_delay,camera_principle,camera_type);
	end
else
	straddling_figure=findobj('tag','straddling_figure');
	if ~isempty(straddling_figure)
		close(straddling_figure)
	end
end

