function pref_apply_Callback (~, ~)
gui.gui_put('num_handle_calls',0);
hgui=getappdata(0,'hgui');
handles=gui.gui_gethand;
panelwidth=round(get(handles.panelslider,'Value'));
gui.gui_put('panelwidth',panelwidth);
gui.gui_put('quickwidth',panelwidth);
gui.gui_destroyUI
gui.gui_generateUI
gui.gui_MainWindow_ResizeFcn(gcf)
gui.gui_preferences_Callback
gui.gui_clear_user_content
gui.gui_displogo(1)

