function zoom_reset_zoom(~,~)
handles=gui.gui_gethand;
setappdata(getappdata(0,'hgui'),'xzoomlimit',[]);
setappdata(getappdata(0,'hgui'),'yzoomlimit',[]);
%zoom reset
zoom out
set(handles.zoomon,'Value',0);
set(handles.panon,'Value',0);
zoom(gca,'off')
pan(gca,'off')
expected_image_size=gui.gui_retr('expected_image_size');
set(gui.gui_retr('pivlab_axis'),'xlim',[0.5 expected_image_size(2)+0.5])
set(gui.gui_retr('pivlab_axis'),'ylim',[0.5 expected_image_size(1)+0.5])

