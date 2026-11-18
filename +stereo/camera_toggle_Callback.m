function camera_toggle_Callback(~, ~, ~)
%CAMERA_TOGGLE_CALLBACK CAM button of the Tools panel.
%Image Acquisition panel with stereo acquisition: cameras shown, CAM 1+2 -> CAM 1 -> CAM 2 -> CAM 1+2
%(acquisition.camera_view; also while the live image or the PIV capture runs).
%Stereo-PIV mode: camera switch, camera 1 <-> camera 2.
if acquisition.camera_view_active
    view = acquisition.camera_view();
    gui.put('capture_camera_view', mod(view + 1, 3));
    acquisition.camera_view_button;
    acquisition.apply_camera_view;
    return
end
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
