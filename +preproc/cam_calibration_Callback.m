function cam_calibration_Callback(caller, ~, ~)
handles=gui.gethand;
if isequal(gui.retr('stereomode'), 1) % stereo-PIV: the menu entry selects the camera
    if strcmpi(caller.Text, 'camera 2')
        stereo.switch_camera(2);
    else
        stereo.switch_camera(1);
    end
else
    handles.calib_undist_cam_label.String = 'Current camera: CAMERA 1';
end
gui.switchui('multip26')
