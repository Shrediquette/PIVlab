function T = frame_transform(frame_points, printed_points)
%FRAME_TRANSFORM Coordinates of an estimation (frame) -> coordinates of the board as printed.
%   T = scene3d.frame_transform(frame_points, printed_points)
% frame_points    N x 2 board corners [mm] in the coordinates in which poses were estimated
% printed_points  N x 2 the same corners on the board as printed (preproc.cam_board_corners)
% T               rigidtform3d, frame -> printed board (for scene3d.board(..., Frame=T))
% The frame may differ from the printed board by a turn about z (boards with more rows than columns:
% the detector and patternWorldPoints number the corners turned by 90 degrees) and by a mirror (board
% seen from behind: x -> -x). A mirror of the board plane is a turn by 180 degrees in 3D (z changes
% sign too), so T is a proper rigid transform.
ok = all(isfinite(frame_points), 2) & all(isfinite(printed_points), 2);
F = frame_points(ok, :);
P = printed_points(ok, :);
mf = mean(F, 1);
mp = mean(P, 1);
[U, ~, V] = svd((F - mf)' * (P - mp));
A = V * U'; % printed = A * frame + b (rotation or mirror)
b = mp' - A * mf';
T = rigidtform3d(blkdiag(A, det(A)), [b; 0]');
end
