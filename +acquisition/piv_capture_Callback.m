function piv_capture_Callback(~,~,~)
try
	acquisition.control_simple_sync_serial(0,0);
catch
	keyboard
end
gui.put('capturing',0);
camera_type=gui.retr('camera_type');
required_files_check=1;
if strcmp(camera_type,'pco_pixelfly') || strcmp(camera_type,'pco_panda') %calib
	if exist('pco_camera_load_defines.m','file') && exist('pco_recorder.dll','file') %pco.matlab must be installed and permanently added to the search path
		required_files_check=1;
	else
		required_files_check=0;
	end
end
if required_files_check
	button = questdlg('Arm LASER and camera?','Warning','Yes','Cancel','Yes');
	if strmatch(button,'Yes')==1
		handles=gui.gethand;
		gui.put('cancel_capture',0);
		projectpath=get(handles.ac_project,'String');
		if get(handles.ac_pivcapture_save,'Value')==1 %check settings only when user wants to save data
			imageamount=str2double(get(handles.ac_imgamount,'String'));
			capture_ok=acquisition.check_project_path(projectpath,'double_images');
		else
			imageamount=inf; %run forever if user doesnt want to save images
			capture_ok=1;
		end
		%Camera fps
		ac_fps_value=get(handles.ac_fps,'Value');
		ac_fps_str=get(handles.ac_fps,'String');
		cam_fps=str2double(ac_fps_str(ac_fps_value));
		ac_ROI_realtime=gui.retr('ac_ROI_realtime');
		do_realtime=gui.retr('do_realtime');
		if isempty(do_realtime)
			do_realtime=0;
		end
		if capture_ok==1
			gui.put('expected_image_size',[])
			ac_ROI_general=gui.retr('ac_ROI_general');
			if isempty(ac_ROI_general)
				max_cam_res=gui.retr('max_cam_res');
				ac_ROI_general=[1 1 max_cam_res(1) max_cam_res(2)];
			end
			gui.put('capturing',1);
			if isinf(imageamount)
				gui.toolsavailable(0,'Starting PIV preview...')
			else
				gui.toolsavailable(0,'Starting PIV capture...')
			end
			set(handles.ac_pivstop,'enable','on')
			set(handles.togglepair,'enable','on')
			set(handles.ac_serialstatus,'enable','on')
			set(handles.ac_laserstatus,'enable','on')
			set(handles.ac_lasertoggle,'enable','on')

			value=get(handles.ac_config,'value');

			%save capture configuration to mat file
			if ~isinf(imageamount)
				config_strings=get(handles.ac_config,'String');
				config_strings_selected=cell2mat((config_strings(value)));
				las_percent=str2double(get(handles.ac_power,'String'));
				pulse_sep=str2double(get(handles.ac_interpuls,'String'));
				binning=gui.retr('binning');
				OPTOcam_bits =gui.retr('OPTOcam_bits');
				if isempty (OPTOcam_bits)
					OPTOcam_bits=8;
				end
				recording_time=char(datetime('now'));
				logger_path = get(handles.ac_project,'String');
				if exist(logger_path,'dir') %only log when directory has been set up.
					timestamp=char(datetime('now'));
					if exist (fullfile(logger_path, 'acquisition_log.txt'),'file')~=2
						try
							logger_fid = fopen(fullfile(logger_path, 'acquisition_log.txt'), 'w');
							fprintf(logger_fid,'recording_time\tconfig_strings_selected\timageamount\tcam_fps\tpulse_sep\tlas_percent\tac_ROI_general\tbinning\tcam_bits');
							fprintf(logger_fid, '\n');
							fclose(logger_fid);
						catch
						end
					end
					try
						logger_fid = fopen(fullfile(logger_path, 'acquisition_log.txt'), 'a');
						fprintf(logger_fid, '%s', recording_time);
						fprintf(logger_fid, '\t');
						fprintf(logger_fid, '%s', config_strings_selected);
						fprintf(logger_fid, '\t');
						fprintf(logger_fid, '%s', num2str(imageamount));
						fprintf(logger_fid, '\t');
						fprintf(logger_fid, '%s', num2str(cam_fps));
						fprintf(logger_fid, '\t');
						fprintf(logger_fid, '%s', num2str(pulse_sep));
						fprintf(logger_fid, '\t');
						fprintf(logger_fid, '%s', num2str(las_percent));
						fprintf(logger_fid, '\t');
						fprintf(logger_fid, '%s', mat2str(ac_ROI_general));
						fprintf(logger_fid, '\t');
						fprintf(logger_fid, '%s', num2str(binning));
						fprintf(logger_fid, '\t');
						fprintf(logger_fid, '%s', num2str(OPTOcam_bits));
						fprintf(logger_fid, '\n');
						fclose(logger_fid);
					catch ME
						disp('Settings logger error:')
						disp(ME)
					end
				end
			end

			if value== 1 || value == 2 %setups without lD-PS
				set(handles.ac_power,'enable','on') %here, laser power can be adjusted while it is running.
			end
			set(handles.ac_lensctrl,'enable','on')

			f = waitbar(0,'Initializing...');
			%if any external device is activated for automatic control, then...
			if (~isempty(gui.retr('ac_enable_seeding1')) && gui.retr('ac_enable_seeding1') ~=0) || (~isempty(gui.retr('ac_enable_device1')) && gui.retr('ac_enable_device1') ~=0) || (~isempty(gui.retr('ac_enable_device2')) && gui.retr('ac_enable_device2') ~=0) || (~isempty(gui.retr('ac_enable_flowlab')) && gui.retr('ac_enable_flowlab') ~=0)
				acquisition.external_device_control(1); %starts activated devices
				waitbar(.15,f,'Starting external devices...');
				pause(0.5)
				waitbar(.33,f,'Starting external devices...');
				pause(0.5)
				if (~isempty(gui.retr('ac_enable_flowlab')) && gui.retr('ac_enable_flowlab') ~=0) %flowlab is activated
					%ask if flowlab was already running
					%if yes --> proceed, if not --> pause to wait for uniform flow velocity.
					flowlab_percent=gui.retr('flowlab_percent');
					if flowlab_percent ~= 0
						acquisition.external_device_control(1);
						%wait a variable time untl capturing...
						%slower velocities require more time to settle.
						time_to_wait = round(-7*flowlab_percent/100 + 10);
						for i=1:time_to_wait
							waitbar(.4 + 0.6*(i/time_to_wait),f,'Waiting for flow stabilization...');
							pause(1)
						end
					end
				end
			end
			if value==1 || value==2 %setup withOUT LD-PS
				%Start-up sequence for normal Q-Switched laser
				waitbar(.5,f,'Starting laser...');
				uiwait(warndlg('Pressing ''OK'' will start the laser.','Laser is armed','modal'))
				acquisition.control_simple_sync_serial(1,0);
				gui.put('laser_running',1);
				pause(1)
				waitbar(.6,f,'Starting laser...');
				pause(1)
				waitbar(.7,f,'Laser stabilization...');
				pause(1)
				waitbar(.85,f,'Starting camera...');
				pause(1)
				waitbar(1,f,'Starting camera...');
				pause(1)
				close(f)
			elseif value == 3 || value == 4 %pco cameras with laser diode
				%Start-up sequence for PIVlab LD-PS (much quicker)
				waitbar(.01,f,'Starting laser...');
				las_percent=str2double(get(handles.ac_power,'String'));
				pulse_sep=str2double(get(handles.ac_interpuls,'String'));
				if strcmpi(gui.retr('sync_type'),'xmSync')
					f1exp_cam =floor(pulse_sep*las_percent/100)+1; %+1 because in the snychronizer, the cam expo is started 1 us before the ld pulse
				elseif strcmpi(gui.retr('sync_type'),'oltSync')
					f1exp_cam =floor(pulse_sep*las_percent/100);
					gui.put('f1exp_cam',f1exp_cam);
				end
				uiwait(warndlg('Pressing ''OK'' will start the laser.','Laser is armed','modal'))
				acquisition.control_simple_sync_serial(1,0);
				gui.put('laser_running',1);
				close(f)
			elseif value== 5 || value == 6 || value==7 || value==8 || value==9%chronos and basler and flir and OPTOcam and OPTRONIS: Camera needs to be started first, afterwards the laser is enabled.
				close(f)
			end
			camera_type=gui.retr('camera_type');
			binning=gui.retr('binning');
			if isempty(binning)
				binning=1;
			end
			value=get(handles.ac_config,'value');
			if value== 3 || value == 4 %setup with LD-PS and pco
				%require a calculation of the exposure time which depends on the laser pulse length
				las_percent=str2double(get(handles.ac_power,'String'));
				pulse_sep=str2double(get(handles.ac_interpuls,'String'));
				if strcmpi(gui.retr('sync_type'),'xmSync')
					f1exp_cam =floor(pulse_sep*las_percent/100)+1; %+1 because in the snychronizer, the cam expo is started 1 us before the ld pulse
				elseif strcmpi(gui.retr('sync_type'),'oltSync')
					f1exp_cam =floor(pulse_sep*las_percent/100);
					gui.put('f1exp_cam',f1exp_cam);
				end
				disp(['camera exposure time = ' num2str(f1exp_cam)])
				if f1exp_cam < 6
					msgbox (['Exposure time of camera too low. Please increase laser energy or pulse distance.' sprintf('\n') 'Pulse_distance[µs] * laser_energy[%] must be >= 6 µs'])
					uiwait
				end
			else
				f1exp_cam=gui.retr('f1exp_cam');
			end
			if value == 5 %chronos
				%capture to camera RAM
				%zuerst:camera konfigurieren. Dann kamera starten. dann laser. nach laserstart warten und aufnahme beenden.dann laser aus
				cameraIP=gui.retr('Chronos_IP');
				acquisition.control_simple_sync_serial(0,0) %stop triggering when already running.
				[OutputError] = PIVlab_capture_chronos_synced_start(cameraIP,cam_fps); %prepare cam and start camera (waiting for trigger...)
				uiwait(warndlg('Pressing ''OK'' will start the laser.','Laser is armed','modal'))
				acquisition.control_simple_sync_serial(1,0); gui.put('laser_running',1); %turn on laser
				[OutputError,ima,frame_nr_display] = PIVlab_capture_chronos_synced_capture(cameraIP,imageamount,cam_fps,do_realtime,ac_ROI_realtime); %capture n images, display livestream
			elseif value == 1 || value == 2 || value == 3 || value == 4  %pco cameras
				PIVlab_capture_pco(imageamount,f1exp_cam,'Synchronizer',projectpath,binning,ac_ROI_general,camera_type);
			elseif value == 6  %basler cameras
				[OutputError,basler_vid,frame_nr_display] = PIVlab_capture_basler_synced_start(imageamount,ac_ROI_general); %prepare cam and start camera (waiting for trigger...)
				uiwait(warndlg('Pressing ''OK'' will start the laser.','Laser is armed','modal'))
				acquisition.control_simple_sync_serial(1,0); gui.put('laser_running',1); %turn on laser
				[OutputError,basler_vid] = PIVlab_capture_basler_synced_capture(basler_vid,imageamount,do_realtime,ac_ROI_realtime,frame_nr_display); %capture n images, display livestream
			elseif value == 7  %flir cameras
				[OutputError,flir_vid,frame_nr_display] = PIVlab_capture_flir_synced_start(imageamount,cam_fps); %prepare cam and start camera (waiting for trigger...)
				uiwait(warndlg('Pressing ''OK'' will start the laser.','Laser is armed','modal'))
				acquisition.control_simple_sync_serial(1,0); gui.put('laser_running',1); %turn on laser
				[OutputError,flir_vid] = PIVlab_capture_flir_synced_capture(flir_vid,imageamount,do_realtime,ac_ROI_realtime,frame_nr_display); %capture n images, display livestream
			elseif value == 8  %OPTOcam
				OPTOcam_bits =gui.retr('OPTOcam_bits');
				if isempty (OPTOcam_bits)
					OPTOcam_bits=8;
				end
				[OutputError,OPTOcam_vid,frame_nr_display] = PIVlab_capture_OPTOcam_synced_start(imageamount,ac_ROI_general,cam_fps,OPTOcam_bits); %prepare cam and start camera (waiting for trigger...)
				Error_Reason={};
				OPTOcam_settings_check = 1;
				max_fps_with_current_settings = 1/((get(OPTOcam_vid.Source,'SensorReadoutTime') + get(OPTOcam_vid.Source,'BslExposureStartDelay'))/1000/1000);
				if cam_fps > max_fps_with_current_settings
					OPTOcam_settings_check = 0;
					Error_Reason{end+1,1}='Frame rate too high for selected ROI and/or bit rate.';
					Error_Reason{end+1,1}=['With current settings, sensor max. fps is ' num2str(round(max_fps_with_current_settings,1)) ' fps'];
					Error_Reason{end+1,1}='Please make the ROI smaller, or decrease the frame rate.';
				end
				min_allowed_interframe = gui.retr('min_allowed_interframe');
				pulse_sep=str2double(get(handles.ac_interpuls,'String'));
				if pulse_sep < min_allowed_interframe
					OPTOcam_settings_check = 0;
					Error_Reason{end+1,1}='Pulse distance too small for current bit mode.';
					Error_Reason{end+1,1}=['In ' num2str(OPTOcam_bits) ' bit mode, the puse distance must be at least ' num2str(min_allowed_interframe) ' µs.'];
					Error_Reason{end+1,1}='Please increase the pulse distance, or decrease the bit mode.';
				end
				if OPTOcam_settings_check == 1
					uiwait(warndlg('Pressing ''OK'' will start the laser.','Laser is armed','modal'))
					acquisition.control_simple_sync_serial(1,0); gui.put('laser_running',1); %turn on laser
					[OutputError,OPTOcam_vid] = PIVlab_capture_OPTOcam_synced_capture(OPTOcam_vid,imageamount,do_realtime,ac_ROI_realtime,frame_nr_display,OPTOcam_bits); %capture n images, display livestream
				else
					msgbox(Error_Reason,'modal')
					uiwait
					gui.put('cancel_capture',1);
					imageamount=inf; %will prevent saving of images
				end
			elseif value == 9  %OPTRONIS
				OPTRONIS_bits =gui.retr('OPTRONIS_bits');
				if isempty (OPTRONIS_bits)
					OPTRONIS_bits=8;
				end
				[OutputError,OPTRONIS_vid,frame_nr_display] = PIVlab_capture_OPTRONIS_synced_start(imageamount,ac_ROI_general,cam_fps,OPTRONIS_bits); %prepare cam and start camera (waiting for trigger...)
				pause(1) %make sure OPTRONIS is ready to capture.
				Error_Reason={};
				OPTRONIS_settings_check = 1;
				%2166 mit 8 bit
				%1750 mit 10 bit

				camera_sub_type=gui.retr('camera_sub_type');
				if OPTRONIS_bits==8
					switch camera_sub_type
						case 'Cyclone-2-2000-M'
							max_fps_with_current_settings = 2165;
						case 'Cyclone-1HS-3500-M'
							max_fps_with_current_settings = 3500;
						case 'Cyclone-25-150-M'
							max_fps_with_current_settings = 150;
						otherwise
							max_fps_with_current_settings=1111;
					end

				elseif OPTRONIS_bits==10
					switch camera_sub_type
						case 'Cyclone-2-2000-M'
							max_fps_with_current_settings = 1750;
						case 'Cyclone-1HS-3500-M'
							max_fps_with_current_settings = 3175;
						case 'Cyclone-25-150-M'
							max_fps_with_current_settings = 149;
						otherwise
							max_fps_with_current_settings=1111;
					end
				end

				if cam_fps > max_fps_with_current_settings
					OPTRONIS_settings_check = 0;
					Error_Reason{end+1,1}='Frame rate too high for selected bit rate.';
					Error_Reason{end+1,1}=['With current settings, sensor max. fps is ' num2str(round(max_fps_with_current_settings,1)) ' fps'];
					Error_Reason{end+1,1}='Please select a lower frame rate.';
				end
				min_allowed_interframe = gui.retr('min_allowed_interframe');
				pulse_sep=str2double(get(handles.ac_interpuls,'String'));
				if OPTRONIS_settings_check == 1
					uiwait(warndlg('Pressing ''OK'' will start the laser.','Laser is armed','modal'))
					acquisition.control_simple_sync_serial(1,0); gui.put('laser_running',1); %turn on laser
					[OutputError,OPTRONIS_vid] = PIVlab_capture_OPTRONIS_synced_capture(OPTRONIS_vid,imageamount,do_realtime,ac_ROI_realtime,frame_nr_display,OPTRONIS_bits); %capture n images, display livestream
				else
					msgbox(Error_Reason,'modal')
					uiwait
					gui.put('cancel_capture',1);
					imageamount=inf; %will prevent saving of images
				end
			end
			%disable external devices
			if (~isempty(gui.retr('ac_enable_seeding1')) && gui.retr('ac_enable_seeding1') ~=0) || (~isempty(gui.retr('ac_enable_device1')) && gui.retr('ac_enable_device1') ~=0) || (~isempty(gui.retr('ac_enable_device2')) && gui.retr('ac_enable_device2') ~=0) || (~isempty(gui.retr('ac_enable_flowlab')) && gui.retr('ac_enable_flowlab') ~=0)
				acquisition.external_device_control(0); % stops all external devices
			end
			acquisition.control_simple_sync_serial(0,0);pause(0.1);acquisition.control_simple_sync_serial(0,0);
			gui.put('laser_running',0);
			if value == 5 %chronos
				%when Chronos:save the images when finished recording to camera ram
				if ~isinf(imageamount) % when the nr. of images is inf, then dont save images. nr of images becomes inf when user selects to not save the images.
					PIVlab_capture_chronos_save (cameraIP,imageamount,projectpath,frame_nr_display)
				end
			end
			if value == 6 %basler
				if ~isinf(imageamount) % when the nr. of images is inf, then dont save images. nr of images becomes inf when user selects to not save the images.
					[OutputError] = PIVlab_capture_basler_save(basler_vid,imageamount,projectpath,frame_nr_display); %save the images from ram to disk.
				end
			end
			if value == 7 %flir
				if ~isinf(imageamount) % when the nr. of images is inf, then dont save images. nr of images becomes inf when user selects to not save the images.
					[OutputError] = PIVlab_capture_flir_save(flir_vid,imageamount,projectpath,frame_nr_display); %save the images from ram to disk.
				end
			end
			if value == 8 %OPTOcam
				if ~isinf(imageamount) % when the nr. of images is inf, then dont save images. nr of images becomes inf when user selects to not save the images.
					if gui.retr('cancel_capture')==1
						answer = questdlg('Save the PIV images that were recorded?', 'Save images?', 'Yes','No','Yes');
						if strcmp(answer , 'Yes')
							gui.put('cancel_capture',0); %user pressed cancel, but still wants to save the recorded images.
							imageamount=floor(OPTOcam_vid.FramesAcquired/2);
						end
					end
					[OutputError] = PIVlab_capture_OPTOcam_save(OPTOcam_vid,imageamount,projectpath,frame_nr_display,OPTOcam_bits); %save the images from ram to disk.
				end
			end
			if value == 9 %OPTRONIS
				if ~isinf(imageamount) % when the nr. of images is inf, then dont save images. nr of images becomes inf when user selects to not save the images.
					[OutputError] = PIVlab_capture_OPTRONIS_save(OPTRONIS_vid,imageamount,projectpath,frame_nr_display,OPTRONIS_bits); %save the images from ram to disk.
				end
			end
			found_the_data=0;
			if gui.retr('cancel_capture')==0
				camera_type=gui.retr('camera_type');
				found_the_data=acquisition.push_recorded_to_GUI(camera_type,imageamount);
				if found_the_data==1
					gui.put('sessionpath',projectpath );
					set(handles.time_inp,'String',num2str(str2num(get(handles.ac_interpuls,'String'))/1000));
					hgui=getappdata(0,'hgui');
					serpo=getappdata(hgui,'serpo');
					export.save_session_function (projectpath,'PIVlab_Capture_Session.mat');
					gui.put('serpo',serpo); %Serpo gets inaccessible after savesession. Probably because there are a number of variables cleared to allow saving without crashing.
				else
					gui.displogo
				end
			end
		end
	end
else
	acquisition.pco_error_msgbox
end
gui.put('capturing',0);
gui.toolsavailable(1)
if exist('found_the_data','var') && found_the_data==1
	set (handles.remove_imgs,'enable','on');
end