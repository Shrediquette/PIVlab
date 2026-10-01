function cal = compute_calibration(pointscali, realdist, time, x_axis_direction, y_axis_direction, points_offsetx, points_offsety, size_of_the_image)
%COMPUTE_CALIBRATION PIVlab calibration factors from a reference distance (no GUI needed).
%   cal = calibrate.compute_calibration(pointscali, realdist, time, x_axis_direction, ...
%           y_axis_direction, points_offsetx, points_offsety, size_of_the_image)
%
%   pointscali        2x2 [x1 y1; x2 y2] end points of the reference distance in pixels
%   realdist          real length of the reference distance in mm
%   time              time between the two images of a pair in ms (0 = displacements only)
%   x_axis_direction  1 = x increases to the right, 2 = to the left
%   y_axis_direction  1 = y increases to the bottom, 2 = to the top
%   points_offsetx    [] or [x_px y_px x_true_mm] position of a known x coordinate
%   points_offsety    [] or [x_px y_px y_true_mm] position of a known y coordinate
%   size_of_the_image [height width] in pixels (only needed for offsets with flipped axes)
%
%   cal  struct with calxy (m/px), calu, calv (m/s per px/frame, or m/frame per px/frame),
%        offset_x_true, offset_y_true (m), displacement_only, x_axis_direction, y_axis_direction
%
%   Used by calibrate.calccali (GUI) and pivlab.toMetric.
xposition=pointscali(:,1);
yposition=pointscali(:,2);
dist=sqrt((xposition(1)-xposition(2))^2 + (yposition(1)-yposition(2))^2);

calxy=(realdist/1000)/dist; %m/px %realdist=realdistance in m; dist=distance in px

if time == 0 %user entered zero as time step --> PIVlab will measure displacements instead of velocities
    displacement_only=1;
    if x_axis_direction==1
        calu=calxy;
    else
        calu=-1*calxy;
    end
    if y_axis_direction==1
        calv=calxy;
    else
        calv=-1*calxy;
    end
else
    displacement_only=0;
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
end
if numel(points_offsetx)>0
    offset_x_true = offset_axis(x_axis_direction, points_offsetx(1), points_offsetx(3), calxy, size_of_the_image(2));
else %no offsets applied
    offset_x_true = 0;
end
if numel(points_offsety)>0
    offset_y_true = offset_axis(y_axis_direction, points_offsety(2), points_offsety(3), calxy, size_of_the_image(1));
else %no offsets applied
    offset_y_true = 0;
end
cal = struct('calxy',calxy,'calu',calu,'calv',calv,'offset_x_true',offset_x_true, ...
    'offset_y_true',offset_y_true,'displacement_only',displacement_only, ...
    'x_axis_direction',x_axis_direction,'y_axis_direction',y_axis_direction);
end

function offset = offset_axis(axis_direction, pixel_position, true_position, calxy, size_dim)
if axis_direction ==1
    offset = pixel_position*calxy - true_position/1000;
else
    offset = (size_dim-pixel_position)*calxy - true_position/1000;
end
end
