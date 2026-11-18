function out = limit_test(U, V, W, velrect, roi_freehand, notch_limits, residual, W_px, stereo_filters)
%LIMIT_TEST Vectors of a 3D result outside the velocity limits or rejected by the stereo filters (GUI and API).
%   out = stereo.limit_test(U, V, W, velrect, roi_freehand, notch_limits)
%   out = stereo.limit_test(U, V, W, velrect, roi_freehand, notch_limits, residual, W_px, stereo_filters)
%   U, V, W          one image pair, in the units of the limits (calibrated like u, v; W with calibrate.w_factor)
%   velrect          rectangle [umin vmin width height] (as postproc.PIVlab_postproc), [] = none
%   roi_freehand     freehand shape (images.roi.Freehand) in the u-v plane, [] = none; NaN vectors are not tested
%   notch_limits     [low high]: vectors with a 3D magnitude sqrt(U^2 + V^2 + W^2) between them, [] = none
%   residual         reconstruction residual of this image pair [px] (stereo.reconstruct)
%   W_px             W of this image pair in px per image pair (for the median test, as the local median
%                    filter of 2D results works on px)
%   stereo_filters   filters of the stereo based validation panel, each [] = off:
%                    .residual_thresh  vectors with |residual| above it [px] (both cameras do not fit one 3D velocity)
%                    .w_median_thresh  normalized median test of W_px (Westerweel & Scarano 2005, as the local
%                                      median filter, postproc.PIVlab_postproc)
%                    .w_limits         [wmin wmax]: vectors with W outside this range (units of W)
%   out              logical map: true = rejected (discarded in both cameras, stereo.limit_discard)
if nargin < 9
    stereo_filters = no_stereo_filters();
end
out = false(size(U));
U = double(U);
V = double(V);
W = double(W);
if ~isempty(velrect)
    out = out | U < velrect(1) | U > velrect(1) + velrect(3) | V < velrect(2) | V > velrect(2) + velrect(4);
end
if ~isempty(roi_freehand)
    valid = isfinite(U) & isfinite(V);
    inside = inROI(roi_freehand, U(valid), V(valid));
    outside_map = false(size(U));
    outside_map(valid) = ~inside;
    out = out | outside_map;
end
if ~isempty(notch_limits)
    magnitude = sqrt(U .^ 2 + V .^ 2 + W .^ 2);
    out = out | (magnitude < notch_limits(2) & magnitude > notch_limits(1));
end
if ~isempty(stereo_filters.residual_thresh)
    out = out | abs(double(residual)) > stereo_filters.residual_thresh;
end
if ~isempty(stereo_filters.w_median_thresh)
    out = out | w_median_outliers(double(W_px), stereo_filters.w_median_thresh);
end
if ~isempty(stereo_filters.w_limits)
    out = out | W < stereo_filters.w_limits(1) | W > stereo_filters.w_limits(2);
end
end

function s = no_stereo_filters()
s.residual_thresh = [];
s.w_median_thresh = [];
s.w_limits = [];
end

function outliers = w_median_outliers(W, threshold)
% normalized median test of one component (as postproc.PIVlab_postproc for u and v): NaN vectors (masked) are
% filled for the median only and are never outliers
outliers = false(size(W));
missing = isnan(W);
if all(missing(:)) || min(size(W)) < 3
    return
end
if any(missing(:))
    W = misc.inpaint_nans(W);
end
noise = 0.1; % estimated measurement noise [px], as in 2D
b = 2;       % neighbourhood radius
median_W = medfilt2(W, [2*b + 1, 2*b + 1], 'symmetric');
fluct = W - median_W;
median_res = medfilt2(abs(fluct), [2*b + 1, 2*b + 1], 'symmetric');
outliers = abs(fluct ./ (median_res + noise)) > threshold;
outliers(missing) = false;
end
