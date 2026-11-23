function out = result(ax, in, kind)
%RESULT Coordinates of the data of the scene -> axes of the results (the scene).
%   P    = scene3d.result(ax, P)                     points, N x 3 (N x 2: z = 0)
%   d    = scene3d.result(ax, d, 'direction')        directions, N x 3
%   pose = scene3d.result(ax, extrinsics, 'pose')    camera pose (rigidtform3d, camera -> results) from
%                                                    extrinsics (rigidtform3d, data coordinates -> camera)
% The data coordinates are those of the frame given to scene3d.board (Frame, default: the board as
% printed), then scene3d.to_result. The other way (e.g. the mouse): scene3d.to_board.
if nargin < 3
    kind = 'point';
end
S = getappdata(ax, 'scene3d');
T = S.frame; % frame -> printed board
switch kind
    case 'point'
        if size(in, 2) == 2
            in(:, 3) = 0;
        end
        out = scene3d.to_result(transformPointsForward(T, in), S.y0);
    case 'direction'
        out = scene3d.to_result(in * T.R', S.y0, 'direction');
    case 'pose' % camera = R p_frame + t, p_frame = T.R' (p_printed - T.t)
        R = in.R * T.R';
        out = scene3d.to_result(rigidtform3d(R, (in.Translation(:) - R * T.Translation(:))'), S.y0, 'pose');
    otherwise
        error('scene3d.result: unknown kind %s', kind);
end
end
