function h = up_control(parent, ax, position, units)
%UP_CONTROL The switch "Board upright / Board lying flat": where the floor of the scene is.
%   h = scene3d.up_control(parent, ax, position)          position in pixels
%   h = scene3d.up_control(parent, ax, position, units)
% Stored as per-user preference (gui.set_preference('scene3d_board_lying')), for all 3D views. After a
% change, the OnUpChange of scene3d.init is called (it draws the scene again).
if nargin < 4
    units = 'pixels';
end
S = getappdata(ax, 'scene3d');
h = uicontrol(parent, 'Style', 'popupmenu', 'Units', units, 'Position', position, ...
    'String', {'Board upright (floor below it)', 'Board lying flat (floor behind it)'}, 'Value', 1 + S.lying, ...
    'Tag', 'scene3d_up', 'Callback', @(src, ~) changed(src, ax), 'TooltipString', ...
    ['Where the floor of the 3D view is: below the board (board standing upright, e.g. in a vertical ' ...
    'light sheet) or behind it (board lying flat, cameras above or below it)']);
end

function changed(src, ax)
if ~isgraphics(ax)
    return
end
S = getappdata(ax, 'scene3d');
S.lying = src.Value == 2;
setappdata(ax, 'scene3d', S);
gui.set_preference('scene3d_board_lying', S.lying);
if ~isempty(S.on_up)
    S.on_up();
end
end
