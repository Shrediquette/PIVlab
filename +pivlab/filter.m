function res = filter(res, opts)
%FILTER Remove outlier vectors and fill the gaps (PIVlab "Vector validation").
%   res = pivlab.filter(res) applies PIVlab's default validation: global standard deviation
%   filter, local normalized median test, second-peak substitution and interpolation of the
%   removed vectors. The filter always starts from the unfiltered PIV result (res.u_raw),
%   so it can be repeated with different settings. Values you changed by hand in res.u_raw /
%   res.v_raw are used; changes in res.u / res.v are replaced by the new filter result.
%
%   Name=value options (empty = value from Settings, or the PIVlab default)
%   StdevCheck, StdevThreshold              global standard deviation filter (default on, 8)
%   LocalMedian, LocalMedianThreshold       normalized median test (default on, 3)
%   VelocityLimits                          [umin umax vmin vmax] in the CURRENT units of res
%                                           (res.units: px/frame before pivlab.toMetric, m/s
%                                           after it), "none" = no velocity limits
%   VelocityLimitsFreehand                  outline [u v] (N x 2, same units as VelocityLimits):
%                                           vectors outside it are removed (the freehand
%                                           velocity limits of the PIVlab window), "none" = off
%   CorrelationFilter, CorrelationThreshold remove vectors with low correlation coefficient
%   NotchFilter, NotchLimits                remove vectors with a magnitude between the limits
%   ResidualFilter, ResidualThreshold       stereo-PIV only: remove vectors whose reconstruction residual
%                                           (res.stereo.residual_raw, px) is larger than the threshold
%                                           (default off, 2 px), in both cameras
%   WMedianFilter, WMedianThreshold         stereo-PIV only: normalized median test of W (default off, 3)
%   WLimitFilter, WLimits                   stereo-PIV only: remove vectors with W outside [wmin wmax]
%                                           (default off, [-1 1], units as VelocityLimits)
%   ContrastFilter, ContrastThreshold       remove vectors in low-contrast image areas
%   BrightnessFilter, BrightnessThreshold   remove vectors in bright image areas
%   Interpolate                             fill removed vectors by interpolation (default true)
%   Verbose                                 true (default) / false: print a summary
%   Settings                                settings struct from pivlab.defaults / pivlab.loadSettings
%
%   res.typevector: 1 = valid, 2 = removed (interpolated if Interpolate is true),
%   3 = replaced by the second correlation peak, 0 = masked.
%   A warning appears when more than half of the vectors are removed (often limits in the
%   wrong units, e.g. m/s limits for results that are still in px/frame).
%
%   Example
%       res = pivlab.filter(res, StdevThreshold=5, VelocityLimits=[-2 10 -3 3]);
%
%   See also pivlab.analyze, pivlab.toMetric
arguments
    res (1,1) struct
    opts.StdevCheck = []
    opts.StdevThreshold = []
    opts.LocalMedian = []
    opts.LocalMedianThreshold = []
    opts.VelocityLimits = []
    opts.VelocityLimitsFreehand = []
    opts.CorrelationFilter = []
    opts.CorrelationThreshold = []
    opts.NotchFilter = []
    opts.NotchLimits = []
    opts.ResidualFilter = []
    opts.ResidualThreshold = []
    opts.WMedianFilter = []
    opts.WMedianThreshold = []
    opts.WLimitFilter = []
    opts.WLimits = []
    opts.ContrastFilter = []
    opts.ContrastThreshold = []
    opts.BrightnessFilter = []
    opts.BrightnessThreshold = []
    opts.Interpolate = []
    opts.Verbose (1,1) logical = true
    opts.Settings struct = struct()
end
verbose = opts.Verbose;
opts = rmfield(opts, 'Verbose');
[res, edited] = take_user_edits(res);
if edited.filtered
    warning('pivlab:filter:editsReplaced', ['You changed res.u / res.v. pivlab.filter starts again from ' ...
        'the unfiltered result (res.u_raw / res.v_raw), so these changes are replaced. ' ...
        'Change res.u_raw / res.v_raw instead if the filter should use your values.']);
end
explicit_limits = ~isempty(opts.VelocityLimits) || ~isempty(opts.NotchLimits) || ~isempty(opts.VelocityLimitsFreehand) || ~isempty(opts.WLimits);
[f, s] = resolve_options('filter', opts);

% velocity / notch limits: GUI semantics = calibrated units of the current calibration
limits = f.VelocityLimits;
if (ischar(limits) || isstring(limits)) && strcmpi(limits, "none")
    limits = [];
    f.VelocityLimits = [];
    explicit_limits = true;
