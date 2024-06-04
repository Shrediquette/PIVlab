function lasertoggle_Callback(~,~,~)
handles=gui.gethand;
serpo=gui.retr('serpo');
laser_running = gui.retr('laser_running');
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
		acquisition.control_simple_sync_serial(0,0);
		laser_running=0;
	else %laser is off
		acquisition.control_simple_sync_serial(1,0);
		laser_running=1;
	end
	gui.put('laser_running',laser_running);
else
	acquisition.no_dongle_msgbox
end

