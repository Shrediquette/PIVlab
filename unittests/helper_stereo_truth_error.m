function err = helper_stereo_truth_error(vel, c, calib)
%HELPER_STEREO_TRUTH_ERROR Errors of the mean U, V, W against the ground truth of stereo_synthetic_case (unit tests).
%   err = helper_stereo_truth_error(vel, c)
%   err = helper_stereo_truth_error(vel, c, calib)   calib (stereo.calibrate): if camera 1 saw the board from
%         behind, the result is in board coordinates turned about the y axis (x -> -x, z -> -z)
%   vel  stereo.reconstruct result (U, V, W [px per pair], x_mm, y_mm, mm_per_px)
%   err  bias_U, rms_U, bias_V, rms_V, bias_W, rms_W [mm per pair], W_slope (estimated / true W)
% Errors of the mean field against the ground truth (helper_stereo_truth_maps).
flip = 1;
if nargin >= 3 && isfield(calib, 'board_from_behind') && calib.board_from_behind(1)
    flip = -1;
end
[Ut, Vt, Wt] = helper_stereo_truth_maps(vel.x_mm, vel.y_mm, c, flip);
Ue = mean(vel.U, 3) * vel.mm_per_px(1);
Ve = mean(vel.V, 3) * vel.mm_per_px(2);
We = mean(vel.W, 3) * vel.mm_per_px(1);
ok = ~isnan(Ut) & ~isnan(Ue);
e = Ue(ok) - Ut(ok); err.bias_U = mean(e); err.rms_U = sqrt(mean(e .^ 2));
e = Ve(ok) - Vt(ok); err.bias_V = mean(e); err.rms_V = sqrt(mean(e .^ 2));
e = We(ok) - Wt(ok); err.bias_W = mean(e); err.rms_W = sqrt(mean(e .^ 2));
err.W_slope = sum(We(ok) .* Wt(ok)) / sum(Wt(ok) .^ 2);
end
