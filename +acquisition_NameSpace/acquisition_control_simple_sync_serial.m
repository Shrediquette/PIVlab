function serial_answer = acquisition_control_simple_sync_serial(switch_it,calibration_pulse)
%first argument 0 = turn synchronized laser diode off
%first argument 1 = turn synchronized laser diode on
%second argument 0 = don't care about calibration camera signal
%second argument 1 = turn calibration camera signal on
%second argument 2 = turn calibration camera signal off
try %try to switch of camera angle report
	stop(timerfind)
	delete(timerfind)
	set(getappdata(0,'handle_to_lens_timer_checkbox'),'Value',0)
catch
end
handles=gui_NameSpace.gui_gethand;
serpo=gui_NameSpace.gui_retr('serpo');
try
	serpo.Port;
	alreadyconnected=1;
catch ME
	alreadyconnected=0;
	disp('hier ist serialport deleted nach dem ersten erfolgreichen aufzeichnen')
end
if alreadyconnected
	%Master frequency in Hz
	master_freq =gui_NameSpace.gui_retr('master_freq'); %will depend on the laser system (frequency with best beam quality)
	%frame 1 exposure time incl. readout time in µs
	f1exp = gui_NameSpace.gui_retr('f1exp'); % will depend on camera model
	%External trigger input settings
	if get(handles.ac_enable_ext_trigger,'Value') == 0
		extdly = -1; % external trigger input delay. -1 disables external trigger
		extskp = 0; %external trigger amount of signals to skip.
	else
		extdly = gui_NameSpace.gui_retr('selectedtriggerdelay'); % external trigger input delay. -1 disables external trigger
		extskp = gui_NameSpace.gui_retr('selectedtriggerskip'); %external trigger amount of signals to skip.
	end
	%Camera fps
	ac_fps_value=get(handles.ac_fps,'Value');
	ac_fps_str=get(handles.ac_fps,'String');
	cam_prescaler=round(master_freq/str2double(ac_fps_str(ac_fps_value)));

	%Laser power
	las_percent=str2double(get(handles.ac_power,'String'));
	%specific laser power polynom for converting Q-switch delay to laser energy
	load q_delay_to_laser_power_polynom.mat %loads q and min_energy
	energy_us = round(polyval(p,las_percent));
	if energy_us > min_energy
		energy_us = min_energy;
	end
	%Pulse distance
	pulse_sep=str2double(get(handles.ac_interpuls,'String'));
	laser_device_id=gui_NameSpace.gui_retr('laser_device_id');

	%potential bug fixes go here:
	bugfix_factor=1;
	try
		if strncmp(laser_device_id,'LDPS_BAS1',12)
			disp('Bug fix for LDPS_BAS1 activated');
			bugfix_factor=2;
		end
	catch
		bugfix_factor=1;
	end

	if switch_it==1
		flush(serpo)
		camera_type=gui_NameSpace.gui_retr('camera_type');
		if strcmp(camera_type,'pco_panda') || strcmp(camera_type,'pco_pixelfly')
			send_string=['TALKINGTO:' laser_device_id ';FREQ:' int2str(master_freq) ';CAM:' int2str(cam_prescaler) ';ENER:' int2str(energy_us) ';ener%:' int2str(las_percent) ';F1EXP:' int2str(f1exp) ';INTERF:' int2str(pulse_sep) ';EXTDLY:' int2str(extdly) ';EXTSKP:' int2str(extskp) ';LASER:enable'];
		else
			send_string=['TALKINGTO:' laser_device_id ';FREQ:' int2str(str2double(ac_fps_str(ac_fps_value))*bugfix_factor) ';CAM:' int2str(0) ';ENER:' int2str(0) ';ener%:' int2str(las_percent) ';F1EXP:' int2str(0) ';INTERF:' int2str(round(pulse_sep/bugfix_factor)) ';EXTDLY:' int2str(0) ';EXTSKP:' int2str(0) ';LASER:enable'];
		end
		writeline(serpo,send_string);
	else
		flush(serpo)
		%configureTerminator(serpo,'CR');
		send_string=['TALKINGTO:' laser_device_id ';FREQ:1;CAM:1;ENER:' int2str(min_energy) ';ener%:0;F1EXP:100;INTERF:1234;EXTDLY:-1;EXTSKP:0;LASER:disable'];
		writeline(serpo,send_string);
		%writeline(serpo,'FREQ:5;EXPO:300;CAMDLY:835;LDPULS:300;INTERF:500;LASER:disable');
		%disp('testing laserdiode')
	end
	pause(0.1)
	warning off
	serial_answer = acquisition_NameSpace.acquisition_process_sync_reply(serpo);
	if calibration_pulse ~= 0 %this is needed for the OPTRONIS cameras, they cannot be configured to free run internal trigger
		camera_type=gui_NameSpace.gui_retr('camera_type');
		if strcmp(camera_type,'OPTRONIS')
			if calibration_pulse ==1
				writeline(serpo,'CAMERA_FREERUN_ON!');
			elseif calibration_pulse ==2
				writeline(serpo,'CAMERA_FREERUN_OFF!');
			end
		end
	end
	%% debug messages
	%{
	disp('---------')
	disp(['Terminator set to: ' serpo.Terminator])
	disp(['String written: ' send_string])
	disp(['Answer: ' convertStringsToChars(serial_answer)])
	disp('---------')
	%}
else
	acquisition_NameSpace.acquisition_no_dongle_msgbox
end
