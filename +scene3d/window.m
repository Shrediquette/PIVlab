function [fig, ax] = window(draw, opts)
%WINDOW Figure with a 3D scene of cameras and board.
%   [fig, ax] = scene3d.window(@draw, Name='Camera setup in 3D')
%   [fig, ax] = scene3d.window(@draw, Figure=fig)      in an existing (empty) figure
% draw(ax) draws the board (scene3d.board), the cameras (scene3d.camera) and whatever else; then the
% floor (scene3d.finish) and the view (scene3d.reset_view) follow. Further objects that the floor and
% the view should take into account: scene3d.add_points. After the switch
% "Board upright / lying flat" everything is drawn again.
% Buttons at the bottom left: "Reset view" and the switch (scene3d.up_control).
arguments
    draw function_handle
    opts.Name = 'PIVlab: 3D view'
    opts.Figure = []
    opts.Visible = 'on'
end
fig = opts.Figure;
if isempty(fig)
    fig = figure('Name', opts.Name, 'NumberTitle', 'off', 'DockControls', 'off', 'MenuBar', 'figure', 'ToolBar', 'none', ...
        'Visible', opts.Visible);
end
panel = uipanel(fig, 'Units', 'normalized', 'Position', [0 0 1 1], 'BorderType', 'none', 'Tag', 'scene3d_panel');
ax = axes(panel, 'Units', 'normalized', 'Position', [0 0 1 1], 'Tag', 'scene3d_axes');
scene3d.init(ax, OnUpChange=@() redraw(ax, draw));
uicontrol(panel, 'Style', 'pushbutton', 'String', 'Reset view', 'Units', 'pixels', 'Position', [8 8 90 24], ...
    'Callback', @(~, ~) scene3d.reset_view(ax), 'Tag', 'scene3d_resetview', ...
    'TooltipString', 'Look at everything again (also: double click). Mouse: drag to rotate, right drag to pan, wheel to zoom');
scene3d.up_control(panel, ax, [104 8 230 24]);
redraw(ax, draw);
end

function redraw(ax, draw)
scene3d.clear(ax, 'all');
draw(ax);
scene3d.finish(ax);
scene3d.reset_view(ax);
end
