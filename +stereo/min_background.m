function bg = min_background(imgs, opts, verbose)
%MIN_BACKGROUND Minimum-intensity background of the A images of one camera (raw camera image).
%   bg = stereo.min_background(imgs, opts)
%   imgs  pivlab image set of one camera
%   opts  stereo.defaults().disparity (MinBackground, MinBackgroundFrames, MinBackgroundMaxFrames)
%   bg    struct with A (raw camera image) and B = [] for import.read_frame, or [] when there is
%         no background (switched off, or fewer than opts.MinBackgroundFrames A images)
% Used for the disparity measurement: static image content (reflections, walls, objects outside
% the light sheet) would otherwise give wrong correlation peaks. If the image set already has a
% minimum-intensity background in camera coordinates (computed with a stereo camera), it is reused.
if nargin < 3
    verbose = true;
end
bg = [];
if ~opts.MinBackground
    return
end
stereo_cam = isfield(imgs.cam, 'stereo_map') && ~isempty(imgs.cam.stereo_map);
if ~isempty(imgs.background) && isfield(imgs.background, 'mode') && imgs.background.mode == "min" && stereo_cam
    bg = struct('A', imgs.background.A, 'B', []);
    return
end
n_a = numel(imgs.filepath) / 2;
sel = 1:2:numel(imgs.filepath); % the A image of every pair (time-resolved: every image once)
if imgs.sequencer == 2 % reference: the A image is always the same image
    sel = 1;
end
if numel(sel) < opts.MinBackgroundFrames
    if verbose
        fprintf('Disparity: only %d A images, no minimum-intensity background is subtracted (at least %d are needed).\n', ...
            numel(sel), opts.MinBackgroundFrames);
    end
    return
end
if numel(sel) > opts.MinBackgroundMaxFrames % evenly spread over the whole recording
    sel = sel(unique(round(linspace(1, numel(sel), opts.MinBackgroundMaxFrames))));
end
src.filepath = imgs.filepath(sel);
src.framenum = imgs.framenum(sel);
src.framepart = imgs.framepart(sel, :);
if verbose
    fprintf('Disparity: minimum-intensity background from %d A images (%d image pairs)...\n', numel(sel), n_a);
end
% sequencer 0: one background from all given images; no camera: the background stays a raw image
[A, ~, msg] = preproc.compute_background(src, 0, 3, import.cam_settings());
if ~isempty(msg)
    error('stereo:min_background', '%s', msg);
end
bg = struct('A', A, 'B', []);
end

