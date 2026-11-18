function changed = PIVlab_capture_OPTOcam_model_changed(expected_model)
%PIVlab_capture_OPTOcam_model_changed  After a failed OPTOcam start: is now another OPTOcam model connected?
%
%   changed = PIVlab_capture_OPTOcam_model_changed(expected_model)
%
%   expected_model  the model the driver was started for: '2_80' or '20_9'
%   changed         true: the other model is connected (and the expected one is not). The GUI was switched to
%                   it (frame rates, resolution, pulse distance limits) and the user was asked to check the
%                   settings and start again. false: nothing was changed, the caller shows its own error.
%
%   Called when the camera of the selected model is not found (open functions) or when the driver of the
%   selected model throws an error (PIVlab_capture_OPTOcam_capture_error), e.g. because the camera was swapped
%   after "PIVlab LD-PS + OPTOcam" had been selected.
changed = false;
hgui = getappdata(0,'hgui');
if isempty(hgui) || ~ishandle(hgui) %no PIVlab GUI (driver called directly)
	return
end
handles = gui.gethand;
if ~isfield(handles,'ac_config')
	return
end
value = get(handles.ac_config,'value');
if ~strcmpi(char(handles.ac_config.String(value)),'PIVlab LD-PS + OPTOcam')
	return
end
[models,imaq_error] = PIVlab_capture_OPTOcam_detect();
if imaq_error ~= 0 || isempty(models) || any(strcmp(models,expected_model))
	return
end
changed = true;
new_model = models{1}; %the expected model is not connected, so this is the other one
names = struct('m2_80','OPTOcam 2/80','m20_9','OPTOcam 20/9');
%stop the started capture / live image
gui.put('cancel_capture',1);
gui.put('capturing',0);
try
	set(handles.ac_calibcapture,'String','Start')
catch
end
gui.toolsavailable(1)
%set up the GUI for the connected camera (uses this list instead of listing the cameras again)
gui.put('OPTOcam_detected_models',models);
acquisition.select_capture_config_Callback
gui.custom_msgbox('warn',getappdata(0,'hgui'),'Other OPTOcam connected', ...
	{['An ' names.(['m' new_model]) ' is connected instead of the ' names.(['m' expected_model]) '.'] ...
	['The capture settings were switched to the ' names.(['m' new_model]) ' (frame rates, resolution, pulse distance limits).'] ...
	'Please check the settings (e.g. ROI and frame rate) and start again.'},'modal');
