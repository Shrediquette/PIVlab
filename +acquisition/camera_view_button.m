function camera_view_button()
%CAMERA_VIEW_BUTTON Label and visibility of the CAM button of the Tools panel.
%Image Acquisition panel with stereo acquisition (two cameras): "CAM 1+2" / "CAM 1" / "CAM 2" (acquisition.camera_view).
%Otherwise: the camera switch of stereo-PIV ("CAM 1" / "CAM 2", only in stereo mode).
handles = gui.gethand;
button = handles.stereo_camera_toggle;
if acquisition.camera_view_active
    view = acquisition.camera_view();
    if view == 0
        label = 'CAM 1+2';
        cam_color = [0.25 0.25 0.25];
        text_color = [1 1 1];
    else
        label = ['CAM ' int2str(view)];
        [cam_color, text_color] = stereo.camera_colors(view);
    end
    set(button, 'Visible', 'on', 'String', label, 'BackgroundColor', cam_color, 'ForegroundColor', text_color, ...
        'TooltipString', 'Cameras shown in the live image and PIV capture: both, camera 1 or camera 2 (both cameras always record)');
elseif isequal(gui.retr('stereomode'), 1)
    active = gui.retr('stereo_active_camera');
    if isempty(active)
        active = 1;
    end
    [cam_color, text_color] = stereo.camera_colors(active);
    set(button, 'Visible', 'on', 'String', ['CAM ' int2str(active)], 'BackgroundColor', cam_color, 'ForegroundColor', text_color, ...
        'TooltipString', 'Switch between camera 1 and camera 2');
else
    set(button, 'Visible', 'off');
end
end