end
outline = f.VelocityLimitsFreehand;
if (ischar(outline) || isstring(outline)) && strcmpi(outline, "none")
    outline = [];
    f.VelocityLimitsFreehand = [];
    explicit_limits = true;
end
if ~isempty(outline) && (size(outline, 2) ~= 2 || size(outline, 1) < 3)
    error('pivlab:filter:limits', 'VelocityLimitsFreehand must be an outline [u v] with at least 3 points.');
end
notch = f.NotchLimits;
w_limits = f.WLimits;
if numel(w_limits) ~= 2
    error('pivlab:filter:limits', 'WLimits must be [wmin wmax].');
end
if ~explicit_limits && f.LimitUnits == "calibrated" && res.units == "px/frame"
    % calibrated limits -> px/frame of res, which keep the axis directions (res.calibration.calu / calv = +1 or
    % -1, e.g. calv = -1 with the y axis upwards): the limits are tested on u_raw * calu (as in the GUI)
    sc = s.calibration;
    rc = res.calibration;
    fu = rc.calu / sc.calu;
    fv = rc.calv / sc.calv;
    limits = to_px(limits, fu, fv);
    notch = notch * abs(rc.calu) / abs(sc.calu);
    w_limits = w_limits * calibrate.w_factor(rc.calu, rc.calv) / calibrate.w_factor(sc.calu, sc.calv);
    if ~isempty(outline)
        outline = [outline(:, 1) * fu, outline(:, 2) * fv];
    end
end
roi_freehand = [];
if ~isempty(outline)
    roi_freehand = images.roi.Freehand('Position', double(outline)); % as validate.filtervectors in the GUI
end
if isempty(limits)
    velrect = [];
