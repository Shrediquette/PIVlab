function gui_MainWindow_CloseRequestFcn(hObject, ~, ~)
handles=gui.gui_gethand;
batchModeActive=gui.gui_retr('batchModeActive');
if batchModeActive == 0
	button = questdlg('Do you want to quit PIVlab?','Quit?','Yes','Cancel','Cancel');
else
	button = 'Yes';
end
try
	gui.gui_toolsavailable(1)
catch
end
if strcmp(button,'Yes')==1
	try
		homedir=gui.gui_retr('homedir');
		pathname=gui.gui_retr('pathname');
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
		
		hgui = getappdata(0,'hgui');
		serpo=getappdata(hgui,'serpo');
		string3='WarningSignDisable!';
		pause(1)
		writeline(serpo,string3); %disable the lighting of the laser warning sign
		pause(0.5)
	catch
	end
	try
		delete(hObject);
	catch
		close(gcf,'force');
	end
end

