function disparity = measure_disparity(imgs, calib, opts, verbose, backgrounds, progress_target)
%MEASURE_DISPARITY Misalignment between the rectified views of both cameras (disparity correction).
%   disparity = stereo.measure_disparity(imgs, calib, opts)
%   imgs   1x2 cell, pivlab image sets of camera 1 and 2 (pivlab.readImages; pivlab.preprocess sets
%          the image pre-processing, which is used here too; region of interest and mask are not used)
%   calib  stereo.calibrate
%   opts   stereo.defaults() (groups disparity and Parallel)
%
% The A image of camera 1 is correlated with the A image of camera 2 (both rectified onto the common
% grid, minimum-intensity background removed, pre-processed), for opts.disparity.Pairs image pairs
% spread over the series. The validated maps are smoothed and averaged, then a smooth model is fitted
% (opts.disparity.Model, stereo.fit_disparity). With opts.disparity.Passes > 1 the disparity is
% measured again on the corrected images and the residual is added, until it is below
% opts.disparity.StopThreshold [px].
%   disparity.u_full, v_full     disparity of every output pixel [px] (camera 1 -> camera 2)
%   disparity.x, y, u_mean_smooth, v_mean_smooth   the map on the PIV grid
%   disparity.raw                first measurement (mean, scatter, number of valid pairs)
%   disparity.fit                model fit of the first measurement
%   disparity.residual_history   [max rms] of each residual measurement inside the overlap
%   disparity.background         minimum-intensity backgrounds used (per camera, [] = none)
% backgrounds (optional): {background of camera 1, of camera 2} (raw camera images, struct with A and B)
%   to use instead of computing them (e.g. disparity.background of an earlier measurement)
% progress_target (optional): text control of the GUI for the progress and the remaining time (gui.pivprogress,
%   as in the PIV analysis; also the progress bar of the GUI)
if nargin < 4
    verbose = true;
end
if nargin < 5
    backgrounds = {};
end
if nargin < 6
    progress_target = [];
end
% progress: one disparity pair takes about as long as reading 50 images for the minimum background (30 with
% parallel processing; measured on 6243 x 4635 px images, the ratio hardly depends on the image size)
pair_units = 50;
if opts.Parallel
    pair_units = 30;
end
d = opts.disparity;
n_all = imgs{1}.pairs;
if imgs{2}.pairs ~= n_all
    error('stereo:measure_disparity', 'Both cameras must have the same number of image pairs (%d and %d).', n_all, imgs{2}.pairs);
end
pairs = 1:n_all;
if ~isempty(d.Pairs) && d.Pairs < n_all
    pairs = unique(round(linspace(1, n_all, d.Pairs)));
end
hbar = [];
if ~isempty(progress_target)
    units = pair_units * numel(pairs) * max(d.Passes, 1);
    if numel(backgrounds) ~= 2
        units = units + background_units(imgs{1}) + background_units(imgs{2});
    end
    hbar = gui.pivprogress(units, progress_target);
end
try
    disparity = measure(imgs, calib, opts, verbose, backgrounds, pairs, hbar, pair_units);
catch err
    close_progress(hbar)
    rethrow(err)
end
close_progress(hbar)
end

function disparity = measure(imgs, calib, opts, verbose, backgrounds, pairs, hbar, pair_units)
d = opts.disparity;
% image sets that read the A images for the disparity: minimum background, no ROI
for k = 1:2
    if numel(backgrounds) == 2
        bg = backgrounds{k};
    else
        bg = stereo.min_background(imgs{k}, d, verbose);
        if ~isempty(hbar)
            hbar.iterate(background_units(imgs{k}));
            drawnow
        end
    end
    imgs{k}.background = bg;
    if ~isempty(imgs{k}.preprocess)
        imgs{k}.preprocess.Roi = [];
    end
end
disparity_background = {imgs{1}.background, imgs{2}.background};

imgs = stereo.rectified_images(imgs, calib, []);
raw = measure_once(imgs, calib, pairs, d, opts.Parallel, verbose, hbar, pair_units);
[u_grid, v_grid, fit] = model_grid(calib, raw, d.Model);
disparity = stereo.disparity_field(calib, raw.x, raw.y, u_grid, v_grid);
disparity.u_mean = raw.u_mean;
disparity.v_mean = raw.v_mean;
disparity.valid_fraction = raw.valid_fraction;
disparity.raw = raw;
disparity.fit = fit;
disparity.model = char(d.Model);
disparity.pairs = pairs;

inside = ~calib.mask(sub2ind(size(calib.mask), min(max(round(double(raw.y)), 1), size(calib.mask, 1)), ...
    min(max(round(double(raw.x)), 1), size(calib.mask, 2))));
