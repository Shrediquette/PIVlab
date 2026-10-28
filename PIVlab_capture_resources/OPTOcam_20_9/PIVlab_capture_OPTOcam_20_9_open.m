function [OPTOcam_vid,imaq_error] = PIVlab_capture_OPTOcam_20_9_open(bitmode)
%PIVlab_capture_OPTOcam_20_9_open  Find and open the OPTOcam 20/9, or reuse the already opened camera.
%
%   [OPTOcam_vid,imaq_error] = PIVlab_capture_OPTOcam_20_9_open(bitmode)
%
%   bitmode      8 (Mono8) or 12 (Mono12p, packed -> higher frame rate than Mono12)
%   imaq_error   0 = ok, 1 = no Image Acquisition Toolbox, 2 = no GenTL adaptor, 3 = camera not found
%
%   Opening the camera (videoinput) takes ~2 s. The videoinput object is therefore kept after a
%   capture (tagged 'OPTOcam_20_9') and reused by the next start if the pixel format still matches.
%   All camera settings are applied by the callers every time, so a reused object behaves like a
%   fresh one. Changing the configuration in the GUI releases the camera
%   (select_capture_config_Callback: delete(imaqfind) + imaqreset). A kept camera that was unplugged in
%   the meantime is opened again after an imaqreset.

if bitmode == 8
	video_format = 'Mono8';
else
	video_format = 'Mono12p';
end
warning('off','imaq:gentl:noSupportedPixelFormat')

%% fast path: reuse the opened camera
disconnected = false; %the kept camera was unplugged: reset the toolbox before opening the camera again
try
	OPTOcam_vid = imaqfind('Tag','OPTOcam_20_9');
	if iscell(OPTOcam_vid) %imaqfind returns a cell array here
		OPTOcam_vid = [OPTOcam_vid{:}];
	end
	if isscalar(OPTOcam_vid) && isvalid(OPTOcam_vid) && ~camera_connected(OPTOcam_vid)
		disconnected = true;
	elseif isscalar(OPTOcam_vid) && isvalid(OPTOcam_vid) && strcmp(OPTOcam_vid.VideoFormat,video_format)
		if isrunning(OPTOcam_vid)
			stop(OPTOcam_vid);
		end
		stoppreview(OPTOcam_vid);
		flushdata(OPTOcam_vid);
		OPTOcam_vid.ErrorFcn = ''; %set again by synced_start where needed
		imaq_error = 0;
		disp('Found camera: OPTOcam 20/9 (already open)')
		return
	end
catch
	%camera unplugged, toolbox reset etc. -> open it again below
	disconnected = true;
end

%% slow path: find the camera and open it
OPTOcam_vid = [];
imaq_error = 0;
try
	delete(imaqfind); %clears all previous videoinputs
	if disconnected
		imaqreset %the toolbox finds the plugged-in camera again only after a reset
	end
	warning off
	hwinf = imaqhwinfo;
catch
	imaq_error = 1;
end
if imaq_error == 0 && isempty(hwinf.InstalledAdaptors)
	imaq_error = 2;
end
if imaq_error == 0
	imaq_error = 2;
	for adaptorID = 1:numel(hwinf.InstalledAdaptors)
		info = imaqhwinfo(hwinf.InstalledAdaptors{adaptorID});
		%'gentl' in a normal MATLAB, 'mwgentlimaq' when the adaptor was registered by path (imaqregister)
		if strcmp(info.AdaptorName,'gentl') || strcmp(info.AdaptorName,'mwgentlimaq')
			imaq_error = 0;
			break
		end
	end
end
if imaq_error == 0
	%Identify the camera by the OEM USB Vendor ID embedded in its enumerated device name, so no camera
	%has to be opened just to detect it (fast). The Vendor ID is fixed in the hardware and is therefore
	%identical on every unit of this camera; it also differs from the 2/80's manufacturer.
	imaq_error = 3;
	try
		for CamID = 1:size(info.DeviceInfo,2)
			if contains(info.DeviceInfo(CamID).DeviceName,'VID164C','IgnoreCase',true)
				imaq_error = 0;
				break
			end
		end
	catch
	end
end

if imaq_error == 1
	gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Error: Image Acquisition Toolbox not available! This camera needs the image acquisition toolbox.','modal');
	disp('Error: Image Acquisition Toolbox not available! This camera needs the image acquisition toolbox.')
elseif imaq_error == 2
	disp('ERROR: gentl adaptor not found. Please install the GenICam / GenTL support package from here:')
	disp('https://de.mathworks.com/matlabcentral/fileexchange/45180')
	gui.custom_msgbox('error',getappdata(0,'hgui'),'Error, support package missing',{'ERROR: gentl adaptor not found. Please got to Matlab file exchange and search for "GenICam Interface " to install it.' 'Link: https://de.mathworks.com/matlabcentral/fileexchange/45180'},'modal');
elseif imaq_error == 3
	gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Error: Camera not found! Is it connected?','modal');
end
if imaq_error ~= 0
	return
end

OPTOcam_vid = videoinput(info.AdaptorName,info.DeviceInfo(CamID).DeviceID,video_format);
OPTOcam_vid.Tag = 'OPTOcam_20_9';
disp('Found camera: OPTOcam 20/9')

function connected = camera_connected(OPTOcam_vid)
%After unplugging and plugging in the camera, the kept videoinput is still valid, but the camera does not
%answer any more: its ExposureTime limits are then 0 (error "'ExposureTime' value must be less than or equal to 0").
try
	OPTOcam_src = OPTOcam_vid.Source;
	limits = propinfo(OPTOcam_src,'ExposureTime').ConstraintValue;
	connected = limits(2) > 0;
catch
	connected = false;
end
