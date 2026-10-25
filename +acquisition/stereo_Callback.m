function stereo_Callback(~,~,~)
%"Stereo (2 cameras)": stereo-PIV acquisition with two cameras of the selected type. When it is ticked, PIVlab
%checks (without opening the cameras) that two of them are connected; otherwise the box is unticked again.
handles=gui.gethand;
if get(handles.ac_stereo,'Value') == 1
	camera_type=gui.retr('camera_type');
	if ~acquisition.stereo_supported(camera_type)
		set(handles.ac_stereo,'Value',0);
		gui.custom_msgbox('error',getappdata(0,'hgui'),'Stereo acquisition','Stereo acquisition is not (yet) available for the selected camera.','modal');
	else
		n_found = connected_cameras(camera_type);
		if n_found < 2
			set(handles.ac_stereo,'Value',0);
			gui.custom_msgbox('error',getappdata(0,'hgui'),'Stereo acquisition',['Stereo acquisition needs two cameras of the selected type. Cameras found: ' ...
				int2str(n_found) '. Please connect both cameras to the computer, and both to the camera output of the synchronizer (Y-cable).'],'modal');
		end
	end
end
acquisition.image_amount_Callback %RAM for one or two cameras

function n_found = connected_cameras(camera_type)
%number of connected cameras of this type (device names only, no camera is opened)
n_found = 0;
try
	hwinf = imaqhwinfo;
	for adaptorID = 1:numel(hwinf.InstalledAdaptors)
		info = imaqhwinfo(hwinf.InstalledAdaptors{adaptorID});
		if strcmp(camera_type,'OPTOcam') && (strcmp(info.AdaptorName,'gentl') || strcmp(info.AdaptorName,'mwgentlimaq'))
			for CamID = 1:size(info.DeviceInfo,2)
				camName = info.DeviceInfo(CamID).DeviceName;
				if contains(camName,'160um','IgnoreCase',true) || contains(camName,'OPTOcam','IgnoreCase',true) %as PIVlab_capture_OPTOcam_open
					n_found = n_found+1;
				end
			end
		end
	end
catch %no Image Acquisition Toolbox
end
