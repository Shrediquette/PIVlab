function cam_calibration_Callback(~, ~, ~)
if ~misc.require_toolbox('Computer Vision Toolbox','Camera calibration')
    return
end
handles=gui.gethand;
if ~isequal(gui.retr('stereomode'), 1) % stereo-PIV: the panel is for the active camera (label set in update_dependent_controls)
    handles.calib_undist_cam_label.String = 'Current camera: CAMERA 1';
end
gui.switchui('multip26')
