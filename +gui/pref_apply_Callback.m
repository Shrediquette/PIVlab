function pref_apply_Callback (~, ~)
gui.put('num_handle_calls',0);
hgui=getappdata(0,'hgui');
handles=gui.gethand;
panelwidth=round(get(handles.panelslider,'Value'));
gui.put('panelwidth',panelwidth);
gui.put('quickwidth',panelwidth);
gui.destroyUI
gui.generateUI
gui.MainWindow_ResizeFcn(gcf)
gui.preferences_Callback
gui.clear_user_content
gui.displogo(1)

