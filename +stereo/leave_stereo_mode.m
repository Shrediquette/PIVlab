function leave_stereo_mode
%LEAVE_STEREO_MODE Back to 2D PIV: remove the stereo data (the other camera, calibration, disparity).
%   stereo.leave_stereo_mode
% The data of the active camera stays in the GUI like a 2D session; it is normally replaced right
% afterwards (new images). Does nothing outside stereo mode.
if ~isequal(gui.retr('stereomode'), 1)
    return
end
gui.put('stereomode', 0);
gui.put('stereo_active_camera', 1);
gui.put('stereo_cam_state', []);
gui.put('stereo_calib', []);
gui.put('stereo_disparity', []);
gui.put('stereo_maps', []);
gui.put('stereo_maps_plain', []);
gui.put('stereo_result', []);
gui.put('stereo_check', []);
gui.put('stereo_vel', []);
handles = gui.gethand;
set(handles.calib_undist_cam_label, 'String', 'N/A', 'ForegroundColor', get(handles.filenameshow, 'ForegroundColor'));
set(handles.calib_rect_cam_label, 'String', 'N/A', 'ForegroundColor', get(handles.filenameshow, 'ForegroundColor'));
gui.update_dependent_controls(handles);
end
