function result = PIVlab_capture_edge_width(input_image, n_cols, n_rows, markers)
%Width of black / white edges (calibration board) per image region, as a focus measure.
%   result = PIVlab_capture_edge_width(input_image) splits the image into 3 x 3 regions.
%   result = PIVlab_capture_edge_width(input_image, n_cols, n_rows) uses n_cols x n_rows regions.
%   result = PIVlab_capture_edge_width(input_image, n_cols, n_rows, markers) uses only edges near the
%   markers found by PIVlab_capture_board_markers (not e.g. a wall next to the board) and its reduced image.
%
%   The edge width (10 % to 90 % rise of the intensity across an edge, in pixels) depends on the focus,
%   not on the size of the checkers, the contrast or the light. For a Gaussian blur with sigma s it is
%   2.56 s. Whether the image shows a board is not tested here (PIVlab_capture_board_markers does that).
%
%   result.width        n_rows x n_cols, median edge width [px]; NaN: fewer than 20 clean edges
%   result.n_edges      n_rows x n_cols, number of clean edge profiles
%   result.spread       n_rows x n_cols, interquartile range / median of the widths
%   result.col_edges    1 x n_cols+1, region borders in pixels
%   result.row_edges    1 x n_rows+1
%
%   Method: the strong edges (Canny) and their directions are found in a copy of the image reduced to
%   about 1000 px (fast; the reduction also removes the grain of a black print). Up to 300 edge points
%   per region; at each, intensity profiles across the edge are taken from the full image, averaged
%   within +-8 px along the edge (a straight edge keeps its width, grain averages out) and centred on
%   the steepest point. A profile counts if it rises from dark to bright without going back; the 10 % and
%   90 % points are interpolated linearly. Widths above about 12 px (sigma 5 px) cannot be measured on a
%   ChArUco board: the white margins next to the markers are too narrow.

if nargin < 2
	n_cols = 3;
end
if nargin < 3
	n_rows = 3;
end
half_length = 15;    %profile length on each side of the edge [px, full image]
max_points = 300;    %edge points per region
min_edges = 20;      %clean profiles needed for a value
canny_thresholds = [0.12 0.3]; %of the largest gradient: only strong edges (not the grain of the black print)
reduced_size = 1000; %[px] larger image side for the edge detection
lateral_shifts = -8:2:8; %[px, full image] along the edge: profiles averaged over these shifts

if size(input_image,3) > 1
	input_image = input_image(:,:,1);
end
[height, width] = size(input_image);
col_edges = round(linspace(0, width, n_cols+1));
row_edges = round(linspace(0, height, n_rows+1));

result.width = nan(n_rows, n_cols);
result.n_edges = zeros(n_rows, n_cols);
result.spread = nan(n_rows, n_cols);
result.col_edges = col_edges;
result.row_edges = row_edges;

%reduced copy for the edge detection
if nargin < 4
	markers = [];
end
if ~isempty(markers) && ~isempty(markers.reduced)
	scale = markers.scale;
	reduced = markers.reduced;
else
	scale = min(1, reduced_size / max(height, width));
	if scale < 1
		reduced = single(imresize(input_image, scale, 'box')); %in the image class: much faster than in single
	else
		reduced = single(input_image);
	end
end
canny_sigma = max(1.5, 4 * scale); %[px, reduced image]: about 4 px in the full image
%the edge found in the reduced image can be off by about one reduced pixel: search the steepest point there
slack = ceil(1 / scale) + 1;
t = -(half_length + slack):(half_length + slack);
margin = half_length + slack + max(abs(lateral_shifts)) + 2; %[px, full image] profiles stay in the region

