function external_device_control(switch_it)
handles=gui.gui_gethand;
serpo=gui.gui_retr('serpo');
if ~isempty(serpo)
	flush(serpo)
	if switch_it==1
		if ~isempty(gui.gui_retr('ac_enable_seeding1')) && gui.gui_retr('ac_enable_seeding1') == 1
			ext_dev_01_pwm = gui.gui_retr('ext_dev_01_pwm');
			line_to_write=['SEEDER_01:' num2str(ext_dev_01_pwm)];
			writeline(serpo,line_to_write);
			gui.gui_put('ac_seeding1_status',1);
			pause(0.2)
		end
		if ~isempty(gui.gui_retr('ac_enable_device1')) && gui.gui_retr('ac_enable_device1') == 1
			ext_dev_02_pwm = gui.gui_retr('ext_dev_02_pwm');
			line_to_write=['DEVICE_01:' num2str(ext_dev_02_pwm)];
			writeline(serpo,line_to_write);
			gui.gui_put('ac_device1_status',1);
			pause(0.2)
		end
		if ~isempty(gui.gui_retr('ac_enable_device2')) && gui.gui_retr('ac_enable_device2') == 1
			ext_dev_03_pwm = gui.gui_retr('ext_dev_03_pwm');
			line_to_write=['DEVICE_02:' num2str(ext_dev_03_pwm)];
			writeline(serpo,line_to_write);
			gui.gui_put('ac_device2_status',1);
			pause(0.2)
		end
		if ~isempty(gui.gui_retr('ac_enable_flowlab')) && gui.gui_retr('ac_enable_flowlab') == 1
			flowlab_percent = gui.gui_retr('flowlab_percent');
			line_to_write=['FLOWLAB:' num2str(flowlab_percent/100)];
			writeline(serpo,line_to_write);
			gui.gui_put('ac_flowlab_status',1);
			pause(0.2)
		end
	else
		writeline(serpo,'SEEDER_01:0');
		pause(0.1)
		writeline(serpo,'DEVICE_01:0');
		pause(0.1)
		writeline(serpo,'DEVICE_02:0');
		pause(0.1)
		writeline(serpo,'FLOWLAB:0');
		gui.gui_put('ac_seeding1_status',0);
		gui.gui_put('ac_device1_status',0);
		gui.gui_put('ac_device2_status',0);
		gui.gui_put('ac_flowlab_status',0);
	end
end

