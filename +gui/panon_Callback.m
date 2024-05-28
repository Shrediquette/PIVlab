function panon_Callback(hObject, ~, ~)
handles=gui.gethand;
if get(hObject,'Value')==1
	hCMP = uicontextmenu;
	hPMenu = uimenu('Parent',hCMP,'Label','Reset Pan / Zoom','Callback',@gui.zoom_reset_zoom);
	hPan=pan(gcf);
	hPan.UIContextMenu = hCMP;
	pan(gui.retr('pivlab_axis'),'on')
	set(handles.zoomon,'Value',0);
else
	pan(gui.retr('pivlab_axis'),'off')
	gui.put('xzoomlimit', get (gui.retr('pivlab_axis'), 'xlim'));
	gui.put('yzoomlimit', get (gui.retr('pivlab_axis'), 'ylim'));
end

