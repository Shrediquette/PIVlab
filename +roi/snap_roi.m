function [x, y, w, h] = snap_roi(x, y, w, h, c)
% Snap offsets to nearest valid step, clamped so min_w/min_h always fits
x_max = floor((c.sensor_w - c.min_w) / c.step_x) * c.step_x + 1;
x = max(1, min(x_max, round((x-1)/c.step_x)*c.step_x + 1));

y_max = floor((c.sensor_h - c.min_h) / c.step_y) * c.step_y + 1;
y = max(1, min(y_max, round((y-1)/c.step_y)*c.step_y + 1));

% Snap sizes to nearest valid step, clamped to [min, space remaining after offset]
w_max = floor((c.sensor_w - (x-1)) / c.step_w) * c.step_w;
w = max(c.min_w, min(w_max, round(w/c.step_w)*c.step_w));

h_max = floor((c.sensor_h - (y-1)) / c.step_h) * c.step_h;
h = max(c.min_h, min(h_max, round(h/c.step_h)*c.step_h));