for r = 1:n_rows
	for c = 1:n_cols
		%region in the reduced image
		rows_r = max(1, round(row_edges(r) * scale) + 1):min(size(reduced, 1), round(row_edges(r+1) * scale));
		cols_r = max(1, round(col_edges(c) * scale) + 1):min(size(reduced, 2), round(col_edges(c+1) * scale));
		region = reduced(rows_r, cols_r);
		if numel(rows_r) < 16 || numel(cols_r) < 16 || max(region(:)) == min(region(:))
			continue
		end
		low = min(region(:));
		high = max(region(:));
		edge_map = edge((region - low) / (high - low), 'canny', canny_thresholds, canny_sigma);
		[ey, ex] = find(edge_map);
		%positions in the full image (pixel centres)
		x = (cols_r(1) - 1 + ex - 0.5) / scale + 0.5;
		y = (rows_r(1) - 1 + ey - 0.5) / scale + 0.5;
		inside = x > col_edges(c) + margin & x < col_edges(c+1) - margin & y > row_edges(r) + margin & y < row_edges(r+1) - margin;
		if ~isempty(markers)
			%near a marker: within 1.5 marker sizes of its centre (the checker edges of a ChArUco board)
			near_marker = false(size(x));
			for k = 1:size(markers.centres, 1)
				near_marker = near_marker | (x - markers.centres(k, 1)).^2 + (y - markers.centres(k, 2)).^2 <= (1.5 * markers.sizes(k))^2;
			end
			inside = inside & near_marker;
		end
		x = x(inside);
		y = y(inside);
		ex = ex(inside);
		ey = ey(inside);
		if numel(x) < min_edges
			continue
		end
		if numel(x) > max_points
			pick = round(linspace(1, numel(x), max_points));
			x = x(pick);
			y = y(pick);
			ex = ex(pick);
			ey = ey(pick);
		end
		%edge direction (dark -> bright) from the reduced image
		[gx, gy] = imgradientxy(imgaussfilt(region, 1));
		index = sub2ind(size(region), ey, ex);
		gx = gx(index);
		gy = gy(index);
		g = sqrt(gx.^2 + gy.^2);
		ux = gx ./ g;
		uy = gy ./ g;
		%profiles from the full image, averaged along the edge; intensities relative to the region range
		profiles = zeros(numel(x), numel(t));
		for shift = lateral_shifts
			profiles = profiles + bilinear(input_image, x - shift * uy + ux * t, y + shift * ux + uy * t);
		end
		profiles = (profiles / numel(lateral_shifts) - low) / (high - low);
		widths = nan(numel(x), 1);
		for i = 1:numel(x)
			widths(i) = step_width(profiles(i,:), t, slack);
		end
		valid = ~isnan(widths);
		result.n_edges(r,c) = nnz(valid);
		if nnz(valid) >= min_edges
			result.width(r,c) = median(widths(valid));
			result.spread(r,c) = quartile_range(widths(valid)) / result.width(r,c);
		end
	end
end
end

function values = bilinear(img, x, y)
%bilinear interpolation of img at the positions x, y (all inside the image)
x0 = floor(x);
y0 = floor(y);
fx = x - x0;
fy = y - y0;
h = size(img, 1);
i00 = y0 + (x0 - 1) * h;
values = double(img(i00)) .* (1 - fx) .* (1 - fy) + double(img(i00 + h)) .* fx .* (1 - fy) + ...
	double(img(i00 + 1)) .* (1 - fx) .* fy + double(img(i00 + h + 1)) .* fx .* fy;
end

function width = step_width(p, t, slack)
%10-90 % width of the step at the steepest point within +-slack of t = 0: from the darkest point before it
%to the brightest point after it (the white margin next to a ChArUco marker can be narrow, so the levels are
%not taken at the profile ends). NaN if it is not a clean step.
width = NaN;
if any(isnan(p))
	return
end
smoothed = movmean(p, 3); %levels and centre not set by a single grain minimum / maximum
near = find(abs(t) <= slack);
[~, k] = max(diff(smoothed(near(1):near(end) + 1)));
centre = near(1) + k - 1;
[low, i_low] = min(smoothed(1:centre));
[high, i_high] = max(smoothed(centre:end));
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
%first position where q rises through level (linear interpolation)
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
