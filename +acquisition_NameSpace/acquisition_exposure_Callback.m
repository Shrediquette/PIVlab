function acquisition_exposure_Callback(~,~,~)
handles=gui_NameSpace.gui_gethand;
camera_type=gui_NameSpace.gui_retr('camera_type');
if strcmp(camera_type,'pco_pixelfly')
	if str2double(get(handles.ac_expo,'String')) < 1
		set(handles.ac_expo,'String','1')
	end
	if str2double(get(handles.ac_expo,'String')) > 2000
		set(handles.ac_expo,'String','2000')
	end
end
if strcmp(camera_type,'pco_panda')
	if str2double(get(handles.ac_expo,'String')) < 6
		set(handles.ac_expo,'String','6')
	end
	if str2double(get(handles.ac_expo,'String')) > 350
		set(handles.ac_expo,'String','350')
	end
end
if strcmp(camera_type,'chronos')
	if str2double(get(handles.ac_expo,'String')) < 0.1
		set(handles.ac_expo,'String','0.1')
	end
	if str2double(get(handles.ac_expo,'String')) > 1000
		set(handles.ac_expo,'String','10000')
	end
end
if strcmp(camera_type,'basler')
	if str2double(get(handles.ac_expo,'String')) < 0.05
		set(handles.ac_expo,'String','0.05')
	end
	if str2double(get(handles.ac_expo,'String')) > 1000
		set(handles.ac_expo,'String','1000')
	end
end
if strcmp(camera_type,'flir')
	if str2double(get(handles.ac_expo,'String')) < 0.02
		set(handles.ac_expo,'String','0.02')
	end
	if str2double(get(handles.ac_expo,'String')) > 25
		set(handles.ac_expo,'String','25')
	end
end
