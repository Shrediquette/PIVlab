function acquisition_ext_trigger_settings_Callback (~,~,~)
handles=gui.gui_gethand;
serpo=gui.gui_retr('serpo');
if ~isempty(serpo)
	acquisition.acquisition_control_simple_sync_serial(0,0);
	if get(handles.ac_enable_ext_trigger,'Value')==1 %execute only if checkbox was off before it was clicked.
		old_label=get(handles.ac_enable_ext_trigger,'String');
		set(handles.ac_enable_ext_trigger,'String','Acquiring...','Enable','off')

		drawnow;
		flush(serpo)
		%configureTerminator(serpo,'CR');
		writeline(serpo,'TrigFreq?');
		pause(1.25);
		warning off
		%configureTerminator(serpo,'CR/LF');
		serial_answer=readline(serpo);
		warning on
		set(handles.ac_enable_ext_trigger,'String',old_label,'Enable','on');
		selectedtriggerdelay=gui.gui_retr('selectedtriggerdelay');
		if isempty(selectedtriggerdelay)
			selectedtriggerdelay=100;
		end
		selectedtriggerskip=gui.gui_retr('selectedtriggerskip');
		if isempty(selectedtriggerskip)
			selectedtriggerdelay=0;
		end
		prompt = {['Detected frequency on trigger input: ' num2str(serial_answer) ' Hz.' sprintf('\n\n') 'Trigger delay in µs (must be > 100):'],'Nr. of trigger signals to skip:'};
		dlgtitle = 'External Trigger Configuration';
		dims = [1 50];
		definput = {num2str(selectedtriggerdelay),num2str(selectedtriggerskip)};
		answer = inputdlg(prompt,dlgtitle,dims,definput);
		if ~isempty(answer)
			gui.gui_put('selectedtriggerdelay',str2double(answer{1}));
			gui.gui_put('selectedtriggerskip',str2double(answer{2}));
		end
	end
end

