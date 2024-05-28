function preferences_Callback (~,~)
hgui=getappdata(0,'hgui');
handles=gui.gui_gethand;
panelwidth=gui.gui_retr('panelwidth');
set(handles.panelslider,'Value',panelwidth);
gui.gui_switchui('multip21')

