function area_panel_activation_Callback(~, ~, ~)
handles=gui.gethand;
gui.switchui('multip17');
if (gui.retr('calu')==1 || gui.retr('calu')==-1) && gui.retr('calxy')==1
	%set(handles.area_para_select,'string', {'Vorticity [1/frame]';'Magnitude [px/frame]';'u component [px/frame]';'v component [px/frame]';'Divergence [1/frame]';'Vortex locator [1]';'Shear rate [1/frame]';'Strain rate [1/frame]';'Vector direction [degrees]';'Correlation coefficient [-]'});
	set(handles.extraction_choice_area,'string', {'Vorticity [1/frame]';'Magnitude [px/frame]';'u component [px/frame]';'v component [px/frame]';'Divergence [1/frame]';'Vortex locator [1]';'Shear rate [1/frame]';'Strain rate [1/frame]';'Vector direction [degrees]';'Correlation coefficient [-]'});
else
	%set(handles.area_para_select,'string', {'Vorticity [1/s]';'Magnitude [m/s]';'u component [m/s]';'v component [m/s]';'Divergence [1/s]';'Vortex locator [1]';'Shear rate [1/s]';'Strain rate [1/s]';'Vector direction [degrees]';'Correlation coefficient [-]'});
	set(handles.extraction_choice_area,'string', {'Vorticity [1/s]';'Magnitude [m/s]';'u component [m/s]';'v component [m/s]';'Divergence [1/s]';'Vortex locator [1]';'Shear rate [1/s]';'Strain rate [1/s]';'Vector direction [degrees]';'Correlation coefficient [-]'});
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
	if strcmp(extract_type,'extract_poly_area') || strcmp(extract_type,'extract_rectangle_area') || strcmp(extract_type,'extract_circle_area') || strcmp(extract_type,'extract_circle_series_area')
		extract.update_display(extract_type, xposition, yposition)
	end
end

