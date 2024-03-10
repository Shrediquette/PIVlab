function gui_panon_Callback(hObject, ~, ~)
handles=gui_NameSpace.gui_gethand;
if get(hObject,'Value')==1
	hCMP = uicontextmenu;
	hPMenu = uimenu('Parent',hCMP,'Label','Reset Pan / Zoom','Callback',@gui_NameSpace.gui_zoom_reset_zoom);
	hPan=pan(gcf);
	hPan.UIContextMenu = hCMP;
	pan(gui_NameSpace.gui_retr('pivlab_axis'),'on')
	set(handles.zoomon,'Value',0);
else
	pan(gui_NameSpace.gui_retr('pivlab_axis'),'off')
	gui_NameSpace.gui_put('xzoomlimit', get (gui_NameSpace.gui_retr('pivlab_axis'), 'xlim'));
	gui_NameSpace.gui_put('yzoomlimit', get (gui_NameSpace.gui_retr('pivlab_axis'), 'ylim'));
end
