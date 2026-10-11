function camera = collect_camera
%COLLECT_CAMERA The per-camera data and controls that are in the GUI now (stereo.camera_data_keys,
%stereo.camera_controls), as stored in gui.retr('stereo_cam_state'){k}.
camera = struct();
keys = stereo.camera_data_keys;
for i = 1:numel(keys)
    camera.(keys{i}) = gui.retr(keys{i});
end
handles = gui.gethand;
tags = stereo.camera_controls;
camera.controls = struct();
for i = 1:numel(tags)
    camera.controls.(tags{i}) = get(handles.(tags{i}), 'Value');
end
end
