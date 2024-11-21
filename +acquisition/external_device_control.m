function external_device_control(switch_it)
handles=gui.gethand;
serpo=gui.retr('serpo');
if ~isempty(serpo)
	flush(serpo);pause(0.1)
	if switch_it==1
		if ~isempty(gui.retr('ac_enable_seeding1')) && gui.retr('ac_enable_seeding1') == 1
			ext_dev_01_pwm = gui.retr('ext_dev_01_pwm');
			line_to_write=['SEEDER_01:' num2str(ext_dev_01_pwm)];
			writeline(serpo,line_to_write);
			gui.put('ac_seeding1_status',1);
			pause(0.2)
		end
		if ~isempty(gui.retr('ac_enable_device1')) && gui.retr('ac_enable_device1') == 1
			ext_dev_02_pwm = gui.retr('ext_dev_02_pwm');
			line_to_write=['DEVICE_01:' num2str(ext_dev_02_pwm)];
			writeline(serpo,line_to_write);
			gui.put('ac_device1_status',1);
			pause(0.2)
		end
		if ~isempty(gui.retr('ac_enable_device2')) && gui.retr('ac_enable_device2') == 1
			ext_dev_03_pwm = gui.retr('ext_dev_03_pwm');
			line_to_write=['DEVICE_02:' num2str(ext_dev_03_pwm)];
			writeline(serpo,line_to_write);
			gui.put('ac_device2_status',1);
			pause(0.2)
		end
		if ~isempty(gui.retr('ac_enable_flowlab')) && gui.retr('ac_enable_flowlab') == 1
			flowlab_percent = gui.retr('flowlab_percent');
			line_to_write=['FLOWLAB:' num2str(flowlab_percent/100)];
			writeline(serpo,line_to_write);
			gui.put('ac_flowlab_status',1);
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
		gui.put('ac_seeding1_status',0);
		gui.put('ac_device1_status',0);
		gui.put('ac_device2_status',0);
		gui.put('ac_flowlab_status',0);
	end
end

