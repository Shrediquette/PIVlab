function img = camera_image(k, selected, corrected)
%CAMERA_IMAGE Image of camera k on the common grid of both cameras (stereo-PIV, after the calibration).
%   img = stereo.camera_image(k, selected, corrected)
%   selected   frame index (odd = A, even = B) as in import.get_img
%   corrected  true: with the disparity correction (as the GUI shows it), false: rectified only
% The background of camera k is subtracted when background subtraction is on.
calib = gui.retr('stereo_calib');
active = gui.retr('stereo_active_camera');
if k == active
    camera = stereo.collect_camera;
else
    state = gui.retr('stereo_cam_state');
    camera = state{k};
end
src.filepath = camera.filepath;
src.framenum = camera.framenum;
src.framepart = camera.framepart;
cam = import.cam_settings();
if corrected
    maps = gui.retr('stereo_maps');
    cam.stereo_map = maps{k};
else
    plain = gui.retr('stereo_maps_plain'); % rectification without disparity correction, made once
    if ~iscell(plain) || numel(plain) ~= 2 || isempty(plain{k})
        plain = {stereo.camera_map(calib, 1, []), stereo.camera_map(calib, 2, [])};
        gui.put('stereo_maps_plain', plain);
    end
    cam.stereo_map = plain{k};
end
bg = [];
handles = gui.gethand;
if get(handles.bg_subtract, 'Value') > 1 && ~isempty(camera.bg_img_A) && ~isempty(camera.bg_img_B)
    bg = struct('A', camera.bg_img_A, 'B', camera.bg_img_B);
end
img = import.read_frame(src, selected, cam, bg);
end
