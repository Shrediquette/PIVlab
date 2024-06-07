function calccali
gui.put('derived',[]) %calibration makes previously derived params incorrect
handles=gui.gethand;

pointscali=gui.retr('pointscali');
if numel(pointscali)>0
	xposition=pointscali(:,1);
	yposition=pointscali(:,2);
	dist=sqrt((xposition(1)-xposition(2))^2 + (yposition(1)-yposition(2))^2);
	realdist=str2double(get(handles.realdist, 'String'));
	time=str2double(get(handles.time_inp, 'String'));
	calxy=(realdist/1000)/dist; %m/px %realdist=realdistance in m; dist=distance in px
	x_axis_direction=get(handles.x_axis_direction,'value'); %1= increase to right, 2= increase to left
	y_axis_direction=get(handles.y_axis_direction,'value'); %1= increase to bottom, 2= increase to top
	if x_axis_direction==1
		calu=calxy/(time/1000);
	else
		calu=-1*(calxy/(time/1000));
	end
	if y_axis_direction==1
		calv=calxy/(time/1000);
	else
		calv=-1*(calxy/(time/1000));
	end
	gui.put('calu',calu);
	gui.put('calv',calv);
	gui.put('calxy',calxy);
	set(findobj(handles.uipanel_offsets,'Type','uicontrol'),'Enable','on')
	points_offsetx=gui.retr('points_offsetx');
	if numel(points_offsetx)>0
		offsetx = calibrate.calculate_offset_axis('x',points_offsetx(1),points_offsetx(3));
		gui.put('offset_x_true',offsetx);
	else %no offsets applied
		gui.put('offset_x_true',0);
	end
	points_offsety=gui.retr('points_offsety');
	if numel(points_offsety)>0
		offsety = calibrate.calculate_offset_axis('y',points_offsety(2),points_offsety(3));
		gui.put('offset_y_true',offsety);
	else %no offsets applied
		gui.put('offset_y_true',0);
	end

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
	msgbox ('You need to select a reference distance befor applying a calibration.','modal')
end

