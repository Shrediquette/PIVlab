function result = PIVlab_capture_edge_width(input_image, n_cols, n_rows, max_size)
%Width of black / white edges (e.g. a calibration board) per image region, as a focus measure.
%   result = PIVlab_capture_edge_width(input_image) splits the image into 3 x 3 regions.
%   result = PIVlab_capture_edge_width(input_image, n_cols, n_rows, max_size) uses n_cols x n_rows
%   regions and at most max_size x max_size pixels in the centre of each region (default 256).
%
%   The edge width (10 % to 90 % rise of the intensity across an edge, in pixels) depends on the focus,
%   not on the size of the checkers, the contrast or the light. For a Gaussian blur with sigma s it is
%   2.56 s.
%
%   result.width        n_rows x n_cols, median edge width [px]; NaN: no clean edges
%   result.is_board     n_rows x n_cols, true for a board: 15-85 % of the area bright, many edges are clean
%                       steps, all with about the same width; false e.g. for particles or a photo
%   result.n_edges      n_rows x n_cols, number of clean edge profiles
%   result.col_edges    1 x n_cols+1, region borders in pixels
%   result.row_edges    1 x n_rows+1
%
%   Method: edge pixels (Canny), up to 300 per region; for each, an intensity profile of +-10 px along
%   the gradient. A profile counts if it rises from a flat dark end to a flat bright end without going
%   back; the 10 % and 90 % points are interpolated linearly. Widths above about 12 px (sigma 5 px)
%   cannot be measured: the white margins next to the markers of a ChArUco board are too narrow.

if nargin < 2
	n_cols = 3;
end
if nargin < 3
	n_rows = 3;
end
if nargin < 4
	max_size = 256;
end
half_length = 15;    %profile length on each side of the edge [px]
max_points = 300;
min_edges = 20;      %clean profiles needed for a value
min_fraction = 0.3;  %of the edge pixels, for "board"
max_spread = 0.5;    %interquartile range / median of the widths, for "board" (one blur for all edges)

if size(input_image,3) > 1
	input_image = input_image(:,:,1);
end
[height, width] = size(input_image);
col_edges = round(linspace(0, width, n_cols+1));
row_edges = round(linspace(0, height, n_rows+1));

result.width = nan(n_rows, n_cols);
result.is_board = false(n_rows, n_cols);
result.n_edges = zeros(n_rows, n_cols);
result.fraction = zeros(n_rows, n_cols);
result.spread = nan(n_rows, n_cols);
result.col_edges = col_edges;
result.row_edges = row_edges;

t = -half_length:half_length;
for r = 1:n_rows
	for c = 1:n_cols
		rows = central_range(row_edges(r)+1, row_edges(r+1), max_size);
		cols = central_range(col_edges(c)+1, col_edges(c+1), max_size);
		region = single(input_image(rows, cols));
		[h, w] = size(region);
		if h < 4 * half_length || w < 4 * half_length || max(region(:)) == min(region(:))
			continue
		end
		region = (region - min(region(:))) / (max(region(:)) - min(region(:)));
		%board: black and white areas; particle images: mostly dark
		sorted = sort(region(:));
		low = sorted(max(1, round(0.02 * numel(sorted))));
		high = sorted(round(0.98 * numel(sorted)));
		bright_fraction = nnz(region > (low + high) / 2) / numel(region);
		black_and_white = bright_fraction >= 0.15 && bright_fraction <= 0.85;
		edge_map = edge(region, 'canny');
		%no profiles that leave the region
		edge_map([1:half_length+1, end-half_length:end], :) = false;
		edge_map(:, [1:half_length+1, end-half_length:end]) = false;
		[ey, ex] = find(edge_map);
		if numel(ex) < min_edges
			continue
		end
		if numel(ex) > max_points
			pick = round(linspace(1, numel(ex), max_points));
			ex = ex(pick);
			ey = ey(pick);
		end
		[gx, gy] = imgradientxy(imgaussfilt(region, 1));
		index = sub2ind([h w], ey, ex);
		gx = gx(index);
		gy = gy(index);
		g = sqrt(gx.^2 + gy.^2);
		ux = gx ./ g; %direction dark -> bright
		uy = gy ./ g;
		%profiles: one row per edge pixel
		px = ex + ux * t;
		py = ey + uy * t;
		profiles = interp2(region, px, py, 'linear');
		widths = nan(numel(ex), 1);
		for i = 1:numel(ex)
			widths(i) = step_width(profiles(i,:), t);
		end
		valid = ~isnan(widths);
		result.n_edges(r,c) = nnz(valid);
		result.fraction(r,c) = nnz(valid) / numel(ex);
		if nnz(valid) >= min_edges
			result.width(r,c) = median(widths(valid));
			result.spread(r,c) = quartile_range(widths(valid)) / result.width(r,c);
			result.is_board(r,c) = black_and_white && result.fraction(r,c) >= min_fraction && result.spread(r,c) <= max_spread;
		end
	end
end
end

function width = step_width(p, t)
%10-90 % width of the step at t = 0: from the darkest point before it to the brightest point after it
%(the white margin next to a ChArUco marker can be narrow, so the levels are not taken at the profile ends).
%NaN if it is not a clean step.
width = NaN;
if any(isnan(p))
	return
end
centre = find(t == 0);
[low, i_low] = min(p(1:centre));
[high, i_high] = max(p(centre:end));
i_high = i_high + centre - 1;
step = high - low;
if step < 0.2 %of the intensity range of the region
	return
end
q = (p(i_low:i_high) - low) / step;
tq = t(i_low:i_high);
%rises without going back (small noise allowed)
if any(diff(q) < -0.1)
	return
end
t10 = crossing(q, tq, 0.1);
t90 = crossing(q, tq, 0.9);
if ~isnan(t10) && ~isnan(t90) && t90 > t10
	width = t90 - t10;
end
end

function tc = crossing(q, t, level)
%last position before the centre ... first after: q rises through level (linear interpolation)
tc = NaN;
k = find(q(1:end-1) < level & q(2:end) >= level, 1, 'first');
if ~isempty(k)
	tc = t(k) + (level - q(k)) / (q(k+1) - q(k)) * (t(k+1) - t(k));
end
end

function q = quartile_range(values)
%interquartile range (without the Statistics Toolbox)
values = sort(values(:));
n = numel(values);
q = values(max(1, round(0.75 * n))) - values(max(1, round(0.25 * n)));
end

function range = central_range(first, last, max_size)
n = last - first + 1;
if n > max_size
	first = first + floor((n - max_size) / 2);
	last = first + max_size - 1;
end
range = first:last;
end
