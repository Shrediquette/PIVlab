function pref_apply_Callback (~, ~)
gui.put('num_handle_calls',0);
hgui=getappdata(0,'hgui');
handles=gui.gethand;
panelwidth=round(get(handles.panelslider,'Value'));
gui.put('panelwidth',panelwidth);
gui.put('quickwidth',panelwidth);
gui.set_preference('panelwidth',panelwidth);
settings = gui.collect_settings; % the window is rebuilt: keep the settings
gui.destroyUI
gui.generateUI
gui.put('num_handle_calls',0); % fresh handles of the new controls
gui.apply_settings(settings, fieldnames(gui.default_settings), true);
gui.MainWindow_ResizeFcn(gcf)
gui.preferences_Callback
gui.clear_user_content
gui.displogo(1)

