function add_points(ax, P)
%ADD_POINTS Further points of the scene that the floor and the view take into account (e.g. the corners of
% the light sheet).
%   scene3d.add_points(ax, P)    P: N x 3, axes of the results
S = getappdata(ax, 'scene3d');
S.points = [S.points; P];
setappdata(ax, 'scene3d', S);
end
