function cam_calibration_Callback(~, ~, ~)
handles=gui.gethand;
if ~isequal(gui.retr('stereomode'), 1) % stereo-PIV: the panel is for the active camera (label set in update_dependent_controls)
    handles.calib_undist_cam_label.String = 'Current camera: CAMERA 1';
end
gui.switchui('multip26')
