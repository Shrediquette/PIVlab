function clear_plot_Callback(~, ~, ~)
h_extractionplot=gui.retr('h_extractionplot');
h_extractionplot2=gui.retr('h_extractionplot2');
for i=1:size(h_extractionplot,1)
	try
		close (h_extractionplot(i));
	catch
	end
	try
		close (h_extractionplot2(i));
	catch
	end
end
gui.put ('h_extractionplot', []);
gui.put ('h_extractionplot2', []);
delete(findobj(gui.retr('pivlab_axis'),'tag', 'extractpoint'));
delete(findobj(gui.retr('pivlab_axis'),'tag', 'extractline'));
delete(findobj(gui.retr('pivlab_axis'),'tag', 'circstring'));
delete(findobj(gui.retr('pivlab_axis'),'Tag','extract_poly'))
delete(findobj(gui.retr('pivlab_axis'),'Tag','extract_circle'))
delete(findobj(gui.retr('pivlab_axis'),'Tag','extract_circle_series'))
delete(findobj(gui.retr('pivlab_axis'),'Tag','extract_circle_series_displayed_smaller_radii'))
delete(findobj(gui.retr('pivlab_axis'),'Tag','extract_circle_series_max_circulation'))
delete(findobj(gui.retr('pivlab_axis'),'Tag','extract_poly_area'))
delete(findobj(gui.retr('pivlab_axis'),'Tag','extract_rectangle_area'))
delete(findobj(gui.retr('pivlab_axis'),'Tag','extract_circle_area'))
delete(findobj(gui.retr('pivlab_axis'),'Tag','extract_circle_series_area'))
delete(findobj(gui.retr('pivlab_axis'),'Tag','extract_circle_series_area_displayed_smaller_radii'))
delete(findobj(gui.retr('pivlab_axis'),'Tag','extract_circle_series_area_max_circulation'))
gui.put('xposition',[]);
gui.put('yposition',[]);
gui.put('extract_type',[]);
handles=gui.gethand;
set(handles.area_results,'String','');

