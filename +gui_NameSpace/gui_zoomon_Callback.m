function gui_zoomon_Callback(hObject, ~, ~)
hgui=getappdata(0,'hgui');
handles=gui_NameSpace.gui_gethand;
if get(hObject,'Value')==1
	hCMZ = uicontextmenu;
	hZMenu = uimenu('Parent',hCMZ,'Label','Reset Zoom / Pan','Callback',@gui_NameSpace.gui_zoom_reset_zoom);
	hZoom=zoom(gcf);
	hZoom.UIContextMenu = hCMZ;
	zoom(gui_NameSpace.gui_retr('pivlab_axis'),'on')
	set(handles.panon,'Value',0);
else
	zoom(gui_NameSpace.gui_retr('pivlab_axis'),'off')
	gui_NameSpace.gui_put('xzoomlimit', get (gui_NameSpace.gui_retr('pivlab_axis'), 'xlim'));
	gui_NameSpace.gui_put('yzoomlimit', get (gui_NameSpace.gui_retr('pivlab_axis'), 'ylim'));
end
