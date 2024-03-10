function gui_preferences_Callback (~,~)
hgui=getappdata(0,'hgui');
handles=gui_NameSpace.gui_gethand;
panelwidth=gui_NameSpace.gui_retr('panelwidth');
set(handles.panelslider,'Value',panelwidth);
gui_NameSpace.gui_switchui('multip21')
