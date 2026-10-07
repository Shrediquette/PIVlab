function view = collect_view
% What the PIVlab window shows (stored in sessions, see gui.apply_view): the open panel, the
% displayed frame, A or B image, the zoom and the Basic/Advanced mode.
hgui = getappdata(0, 'hgui');
handles = gui.gethand;
view.panel = '';
panels = findobj(hgui, '-regexp', 'Tag', '^multip\d+$', 'Visible', 'on');
if ~isempty(panels)
    view.panel = panels(1).Tag;
end
view.frame = get(handles.fileselector, 'Value');
view.toggler = gui.retr('toggler');
view.xzoomlimit = gui.retr('xzoomlimit');
view.yzoomlimit = gui.retr('yzoomlimit');
view.ui_mode = gui.retr('ui_mode');
end