disparity.residual_history = zeros(0, 2);
for it = 2:d.Passes
    imgs = stereo.rectified_images(imgs, calib, disparity);
    raw_r = measure_once(imgs, calib, pairs, d, opts.Parallel, verbose, hbar, pair_units);
    [ru, rv] = model_grid(calib, raw_r, d.Model);
    r = sqrt(ru(inside) .^ 2 + rv(inside) .^ 2);
    disparity.residual_history(end + 1, :) = [max(r), sqrt(mean(r .^ 2))];
    if verbose
        fprintf('Disparity pass %d: residual max %.3g px, rms %.3g px\n', it, max(r), sqrt(mean(r .^ 2)));
    end
    total_u = disparity.u_mean_smooth + ru;
    total_v = disparity.v_mean_smooth + rv;
    keep = rmfield(disparity, {'u_full', 'v_full', 'xq', 'yq', 'x', 'y', 'u_mean_smooth', 'v_mean_smooth'});
    disparity = stereo.disparity_field(calib, raw.x, raw.y, total_u, total_v);
    names = fieldnames(keep);
    for f = 1:numel(names)
        disparity.(names{f}) = keep.(names{f});
    end
    disparity.residual_u = ru;
    disparity.residual_v = rv;
    disparity.raw_residual = raw_r;
    if max(r) < d.StopThreshold
        break
    end
end
disparity.background = disparity_background;
end

function n = background_units(img_set)
% progress units of the minimum background of one camera: its A images
n = max(1, floor(numel(img_set.filepath) / 2));
end

function close_progress(hbar)
if ~isempty(hbar)
    close(hbar);
    gui.update_progress(0)
end
end

function raw = measure_once(imgs, calib, pairs, d, parallel, verbose, hbar, pair_units)
% one disparity measurement over the selected image pairs
interrogationarea = d.InterrogationArea;
if isempty(interrogationarea)
    interrogationarea = floor(min(calib.Ravg.ImageSize) / 10) * 2;
end
d.PassSize2 = min(d.PassSize2, round(interrogationarea / 4) * 2); % second pass at most half the first
n = numel(pairs);
out = cell(n, 1);
mask = calib.mask;
if parallel
    if misc.pivparpool('size') == 0
        gcp();
    end
    imgs1 = imgs{1};
    imgs2 = imgs{2};
    parfor i = 1:n
        out{i} = disparity_pair(imgs1, imgs2, pairs(i), mask, interrogationarea, d);
        if ~isempty(hbar)
            hbar.iterate(pair_units);
        end
    end
else
    for i = 1:n
        out{i} = disparity_pair(imgs{1}, imgs{2}, pairs(i), mask, interrogationarea, d);
        if ~isempty(hbar)
            hbar.iterate(pair_units);
            drawnow % the progress timer updates the GUI
        end
        if verbose
            fprintf('  disparity: image pair %d of %d\n', i, n);
        end
    end
end
sz = size(out{1}.x);
u_filt = zeros([sz n]); v_filt = u_filt; u_smooth = u_filt; v_smooth = u_filt;
for i = 1:n
    u_filt(:,:,i) = out{i}.u_filt;
    v_filt(:,:,i) = out{i}.v_filt;
    u_smooth(:,:,i) = out{i}.u_filt_smooth;
    v_smooth(:,:,i) = out{i}.v_filt_smooth;
end
raw.x = out{1}.x;
raw.y = out{1}.y;
raw.u_mean = mean(u_smooth, 3, 'omitnan');
raw.v_mean = mean(v_smooth, 3, 'omitnan');
raw.u_mean_smooth = misc.smoothn(raw.u_mean, d.SmoothMean);
raw.v_mean_smooth = misc.smoothn(raw.v_mean, d.SmoothMean);
raw.valid_fraction = squeeze(mean(~isnan(u_filt), [1 2])); % per image pair
% statistics of the validated vectors (for the model fits and diagnostics)
raw.u = mean(u_filt, 3, 'omitnan');
raw.v = mean(v_filt, 3, 'omitnan');
raw.u_std = std(u_filt, 0, 3, 'omitnan');
raw.v_std = std(v_filt, 0, 3, 'omitnan');
raw.n_valid = sum(~isnan(u_filt) & ~isnan(v_filt), 3);
raw.u_frames = u_filt;
raw.v_frames = v_filt;
end

function r = disparity_pair(imgs1, imgs2, pair, mask, interrogationarea, d)
% camera 1 A image against camera 2 A image (rectified, background removed, pre-processed)
image1 = pivlab.getImage(imgs1, pair);
image2 = pivlab.getImage(imgs2, pair);
[x, y, u, v] = piv.piv_FFTmulti(image1=image1, image2=image2, interrogationarea=interrogationarea, ...
    step=interrogationarea / 2, subpixfinder=1, mask_inpt=mask, roi_inpt=[], passes=2, int2=d.PassSize2, ...
    int3=[], int4=[], imdeform='*linear', repeat=0, mask_auto=0, do_linear_correlation=0, ...
    do_correlation_matrices=0, repeat_last_pass=0, delta_diff_min=0);
[u_filt, v_filt] = postproc.PIVlab_postproc(u=u, v=v, calu=1, calv=1, valid_vel=[], do_stdev_check=1, ...
    stdthresh=d.StdevThreshold, do_local_median=1, neigh_thresh=d.LocalMedianThreshold);
r.x = x;
r.y = y;
r.u_filt = double(u_filt);
r.v_filt = double(v_filt);
r.u_filt_smooth = double(misc.smoothn(u_filt, d.SmoothFrame));
r.v_filt_smooth = double(misc.smoothn(v_filt, d.SmoothFrame));
end

function [u_grid, v_grid, fit] = model_grid(calib, raw, model)
% disparity map on the PIV grid from one measurement
fit = stereo.fit_disparity(calib, raw, model);
u_grid = fit.u;
v_grid = fit.v;
end
