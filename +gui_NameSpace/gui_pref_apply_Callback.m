function gui_pref_apply_Callback (~, ~)
gui_NameSpace.gui_put('num_handle_calls',0);
hgui=getappdata(0,'hgui');
handles=gui_NameSpace.gui_gethand;
panelwidth=round(get(handles.panelslider,'Value'));
gui_NameSpace.gui_put('panelwidth',panelwidth);
gui_NameSpace.gui_put('quickwidth',panelwidth);
gui_NameSpace.gui_destroyUI
gui_NameSpace.gui_generateUI
gui_NameSpace.gui_MainWindow_ResizeFcn(gcf)
gui_NameSpace.gui_preferences_Callback
gui_NameSpace.gui_clear_user_content
gui_NameSpace.gui_displogo(1)
