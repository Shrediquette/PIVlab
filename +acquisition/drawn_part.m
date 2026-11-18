function [rows, cols, step] = drawn_part(himg, frame_size, x_offset, ds)
%DRAWN_PART Rows and columns of a camera frame that acquisition.show_frame draws.
%   [rows, cols, step] = acquisition.drawn_part(himg, frame_size, x_offset, ds)
%   The part of the frame inside the axes limits (zoom), every step-th pixel, step = camera pixels per screen
%   pixel (at least ds). An image outside the view: a coarse image (about 200 pixels wide).
%   Also used for the display rate (acquisition.display_rate): the number of pixels drawn.
rows = 1:ds:frame_size(1);
cols = 1:ds:frame_size(2);
step = ds;
ax = himg.Parent;
if ~isgraphics(ax, 'axes')
    return
end
x_lim = ax.XLim - x_offset;
y_lim = ax.YLim;
c1 = max(1, floor(x_lim(1)));
c2 = min(frame_size(2), ceil(x_lim(2)));
r1 = max(1, floor(y_lim(1)));
r2 = min(frame_size(1), ceil(y_lim(2)));
if c1 > c2 || r1 > r2 % this image is outside the view
    step = max(ds, ceil(max(frame_size) / 200));
    rows = 1:step:frame_size(1);
    cols = 1:step:frame_size(2);
    return
end
old_units = ax.Units;
ax.Units = 'pixels';
ax_pixels = ax.Position(3:4);
ax.Units = old_units;
step = floor(min(diff(x_lim) / max(ax_pixels(1), 1), diff(y_lim) / max(ax_pixels(2), 1)));
step = max([1, step, ds]);
cols = c1:step:c2;
rows = r1:step:r2;
end
