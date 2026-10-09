function pref_apply_Callback (~, ~)
gui.put('num_handle_calls',0);
hgui=getappdata(0,'hgui');
handles=gui.gethand;
panelwidth=round(get(handles.panelslider,'Value'));
gui.put('panelwidth',panelwidth);
gui.put('quickwidth',panelwidth);
gui.set_preference('panelwidth',panelwidth);
settings = gui.collect_settings; % the window is rebuilt: keep the settings, the data and the view
view = gui.collect_view;
gui.destroyUI
gui.generateUI
gui.put('num_handle_calls',0); % fresh handles of the new controls
gui.apply_settings(settings, fieldnames(gui.default_settings), true);
gui.MainWindow_ResizeFcn(getappdata(0,'hgui'))
gui.preferences_Callback % open the preferences panel first: only it is visible while the data is shown again
gui.show_data_after_rebuild(view)

