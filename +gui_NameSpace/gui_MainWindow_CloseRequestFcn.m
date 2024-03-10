function gui_MainWindow_CloseRequestFcn(hObject, ~, ~)
handles=gui_NameSpace.gui_gethand;
batchModeActive=gui_NameSpace.gui_retr('batchModeActive');
if batchModeActive == 0
	button = questdlg('Do you want to quit PIVlab?','Quit?','Yes','Cancel','Cancel');
else
	button = 'Yes';
end
try
	gui_NameSpace.gui_toolsavailable(1)
catch
end
if strcmp(button,'Yes')==1
	try
		homedir=gui_NameSpace.gui_retr('homedir');
		pathname=gui_NameSpace.gui_retr('pathname');
		save('PIVlab_settings_default.mat','homedir','pathname','-append');
		last_selected_device = get(handles.ac_config, 'value');
		save('PIVlab_settings_default.mat','last_selected_device','-append');
	catch
	end
	try
		PIVlab_capture_lensctrl (1400,1400,0) %lens needs to be set to neutral otherwise re-enabling power might cause issues
	catch
	end
	try
		delete(hObject);
	catch
		delete(gcf,'force');
	end
end
