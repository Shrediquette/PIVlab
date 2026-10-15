function area_panel_activation_Callback(~, ~, ~)
handles=gui.gethand;
gui.switchui('multip17');
extract.update_choice_lists(handles) %units of the calibration; stereo-PIV: w component
%draw extraction polygon when frame was changed.
pivlab_axis=gui.retr('pivlab_axis');
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
xposition = gui.retr('xposition');
yposition = gui.retr('yposition');
extract_type = gui.retr('extract_type');

if ~isempty(xposition) && ~isempty(yposition) && ~isempty(extract_type)
	if strcmp(extract_type,'extract_poly_area') || strcmp(extract_type,'extract_rectangle_area') || strcmp(extract_type,'extract_circle_area') || strcmp(extract_type,'extract_circle_series_area')
		extract.update_display(extract_type, xposition, yposition)
	end
end

