function P = view_points(ax, full)
%VIEW_POINTS Points of the scene: corners of the board, the cameras (with the size of their symbol) and the
% points of scene3d.add_points.
%   P = scene3d.view_points(ax)          what the view shows (scene3d.reset_view, scene3d.fit_view): also the
%                                        labels of the cameras and where they stand on the floor
%   P = scene3d.view_points(ax, false)   only the objects (scene3d.finish: where the floor goes)
% P: N x 3, axes of the results
if nargin < 2
    full = true;
end
S = getappdata(ax, 'scene3d');
P = S.board_rect;
u = scene3d.up(ax);
for k = 1:numel(S.cams)
    C = S.cams(k).centre;
    P = [P; C + S.cams(k).size * [-1 -1 -1; 1 1 1]]; %#ok<AGROW>
    if full
        P = [P; C + 3.5 * S.cams(k).size * u]; %#ok<AGROW> (label)
        if ~isempty(S.floor)
            P = [P; C - (C * u' - S.floor.height) * u]; %#ok<AGROW>
        end
    end
end
P = [P; S.points];
end
