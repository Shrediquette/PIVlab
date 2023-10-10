function [OutputError,camera_sub_type] = PIVlab_capture_OPTRONIS_cam_detect(~)
OutputError=0;
%% Prepare camera
try
	delete(imaqfind); %clears all previous videoinputs
	warning off
	hwinf = imaqhwinfo;
	warning on
	warning('off','imaq:gentl:hardwareTriggerTriggerModeOff'); %trigger property of OPTRONIS cannot be set in Matlab.
    warning('off','MATLAB:JavaEDTAutoDelegation'); %strange warning
	imaqreset
catch
	errordlg('Error: Image Acquisition Toolbox not available! This camera needs the image acquisition toolbox.','Error!','modal')
	disp('Error: Image Acquisition Toolbox not available! This camera needs the image acquisition toolbox.')
	commandwindow
end
info = imaqhwinfo(hwinf.InstalledAdaptors{1});
if strcmp(info.AdaptorName,'gentl')
	disp('gentl adaptor found.')
else
	disp('ERROR: gentl adaptor not found. Please install the GenICam / GenTL support package from here:')
	disp('https://de.mathworks.com/matlabcentral/fileexchange/45180')
	errordlg({'ERROR: gentl adaptor not found. Please got to Matlab file exchange and search for "GenICam Interface " to install it.' 'Link: https://de.mathworks.com/matlabcentral/fileexchange/45180'},'Error, support package missing','modal')
	commandwindow
end

try
	OPTRONIS_name = info.DeviceInfo.DeviceName;
catch
	errordlg('Error: Camera not found! Is it connected?','Error!','modal')
end

if contains(OPTRONIS_name,'Cyclone-2-2000-M')
	camera_sub_type='Cyclone-2-2000-M';
elseif contains (OPTRONIS_name,'Cyclone-1HS-3500-M')
	camera_sub_type='Cyclone-1HS-3500-M';
elseif contains (OPTRONIS_name,'Cyclone-25-150-M')
	camera_sub_type='Cyclone-25-150-M';
else
	disp (OPTRONIS_name)
	disp('--> camera type unknown!')
	camera_sub_type='unknown';

end
disp(['Found camera: ' camera_sub_type])