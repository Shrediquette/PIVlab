function calibrate_update_green_calibration_box(calxy, calu, offset_x_true, offset_y_true, handles)
if calxy > 1000 || calxy <0.001
	px_per_m_display=sprintf('%0.4e',calxy);
else
	px_per_m_display=sprintf('%0.4f',calxy);
end

if calu > 1000 || calu < 0.001
	px_per_frame_display=sprintf('%0.4e',calu);
else
	px_per_frame_display=sprintf('%0.4f',calu);
end

if abs(offset_x_true) > 1000 || abs(offset_x_true) < 0.001
	x_offset_display=sprintf('%0.4e',offset_x_true);
	if offset_x_true == 0
		x_offset_display='0';
	end
else
	x_offset_display=sprintf('%0.4f',offset_x_true);
end

if abs(offset_y_true) > 1000 || abs(offset_y_true) < 0.001
	y_offset_display=sprintf('%0.4e',offset_y_true);
	if offset_y_true == 0
		y_offset_display='0';
	end
else
	y_offset_display=sprintf('%0.4f',offset_y_true);
end

set(handles.calidisp, 'string', ['1 px = ' px_per_m_display ' m' sprintf('\n') '1 px/frame = ' px_per_frame_display ' m/s' sprintf('\n') 'x offset: ' x_offset_display ' m' sprintf('\n') 'y offset: ' y_offset_display ' m'],  'backgroundcolor', [0.5 1 0.5]);
