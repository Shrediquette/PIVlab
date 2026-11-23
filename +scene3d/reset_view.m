function reset_view(ax)
%RESET_VIEW Looks at everything: from behind and above the cameras onto the board.
%   scene3d.reset_view(ax)
% Cameras on both sides of an upright board: from the side, somewhat from the side of camera 1.
% Board lying flat with the cameras straight above: from the bottom edge of the board, steeply from above.
S = getappdata(ax, 'scene3d');
P = scene3d.view_points(ax);
if isempty(P)
    return
end
u = scene3d.up(ax);
target = (min(P, [], 1) + max(P, [], 1)) / 2;
if isempty(S.cams)
    v = [0 0 1];
else
    C = vertcat(S.cams.centre);
    v = mean(C, 1) - target;
    if ~S.lying && any(C(:, 3) > 0) && any(C(:, 3) < 0)
        v = [1 0 0.66] * sign(C(1, 3) + (C(1, 3) == 0));
    end
end
h = v - dot(v, u) * u; % horizontal part
if norm(h) < 0.2 * norm(v)
    if S.lying
        h = [0 -1 0]; % from the bottom edge of the board
    else
        h = [0 0 1];
    end
    h = h - dot(h, u) * u;
end
elevation = 0.6;
if S.lying
    elevation = 1.1;
end
scene3d.fit_view(ax, h / norm(h) + elevation * u, P);
end
