function u = up(ax)
%UP Vertical direction of the scene of ax, in the axes of the results.
%   u = scene3d.up(ax)
% Board upright (default): y of the results (the floor is below the board, as below the image).
% Board lying flat: z, on the side of the first camera (the floor is behind the board).
S = getappdata(ax, 'scene3d');
if ~S.lying
    u = [0 1 0];
    return
end
s = 1;
if ~isempty(S.cams) && S.cams(1).centre(3) < 0 % first camera behind the board: it is above
    s = -1;
end
u = [0 0 s];
end
