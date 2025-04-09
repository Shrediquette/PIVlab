function poly_extract_Callback(~, ~, ~)
handles=gui.gethand;
gui.switchui('multip12')
if (gui.retr('calu')==1 || gui.retr('calu')==-1) && gui.retr('calxy')==1
	set(handles.extraction_choice,'string', {'Vorticity in 1/frame';'Magnitude in px/frame';'u component in px/frame';'v component in px/frame';'Divergence in 1/frame';'Vortex locator';'Shear rate in 1/frame';'Strain rate in 1/frame';'Vector direction in degrees';'Correlation coefficient';'Tangent velocity in px/frame'});
else %calibrated
	displacement_only=gui.retr('displacement_only');
	if ~isempty(displacement_only) && displacement_only == 1
		set(handles.extraction_choice,'string', {'Vorticity in 1/frame';'Magnitude in m/frame';'u component in m/frame';'v component in m/frame';'Divergence in 1/frame';'Vortex locator';'Shear rate in 1/frame';'Strain rate in 1/frame';'Vector direction in degrees';'Correlation coefficient';'Tangent velocity in m/frame'});
	else
		set(handles.extraction_choice,'string', {'Vorticity in 1/s';'Magnitude in m/s';'u component in m/s';'v component in m/s';'Divergence in 1/s';'Vortex locator';'Shear rate in 1/s';'Strain rate in 1/s';'Vector direction in degrees';'Correlation coefficient';'Tangent velocity in m/s'});
	end
end
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
	if strcmp(extract_type,'extract_poly') || strcmp(extract_type,'extract_circle') || strcmp(extract_type,'extract_circle_series')
		extract.update_display(extract_type, xposition, yposition)
	end
end

