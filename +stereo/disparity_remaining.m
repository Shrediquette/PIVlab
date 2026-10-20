function remaining = disparity_remaining(measured, model_u, model_v, used)
%DISPARITY_REMAINING Measured disparity that remains after the correction (for the report and the display).
%   remaining = stereo.disparity_remaining(measured, model_u, model_v, used)
%   measured   the last disparity measurement (stereo.measure_disparity: raw of the first pass, or raw_residual of
%              the last pass): u, v (mean of the validated vectors) and u_frames, v_frames (every image pair)
%   model_u/v  the part of it that the correction took over (the model fitted to this measurement)
%   used       grid points that count (fit.used of the first pass: inside the area, valid often enough)
% The model (2nd-order polynomial, ...) cannot follow local structure, e.g. a light sheet that is displaced in
% depth in a stripe. What it leaves is measured - model:
%   remaining.u, remaining.v   map on the grid [px] (NaN where not used)
%   remaining.rms              rms over the used points without the noise of the measurement [px]: the noise is
%                              estimated from the difference of two halves of the image pairs
%   remaining.noise            rms of that noise [px]
%   remaining.p95              95th percentile of the magnitude ("up to") [px]
u = measured.u - model_u;
v = measured.v - model_v;
ok = used & isfinite(u) & isfinite(v);
u(~ok) = NaN;
v(~ok) = NaN;
remaining.u = u;
remaining.v = v;
magnitude = sqrt(u(ok) .^ 2 + v(ok) .^ 2);
total = sqrt(mean(magnitude .^ 2));
remaining.noise = NaN;
n = size(measured.u_frames, 3);
if n >= 2
    du = (mean(measured.u_frames(:, :, 1:2:n), 3, 'omitnan') - mean(measured.u_frames(:, :, 2:2:n), 3, 'omitnan')) / 2;
    dv = (mean(measured.v_frames(:, :, 1:2:n), 3, 'omitnan') - mean(measured.v_frames(:, :, 2:2:n), 3, 'omitnan')) / 2;
    both = ok & isfinite(du) & isfinite(dv);
    if any(both(:))
        remaining.noise = sqrt(mean(du(both) .^ 2 + dv(both) .^ 2));
    end
end
if isnan(remaining.noise)
    remaining.rms = total;
else
    remaining.rms = sqrt(max(0, total ^ 2 - remaining.noise ^ 2));
end
remaining.p95 = NaN;
if ~isempty(magnitude)
    remaining.p95 = prctile(magnitude, 95);
end
end
