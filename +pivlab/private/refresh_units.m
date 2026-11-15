function res = refresh_units(res)
%REFRESH_UNITS Recompute the user-facing fields (x, y, u, v, ...) from the pixel data in res.px.
c = res.calibration;
p = res.px;
imsize = res.images.imageSize;
[res.x, res.y] = calibrate.apply_xy(p.x, p.y, c, imsize);
u = p.u; v = p.v;
if res.smoothed && ~isempty(p.u_smoothed)
    u = p.u_smoothed; v = p.v_smoothed;
end
f = calibrate.statistic_factors(c.calu, c.calv, result_statistic(res)); % std and TKE: own units
res.u = u*f.u;
res.v = v*f.v;
res.u_raw = p.u_raw*f.u;
res.v_raw = p.v_raw*f.v;
if isfield(p, 'w') % stereo-PIV: out-of-plane component, positive along z = x cross y
    w = p.w;
    if res.smoothed && ~isempty(p.w_smoothed)
        w = p.w_smoothed;
    end
    res.w = w*f.w;
    res.w_raw = p.w_raw*f.w;
end
if isempty(p.uncertainty)
    res.uncertainty = [];
else
    res.uncertainty = p.uncertainty*abs(c.calu);
end
res.units = unit_string(c);
end

function u = unit_string(c)
if (c.calu==1 || c.calu==-1) && c.calxy==1
    u = "px/frame";
elseif c.displacement_only
    u = "m/frame";
else
    u = "m/s";
end
end
