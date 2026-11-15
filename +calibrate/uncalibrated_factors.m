function [calu, calv] = uncalibrated_factors(x_axis_direction, y_axis_direction)
%UNCALIBRATED_FACTORS calu and calv without a calibration (results in px and px/frame).
%   [calu, calv] = calibrate.uncalibrated_factors(x_axis_direction, y_axis_direction)
%   x_axis_direction  1 = x increases to the right, 2 = to the left
%   y_axis_direction  1 = y increases to the bottom, 2 = to the top
%   The axis directions apply to pixel units too: calu and calv are +1 or -1.
calu = 1;
if x_axis_direction == 2
    calu = -1;
end
calv = 1;
if y_axis_direction == 2
    calv = -1;
end
end
