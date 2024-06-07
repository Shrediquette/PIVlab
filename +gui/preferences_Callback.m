function preferences_Callback (~,~)
hgui=getappdata(0,'hgui');
handles=gui.gethand;
panelwidth=gui.retr('panelwidth');
set(handles.panelslider,'Value',panelwidth);
gui.switchui('multip21')

