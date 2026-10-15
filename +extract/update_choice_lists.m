function update_choice_lists(handles)
% Fills the lists of what to extract along a poly-line (extraction_choice) and from an area
% (extraction_choice_area) with the units of the current calibration. Stereo-PIV: one more item at
% the end of each list, the w component (poly-line item 14, area item 12; the magnitude is then 3D).
% A list item wanted by loaded settings is selected afterwards (gui.apply_pending_popup).
if nargin < 1
	handles=gui.gethand;
end
if (gui.retr('calu')==1 || gui.retr('calu')==-1) && gui.retr('calxy')==1
	velocity_unit='px/frame';
	time_unit='frame';
else %calibrated
	displacement_only=gui.retr('displacement_only');
	if ~isempty(displacement_only) && displacement_only == 1
		velocity_unit='m/frame';
		time_unit='frame';
	else
		velocity_unit='m/s';
		time_unit='s';
	end
end
area_items={['Vorticity in 1/' time_unit];['Magnitude in ' velocity_unit];['u component in ' velocity_unit];['v component in ' velocity_unit];['Divergence in 1/' time_unit];['Q criterion in 1/' time_unit '^2'];['Shear rate in 1/' time_unit];['Strain rate in 1/' time_unit];'Vector direction in degrees';'Correlation coefficient';['Uncertainty in ' velocity_unit]};
line_items=[area_items;{['Tangent velocity in ' velocity_unit];['Normal velocity in ' velocity_unit]}]; % <-- Kozlov N.
if isequal(gui.retr('stereomode'),1)
	area_items{end+1,1}=['w component in ' velocity_unit];
	line_items{end+1,1}=['w component in ' velocity_unit];
end
set_list(handles.extraction_choice,line_items);
set_list(handles.extraction_choice_area,area_items);
end

function set_list(control,items)
set(control,'String',items);
if get(control,'Value')>numel(items) %w component chosen, back in 2D mode
	set(control,'Value',1);
end
gui.apply_pending_popup(control) %item wanted by a loaded session
end
