function cam_calibration_Callback(caller, ~, ~)
handles=gui.gethand;
if strcmpi(caller.Text, 'camera 1')
    gui.put('current_cam_nr',1);
    handles.calib_undist_cam_label.String = 'Current camera: CAMERA 1';
elseif strcmpi(caller.Text, 'camera 2')
    gui.put('current_cam_nr',2);
    handles.calib_undist_cam_label.String = 'Current camera: CAMERA 2';
end
gui.switchui('multip26')