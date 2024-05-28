function sync_settings_Callback(~,~,~)
serpo=gui.retr('serpo');
handles=gui.gethand;

if str2double(get(handles.ac_interpuls,'String')) < gui.retr('min_allowed_interframe')
	old_bg=get(handles.ac_interpuls,'BackgroundColor');
	for i=1:3
		set(handles.ac_interpuls,'BackgroundColor',[1 0 0]);
		pause(0.1)
		set(handles.ac_interpuls,'BackgroundColor',old_bg);
		pause(0.1)
	end
	set(handles.ac_interpuls,'String',num2str(gui.retr('min_allowed_interframe')))
end


if isnan(str2double(get(handles.ac_power,'String')))
	set(handles.ac_power,'String','0')
end
if str2double(get(handles.ac_power,'String')) > 100
	%camera_type=retr('camera_type');
	%if ~strcmp(camera_type,'chronos')
	set(handles.ac_power,'String','100')
	%end
end

%check that interpuls is not larger than frame period
selected_interpulse = str2double(get(handles.ac_interpuls,'String'));
selected_fps_value = get(handles.ac_fps,'Value');
selected_fps_string = get(handles.ac_fps,'String');
selected_fps=str2double(selected_fps_string{selected_fps_value});
selected_frame_period_us = 1/selected_fps*1000*1000;

if selected_interpulse > selected_frame_period_us
	old_bg=get(handles.ac_interpuls,'BackgroundColor');
	for i=1:3
		set(handles.ac_interpuls,'BackgroundColor',[1 0 0]);
		pause(0.1)
		set(handles.ac_interpuls,'BackgroundColor',old_bg);
		pause(0.1)
	end
	set(handles.ac_interpuls,'String',round(selected_frame_period_us))
end

try
	serpo.Port;
	alreadyconnected=1;
catch
	alreadyconnected=0;
end
if alreadyconnected
	laser_running=gui.retr('laser_running');
	if isempty(laser_running)
		laser_running=0;
	end
	acquisition.control_simple_sync_serial(laser_running,0);
end
acquisition.initiate_straddling_graph

