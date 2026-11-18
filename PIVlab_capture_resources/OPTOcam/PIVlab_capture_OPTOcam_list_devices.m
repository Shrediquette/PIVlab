function PIVlab_capture_OPTOcam_list_devices
%PIVlab_capture_OPTOcam_list_devices  Prints everything that could identify the connected GenTL cameras.
%   Diagnostic tool: run it with an OPTOcam connected and send the output to the developers. It shows the
%   device name, the user ID and how PIVlab_capture_OPTOcam_model classifies the camera.
%   Each camera is opened briefly (about 2 s per camera).
delete(imaqfind); imaqreset
hwinf = imaqhwinfo;
for a = 1:numel(hwinf.InstalledAdaptors)
	adaptor = hwinf.InstalledAdaptors{a};
	if ~any(strcmp(adaptor,{'gentl','mwgentlimaq'}))
		continue
	end
	info = imaqhwinfo(adaptor);
	for k = 1:numel(info.DeviceInfo)
		d = info.DeviceInfo(k);
		fprintf('\n--- %s device %d ---\nName: %s\nDefault format: %s\nFormats: %s\n', ...
			adaptor, k, d.DeviceName, d.DefaultFormat, strjoin(d.SupportedFormats, ', '));
		user_id = '';
		try
			v = videoinput(adaptor, d.DeviceID);
			s = v.Source;
			for p = {'DeviceVendorName','DeviceModelName','DeviceManufacturerInfo','DeviceSerialNumber', ...
					'DeviceVersion','DeviceFirmwareVersion','DeviceUserID','SensorWidth','SensorHeight','WidthMax','HeightMax'}
				try
					fprintf('%s: %s\n', p{1}, num2str(s.(p{1})));
				catch
				end
			end
			try
				user_id = char(s.DeviceUserID);
			catch
			end
			delete(v);
		catch ME
			fprintf('Could not open the camera: %s\n', ME.message);
		end
		fprintf('Detected as: "%s"\n', PIVlab_capture_OPTOcam_model(d.DeviceName, user_id));
	end
end
delete(imaqfind); imaqreset
