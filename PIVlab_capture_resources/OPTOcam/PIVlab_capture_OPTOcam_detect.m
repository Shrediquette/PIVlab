function [models,imaq_error] = PIVlab_capture_OPTOcam_detect()
%PIVlab_capture_OPTOcam_detect  Which OPTOcam models are connected.
%
%   [models,imaq_error] = PIVlab_capture_OPTOcam_detect()
%
%   models      cell array with the connected models, each once: {}, {'2_80'}, {'20_9'} or {'2_80','20_9'}
%               (two OPTOcam 2/80 of a stereo setup give {'2_80'})
%   imaq_error  0 = ok, 1 = no Image Acquisition Toolbox, 2 = no GenTL adaptor
%
%   All opened videoinputs are released and the toolbox is reset first, otherwise a camera that was plugged
%   in after the last reset is not listed. A 20/9 is found by its device name; the other GenTL cameras are
%   opened briefly (about 0.5 s each) to read their user ID, the most likely first
%   (PIVlab_capture_OPTOcam_candidates), until a 2/80 is found (PIVlab_capture_OPTOcam_model).

models = {};
imaq_error = 0;
try
	delete(imaqfind);
	imaqreset
	warning('off','imaq:gentl:noSupportedPixelFormat')
	hwinf = imaqhwinfo;
catch
	imaq_error = 1;
	return
end
imaq_error = 2;
for adaptorID = 1:numel(hwinf.InstalledAdaptors)
	%'gentl' in a normal MATLAB, 'mwgentlimaq' when the adaptor was registered by path (imaqregister)
	if ~any(strcmp(hwinf.InstalledAdaptors{adaptorID},{'gentl','mwgentlimaq'}))
		continue
	end
	imaq_error = 0;
	try
		info = imaqhwinfo(hwinf.InstalledAdaptors{adaptorID});
		for CamID = 1:numel(info.DeviceInfo) %20/9: device name only, no camera is opened
			if strcmp(PIVlab_capture_OPTOcam_model(info.DeviceInfo(CamID).DeviceName),'20_9')
				models{end+1} = '20_9'; %#ok<AGROW>
				break
			end
		end
		candidates = PIVlab_capture_OPTOcam_candidates(info.DeviceInfo); %2/80: user ID, the most likely cameras first
		for c = 1:numel(candidates)
			d = info.DeviceInfo(candidates(c));
			user_id = PIVlab_capture_OPTOcam_user_id(info.AdaptorName,d.DeviceID);
			if strcmp(PIVlab_capture_OPTOcam_model(d.DeviceName,user_id),'2_80')
				models{end+1} = '2_80'; %#ok<AGROW>
				break %one 2/80 is enough
			end
		end
	catch
	end
end
models = sort(models); %fixed order: '20_9' before '2_80'
