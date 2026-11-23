function cameras = setup_of_cameras(state)
%SETUP_OF_CAMERAS Per-camera setup data (stereo.setup_keys: lens calibration, board image) of both cameras.
%   cameras = stereo.setup_of_cameras(state)
%   state    gui.retr('stereo_cam_state') after stereo.store_active_camera
%   cameras  1x2 cell of structs with the fields of stereo.setup_keys that the camera has
% Kept for new images of the same cameras (stereo import, two combined cameras).
keys = stereo.setup_keys;
cameras = cell(1, 2);
for k = 1:2
    cameras{k} = struct();
    for i = 1:numel(keys)
        if isfield(state{k}, keys{i})
            cameras{k}.(keys{i}) = state{k}.(keys{i});
        end
    end
end
end
