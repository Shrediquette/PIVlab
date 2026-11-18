function candidates = PIVlab_capture_OPTOcam_candidates(device_info)
%PIVlab_capture_OPTOcam_candidates  GenTL devices that may be an OPTOcam 2/80, the most likely first.
%
%   candidates = PIVlab_capture_OPTOcam_candidates(device_info)
%
%   device_info  imaqhwinfo(adaptor).DeviceInfo
%   candidates   indices into device_info
%
%   A 2/80 is only known from its user ID, so these cameras have to be opened (PIVlab_capture_OPTOcam_user_id).
%   A 20/9 (known from its device name) is left out. The device name ends with the serial number in brackets,
%   e.g. 'xxx (41932848)'; the serial numbers of the 2/80 start with 4, so these cameras are opened first.

likely = [];
others = [];
for CamID = 1:numel(device_info)
	device_name = device_info(CamID).DeviceName;
	if strcmp(PIVlab_capture_OPTOcam_model(device_name),'20_9')
		continue
	end
	serial = regexp(char(device_name),'\((\d+)\)\s*$','tokens','once');
	if ~isempty(serial) && strncmp(serial{1},'4',1)
		likely(end+1) = CamID; %#ok<AGROW>
	else
		others(end+1) = CamID; %#ok<AGROW>
	end
end
candidates = [likely others];
