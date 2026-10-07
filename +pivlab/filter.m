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
%   CorrelationFilter, CorrelationThreshold remove vectors with low correlation coefficient
%   NotchFilter, NotchLimits                remove vectors with a magnitude between the limits
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
    opts.CorrelationFilter = []
    opts.CorrelationThreshold = []
    opts.NotchFilter = []
    opts.NotchLimits = []
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
explicit_limits = ~isempty(opts.VelocityLimits) || ~isempty(opts.NotchLimits);
[f, s] = resolve_options('filter', opts);
c = res.calibration;

% velocity / notch limits: GUI semantics = calibrated units of the current calibration
limits = f.VelocityLimits;
if (ischar(limits) || isstring(limits)) && strcmpi(limits, "none")
    limits = [];
    f.VelocityLimits = [];
    explicit_limits = true;
end
notch = f.NotchLimits;
if ~explicit_limits && f.LimitUnits == "calibrated" && res.units == "px/frame"
    sc = s.calibration;
    limits = to_px(limits, sc.calu, sc.calv);
    notch = notch / abs(sc.calu);
end
if isempty(limits)
    velrect = [];
else
    if numel(limits) ~= 4 || limits(2) <= limits(1) || limits(4) <= limits(3)
        error('pivlab:filter:limits','VelocityLimits must be [umin umax vmin vmax].');
    end
    velrect = [limits(1) limits(3) limits(2)-limits(1) limits(4)-limits(3)];
end

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
    u2 = []; v2 = [];
    if ~isempty(p.u2)
        u2 = p.u2(:,:,i); v2 = p.v2(:,:,i);
    end
    [u, v, tv] = validate.filtervectors_all_parallel(p.x, p.y, p.u_raw(:,:,i), p.v_raw(:,:,i), ...
        res.typevector_raw(:,:,i), c.calu, c.calv, velrect, ...
        double(f.StdevCheck), f.StdevThreshold, double(f.LocalMedian), f.LocalMedianThreshold, ...
        double(f.ContrastFilter), double(f.BrightnessFilter), f.ContrastThreshold, f.BrightnessThreshold, ...
        double(f.Interpolate), A, B, rawA, rawB, ...
        double(f.CorrelationFilter), f.CorrelationThreshold, res.correlation_map(:,:,i), ...
        double(f.NotchFilter), notch(1), notch(2), [], u2, v2);
    p.u(:,:,i) = u;
    p.v(:,:,i) = v;
    res.typevector(:,:,i) = tv;
end
p.u_smoothed = []; p.v_smoothed = [];
res.px = p;
res.smoothed = false;
res.filtered = true;
res.derived = struct();
s.filter = f;
res.settings.filter = f;
res = refresh_units(res);
nrem = nnz(res.typevector == 2);
nall = nnz(res.typevector > 0);
share = 100*nrem/max(nall,1);
if verbose
    fprintf('Vector validation: %d of %d vectors (%.1f %%) were removed%s.\n', nrem, nall, share, ...
        string(ifelse(f.Interpolate, ' and interpolated', '')));
end
if share > 50
    if ~isempty(velrect) || f.NotchFilter
        hint = sprintf(['Check VelocityLimits / NotchLimits: they are in the current units of the ' ...
            'result (%s).'], res.units);
    else
        hint = 'Check the filter thresholds and the PIV settings.';
    end
    warning('pivlab:filter:manyRemoved', '%.0f %% of the vectors were removed. %s', share, hint);
end
end

function l = to_px(l, calu, calv)
if isempty(l), return; end
u = sort(l(1:2)/calu); v = sort(l(3:4)/calv);
l = [u v];
end

function out = ifelse(c, a, b)
if c, out = a; else, out = b; end
end
