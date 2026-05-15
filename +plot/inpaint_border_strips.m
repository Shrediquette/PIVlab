function out = inpaint_border_strips(out, miny_idx, maxy_idx, minx_idx, maxx_idx)
% Extrapolates NaN border pixels via 4 strip inpaints (spring, method 4).
%
% Order: left+right first, then top+bottom.  This fills corner context
% before the top/bottom strips run, eliminating seam artefacts at corners.
%
% Only NaN pixels are modified; interior valid pixels are untouched.

k_ctx  = 3;   % interior context rows/cols used as boundary conditions
nrows  = size(out, 1);
ncols  = size(out, 2);

% ── Left border (non-corner rows: miny_idx:maxy_idx) ──────────────────────
if minx_idx > 1
    c_far = min(ncols, minx_idx + k_ctx - 1);
    s = misc.inpaint_nans(out(miny_idx:maxy_idx, 1:c_far), 4);
    out(miny_idx:maxy_idx, 1:minx_idx-1) = s(:, 1:minx_idx-1);
end

% ── Right border (non-corner rows: miny_idx:maxy_idx) ─────────────────────
if maxx_idx < ncols
    c_far = max(1, maxx_idx - k_ctx + 1);
    s = misc.inpaint_nans(out(miny_idx:maxy_idx, c_far:ncols), 4);
    out(miny_idx:maxy_idx, maxx_idx+1:ncols) = s(:, maxx_idx - c_far + 2:end);
end

% ── Top border (full width; left/right corner context now available) ───────
if miny_idx > 1
    r_far = min(nrows, miny_idx + k_ctx - 1);
    s = misc.inpaint_nans(out(1:r_far, :), 4);
    out(1:miny_idx-1, :) = s(1:miny_idx-1, :);
end

% ── Bottom border (full width; left/right corner context now available) ────
if maxy_idx < nrows
    r_far = max(1, maxy_idx - k_ctx + 1);
    s = misc.inpaint_nans(out(r_far:nrows, :), 4);
    out(maxy_idx+1:nrows, :) = s(maxy_idx - r_far + 2:end, :);
end
