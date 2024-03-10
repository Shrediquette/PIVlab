function [x_cal,y_cal] = calibrate_xy(x,y)
handles=gui_NameSpace.gui_gethand;
x_axis_direction=get(handles.x_axis_direction,'value'); %1= increase to right, 2= increase to left
y_axis_direction=get(handles.y_axis_direction,'value'); %1= increase to bottom, 2= increase to top
size_of_the_image=gui_NameSpace.gui_retr('size_of_the_image');
sizex=size_of_the_image(2);
sizey=size_of_the_image(1);
if x_axis_direction == 1
	x_cal=x;
else
	x_cal=sizex-x;
end
if y_axis_direction == 1
	y_cal=y;
else
	y_cal=sizey-y;
end
x_cal=x_cal*gui_NameSpace.gui_retr('calxy');
y_cal=y_cal*gui_NameSpace.gui_retr('calxy');
x_cal=x_cal-gui_NameSpace.gui_retr('offset_x_true');
y_cal=y_cal-gui_NameSpace.gui_retr('offset_y_true');
