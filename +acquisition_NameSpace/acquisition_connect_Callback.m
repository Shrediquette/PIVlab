function acquisition_connect_Callback (~,~,~)
handles=gui_NameSpace.gui_gethand;
set(handles.ac_serialstatus,'Backgroundcolor',[1 0 0]);
if strcmp(get(handles.ac_comport,'String'),'No available serial ports found!')
	acquisition_NameSpace.acquisition_capture_images_Callback; %will also refresh the comport list
else
	try
		delete(gui_NameSpace.gui_retr('serpo')); %delete old serialport
		selected_item=get(handles.ac_comport,'Value');
		avail_ports=get(handles.ac_comport,'String');
		if size(avail_ports,1)>1
			selected_port=avail_ports{selected_item};
		else
			selected_port=avail_ports;
		end
		serpo = serialport(selected_port,9600,'Timeout',1);
		configureTerminator(serpo,'CR/LF');
		gui_NameSpace.gui_put('serpo',serpo);
		set(handles.ac_serialstatus,'Backgroundcolor',[0 1 0]);
		acquisition_NameSpace.acquisition_update_ac_status(['Connected to ' selected_port]);
		gui_NameSpace.gui_put('laser_running',0);

		laser_device_id = acquisition_NameSpace.acquisition_find_laser_device;
		gui_NameSpace.gui_put('laser_device_id',laser_device_id);

		acquisition_NameSpace.acquisition_control_simple_sync_serial(0,0);
	catch ME
		acquisition_NameSpace.acquisition_update_ac_status(ME.message);
		acquisition_NameSpace.acquisition_capture_images_Callback;
	end
end
