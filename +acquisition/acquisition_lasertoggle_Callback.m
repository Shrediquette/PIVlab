function acquisition_lasertoggle_Callback(~,~,~)
handles=gui.gui_gethand;
serpo=gui.gui_retr('serpo');
laser_running = gui.gui_retr('laser_running');
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
		acquisition.acquisition_control_simple_sync_serial(0,0);
		laser_running=0;
	else %laser is off
		acquisition.acquisition_control_simple_sync_serial(1,0);
		laser_running=1;
	end
	gui.gui_put('laser_running',laser_running);
else
	acquisition.acquisition_no_dongle_msgbox
end

