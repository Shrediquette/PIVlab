function gui_panon_Callback(hObject, ~, ~)
handles=gui.gui_gethand;
if get(hObject,'Value')==1
	hCMP = uicontextmenu;
	hPMenu = uimenu('Parent',hCMP,'Label','Reset Pan / Zoom','Callback',@gui.gui_zoom_reset_zoom);
	hPan=pan(gcf);
	hPan.UIContextMenu = hCMP;
	pan(gui.gui_retr('pivlab_axis'),'on')
	set(handles.zoomon,'Value',0);
else
	pan(gui.gui_retr('pivlab_axis'),'off')
	gui.gui_put('xzoomlimit', get (gui.gui_retr('pivlab_axis'), 'xlim'));
	gui.gui_put('yzoomlimit', get (gui.gui_retr('pivlab_axis'), 'ylim'));
end

