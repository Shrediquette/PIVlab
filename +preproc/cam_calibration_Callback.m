function cam_calibration_Callback(~, ~, ~)
if ~misc.require_toolbox('Computer Vision Toolbox','Camera calibration')
    return
end
stereo.acquisition_stereo_mode % stereo acquisition ticked: one lens calibration per camera (CAM 1 / CAM 2)
handles=gui.gethand;
if ~isequal(gui.retr('stereomode'), 1) % stereo-PIV: the panel is for the active camera (label set in update_dependent_controls)
    handles.calib_undist_cam_label.String = 'Current camera: CAMERA 1';
end
gui.update_calibration_buttons(handles);
gui.switchui('multip26')
