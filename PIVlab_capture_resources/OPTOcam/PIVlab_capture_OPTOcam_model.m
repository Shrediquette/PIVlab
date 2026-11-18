function model = PIVlab_capture_OPTOcam_model(device_name,user_id)
%PIVlab_capture_OPTOcam_model  Which OPTOcam a GenTL device is.
%
%   model = PIVlab_capture_OPTOcam_model(device_name)          (20/9 only, no camera opened)
%   model = PIVlab_capture_OPTOcam_model(device_name,user_id)
%
%   device_name  DeviceName of one entry of imaqhwinfo('gentl').DeviceInfo
%   user_id      DeviceUserID of the camera (PIVlab_capture_OPTOcam_user_id)
%   model        '20_9' (OPTOcam 20/9), '2_80' (OPTOcam 2/80) or '' (another camera)
%
%   It is the only place where the two models are told apart.
%   - OPTOcam 20/9: the USB Vendor ID (VID164C) is part of the device name. It is fixed in the hardware.
%   - OPTOcam 2/80: the user ID set before shipping: 'OPTOcam' and one of '2/80', '2-80', '280', '2_80'
%     (case insensitive). It is not part of the device name, so the camera has to be opened to read it.

model = '';
if nargin < 2
	user_id = '';
end
if ~(ischar(device_name) || isstring(device_name))
	device_name = '';
end
if ~(ischar(user_id) || isstring(user_id))
	user_id = '';
end
device_name = char(device_name);
user_id = char(user_id);
if contains(device_name,'VID164C','IgnoreCase',true)
	model = '20_9';
elseif contains(user_id,'OPTOcam','IgnoreCase',true)
	if contains(user_id,'2/80') || contains(user_id,'2-80') || contains(user_id,'280') || contains(user_id,'2_80')
		model = '2_80';
	end
end
