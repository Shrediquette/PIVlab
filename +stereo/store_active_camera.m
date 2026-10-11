function store_active_camera
%STORE_ACTIVE_CAMERA Copy the data of the active camera into the stereo camera states.
%   stereo.store_active_camera
% In stereo-PIV mode, the session data of the camera that is shown (gui.retr('stereo_active_camera'))
% lives in the normal GUI data; the other camera is kept in gui.retr('stereo_cam_state'). This copies
% the active camera there too, e.g. before a session is saved. Does nothing outside stereo mode.
if ~isequal(gui.retr('stereomode'), 1)
    return
end
active = gui.retr('stereo_active_camera');
if isempty(active)
    active = 1;
end
if isempty(gui.retr('stereo_calib'))
    gui.put('stereo_check', stereo.check_result('collect')); % 2D check result of this camera
end
state = gui.retr('stereo_cam_state');
if ~iscell(state) || numel(state) ~= 2
    state = {struct(), struct()};
end
state{active} = stereo.collect_camera;
gui.put('stereo_cam_state', state);
end
