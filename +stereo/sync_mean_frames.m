function sync_mean_frames
%SYNC_MEAN_FRAMES Give the other camera the same mean frames as the camera that is shown (stereo-PIV).
%   stereo.sync_mean_frames
% Temporal operations (mean, sum, stdev, TKE, phase mean) append "frames" to the file list of the GUI;
% in stereo mode the file lists are per camera (stereo.camera_data_keys). After a temporal operation, or
% after a mean frame was removed, this makes the file list of the other camera match: its real image
% pairs, then one entry pair per mean frame, which shows the image of the same position as the camera
% that is shown. Mean frames are always behind the real image pairs (gui.retr('ismean')).
if ~isequal(gui.retr('stereomode'), 1)
    return
end
ismean = gui.retr('ismean');
filepath = gui.retr('filepath');
filename = gui.retr('filename');
n_mean = sum(ismean == 1);
n_real = numel(filepath) / 2 - n_mean;
other = 3 - gui.retr('stereo_active_camera');
state = gui.retr('stereo_cam_state');
camera = state{other};
keep = 1:2 * n_real;
camera.filepath = camera.filepath(keep);
camera.filename = camera.filename(keep);
camera.framenum = camera.framenum(keep, :);
camera.framepart = camera.framepart(keep, :);
if iscell(camera.masks_in_frame) && numel(camera.masks_in_frame) > n_real
    camera.masks_in_frame = camera.masks_in_frame(1:n_real);
end
for i = 2 * n_real + 1:numel(filepath)
    % the image of the same position in the list of the other camera
    position = find(strcmp(filepath(1:2 * n_real), filepath{i}), 1);
    if isempty(position)
        position = 1;
    end
    camera.filepath{i, 1} = camera.filepath{position};
    camera.filename{i, 1} = filename{i};
    camera.framenum(i, :) = camera.framenum(position, :);
    camera.framepart(i, :) = camera.framepart(position, :);
end
state{other} = camera;
gui.put('stereo_cam_state', state);
end
