function user_id = PIVlab_capture_OPTOcam_user_id(adaptor,device_id)
%PIVlab_capture_OPTOcam_user_id  DeviceUserID of a GenTL camera ('' if it cannot be read).
%
%   user_id = PIVlab_capture_OPTOcam_user_id(adaptor,device_id)
%
%   adaptor    'gentl' or 'mwgentlimaq'
%   device_id  DeviceID of one entry of imaqhwinfo(adaptor).DeviceInfo
%
%   If the camera is already open in PIVlab, the user ID is read from that videoinput. Otherwise the camera
%   is opened briefly (about 2 s) and closed again.

user_id = '';
try
	opened = imaqfind('DeviceID',device_id);
	if iscell(opened) %imaqfind returns a cell array here
		opened = [opened{:}];
	end
	for k = 1:numel(opened)
		if isvalid(opened(k)) && contains(opened(k).Name,['-' adaptor '-']) %Name: format-adaptor-DeviceID
			OPTOcam_src = opened(k).Source; %imaq: vid.Source.DeviceUserID in one expression is not allowed
			user_id = char(OPTOcam_src.DeviceUserID);
			return
		end
	end
	vid = videoinput(adaptor,device_id);
	try
		OPTOcam_src = vid.Source;
		user_id = char(OPTOcam_src.DeviceUserID);
	catch
	end
	delete(vid);
catch
end
