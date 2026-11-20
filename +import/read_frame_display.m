function [img, grid, out_size, raw_read, img_whole] = read_frame_display(src, selected, cam, bg, target_axis, limits, raw_read)
%READ_FRAME_DISPLAY One frame at screen resolution (only for drawing it), no GUI needed.
%   [img, grid, out_size] = import.read_frame_display(src, selected, cam, bg, target_axis, limits)
%   [img, grid, out_size, raw_read] = ... also the frame as read (import.read_raw_frame), e.g. for
%   import.get_img when the frame is small, or for the next call after zoom / pan
%   [img, grid, out_size, raw_read, img_whole] = ... also point samples of the whole frame (no
%   averaging), for contrast limits of the full resolution pixels that do not change with zoom
%   [...] = import.read_frame_display(..., raw_read)  the frame as read by an earlier call (not read again)
%   src, selected, cam, bg  as import.read_frame (the PIVlab window: import.frame_inputs)
%   target_axis  axes the frame is drawn into
%   limits       [x1 x2 y1 y2] axes limits it will be shown with, [] = the whole image
%
%   img       the frame as import.get_img returns it (undistorted, rectified, background
%             subtracted, same class and grey value range), but on the display grid: each display
%             pixel is the average of the full resolution pixels it covers. [] when the frame is
%             small enough to be drawn at full resolution (then grid is [] too).
%   grid      display grid (plot.display_grid), full resolution pixel coordinates
%   out_size  [height width] of the full resolution corrected frame (grid []: of the frame as read)
%
%   Only for drawing. Everything that computes with image data (analysis, masks, background,
%   export, ...) uses import.get_img at full resolution.
if nargin < 7 || isempty(raw_read)
	raw_read = import.read_raw_frame(src, selected);
end
raw = raw_read;
if size(raw, 3) > 1
	raw = rgb2gray(raw); % as preproc.cam_undistort / stereo.rectify_map
end
img = [];
img_whole = [];
% small frame: drawn at full resolution by the caller, no display geometry needed (the correction
% keeps the size, the stereo transform about the same; a large corrected size is checked below)
out_size = [size(raw, 1) size(raw, 2)];
grid = plot.display_grid(target_axis, out_size, limits);
if isempty(grid)
	return
end
geo = import.display_geometry(cam, size(raw), class(raw));
out_size = geo.out_size;
if ~isequal(out_size, grid.full_size)
	grid = plot.display_grid(target_axis, out_size, limits);
	if isempty(grid)
		return
	end
end
stereo_mode = isfield(cam, 'stereo_map') && ~isempty(cam.stereo_map);
bg_img = [];
if ~isempty(bg)
	if mod(selected, 2) == 1
		bg_img = bg.A;
	else
		bg_img = bg.B;
	end
end
img = frame_on_grid(raw, geo, grid, bg_img, stereo_mode);
if nargout > 4
	% the whole frame at the display pixel centres without block average (n = 1): the grey value
	% distribution of the full resolution pixels (averaging dims sparse particles)
	whole_grid = plot.display_grid(target_axis, out_size, []);
	whole_grid.n = 1;
	img_whole = frame_on_grid(raw, geo, whole_grid, bg_img, stereo_mode);
end
end

function img = frame_on_grid(raw, geo, grid, bg_img, stereo_mode)
% the corrected frame at the display pixels of grid (see above)
% source position (full resolution raw pixel coordinates) of every display pixel
if geo.identity
	src_x = grid.xc;
	src_y = grid.yc;
	weight = [];
else
	[XQ, YQ] = meshgrid(grid.xc, grid.yc);
	weight = geo.Fw(YQ, XQ);
	src_x = geo.Fx(YQ, XQ) ./ weight;
	src_y = geo.Fy(YQ, XQ) ./ weight;
	valid = weight >= 0.5;
	src_x(~valid) = NaN;
	src_y(~valid) = NaN;
end

% the part of the raw frame that is needed, background subtracted where the background is in raw
% coordinates (no geometry change, or stereo: background before the stereo transform)
n = grid.n;
[r1, r2] = needed_range(src_y, size(raw, 1), n);
[c1, c2] = needed_range(src_x, size(raw, 2), n);
work = single(raw(r1:r2, c1:c2));
bg_in_raw = ~isempty(bg_img) && (geo.identity || stereo_mode);
if bg_in_raw
	work = max(work - single(bg_img(r1:r2, c1:c2)), 0);
end
vals = sample_block_average(work, n, r1, c1, src_y, src_x);
if ~geo.identity
	vals = vals .* single(weight) * geo.scale;
	vals(~valid) = 0;
end
% background in corrected coordinates: averaged the same way and subtracted
if ~isempty(bg_img) && ~bg_in_raw
	[b1, b2] = needed_range(grid.yc, size(bg_img, 1), n);
	[d1, d2] = needed_range(grid.xc, size(bg_img, 2), n);
	bgd = sample_block_average(single(bg_img(b1:b2, d1:d2)), n, b1, d1, grid.yc, grid.xc);
	vals = max(vals - bgd, 0);
end
vals(vals < 0) = 0;
vals(isnan(vals)) = 0;
% class of import.get_img: the corrected frame, minus the background image (stereo: the background
% is subtracted from the raw frame, the stereo transform gives the class)
out_class = geo.out_class;
if ~isempty(bg_img) && ~stereo_mode
	out_class = class(zeros(1, 1, geo.out_class) - bg_img(1));
end
img = cast(vals, out_class); % integer classes: rounded and saturated
end

function [a, b] = needed_range(pos, len, n)
% rows / columns of the raw frame that the sampling positions need (block average + cubic)
p = pos(:);
p = p(~isnan(p));
if isempty(p)
	a = 1;
	b = min(len, 2);
	return
end
a = max(1, floor(min(p)) - 2 * n - 2);
b = min(len, ceil(max(p)) + 2 * n + 2);
end

function vals = sample_block_average(work, n, r1, c1, qy, qx)
% average n x n blocks of work (rows r1..., columns c1... of the full frame) and interpolate
% (cubic) at the full resolution positions qy, qx (vectors: grid, matrices: points)
[h, w] = size(work);
if n > 1
	hb = ceil(h / n);
	wb = ceil(w / n);
	if hb * n > h % incomplete last block: repeat the last row / column
		work = [work; repmat(work(end,:), hb * n - h, 1)];
	end
	if wb * n > w
		work = [work, repmat(work(:,end), 1, wb * n - w)];
	end
	A = reshape(work, n, hb, n, wb);
	P = reshape(sum(sum(A, 1), 3), hb, wb) / n ^ 2;
else
	P = work;
end
% centre of block j (full resolution coordinates): r1 + (j - 1) * n + (n - 1) / 2
gy = (1:size(P, 1)) * n + r1 - n + (n - 1) / 2;
gx = (1:size(P, 2)) * n + c1 - n + (n - 1) / 2;
method = 'cubic';
if numel(gy) < 4 || numel(gx) < 4
	method = 'linear';
end
if numel(gy) < 2 || numel(gx) < 2
	method = 'nearest';
	if numel(gy) < 2
		P = [P; P];
		gy = [gy, gy + 1];
	end
	if numel(gx) < 2
		P = [P, P];
		gx = [gx, gx + 1];
	end
end
F = griddedInterpolant({gy, gx}, P, method, 'nearest');
if isvector(qy) && isvector(qx) && ~isequal(size(qy), size(qx))
	vals = F({qy(:), qx(:)}); % grid vectors
else
	vals = F(qy, qx);
end
end
