function zoomon_Callback(hObject, ~, ~)
hgui=getappdata(0,'hgui');
handles=gui.gui_gethand;
if get(hObject,'Value')==1
	hCMZ = uicontextmenu;
	hZMenu = uimenu('Parent',hCMZ,'Label','Reset Zoom / Pan','Callback',@gui.gui_zoom_reset_zoom);
	hZoom=zoom(gcf);
	hZoom.UIContextMenu = hCMZ;
	zoom(gui.gui_retr('pivlab_axis'),'on')
	set(handles.panon,'Value',0);
else
	zoom(gui.gui_retr('pivlab_axis'),'off')
	gui.gui_put('xzoomlimit', get (gui.gui_retr('pivlab_axis'), 'xlim'));
	gui.gui_put('yzoomlimit', get (gui.gui_retr('pivlab_axis'), 'ylim'));
end

