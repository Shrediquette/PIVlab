function [x_cal,y_cal] = xy(x,y)
%pixel coordinates -> calibrated coordinates with the calibration of the GUI
%(calculation shared with the command-line API: calibrate.apply_xy)
handles=gui.gethand;
cal.x_axis_direction=get(handles.x_axis_direction,'value'); %1= increase to right, 2= increase to left
cal.y_axis_direction=get(handles.y_axis_direction,'value'); %1= increase to bottom, 2= increase to top
cal.calxy=gui.retr('calxy');
cal.offset_x_true=gui.retr('offset_x_true');
cal.offset_y_true=gui.retr('offset_y_true');
[x_cal,y_cal] = calibrate.apply_xy(x, y, cal, gui.retr('size_of_the_image'));
