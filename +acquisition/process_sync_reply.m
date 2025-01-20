function serial_answer = process_sync_reply(serpo)
handles=gui.gethand;
serial_answer=readline(serpo);
warning on
sync_setting=serial_answer;
if isempty(sync_setting)
	sync_setting='No answer from Sync';
end
acquisition.update_ac_status(sync_setting);

set(handles.ac_laserstatus,'BackgroundColor',[1 1 0]); %yellow=warning
set(handles.ac_laserstatus,'String','No Answer');drawnow;
C = strsplit(sync_setting,'\t');
if ~isempty(C)
	if strcmpi(gui.retr('sync_type'),'xmSync')
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
	elseif strcmpi(gui.retr('sync_type'),'oltSync')
		if strcmpi(sync_setting,'Laser:enable')
			set(handles.ac_laserstatus,'BackgroundColor',[0 1 0]); %green = on
			set(handles.ac_laserstatus,'String','Laser ON');
			%calculate pulse timing
			pulse_sep=str2double(get(handles.ac_interpuls,'String'));
			camera_sub_type=gui.retr('camera_sub_type');
			camera_type=gui.retr('camera_type');
			bitmode =gui.retr('OPTOcam_bits');
			ac_fps_value=get(handles.ac_fps,'Value');
			ac_fps_str=get(handles.ac_fps,'String');
			framerate=str2double(ac_fps_str(ac_fps_value));
			f1exp_cam=gui.retr('f1exp_cam');
			las_percent=str2double(get(handles.ac_power,'String'));
			[timing_table, ~,~,~] = PIVlab_calc_oltsync_timings(camera_type,camera_sub_type,bitmode,framerate,f1exp_cam,pulse_sep,las_percent);
			pulse_length=timing_table{2,2}-timing_table{2,1};

			pl_msg=['Pulse length: ' int2str(pulse_length) ' µs'];

			if round(pulse_length) < 1 %Rounding for this test, because string sent to Sync is int2str
				pl_msg='ERROR pulse length! Increase energy.';
			end
			set (handles.ac_pulselengthtxt,'String', pl_msg);
			disp (pl_msg)
		elseif strcmpi(sync_setting,'Laser:disable')
			set(handles.ac_laserstatus,'BackgroundColor',[1 0 0]); %red = off
			set(handles.ac_laserstatus,'String','Laser OFF');
			pl_msg='Pulse length: 0 µs';
			set (handles.ac_pulselengthtxt,'String', pl_msg);
		end

	end
end

