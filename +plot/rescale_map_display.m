function [out, minscale, maxscale, region] = rescale_map_display(in, x, y, imsize, isangle, interp_method, extrapolate_border, roirect, grid, region)
%RESCALE_MAP_DISPLAY Derived map at the display pixels of a large frame (plot.display_grid).
%   [out, minscale, maxscale] = plot.rescale_map_display(in, x, y, imsize, isangle, interp_method, ...
%       extrapolate_border, roirect, grid)
%   [out, minscale, maxscale, region] = plot.rescale_map_display(..., grid, region)
%   Inputs as plot.rescale_map_core (map on the vector grid x, y; image size imsize), plus grid.
%   out                 the map of plot.rescale_map_core taken at the display pixel centres
%                       (grid.ri, grid.ci): [numel(grid.yc) numel(grid.xc)]
%   minscale, maxscale  smallest / largest value of the full resolution map of plot.rescale_map_core
%                       (for the automatic colour limits, NaN ignored)
%   region              the full resolution map inside the vector grid (output of an earlier call):
%                       used again when in, x, y, imsize, isangle and interp_method are the same
%                       (zoom / pan: only the display pixels change); [] = compute it
%
%   Inside the vector grid the values are exactly those of plot.rescale_map_core (the same
%   plot.grid_to_pixels, taken at the display pixels); outside the fill value (mean) is the same. Only the
%   extrapolated border (extrapolate_border, spring inpainting) is computed at display
%   resolution: at full resolution it took 1-3 s for a 26 MP frame. Inpainting with springs gives
%   values between the known neighbours, so the colour limits of the full map are those of the
%   known values (exact).
if nargin < 10
	region = [];
end
ri = grid.ri(:);
ci = grid.ci(:)';
H = imsize(1);
W = imsize(2);
if H == size(in, 1) && W == size(in, 2) % already at image resolution (e.g. LIC)
	out = in(ri, ci, 1);
	minscale = min(in(:));
	maxscale = max(in(:));
	region = [];
	return
end
key = {in, x, y, imsize(1:2), isangle, interp_method};
% region of the vector grid in image pixels (as plot.rescale_map_core)
step = x(1,2) - x(1,1);
minx = (min(min(x)) - step/2);
maxx = (max(max(x)) + step/2);
miny = (min(min(y)) - step/2);
maxy = (max(max(y)) + step/2);
miny_idx = max(1, floor(miny));
minx_idx = max(1, floor(minx));
maxy_idx = min(H, floor(maxy - 1));
maxx_idx = min(W, floor(maxx - 1));
if extrapolate_border
	fill = NaN;
else
	fill = mean(in(:)); % of all layers, as plot.rescale_map_core
end
if size(in, 3) > 1
	in(:, :, 2:end) = [];
end
if isstruct(region) && isfield(region, 'key') && isequaln(region.key, key) % isequaln: maps with NaN
	dispvar = region.dispvar;
else
	rows = miny_idx:maxy_idx;
	cols = minx_idx:maxx_idx;
	if isangle == 1 % angle data is unsteady, needs to interpolated differently
		X_interp = plot.grid_to_pixels(cos(in/180*pi), x(1,:), y(:,1), rows, cols, 'bilinear');
		Y_interp = plot.grid_to_pixels(sin(in/180*pi), x(1,:), y(:,1), rows, cols, 'bilinear');
		dispvar = angle(complex(X_interp, Y_interp))*180/pi;
	else
		dispvar = plot.grid_to_pixels(in, x(1,:), y(:,1), rows, cols, interp_method);
	end
	region = struct();
	region.key = key;
	region.dispvar = dispvar;
	region.min = min(dispvar(:));
	region.max = max(dispvar(:));
end
out = fill * ones(numel(ri), numel(ci));
in_r = ri >= miny_idx & ri <= maxy_idx;
in_c = ci >= minx_idx & ci <= maxx_idx;
out(in_r, in_c) = dispvar(ri(in_r) - miny_idx + 1, ci(in_c) - minx_idx + 1);

% colour limits of the full resolution map: the values inside, and the fill where the image has
% pixels outside the vector grid
minscale = region.min;
maxscale = region.max;
outside = miny_idx > 1 || maxy_idx < H || minx_idx > 1 || maxx_idx < W;
if outside && ~extrapolate_border
	minscale = min(minscale, fill);
	maxscale = max(maxscale, fill);
end

if extrapolate_border
	% inpaint the border strips at display resolution, inside the ROI box (as plot.rescale_map_core)
	interior_nan = false(size(out));
	interior_nan(in_r, in_c) = isnan(out(in_r, in_c));
	if ~isempty(roirect) && numel(roirect) >= 4
		o_r1 = max(1, roirect(2));
		o_r2 = min(H, roirect(2) + roirect(4));
		o_c1 = max(1, roirect(1));
		o_c2 = min(W, roirect(1) + roirect(3));
	else
		o_r1 = 1; o_r2 = H; o_c1 = 1; o_c2 = W;
	end
	box_r = find(ri >= o_r1 & ri <= o_r2);
	box_c = find(ci >= o_c1 & ci <= o_c2);
	if ~isempty(box_r) && ~isempty(box_c)
		sub = out(box_r, box_c);
		reg_r = find(in_r(box_r));
		reg_c = find(in_c(box_c));
		if ~isempty(reg_r) && ~isempty(reg_c)
			sub = plot.inpaint_border_strips(sub, reg_r(1), reg_r(end), reg_c(1), reg_c(end));
			out(box_r, box_c) = sub;
		end
	end
	out(interior_nan) = NaN;
end
end
