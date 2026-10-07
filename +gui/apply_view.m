function apply_view(view)
% Shows what was shown when the session was saved (gui.collect_view). Call it after the session
% data and settings are loaded and gui.sliderrange has set the frame range.
handles = gui.gethand;
if isfield(view, 'ui_mode') && any(strcmp(view.ui_mode, {'basic', 'advanced'})) && ~strcmp(view.ui_mode, gui.retr('ui_mode'))
    gui.apply_ui_mode(view.ui_mode);
end
if isfield(view, 'frame') && ~isempty(view.frame)
    frame = min(max(view.frame, get(handles.fileselector, 'Min')), get(handles.fileselector, 'Max'));
    set(handles.fileselector, 'Value', frame);
end
if isfield(view, 'toggler') && ~isempty(view.toggler)
    gui.put('toggler', view.toggler);
    set(handles.togglepair, 'Value', view.toggler);
end
if isfield(view, 'xzoomlimit')
    gui.put('xzoomlimit', view.xzoomlimit);
    gui.put('yzoomlimit', view.yzoomlimit);
end
if isfield(view, 'panel') && ~isempty(view.panel) && isfield(handles, view.panel)
    if strcmp(view.panel, 'multip08')
        plot.derivs_Callback % derive parameters: also fills the list of parameters
    else
        gui.switchui(view.panel);
    end
end
end