else
    if numel(limits) ~= 4 || limits(2) <= limits(1) || limits(4) <= limits(3)
        error('pivlab:filter:limits','VelocityLimits must be [umin umax vmin vmax].');
    end
    % one-sided limits written with -Inf / Inf: the limit rectangle stores minimum and width, and
    % Inf - (-Inf) would give NaN limits (nothing removed). A finite limit far outside the data has
    % the same effect (not too large: minimum + width must give the other limit back exactly).
    limits = double(limits);
    if any(isinf(limits))
        data = abs(double([res.u_raw(:); res.v_raw(:)]));
        big = 1000 * max([1; data(isfinite(data)); abs(limits(isfinite(limits)))']);
        limits(limits == -Inf) = -big;
        limits(limits == Inf) = big;
    end
    velrect = [limits(1) limits(3) limits(2)-limits(1) limits(4)-limits(3)];
end

if isfield(res, 'stereo') && ~isempty(res.stereo)
    res = filter_stereo(res, f, velrect, roi_freehand, notch, sort(w_limits));
else
    if isequal(opts.ResidualFilter, true) || isequal(opts.WMedianFilter, true) || isequal(opts.WLimitFilter, true)
        error('pivlab:filter:residual', 'ResidualFilter, WMedianFilter and WLimitFilter need a stereo-PIV result (pivlab.stereo).');
    end
    res = filter_frames(res, f, velrect, roi_freehand, notch, {});
end
res.settings.filter = f;
nrem = nnz(res.typevector == 2);
nall = nnz(res.typevector > 0);
share = 100*nrem/max(nall,1);
if verbose
    fprintf('Vector validation: %d of %d vectors (%.1f %%) were removed%s.\n', nrem, nall, share, ...
        string(ifelse(f.Interpolate, ' and interpolated', '')));
end
if share > 50
    if ~isempty(velrect) || ~isempty(roi_freehand) || f.NotchFilter || (isfield(res, 'stereo') && ~isempty(res.stereo) && f.WLimitFilter)
        hint = sprintf(['Check VelocityLimits / NotchLimits / WLimits: they are in the current units of the ' ...
            'result (%s).'], res.units);
    else
        hint = 'Check the filter thresholds and the PIV settings.';
    end
    warning('pivlab:filter:manyRemoved', '%.0f %% of the vectors were removed. %s', share, hint);
end
end

function res = filter_frames(res, f, velrect, roi_freehand, notch, discard)
% the vector validation of every frame (validate.filtervectors_all_parallel, as in the GUI). discard (stereo-PIV,
% filter_stereo): per frame a logical map of vectors that are removed first (also their second peak), [] = none.
c = res.calibration;
p = res.px;
n = size(p.u,3);
need_images = f.ContrastFilter || f.BrightnessFilter;
for i = 1:n
    A = []; B = []; rawA = []; rawB = [];
    if need_images
        if res.isMean(i)
            error('pivlab:filter:imagefilter','Image-based filters cannot be applied to temporal statistics.');
        end
        pr = res.pairs(i);
        [A, rawA] = import.read_frame(res.images, 2*pr-1, res.images.cam, res.images.background);
        [B, rawB] = import.read_frame(res.images, 2*pr, res.images.cam, res.images.background);
    end
    u_raw = p.u_raw(:,:,i);
    v_raw = p.v_raw(:,:,i);
    u2 = []; v2 = [];
    if ~isempty(p.u2)
        u2 = p.u2(:,:,i); v2 = p.v2(:,:,i);
    end
    if ~isempty(discard) && ~isempty(discard{i}) % as stereo.camera_limits in the GUI
        u_raw(discard{i}) = NaN;
        v_raw(discard{i}) = NaN;
        if ~isempty(u2)
            u2(discard{i}) = NaN;
            v2(discard{i}) = NaN;
        end
    end
    [u, v, tv] = validate.filtervectors_all_parallel(p.x, p.y, u_raw, v_raw, ...
        res.typevector_raw(:,:,i), c.calu, c.calv, velrect, ...
        double(f.StdevCheck), f.StdevThreshold, double(f.LocalMedian), f.LocalMedianThreshold, ...
        double(f.ContrastFilter), double(f.BrightnessFilter), f.ContrastThreshold, f.BrightnessThreshold, ...
        double(f.Interpolate), A, B, rawA, rawB, ...
        double(f.CorrelationFilter), f.CorrelationThreshold, res.correlation_map(:,:,i), ...
        double(f.NotchFilter), notch(1), notch(2), roi_freehand, u2, v2);
    p.u(:,:,i) = u;
    p.v(:,:,i) = v;
    res.typevector(:,:,i) = tv;
end
p.u_smoothed = []; p.v_smoothed = [];
res.px = p;
res.smoothed = false;
res.filtered = true;
res.derived = struct();
res.settings.filter = f;
res = refresh_units(res);
end

function res = filter_stereo(res, f, velrect, roi_freehand, notch, w_limits)
% stereo-PIV, as in the GUI (stereo.per_camera, stereo.limit_discard): the velocity limits (U, V), the
% magnitude limits (3D magnitude) and the stereo filters (residual, median of W, W limits) are tested on the 3D
% result of the raw camera data;
% those vectors are removed in both cameras; then each camera is validated with the other filters and U, V, W
% are made again.
if any(res.isMean)
    error('pivlab:filter:stereoTemporal', 'Temporal statistics of a stereo-PIV result can not be validated.');
end
c = res.calibration;
p = res.px;
notch_limits = [];
if f.NotchFilter
    notch_limits = notch;
end
stereo_filters.residual_thresh = [];
stereo_filters.w_median_thresh = [];
stereo_filters.w_limits = [];
if f.ResidualFilter
    stereo_filters.residual_thresh = f.ResidualThreshold;
end
if f.WMedianFilter
    stereo_filters.w_median_thresh = f.WMedianThreshold;
end
if f.WLimitFilter
    stereo_filters.w_limits = w_limits;
end
n = size(p.u_raw, 3);
discard = cell(1, n);
if ~isempty(velrect) || ~isempty(roi_freehand) || ~isempty(notch_limits) || f.ResidualFilter || f.WMedianFilter || f.WLimitFilter
    for i = 1:n
        discard{i} = stereo.limit_test(p.u_raw(:,:,i)*c.calu, p.v_raw(:,:,i)*c.calv, p.w_raw(:,:,i)*calibrate.w_factor(c.calu,c.calv), ...
            velrect, roi_freehand, notch_limits, res.stereo.residual_raw(:,:,i), p.w_raw(:,:,i), stereo_filters);
    end
end
camera_filter = f;
camera_filter.NotchFilter = false; % tested on the 3D result above
cams = res.stereo.cameras;
for k = 1:2
    cams{k} = filter_frames(cams{k}, camera_filter, [], [], notch, discard);
end
info = struct('calib', res.stereo.calib, 'disparity', res.stereo.disparity, 'images', {res.stereo.images}, ...
    'roi', res.stereo.roi, 'stereo_settings', res.stereo.settings, 'board', res.stereo.board, 'boards', {res.stereo.boards});
settings = res.settings;
res = stereo_result(cams, info, res.calibration, settings);
res.filtered = true;
end

function l = to_px(l, fu, fv)
% [umin umax vmin vmax] times the factors from calibrated units to px/frame (sorted: a factor can be negative)
if isempty(l), return; end
u = sort(l(1:2)*fu); v = sort(l(3:4)*fv);
l = [u v];
end

function out = ifelse(c, a, b)
if c, out = a; else, out = b; end
end
