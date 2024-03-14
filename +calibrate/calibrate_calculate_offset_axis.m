function offset = calibrate_calculate_offset_axis (axis,pixel_position,true_position)
handles=gui.gui_gethand;
calxy=gui.gui_retr('calxy');
size_of_the_image=gui.gui_retr('size_of_the_image');
if isempty(size_of_the_image)%user applies calibration before loading images
	caliimg=gui.gui_retr('caliimg');
	size_of_the_image=size(caliimg);
	gui.gui_put('size_of_the_image',size_of_the_image);
end
if strcmp(axis,'x')
	axis_direction=get(handles.x_axis_direction,'value');
	size_dim=size_of_the_image(2);
end
if strcmp(axis,'y')
	axis_direction=get(handles.y_axis_direction,'value');
	size_dim=size_of_the_image(1);
end
if axis_direction ==1
	offset = pixel_position*calxy - true_position/1000;
else
	offset = (size_dim-pixel_position)*calxy - true_position/1000;
end

