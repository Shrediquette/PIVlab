function handled = redirect(action)
%REDIRECT In stereo-PIV mode, run an analysis / validation button for both cameras (stereo.per_camera).
%   handled = stereo.redirect(action): true if the button was handled here (the caller then returns).
%   Inside the camera loop of stereo.per_camera the normal 2D routine runs (handled = false).
%   Before the stereo calibration the normal 2D routine runs too: a 2D check of the camera that is shown
%   (its result goes with the camera when the camera is switched, stereo.store_active_camera).
handled = isequal(gui.retr('stereomode'), 1) && ~isequal(gui.retr('stereo_camera_loop'), 1) ...
    && ~isempty(gui.retr('stereo_calib'));
if handled
    stereo.per_camera(action);
end
end
