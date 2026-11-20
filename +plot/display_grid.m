function grid = display_grid(ax, full_size, limits)
%DISPLAY_GRID Pixel grid for drawing a large image at screen resolution.
%   grid = plot.display_grid(ax, full_size, limits)
%   ax         axes the image is drawn into
%   full_size  [height width] of the full resolution image
%   limits     [x1 x2 y1 y2] axes limits the image will be shown with, [] = the whole image
%
%   grid = [] when the whole image has less than 2 image pixels per screen pixel: then the image is
%   drawn at full resolution as before. Otherwise:
%   grid.full_size  full resolution size [height width]
%   grid.xc, grid.yc  centres of the display pixels in full resolution pixel coordinates (row
%                     vector / column vector); the display pixels tile the drawn region exactly
%   grid.xdata, grid.ydata  XData / YData of the drawn image (first and last centre)
%   grid.ci, grid.ri  full resolution column / row that contains each display pixel centre
%   grid.n            block size for averaging the full resolution image (integer >= 1)
%   grid.region       drawn region [x1 x2 y1 y2] (the whole image, or the visible part with a
%                     margin when zoomed in)
%   grid.step         full resolution pixels per screen pixel in the visible part
%
%   About one display pixel per screen pixel (at least one full resolution pixel). All objects stay
%   in full resolution pixel coordinates (masks, ROI, vectors, clicks are unchanged).
grid = [];
H = full_size(1);
W = full_size(2);
ax_px = axes_pixels(ax);
whole = [0.5, W + 0.5, 0.5, H + 0.5];
% the whole image: display path only for images that are larger than the screen area
step_whole = max(W / ax_px(1), H / ax_px(2));
if step_whole < 2
	return
end
if isempty(limits)
	limits = whole;
end
% visible part of the image
vis = [max(limits(1), whole(1)), min(limits(2), whole(2)), max(limits(3), whole(3)), min(limits(4), whole(4))];
if vis(2) - vis(1) < 1 || vis(4) - vis(3) < 1 % image not visible: draw a coarse whole image
	vis = whole;
	limits = whole;
end
step = max(1, max((limits(2) - limits(1)) / ax_px(1), (limits(4) - limits(3)) / ax_px(2)));
region = vis;
if vis(1) > whole(1) || vis(2) < whole(2) || vis(3) > whole(3) || vis(4) < whole(4)
	% zoomed in: the visible part with a margin of a quarter view on each side (small pans
	% need no new image)
	mx = 0.25 * (vis(2) - vis(1));
	my = 0.25 * (vis(4) - vis(3));
	region = [max(whole(1), vis(1) - mx), min(whole(2), vis(2) + mx), max(whole(3), vis(3) - my), min(whole(4), vis(4) + my)];
	% whole pixels
	region = [floor(region(1) - 0.5) + 0.5, ceil(region(2) - 0.5) + 0.5, floor(region(3) - 0.5) + 0.5, ceil(region(4) - 0.5) + 0.5];
	region = [max(whole(1), region(1)), min(whole(2), region(2)), max(whole(3), region(3)), min(whole(4), region(4))];
end
n = max(1, floor(step));
Wd = max(2, round((region(2) - region(1)) / n));
Hd = max(2, round((region(4) - region(3)) / n));
sx = (region(2) - region(1)) / Wd;
sy = (region(4) - region(3)) / Hd;
grid.full_size = [H W];
grid.xc = region(1) + ((1:Wd) - 0.5) * sx;
grid.yc = region(3) + ((1:Hd)' - 0.5) * sy;
grid.xdata = [grid.xc(1) grid.xc(end)];
grid.ydata = [grid.yc(1) grid.yc(end)];
grid.ci = min(max(round(grid.xc), 1), W);
grid.ri = min(max(round(grid.yc), 1), H);
grid.n = max(1, min(n, round(min(sx, sy)))); % the block size n (sx, sy can be slightly smaller after rounding Wd, Hd)
grid.region = region;
grid.step = step;
end

function px = axes_pixels(ax)
% size of the axes on the screen in pixels (at most the size of the largest monitor; the figure can
% be on any monitor, ScreenSize is only the primary one)
old_units = ax.Units;
ax.Units = 'pixels';
px = ax.Position(3:4);
ax.Units = old_units;
monitors = get(groot, 'MonitorPositions');
screen = max(monitors(:, 3:4), [], 1);
px = min(max(px, 1), max(screen, 1));
end
