function [U, V, W, sx, sy] = truth_at_board(truth, x, y, opts)
% True displacement of a recording of simulate.recording_3d at board positions, as a (stereo-)PIV
% result shows it.
%   [U, V, W] = simulate.truth_at_board(truth, x_mm, y_mm)
%   [U, V, W] = simulate.truth_at_board(truth, x_mm, y_mm, BoardFromBehind=true)
% truth: the variable of ground_truth.mat. x, y: board positions [mm] (e.g. vel.x_mm, vel.y_mm of
% stereo.reconstruct). U, V, W: displacement per image pair [mm] in board axes (W along the board z
% axis, i.e. away from camera 1 when camera 1 is in front of the board). NaN outside of the field.
% sx, sy: the sheet point (sheet coordinates) that is shown at x, y.
%
% The light sheet need not be in the plane of the board: a camera sees a sheet point S on the board
% plane where its line of sight through S hits the board. The disparity correction places the
% vector at the mean of these positions of all cameras, so this is where the truth is taken.
% BoardFromBehind = true: camera 1 saw the board from behind (stereo.calibrate turns the board
% coordinates about the y axis: x -> -x, z -> -z); x, y and U, W are then in these coordinates.
arguments
    truth struct
    x double
    y double
    opts.BoardFromBehind (1,1) logical = false
end
flip = 1;
if opts.BoardFromBehind
    flip = -1;
end
n = numel(truth.cameras);
C = zeros(n, 3);
for k = 1:n
    C(k, :) = truth.cameras{k}.position;
end
target = [flip * x(:), y(:)];
pose = truth.sheet_pose;
P = transformPointsInverse(pose, [target, zeros(size(target, 1), 1)]);
ab = P(:, 1:2);
for iteration = 1:8 % fixed point: sheet point whose mean board position is the target
    S = transformPointsForward(pose, [ab, zeros(size(ab, 1), 1)]);
    mid = zeros(size(target));
    for k = 1:n
        f = -C(k, 3) ./ (S(:, 3) - C(k, 3));
        mid = mid + (C(k, 1:2) + (S(:, 1:2) - C(k, 1:2)) .* f) / n;
    end
    ab = ab + (target - mid);
end
sx = reshape(ab(:, 1), size(x));
sy = reshape(ab(:, 2), size(x));
Us = interp2(truth.X, truth.Y, truth.U, sx, sy);
Vs = interp2(truth.X, truth.Y, truth.V, sx, sy);
Ws = interp2(truth.X, truth.Y, truth.W, sx, sy);
R = pose.R;
U = flip * (R(1, 1) * Us + R(1, 2) * Vs + R(1, 3) * Ws);
V = R(2, 1) * Us + R(2, 2) * Vs + R(2, 3) * Ws;
W = flip * (R(3, 1) * Us + R(3, 2) * Vs + R(3, 3) * Ws);
end
