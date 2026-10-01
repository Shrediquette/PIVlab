function calccali
gui.put('derived',[]) %calibration makes previously derived params incorrect
handles=gui.gethand;

pointscali=gui.retr('pointscali');
if isempty(pointscali)
	pixeldist_val=str2double(get(handles.pixeldist,'String'));
	if ~isnan(pixeldist_val) && pixeldist_val > 0
		calibrate.pixeldist_changed_Callback(handles.pixeldist);
		pointscali=gui.retr('pointscali');
	end
end
if numel(pointscali)>0
	realdist=str2double(get(handles.realdist, 'String'));
	time=str2double(get(handles.time_inp, 'String'));
	x_axis_direction=get(handles.x_axis_direction,'value'); %1= increase to right, 2= increase to left
	y_axis_direction=get(handles.y_axis_direction,'value'); %1= increase to bottom, 2= increase to top
	points_offsetx=gui.retr('points_offsetx');
	points_offsety=gui.retr('points_offsety');
	size_of_the_image=gui.retr('size_of_the_image');
	if isempty(size_of_the_image) && (numel(points_offsetx)>0 || numel(points_offsety)>0) %user applies calibration before loading images
		size_of_the_image=size(gui.retr('caliimg'));
		gui.put('size_of_the_image',size_of_the_image);
	end
	% calibration factors (shared with the command-line API, pivlab.toMetric)
	cal = calibrate.compute_calibration(pointscali, realdist, time, x_axis_direction, y_axis_direction, points_offsetx, points_offsety, size_of_the_image);
	gui.put('displacement_only',cal.displacement_only)
	gui.put('calu',cal.calu);
	gui.put('calv',cal.calv);
	gui.put('calxy',cal.calxy);
	set(findobj(handles.uipanel_offsets,'Type','uicontrol'),'Enable','on')
	gui.put('offset_x_true',cal.offset_x_true);
	gui.put('offset_y_true',cal.offset_y_true);

	calxy=gui.retr('calxy');
	calu=gui.retr('calu');calv=gui.retr('calv');
	offset_x_true = gui.retr('offset_x_true');
	offset_y_true = gui.retr('offset_y_true');

	calibrate.update_green_calibration_box(calxy, calu, offset_x_true, offset_y_true, handles);

	%sliderdisp(retr('pivlab_axis'))

else %no calibration performed yet
	set(findobj(handles.uipanel_offsets,'Type','uicontrol'),'Enable','off')
	set(handles.x_axis_direction,'value',1);
	set(handles.y_axis_direction,'value',1);
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Reference distance','You need to select a reference distance befor applying a calibration.','modal');
end

