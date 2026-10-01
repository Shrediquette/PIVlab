function [res, map] = derive(res, quantity, opts)
%DERIVE Derived quantities: vorticity, velocity magnitude, divergence, Q criterion, ...
%   [res, map] = pivlab.derive(res, quantity) computes the quantity for all frames of res,
%   exactly like PIVlab's "Plot -> Derive parameters". map is H x W x N (N = frames), it is
%   also stored in res.derived.(quantity) so that pivlab.display can show it.
%
%   quantity    "vorticity"   (1/s)            "magnitude"  (velocity magnitude)
%               "u", "v"      (velocity components, optionally minus Subtract)
%               "divergence"  (1/s)            "qcriterion" (1/s^2)
%               "shear"       (shear rate)     "strain"     (simple strain rate)
%               "direction"   (degrees)        "lic"        (line integral convolution)
%               "correlation" (correlation coefficient)
%               "uncertainty" (needs pivlab.analyze(..., Uncertainty=true))
%   Units follow res.units (call pivlab.toMetric first for SI units).
%
%   Name=value options
%   Smoothing          "none" (default) | "spatial" | "temporal" | "spatiotemporal"
%                      smooth the velocity field before computing the quantity. The smoothed
%                      field is also used by pivlab.display and pivlab.temporal.
%   SmoothingStrength  spatial smoothing parameter (smoothn, default 0.3)
%   TemporalWindow     temporal smoothing: number of neighbouring frames on each side
%   Subtract           [u v] velocity subtracted for magnitude, u, v, direction and LIC
%                      (e.g. the mean flow, in the units of res)
%   LICSize            LIC: size of the longer side of the LIC image in pixels (default 1000)
%   Settings           settings struct (uses s.derive)
%
%   Example
%       [res, vort] = pivlab.derive(res, "vorticity");
%       mean_vorticity = mean(vort, 3, 'omitnan');
%
%   See also pivlab.temporal, pivlab.display
arguments
    res (1,1) struct
    quantity (1,1) string
    opts.Smoothing = []
    opts.SmoothingStrength = []
    opts.TemporalWindow = []
    opts.Subtract (1,:) double = [0 0]
    opts.LICSize (1,1) double = 1000
    opts.Settings struct = struct()
end
names = ["vorticity","magnitude","u","v","divergence","qcriterion","shear","strain","lic","direction","correlation","uncertainty"];
q = lower(quantity);
d = find(names == q, 1) + 1;   % PIVlab's "Display parameter" index (2...13)
if isempty(d)
    error('pivlab:derive:quantity','Unknown quantity "%s". Use one of: %s.', quantity, strjoin(names, ', '));
end
subtract = opts.Subtract;
lic_size = opts.LICSize;
opts = rmfield(opts, {'Subtract','LICSize'});
[g, s] = resolve_options('derive', opts);
smoothing = lower(string(g.Smoothing));
if ~ismember(smoothing, ["none","spatial","temporal","spatiotemporal"])
    error('pivlab:derive:smoothing','Smoothing must be "none", "spatial", "temporal" or "spatiotemporal".');
end
S = g.SmoothingStrength;
if isnan(S) || S <= 0
    S = 0.2;
end
interp = s.filter.Interpolate;
p = res.px;
n = size(p.u,3);

% velocity fields the quantities are computed from (pixel units)
U = cell(1,n); V = cell(1,n);
for i = 1:n
    u = p.u(:,:,i); v = p.v(:,:,i);
    if interp && (any(isnan(u(:))) || any(isnan(v(:))))
        u(isnan(v)) = NaN; v(isnan(u)) = NaN;
        u = misc.inpaint_nans(u,4);
        v = misc.inpaint_nans(v,4);
    end
    U{i} = u; V{i} = v;
end
switch smoothing
    case "none"
        p.u_smoothed = []; p.v_smoothed = [];
        res.smoothed = false;
    case "spatial"
        for i = 1:n
            [U{i}, V{i}] = plot.smooth_spatial(U{i}, V{i}, S, interp);
        end
    otherwise
        h = round(g.TemporalWindow);
        if isnan(h) || h < 1
            h = 2;
        end
        [U, V] = plot.temporal_smooth_core(U, V, ~res.isMean', h, S, smoothing == "spatiotemporal", interp);
        for i = find(res.isMean')
            U{i} = p.u(:,:,i); V{i} = p.v(:,:,i);
        end
end
if smoothing ~= "none"
    p.u_smoothed = cat(3, U{:});
    p.v_smoothed = cat(3, V{:});
    res.smoothed = true;
end
res.px = p;

cal = res.calibration;
copt.subtr_u = subtract(1);
copt.subtr_v = subtract(2);
copt.is_tke = isfield(res,'statistic') && res.statistic == "tke";
map = [];
for i = 1:n
    copt.correlation_map = res.correlation_map(:,:,i);
    if ~isempty(p.uncertainty)
        copt.uncertainty = p.uncertainty(:,:,i);
    end
    if d == 10
        sf = lic_size / max(size(U{i}));
        copt.lic = @(a,b) plot.LIC_core(a, b, sf);
    end
    m = plot.compute_derived(p.x, p.y, U{i}, V{i}, d, cal, copt);
    if isempty(m)
        error('pivlab:derive:notAvailable','%s is not available for these results.', quantity);
    end
    if isempty(map)
        map = zeros([size(m) n], 'like', m);
    end
    map(:,:,i) = m;
end
res.derived.(q) = map;
res.settings.derive = g;
res = refresh_units(res);
end
