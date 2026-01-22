function camera_setup_Callback(~,~,~)
camera_type=gui.retr('camera_type');
if strcmp(camera_type,'chronos')
    PIVlab_capture_chronos_settings_GUI
elseif strcmp(camera_type,'OPTOcam')
    PIVlab_capture_OPTOcam_settings_GUI
elseif strcmp(camera_type,'OPTRONIS')
    if ~verLessThan('matlab','25')
        PIVlab_capture_OPTRONIS_settings_GUI
    else
        gui.custom_msgbox('warn',getappdata(0,'hgui'),'Newer Matlab required','OPTRONIS cameras require at least Matlab R2025a to set bit depth and gain.','modal');
    end
elseif strcmp(camera_type,'pco_panda') || strcmp(camera_type,'pco_edge26')
    PIVlab_capture_panda_settings_GUI
else
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Not available','Not available for the selected camera model.','modal');
end