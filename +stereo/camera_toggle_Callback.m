function camera_toggle_Callback(~, ~, ~)
%CAMERA_TOGGLE_CALLBACK Camera switch of the Tools panel: camera 1 <-> camera 2.
if ~isequal(gui.retr('stereomode'), 1)
    return
end
active = gui.retr('stereo_active_camera');
if isempty(active) || active == 2
    stereo.switch_camera(1);
else
    stereo.switch_camera(2);
end
end
