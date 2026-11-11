function result = PIVlab_capture_board_markers(input_image, n_cols, n_rows)
%ArUco markers of a ChArUco board (DICT_4X4_1000) per image region: decides whether a board is in view.
%   result = PIVlab_capture_board_markers(input_image) counts the markers in 3 x 3 regions.
%   result = PIVlab_capture_board_markers(input_image, n_cols, n_rows) uses n_cols x n_rows regions.
%
%   result.n_markers    n_rows x n_cols, number of marker centres in each region
%   result.is_board     true if at least 3 markers are found
%   result.centres      n x 2, marker centres [x y] in pixels; result.sizes: n x 1, marker side lengths [px]
%   result.reduced      the reduced image, result.scale: its scale (for PIVlab_capture_edge_width)
%   result.col_edges    1 x n_cols+1, region borders in pixels
%   result.row_edges    1 x n_rows+1
%
%   The detection runs on a copy reduced to about 1000 px (10-50 ms for 20 MP).

if nargin < 2
	n_cols = 3;
end
if nargin < 3
	n_rows = 3;
end
reduced_size = 1000; %[px] larger image side
min_markers = 3;     %a single marker can be a false detection in a particle image

if size(input_image,3) > 1
	input_image = input_image(:,:,1);
end
[height, width] = size(input_image);
result.col_edges = round(linspace(0, width, n_cols+1));
result.row_edges = round(linspace(0, height, n_rows+1));
result.n_markers = zeros(n_rows, n_cols);
result.is_board = false;
result.centres = zeros(0, 2);
result.sizes = zeros(0, 1);
result.reduced = [];
result.scale = 1;

scale = min(1, reduced_size / max(height, width));
if scale < 1
	reduced = single(imresize(input_image, scale, 'box')); %in the image class: much faster than in single
else
	reduced = single(input_image);
end
if max(reduced(:)) == min(reduced(:))
	return
end
result.reduced = reduced;
result.scale = scale;
%no histeq: it destroys clean two-level images (synthetic boards); the detector thresholds adaptively
[ids, locs] = readArucoMarker(mat2gray(reduced), 'DICT_4X4_1000');
n = numel(ids);
result.centres = zeros(n, 2);
result.sizes = zeros(n, 1);
if n < min_markers
	return
end
result.is_board = true;
for k = 1:n
	%marker centre and side length in the full image
	x = (mean(locs(:, 1, k)) - 0.5) / scale + 0.5;
	y = (mean(locs(:, 2, k)) - 0.5) / scale + 0.5;
	result.centres(k, :) = [x y];
	result.sizes(k) = sqrt(polyarea(locs(:, 1, k), locs(:, 2, k))) / scale;
	c = find(x > result.col_edges(1:end-1) & x <= result.col_edges(2:end), 1);
	r = find(y > result.row_edges(1:end-1) & y <= result.row_edges(2:end), 1);
	if ~isempty(c) && ~isempty(r)
		result.n_markers(r, c) = result.n_markers(r, c) + 1;
	end
end
end
