function err = helper_stereo_truth_error(vel, c)
%HELPER_STEREO_TRUTH_ERROR Errors of the mean U, V, W against the ground truth of stereo_synthetic_case (unit tests).
%   err = helper_stereo_truth_error(vel, c)
%   vel  stereo.reconstruct result (U, V, W [px per pair], x_mm, y_mm, mm_per_px)
%   err  bias_U, rms_U, bias_V, rms_V, bias_W, rms_W [mm per pair], W_slope (estimated / true W)
% Errors of the mean field against the ground truth. The vector at board position (xw, yw) shows the
% sheet point whose projections into both cameras have (xw, yw) as midpoint (that is where the
% disparity correction puts it); the true displacement there is rotated from sheet to board axes.
target = [vel.x_mm(:), vel.y_mm(:)];
C = zeros(2, 3);
for k = 1:2
    C(k, :) = (-c.cams{k}.pose.R' * c.cams{k}.pose.Translation(:))';
end
P = transformPointsInverse(c.sheet_pose, [target, zeros(size(target, 1), 1)]);
ab = P(:, 1:2);
for it = 1:6
    S = transformPointsForward(c.sheet_pose, [ab, zeros(size(ab, 1), 1)]);
    mid = zeros(size(target));
    for k = 1:2
        f = -C(k, 3) ./ (S(:, 3) - C(k, 3));
        mid = mid + (C(k, 1:2) + (S(:, 1:2) - C(k, 1:2)) .* f) / 2;
    end
    ab = ab + (target - mid);
end
sx = reshape(ab(:, 1), size(vel.x_mm));
sy = reshape(ab(:, 2), size(vel.x_mm));
Us = interp2(c.X, c.Y, c.U, sx, sy);
Vs = interp2(c.X, c.Y, c.V, sx, sy);
Ws = interp2(c.X, c.Y, c.W, sx, sy);
R = c.sheet_pose.R;
Ut = R(1, 1) * Us + R(1, 2) * Vs + R(1, 3) * Ws;
Vt = R(2, 1) * Us + R(2, 2) * Vs + R(2, 3) * Ws;
Wt = R(3, 1) * Us + R(3, 2) * Vs + R(3, 3) * Ws;
Ue = mean(vel.U, 3) * vel.mm_per_px(1);
Ve = mean(vel.V, 3) * vel.mm_per_px(2);
We = mean(vel.W, 3) * vel.mm_per_px(1);
ok = ~isnan(Ut) & ~isnan(Ue);
e = Ue(ok) - Ut(ok); err.bias_U = mean(e); err.rms_U = sqrt(mean(e .^ 2));
e = Ve(ok) - Vt(ok); err.bias_V = mean(e); err.rms_V = sqrt(mean(e .^ 2));
e = We(ok) - Wt(ok); err.bias_W = mean(e); err.rms_W = sqrt(mean(e .^ 2));
err.W_slope = sum(We(ok) .* Wt(ok)) / sum(Wt(ok) .^ 2);
end
