function out = to_board(ax, in, kind)
%TO_BOARD Axes of the results (the scene) -> coordinates of the data of the scene (inverse of scene3d.result).
%   P = scene3d.to_board(ax, P)                 points, N x 3 (e.g. the mouse ray ax.CurrentPoint)
%   d = scene3d.to_board(ax, d, 'direction')    directions, N x 3
if nargin < 3
    kind = 'point';
end
S = getappdata(ax, 'scene3d');
switch kind
    case 'point'
        out = transformPointsInverse(S.frame, scene3d.to_result(in, S.y0));
    case 'direction'
        out = scene3d.to_result(in, S.y0, 'direction') * S.frame.R;
    otherwise
        error('scene3d.to_board: unknown kind %s', kind);
end
end
