function calibcapture_Callback(~,~,~)
filepath = fileparts(which('PIVlab_GUI.m'));
camera_type=gui.retr('camera_type');
if strcmp(camera_type,'pco_pixelfly') || strcmp(camera_type,'pco_panda') %calib
	if exist('pco_camera_load_defines.m','file') && exist('pco_recorder.dll','file') %pco.matlab must have been added to matlab search path
		%addpath(fullfile(filepath, 'PIVlab_capture_resources\PCO_resources\scripts'));
		ready=1;
	else
		ready=0;
		acquisition.pco_error_msgbox
	end
else
	ready=1;
end
if ready==1
	handles=gui.gethand;
	try
		expos=round(str2num(get(handles.ac_expo,'String'))*1000);
	catch
		set(handles.ac_expo,'String','100');
		expos=100000;
	end
	gui.put('cancel_capture',0);
	projectpath=get(handles.ac_project,'String');
	capture_ok=acquisition.check_project_path(projectpath,'calibration');
	ac_ROI_general=gui.retr('ac_ROI_general');
	binning=gui.retr('binning');
	if isempty(binning)
		binning=1;
	end
	if isempty(ac_ROI_general)
		max_cam_res=gui.retr('max_cam_res');
		ac_ROI_general=[1,1,max_cam_res(1)/binning,max_cam_res(2)/binning];
	end
	capturing=gui.retr('capturing');
	if isempty(capturing);capturing=0;end
	if capture_ok==1 && capturing == 0
		gui.put('capturing',1);
		gui.toolsavailable(0,'Starting camera...')
		%set(handles.ac_calibsave,'enable','on')
		set(handles.ac_calibcapture,'enable','on')
		set(handles.ac_serialstatus,'enable','on')
		set(handles.ac_laserstatus,'enable','on')
		set(handles.ac_lasertoggle,'enable','on')
		set(handles.ac_lensctrl,'enable','on')
		set(handles.ac_power,'enable','on')
		set(handles.panon,'enable','on');
		set(handles.zoomon,'enable','on');

		%try
		set(handles.ac_calibcapture,'String','Stop')
		if strcmp(camera_type,'pco_pixelfly') || strcmp(camera_type,'pco_panda') %pco cameras
			[~, caliimg,~]=PIVlab_capture_pco(6,expos,'Calibration',projectpath,binning,ac_ROI_general,camera_type);
		elseif strcmp(camera_type,'basler')
			[errorcode, caliimg]=PIVlab_capture_basler_calibration_image(inf,expos,ac_ROI_general);
		elseif strcmp(camera_type,'OPTOcam')
			[errorcode, caliimg]=PIVlab_capture_OPTOcam_calibration_image(inf,expos,ac_ROI_general);
		elseif strcmp(camera_type,'OPTRONIS')
			acquisition.control_simple_sync_serial(0,1); %OPTRONIS requires synchronizer signal because free run mode cannot be set from matlab.
			[errorcode, caliimg]=PIVlab_capture_OPTRONIS_calibration_image(inf,expos,ac_ROI_general);
			acquisition.control_simple_sync_serial(0,2);
		elseif strcmp(camera_type,'flir')
			[errorcode, caliimg]=PIVlab_capture_flir_calibration_image(expos);
		elseif strcmp(camera_type,'chronos')
			cameraIP=gui.retr('Chronos_IP');
			if isempty(cameraIP)
				uiwait(msgbox({'Chronos Setup not performed.' 'Please click "Setup" in "Camera settings"'}))
			else
				[errorcode, caliimg] = PIVlab_capture_chronos_calibration_image(cameraIP,expos);
			end
		end
		gui.put('caliimg',caliimg);
		gui.put('fresh_calib_image',1);
		%{
		catch
			set(handles.ac_calibcapture,'String','Start')
			uiwait(msgbox('Camera not connected'))
			displogo
			put('capturing',0);
			toolsavailable(1)
		end
		%}
	elseif capture_ok==1 && capturing == 1
		gui.put('cancel_capture',1);
		gui.put('capturing',0);
		set(handles.ac_calibcapture,'String','Start')
		gui.toolsavailable(1)
		set(handles.ac_calibsave,'enable','on')
	end
end

