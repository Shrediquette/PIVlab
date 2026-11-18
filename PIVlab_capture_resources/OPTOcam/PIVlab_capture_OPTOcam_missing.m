function missing = PIVlab_capture_OPTOcam_missing
%PIVlab_capture_OPTOcam_missing  true (and a message) if "PIVlab LD-PS + OPTOcam" is selected but no OPTOcam was found.
%   Used at the start of the callbacks that talk to the camera. The laser can still be used (2/80 timing,
%   see select_capture_config_Callback).
missing = false;
handles = gui.gethand;
value = get(handles.ac_config,'value');
OPTOcam_missing = gui.retr('OPTOcam_missing');
if strcmpi(char(handles.ac_config.String(value)),'PIVlab LD-PS + OPTOcam') && isequal(OPTOcam_missing,true)
	missing = true;
	gui.custom_msgbox('error',getappdata(0,'hgui'),'No OPTOcam found','No OPTOcam found. Connect it and select the entry again.','modal');
end
