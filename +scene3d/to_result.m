function out = to_result(in, y0, kind)
%TO_RESULT Board coordinates -> axes of the results, and back (the conversion is its own inverse).
%   P    = scene3d.to_result(P, y0)                points, N x 3 [mm] (N x 2: z = 0)
%   d    = scene3d.to_result(d, y0, 'direction')   directions, N x 3
%   pose = scene3d.to_result(extrinsics, y0, 'pose')  camera pose (rigidtform3d, camera -> results) from
%                                                  extrinsics (rigidtform3d, board -> camera), for plotCamera
% Board coordinates: origin at the first inner corner (top left), x right, y down, z into the board.
% Axes of the results (simulate.result_axes): origin at the '0' of the board (inner corner bottom left),
% x right, y up, z out of the board. y0 = (rows - 2) * checker size, the y of the '0' in board
% coordinates. The conversion is a rotation by 180 degrees about x and a shift: poses stay rotations.
if nargin < 3
    kind = 'point';
end
switch kind
    case 'point'
        if size(in, 2) == 2
            in(:, 3) = 0;
        end
        out = [in(:, 1), y0 - in(:, 2), 0 - in(:, 3)];
    case 'direction'
        out = [in(:, 1), 0 - in(:, 2), 0 - in(:, 3)];
    case 'pose'
        A = extr2pose(in);
        M = diag([1 -1 -1]);
        out = rigidtform3d(M * A.R, scene3d.to_result(A.Translation, y0));
    otherwise
        error('scene3d.to_result: unknown kind %s', kind);
end
end
