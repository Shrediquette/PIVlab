function acquisition_lasertoggle_Callback(~,~,~)
handles=gui_NameSpace.gui_gethand;
serpo=gui_NameSpace.gui_retr('serpo');
laser_running = gui_NameSpace.gui_retr('laser_running');
if isempty(laser_running)
	laser_running=0;
end
try
	serpo.Port;
	alreadyconnected=1;
catch
	alreadyconnected=0;
end
if alreadyconnected
	pause(0.1)
	if laser_running %laser is on
		acquisition_NameSpace.acquisition_control_simple_sync_serial(0,0);
		laser_running=0;
	else %laser is off
		acquisition_NameSpace.acquisition_control_simple_sync_serial(1,0);
		laser_running=1;
	end
	gui_NameSpace.gui_put('laser_running',laser_running);
else
	acquisition_NameSpace.acquisition_no_dongle_msgbox
end
