function zoomon_Callback(hObject, ~, ~)
hgui=getappdata(0,'hgui');
handles=gui.gethand;
if get(hObject,'Value')==1
	hCMZ = uicontextmenu;
	hZMenu = uimenu('Parent',hCMZ,'Label','Reset Zoom / Pan','Callback',@gui.zoom_reset_zoom);
	hZoom=zoom(gcf);
	hZoom.UIContextMenu = hCMZ;
	hZoom.ActionPostCallback = @acquisition.redraw_camera_images; %live camera images: draw the zoomed part sharp
	zoom(gui.retr('pivlab_axis'),'on')
	set(handles.panon,'Value',0);
else
	zoom(gui.retr('pivlab_axis'),'off')
	gui.put('xzoomlimit', get (gui.retr('pivlab_axis'), 'xlim'));
	gui.put('yzoomlimit', get (gui.retr('pivlab_axis'), 'ylim'));
end

