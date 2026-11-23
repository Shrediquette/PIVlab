function custom_drag(ax, move, up)
%CUSTOM_DRAG Replaces the rotation of the view by the drag of an object (call it in the ButtonDownFcn).
%   scene3d.custom_drag(ax, @(fig) move, @(fig) up)
% move is called while the mouse moves, up when the button is released (the mouse handling of
% scene3d.init, which started the rotation just before the ButtonDownFcn).
fig = ancestor(ax, 'figure');
setappdata(fig, 'scene3d_drag', struct('ax', ax, 'kind', 'custom', 'move', move, 'up', up));
end
