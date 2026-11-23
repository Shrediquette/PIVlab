function init(ax, opts)
%INIT Scene state and mouse handling of a 3D view of cameras and board.
%   scene3d.init(ax)
%   scene3d.init(ax, OnViewChange=@(ax, finished) ..., OnUpChange=@() ...)
% Mouse in ax: drag to rotate the view about the vertical axis (scene3d.up), right drag (or Ctrl +
% drag) to pan, wheel to zoom, double click to look at everything again (scene3d.reset_view).
% Objects can replace the rotation by their own drag (scene3d.custom_drag in their ButtonDownFcn).
% OnViewChange is called while the view is rotated / panned (finished = false) and after it (true),
% OnUpChange after the switch "Board upright / lying flat" (scene3d.up_control).
% The figure callbacks WindowButtonDownFcn, WindowButtonUpFcn and WindowScrollWheelFcn are set.
arguments
    ax
    opts.OnViewChange = []
    opts.OnUpChange = []
end
S.lying = logical(gui.get_preference('scene3d_board_lying', false));
S.on_view = opts.OnViewChange;
S.on_up = opts.OnUpChange;
setappdata(ax, 'scene3d', S);
scene3d.clear(ax, 'all'); % board, cameras, points: none yet
hold(ax, 'on');
ax.Visible = 'off';
ax.Clipping = 'off';
try
    disableDefaultInteractivity(ax); % the default rotation would fight with ours
    ax.Toolbar.Visible = 'off';
catch
end
fig = ancestor(ax, 'figure');
list = getappdata(fig, 'scene3d_axes');
list = [list(isgraphics(list)), ax];
setappdata(fig, 'scene3d_axes', list);
set(fig, 'WindowButtonDownFcn', @mouse_down, 'WindowButtonUpFcn', @mouse_up, 'WindowScrollWheelFcn', @mouse_wheel);
end

%% ---------------------------------------------------------------- mouse
function mouse_down(fig, ~)
% runs before the ButtonDownFcn of an object, which may then replace the rotation (scene3d.custom_drag)
ax = axes_under_mouse(fig);
if isempty(ax)
    return
end
if strcmp(fig.SelectionType, 'open') % double click
    setappdata(fig, 'scene3d_drag', []);
    scene3d.reset_view(ax);
    notify_view(ax, true);
    return
end
d.ax = ax;
d.kind = 'orbit';
if strcmp(fig.SelectionType, 'alt') % right button (or Ctrl + left)
    d.kind = 'pan';
end
d.mouse0 = fig.CurrentPoint;
setappdata(fig, 'scene3d_drag', d);
set(fig, 'WindowButtonMotionFcn', @mouse_move);
end

function mouse_move(fig, ~)
d = getappdata(fig, 'scene3d_drag');
if isempty(d) || ~isgraphics(d.ax)
    return
end
if strcmp(d.kind, 'custom')
    d.move(fig);
    return
end
ax = d.ax;
delta = fig.CurrentPoint - d.mouse0;
switch d.kind
    case 'orbit'
        % 1 degree per pixel about the vertical axis of the scene, which stays upright
        u = scene3d.up(ax);
        if any(cross(u, ax.CameraPosition - ax.CameraTarget)) % not looking along the vertical
            ax.CameraUpVector = u;
        end
        camorbit(ax, delta(1), -delta(2), 'data', u);
    case 'pan' % camera and target of the view parallel to the screen: the scene follows the mouse
        f = ax.CameraTarget - ax.CameraPosition;
        distance = norm(f);
        f = f / distance;
        v = ax.CameraUpVector - dot(ax.CameraUpVector, f) * f;
        v = v / norm(v);
        right = cross(f, v);
        pos = getpixelposition(ax);
        [~, tan_v] = scene3d.view_tangents(ax);
        mm_per_px = 2 * distance * tan_v / pos(4); % in the depth of the target
        shift = -mm_per_px * (delta(1) * right + delta(2) * v);
        set(ax, 'CameraPosition', ax.CameraPosition + shift, 'CameraTarget', ax.CameraTarget + shift);
end
d.mouse0 = fig.CurrentPoint;
setappdata(fig, 'scene3d_drag', d);
notify_view(ax, false);
drawnow limitrate
end

function mouse_up(fig, ~)
set(fig, 'WindowButtonMotionFcn', '');
d = getappdata(fig, 'scene3d_drag');
setappdata(fig, 'scene3d_drag', []);
if isempty(d) || ~isgraphics(d.ax)
    return
end
if strcmp(d.kind, 'custom')
    d.up(fig);
else
    notify_view(d.ax, true);
end
end

function mouse_wheel(fig, evt)
% zooms the 3D view wherever the mouse is (the CurrentPoint of the figure is not updated while the
% mouse only moves, so it cannot tell where the mouse is): the first scene of the figure
list = getappdata(fig, 'scene3d_axes');
list = list(isgraphics(list));
if isempty(list)
    return
end
camzoom(list(1), 1.1 ^ (-evt.VerticalScrollCount));
notify_view(list(1), true);
end

function notify_view(ax, finished)
S = getappdata(ax, 'scene3d');
if ~isempty(S.on_view)
    S.on_view(ax, finished);
end
end

function ax = axes_under_mouse(fig)
ax = [];
list = getappdata(fig, 'scene3d_axes');
list = list(isgraphics(list));
p = fig.CurrentPoint; % pixels
for i = 1:numel(list)
    pos = getpixelposition(list(i), true);
    if p(1) >= pos(1) && p(1) <= pos(1) + pos(3) && p(2) >= pos(2) && p(2) <= pos(2) + pos(4)
        ax = list(i);
        return
    end
end
end
