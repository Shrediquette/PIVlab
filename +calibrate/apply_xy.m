function [x_cal,y_cal] = apply_xy(x, y, cal, size_of_the_image)
%APPLY_XY Convert pixel coordinates to calibrated coordinates (no GUI needed).
%   [x_cal, y_cal] = calibrate.apply_xy(x, y, cal, size_of_the_image)
%   cal: struct with calxy, offset_x_true, offset_y_true, x_axis_direction, y_axis_direction
%   (see calibrate.compute_calibration). size_of_the_image: [height width] in pixels.
%   Used by calibrate.xy (GUI) and pivlab.toMetric.
if cal.x_axis_direction == 1
    x_cal=x;
else
    x_cal=size_of_the_image(2)-x;
end
if cal.y_axis_direction == 1
    y_cal=y;
else
    y_cal=size_of_the_image(1)-y;
end
x_cal=x_cal*cal.calxy;
y_cal=y_cal*cal.calxy;
x_cal=x_cal-cal.offset_x_true;
y_cal=y_cal-cal.offset_y_true;
end
