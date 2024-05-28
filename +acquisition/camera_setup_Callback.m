function camera_setup_Callback(~,~,~)
camera_type=gui.gui_retr('camera_type');
if strcmp(camera_type,'chronos')
	PIVlab_capture_chronos_settings_GUI
elseif strcmp(camera_type,'OPTOcam')
	PIVlab_capture_OPTOcam_settings_GUI
elseif strcmp(camera_type,'pco_panda')
	PIVlab_capture_panda_settings_GUI
else
	uiwait(msgbox('Available for OPTOcam, Chronos and pco.panda cameras only.','modal'))
end

