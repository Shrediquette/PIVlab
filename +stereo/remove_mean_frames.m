function removed = remove_mean_frames
%REMOVE_MEAN_FRAMES Remove the mean frames (temporal operations) from both cameras (stereo-PIV).
%   removed = stereo.remove_mean_frames   true if there were mean frames
% Mean frames are made from the current result. ANALYZE and the vector validation in stereo mode
% rebuild the result from the 2D results of both cameras (stereo.per_camera), so the mean frames are
% removed first, from the file lists of both cameras (2D PIVlab removes them at ANALYZE too).
ismean = gui.retr('ismean');
removed = any(ismean == 1);
if ~removed
    return
end
filepath = gui.retr('filepath');
n_real = numel(filepath) / 2 - sum(ismean == 1);
keep = 1:2 * n_real;
for name = {'filepath', 'filename', 'framenum', 'framepart'}
    value = gui.retr(name{1});
    gui.put(name{1}, value(keep, :));
end
masks_in_frame = gui.retr('masks_in_frame');
if iscell(masks_in_frame) && numel(masks_in_frame) > n_real
    gui.put('masks_in_frame', masks_in_frame(1:n_real));
end
resultslist = gui.retr('resultslist');
if size(resultslist, 2) > n_real
    gui.put('resultslist', resultslist(:, 1:n_real));
end
gui.put('ismean', []);
gui.put('derived', []);
stereo.sync_mean_frames % the other camera: only its real image pairs
handles = gui.gethand;
if get(handles.fileselector, 'Value') > n_real % a mean frame was shown
    set(handles.fileselector, 'Value', n_real);
end
gui.sliderrange(0)
end
