function clear(ax, what)
%CLEAR Forgets the cameras and points of the last drawing (their objects are deleted by the caller).
%   scene3d.clear(ax)          cameras and extra points (before drawing them again)
%   scene3d.clear(ax, 'all')   also deletes everything in ax and forgets the board and the floor
S = getappdata(ax, 'scene3d');
S.cams = struct('centre', {}, 'color', {}, 'size', {}); % scene3d.camera
S.points = zeros(0, 3); % further points of the scene (scene3d.add_points), axes of the results
if nargin > 1 && strcmp(what, 'all')
    delete(allchild(ax)); % also the objects with HandleVisibility off (cla keeps them)
    S.board_rect = zeros(0, 3); % corners of the board (axes of the results)
    S.board_size = 100;         % largest side of the board [mm]
    S.y0 = 0;                   % y of the '0' of the board in board coordinates
    S.frame = rigidtform3d;     % coordinates of the data -> board as printed (scene3d.board, Frame)
    S.floor = [];               % scene3d.finish
end
setappdata(ax, 'scene3d', S);
end
