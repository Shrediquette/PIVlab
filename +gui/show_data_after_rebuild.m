function show_data_after_rebuild(view)
% After all controls were rebuilt (Preferences -> Apply, theme change; the settings are already
% back): the loaded images, results, masks, calibration etc. are shown again, with the same frame,
% A/B image and zoom as before (view from gui.collect_view, taken before the rebuild).
handles = gui.gethand;
if isempty(gui.retr('filepath')) % no images loaded: no data to show
	gui.update_dependent_controls
	gui.displogo(1)
	return
end
set(handles.filenamebox,'String',gui.retr('filename'));
set(handles.filenamebox,'Value',1);
gui.sliderrange(0) % frame range of the new slider
gui.refresh_data_displays(handles)
view.panel = ''; % the caller opens the panel it needs
gui.apply_view(view)
set(handles.remove_imgs,'Enable','on');
gui.update_dependent_controls
gui.sliderdisp(gui.retr('pivlab_axis'))
image_size=gui.retr('expected_image_size'); % shown in the Input data panel
if numel(image_size)>=2
	set(handles.imsize, 'string', ['Image size: ' int2str(image_size(2)) '*' int2str(image_size(1)) 'px' ])
end
end
