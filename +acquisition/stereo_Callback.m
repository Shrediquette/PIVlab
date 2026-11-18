function stereo_Callback(~,~,~)
%"Stereo (2 cameras)": stereo-PIV acquisition with two cameras of the selected type. When it is ticked, PIVlab
%checks that two of them are connected (OPTOcam 2/80: each camera is opened briefly to read its user ID; OPTOcam 20/9:
%by the device name); otherwise the box is unticked again.
handles=gui.gethand;
if get(handles.ac_stereo,'Value') == 1
	camera_type=gui.retr('camera_type');
	if ~acquisition.stereo_supported(camera_type)
		set(handles.ac_stereo,'Value',0);
		gui.custom_msgbox('error',getappdata(0,'hgui'),'Stereo acquisition','Stereo acquisition is not (yet) available for the selected camera.','modal');
	else
		gui.toolsavailable(0,'Looking for the cameras...') %listing the cameras can take more than 10 s
		drawnow
		n_found = connected_cameras(camera_type);
		gui.toolsavailable(1)
		if n_found < 2
			set(handles.ac_stereo,'Value',0);
			gui.custom_msgbox('error',getappdata(0,'hgui'),'Stereo acquisition',['Stereo acquisition needs two cameras of the selected type. Cameras found: ' ...
				int2str(n_found) '. Please connect both cameras to the computer, and both to the camera output of the synchronizer (Y-cable).'],'modal');
		end
	end
end
acquisition.image_amount_Callback %RAM for one or two cameras

function n_found = connected_cameras(camera_type)
%number of connected cameras of this type (OPTOcam 2/80: by user ID, see PIVlab_capture_OPTOcam_model)
n_found = 0;
try
	hwinf = imaqhwinfo;
	for adaptorID = 1:numel(hwinf.InstalledAdaptors)
		info = imaqhwinfo(hwinf.InstalledAdaptors{adaptorID});
		if strcmp(camera_type,'OPTOcam') && (strcmp(info.AdaptorName,'gentl') || strcmp(info.AdaptorName,'mwgentlimaq'))
			candidates = PIVlab_capture_OPTOcam_candidates(info.DeviceInfo); %a 2/80 is only known from its user ID
			for c = 1:numel(candidates)
				d = info.DeviceInfo(candidates(c));
				user_id = PIVlab_capture_OPTOcam_user_id(info.AdaptorName,d.DeviceID);
				if strcmp(PIVlab_capture_OPTOcam_model(d.DeviceName,user_id),'2_80')
					n_found = n_found+1;
					if n_found == 2
						break %enough for stereo
					end
				end
			end
		elseif strcmp(camera_type,'OPTOcam_20_9') && (strcmp(info.AdaptorName,'gentl') || strcmp(info.AdaptorName,'mwgentlimaq'))
			for CamID = 1:numel(info.DeviceInfo) %a 20/9 is known from its device name, no camera is opened
				if strcmp(PIVlab_capture_OPTOcam_model(info.DeviceInfo(CamID).DeviceName),'20_9')
					n_found = n_found+1;
				end
			end
		end
	end
catch %no Image Acquisition Toolbox
end
