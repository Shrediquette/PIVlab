function serial_answer = process_sync_reply(serpo)
handles=gui.gui_gethand;
serial_answer=readline(serpo);
warning on
sync_setting=serial_answer;
if isempty(sync_setting)
	sync_setting='No answer from Sync';
end
acquisition.acquisition_update_ac_status(sync_setting);

set(handles.ac_laserstatus,'BackgroundColor',[1 1 0]); %yellow=warning
set(handles.ac_laserstatus,'String','No Answer');drawnow;
C = strsplit(sync_setting,'\t');
if ~isempty(C)
	if size(C,2)==8 %entspricht standard datenpaket
		if strcmp(C{8},'1') %laser is reported to be on
			set(handles.ac_laserstatus,'BackgroundColor',[0 1 0]); %green = on
			set(handles.ac_laserstatus,'String','Laser ON');
		else
			set(handles.ac_laserstatus,'BackgroundColor',[1 0 0]); %red = off
			set(handles.ac_laserstatus,'String','Laser OFF');
		end
	end
	if size(C,2)==12 %entspricht erweitertem datenpaket
		if strcmp(C{8},'1') %laser is reported to be on
			set(handles.ac_laserstatus,'BackgroundColor',[0 1 0]); %green = on
			set(handles.ac_laserstatus,'String','Laser ON');
		else
			set(handles.ac_laserstatus,'BackgroundColor',[1 0 0]); %red = off
			set(handles.ac_laserstatus,'String','Laser OFF');
			pl_msg=['Pulse length: 0 µs'];
			set (handles.ac_pulselengthtxt,'String', pl_msg);
		end
		if strcmp(C{8},'1') %laser is reported to be on
			pl_msg=['Pulse length: ' C{9} ' µs'];
			set (handles.ac_pulselengthtxt,'String', pl_msg);
			disp (pl_msg)
		end
	end

end

