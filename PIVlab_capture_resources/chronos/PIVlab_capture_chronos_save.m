function PIVlab_capture_chronos_save (cameraIP,nr_of_images,ImagePath,frame_nr_display)
hgui=getappdata(0,'hgui');
cameraURL = ['http://' cameraIP];
options = weboptions('MediaType','application/json','HeaderFields',{'Content-Type' 'application/json'});
resx=getappdata(hgui,'Chronos_resx');
resy=getappdata(hgui,'Chronos_resy');
bitdepth=getappdata(hgui,'Chronos_bits');
save_location=getappdata(hgui,'save_location');
save_type=getappdata(hgui,'save_type');

if matches(save_type,'TIFF')
	save_type_command='tiff';
elseif matches(save_type,'H264')
	save_type_command='h264';
elseif matches(save_type,'TIFF RAW')
	save_type_command='tiffraw';
end

%% save to SMB

if matches(save_location,'Download')
	% check if selected save method is existing:
	storage = webread ([cameraURL '/control/p/externalStorage']);
	if isfield(storage.externalStorage,'smb')
		set(frame_nr_display,'String',{'SMB File transfer setup OK!' ['Location: ' storage.externalStorage.smb.device]});drawnow;
		ok_go=1;
	else
		set(frame_nr_display,'String','Error: SMB File transfer not set up correctly');drawnow;
		ok_go=0;
	end
	if ok_go == 1
		if exist([storage.externalStorage.smb.device '\Chronos_PIVlab'],'dir') == 7
			[status,~] = rmdir([storage.externalStorage.smb.device '\Chronos_PIVlab'],'s');
			if status==0
				disp([storage.externalStorage.smb.device '\Chronos_PIVlab']')
				disp('Error: Temp directory could not be cleared.')
			end
		end

		response = webwrite([cameraURL '/control/startFilesave'],'filename','Chronos_PIVlab','format',save_type_command,'device','smb','start',1+2,'length',nr_of_images*2-1+2);

		pause(1)
		chronos_state = webread([cameraURL '/control/p/videoState']); %--> chronos_state.videoState 'filesave'
		%chronos_current_save_frame=webread([cameraURL '/control/p/playbackPosition']); % chronos_current_save_frame.playbackPosition

		exit_cntr=0;
		saving_running=1;
		while strcmp(chronos_state.videoState, 'recording') || strcmp(chronos_state.videoState, 'idle' ) || strcmp(chronos_state.videoState, 'live' )|| strcmp(chronos_state.videoState, 'paused')
			chronos_state = webread([cameraURL '/control/p/videoState']);
			exit_cntr=exit_cntr+1;
			pause(0.5)
			if exit_cntr >= 20
				disp('ERROR: timeout waiting for file transfer begin.')
				saving_running=0;
				response=webread([cameraURL '/control/stopFilesave']);
				break
			end
		end
		set(frame_nr_display,'String','Initiating transfer...');drawnow;
		msg_loop=0;
		if saving_running
			start_save=tic;
			while strcmp(chronos_state.videoState, 'filesave')
				if getappdata(hgui,'cancel_capture') ==1
					response=webread([cameraURL '/control/stopFilesave']);
					disp('cancelling save')
					break
				end
				pause(3)
				chronos_state = webread([cameraURL '/control/p/videoState']); %--> chronos_state.videoState 'filesave'
				direc=dir([storage.externalStorage.smb.device '\Chronos_PIVlab\*.tiff']);
				progress=min ([(length(direc) / (nr_of_images*2)*100) 99]);
				zeit=toc(start_save);
				done=progress/100;
				tocome=1-done;
				zeit=zeit/done*tocome;
				hrs=zeit/60^2;
				mins=(hrs-floor(hrs))*60;
				secs=(mins-floor(mins))*60;
				hrs=floor(hrs);
				mins=floor(mins);
				secs=floor(secs);
				first_line=['Download progress: ' num2str(round(progress*10)/10)  ' %'];
				if msg_loop>=2
					second_line=['Time left: ' sprintf('%2.2d', hrs) 'h ' sprintf('%2.2d', mins) 'm ' sprintf('%2.2d', secs) 's'];
				else
					second_line='...';
				end
				set(frame_nr_display,'String',{first_line second_line});drawnow;
				msg_loop=msg_loop+1;
			end
		end

		[status,~,~] = movefile([storage.externalStorage.smb.device '\Chronos_PIVlab\*.*'],ImagePath,"f");
		if status==0
			disp(['Temp dir: ' storage.externalStorage.smb.device '\Chronos_PIVlab']')
			disp(['Target dir: ' ImagePath])
			disp('Error: Could not move files from temp dir to target dir.')
		end
		[status,~] = rmdir([storage.externalStorage.smb.device '\Chronos_PIVlab'],'s');
		if status==0
			disp([storage.externalStorage.smb.device '\Chronos_PIVlab']')
			disp('Error: Temp directory could not be cleared.')
		end

		elapsed_time=toc(start_save);
		if elapsed_time < 121
			disp(['Elapsed time: ' num2str(round(elapsed_time)) ' seconds.'])
		else
			disp(['Elapsed time: ' num2str(round(elapsed_time/6)/10) ' minutes.'])
		end

		response=webread([cameraURL '/control/startLivedisplay']);
	end
	%% SAVE TO SSD or SD-Card

elseif matches(save_location,'SSD') || matches(save_location,'SD Card')


	if matches(save_location,'SSD')
		storage = webread ([cameraURL '/control/p/externalStorage']);
		if isfield(storage.externalStorage,'sda1')
			set(frame_nr_display,'String','SSD File transfer setup OK!');drawnow;
			ok_go=1;
			medium_string='SSD write progress: ';
		else
			set(frame_nr_display,'String','Error: SSD File transfer not set up correctly');drawnow;
			ok_go=0;
		end
	end

	if matches(save_location,'SD Card')
		storage = webread ([cameraURL '/control/p/externalStorage']);
		if isfield(storage.externalStorage,'mmcblk1p1')
			set(frame_nr_display,'String','SD-card file transfer setup OK!');drawnow;
			ok_go=1;
			medium_string='SD card write progress: ';
		else
			set(frame_nr_display,'String','Error: SD-card File transfer not set up correctly');drawnow;
			ok_go=0;
		end
	end

	if ok_go == 1
		if ImagePath(end) == filesep %remove trailing slashes if existent
			ImagePath(end) = [];
		end
		dindex=strfind(ImagePath,filesep);
		project_name=[ImagePath((dindex(end)+1:end)) '_' datestr(datetime(now,'ConvertFrom','datenum'),'YYYY_dd_mm_HH_MM_SS')];

		if matches(save_location,'SSD')
			response = webwrite([cameraURL '/control/startFilesave'],'filename',project_name,'format',save_type_command,'device','sda1','start',1+2,'length',nr_of_images*2-1+2);
		end
		if matches(save_location,'SD Card')
			response = webwrite([cameraURL '/control/startFilesave'],'filename',project_name,'format',save_type_command,'device','mmcblk1p1','start',1+2,'length',nr_of_images*2-1+2);
		end

		pause(1)
		chronos_state = webread([cameraURL '/control/p/videoState']); %--> chronos_state.videoState 'filesave'

		exit_cntr=0;
		saving_running=1;
		while strcmp(chronos_state.videoState, 'recording') || strcmp(chronos_state.videoState, 'idle' ) || strcmp(chronos_state.videoState, 'live' )|| strcmp(chronos_state.videoState, 'paused')
			chronos_state = webread([cameraURL '/control/p/videoState']);
			exit_cntr=exit_cntr+1;
			pause(0.5)
			if exit_cntr >= 20
				disp('ERROR: timeout waiting for file save begin.')
				saving_running=0;
				response=webread([cameraURL '/control/stopFilesave']);
				break
			end
		end
		set(frame_nr_display,'String','Initiating transfer...');drawnow;
		response = webwrite([cameraURL '/control/p'],'playbackPosition',0); %set to first frame, maybe this fixes jumping progress report...? No... :-(
		urlread([cameraURL '/control/p/totalFrames']); %fix jumping progress...? No...

		msg_loop=0;
		if saving_running
			start_save=tic;
			while strcmp(chronos_state.videoState, 'filesave')
				if getappdata(hgui,'cancel_capture') ==1
					response=webread([cameraURL '/control/stopFilesave']);
					disp('cancelling save')
					break
				end
				chronos_current_save_frame=webread([cameraURL '/control/p/playbackPosition']); % chronos_current_save_frame.playbackPosition
				chronos_state = webread([cameraURL '/control/p/videoState']); %--> chronos_state.videoState 'filesave'
				progress=min ([(chronos_current_save_frame.playbackPosition / (nr_of_images*2)*100) 99]);

				zeit=toc(start_save);
				done=progress/100;
				tocome=1-done;
				zeit=zeit/done*tocome;
				hrs=zeit/60^2;
				mins=(hrs-floor(hrs))*60;
				secs=(mins-floor(mins))*60;
				hrs=floor(hrs);
				mins=floor(mins);
				secs=floor(secs);
				first_line=[medium_string num2str(round(progress*10)/10)  ' %'];
				if msg_loop>=2
					second_line=['Time left: ' sprintf('%2.2d', hrs) 'h ' sprintf('%2.2d', mins) 'm ' sprintf('%2.2d', secs) 's'];
				else
					second_line='...';
				end
				set(frame_nr_display,'String',{first_line second_line});drawnow;
				msg_loop=msg_loop+1;
				pause(2);
			end
		end


	end
end
