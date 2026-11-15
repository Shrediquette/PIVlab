function res = helper_truth_set(res, u, v, w)
%HELPER_TRUTH_SET Put a vector field (px per frame, v downward, H x W x N) into a pivlab result.
%   res = helper_truth_set(res, u, v)      2D
%   res = helper_truth_set(res, u, v, w)   with the stereo component w (px per frame, positive
%                                          away from the camera); w = [] for 2D
%   The pixel data (res.px) and the user fields (res.u, res.v, ...) are set together, in the
%   current units of res, so that the pivlab functions do not see a "change by hand".
%   The vectors are valid (typevector 1). The correlation coefficient is 0.5 + 0.4*x/max(x)
%   (x = res.px.x), the uncertainty map is 0.01 + 0.001*row index (px per frame).
if nargin < 4
    w = [];
end
n = size(u, 3);
sz = size(res.px.x);
p = res.px;
p.u = u;
p.v = v;
p.u_raw = u;
p.v_raw = v;
p.u2 = [];
p.v2 = [];
p.u_smoothed = [];
p.v_smoothed = [];
[rows, ~] = ndgrid(1:sz(1), 1:sz(2));
p.uncertainty = repmat(0.01 + 0.001 * rows, 1, 1, n);
if ~isempty(w)
    p.w = w;
    p.w_raw = w;
    p.w_smoothed = [];
elseif isfield(p, 'w')
    p = rmfield(p, {'w', 'w_raw', 'w_smoothed'});
end
res.px = p;
res.typevector = ones([sz n]);
res.typevector_raw = ones([sz n]);
res.correlation_map = repmat(0.5 + 0.4 * double(res.px.x) / max(double(res.px.x(:))), 1, 1, n);
res.frameLabels = strings(n, 1);
res.isMean = false(n, 1);
res.pairs = 1:n;
res.smoothed = false;
res.filtered = false;
res.derived = struct();
% user fields in the current units (as pivlab's refresh_units does)
c = res.calibration;
f = calibrate.statistic_factors(c.calu, c.calv, '');
res.u = u * f.u;
res.v = v * f.v;
res.u_raw = u * f.u;
res.v_raw = v * f.v;
if ~isempty(w)
    res.w = w * f.w;
    res.w_raw = w * f.w;
elseif isfield(res, 'w')
    res = rmfield(res, {'w', 'w_raw'});
end
res.uncertainty = p.uncertainty * abs(c.calu);
end
