function setup_3d_to_gui(setup)
% Camera positions and aim points of a setup (e.g. moved with the mouse in simulate.preview_3d)
% into the panel "3D particle image generator".
hgui = getappdata(0, 'hgui');
if isempty(hgui) || ~isgraphics(hgui)
    return
end
handles = gui.gethand;
for k = 1:numel(setup.cameras)
    c = sprintf('sim3d_c%d', k);
    values = [setup.cameras(k).Position, setup.cameras(k).Target];
    fields = {'x', 'y', 'z', 'ax', 'ay'};
    for f = 1:numel(fields)
        set(handles.([c fields{f}]), 'String', gui.setting_text(round(values(f) * 10) / 10));
    end
end
end
