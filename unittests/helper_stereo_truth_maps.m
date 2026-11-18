function [Ut, Vt, Wt] = helper_stereo_truth_maps(x_mm, y_mm, c, flip)
%HELPER_STEREO_TRUTH_MAPS True displacement [mm per pair] of helper_stereo_synthetic_case at the board
%   positions of a stereo-PIV result (res.stereo.x_mm, y_mm), in board axes (x, y as on the board,
%   z away from camera 1).
%   flip = -1 if camera 1 saw the board from behind (calib.board_from_behind): the result is then in
%   board coordinates turned about the y axis (x -> -x, z -> -z); else 1.
% The vector at board position (xw, yw) shows the sheet point whose projections into both cameras have
% (xw, yw) as midpoint (that is where the disparity correction puts it); the true displacement there is
% rotated from sheet to board axes.
target = [flip * x_mm(:), y_mm(:)];
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
sx = reshape(ab(:, 1), size(x_mm));
sy = reshape(ab(:, 2), size(x_mm));
Us = interp2(c.X, c.Y, c.U, sx, sy);
Vs = interp2(c.X, c.Y, c.V, sx, sy);
Ws = interp2(c.X, c.Y, c.W, sx, sy);
R = c.sheet_pose.R;
Ut = flip * (R(1, 1) * Us + R(1, 2) * Vs + R(1, 3) * Ws);
Vt = R(2, 1) * Us + R(2, 2) * Vs + R(2, 3) * Ws;
Wt = flip * (R(3, 1) * Us + R(3, 2) * Vs + R(3, 3) * Ws);
end
