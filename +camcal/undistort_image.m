function img_out = undistort_image(img_in, K, D, view)
%UNDISTORT_IMAGE Undistort an image with the OpenCV camera model (incl. tilted sensor), pure MATLAB.
%   img_out = camcal.undistort_image(img_in, K, D)
%   img_out = camcal.undistort_image(img_in, K, D, view)
%   img_in  grayscale or RGB image (uint8, uint16, single, double)
%   K       3x3 intrinsic matrix (OpenCV layout), D distortion vector (up to 14 elements)
%   view    'same' (default, new camera matrix = K), 'valid' or 'full'
%
%   The undistortion of OpenCV (initUndistortRectifyMap + remap with INTER_CUBIC,
%   BORDER_CONSTANT 0), with the same grey values: the source position is rounded to
%   1/32 pixel, the bicubic kernel uses a = -0.75, uint8 images use OpenCV's fixed-point
%   weights, uint16 / single are summed in float as OpenCV. Pixel coordinates as in
%   OpenCV (the first pixel is at (0, 0)).
%   The map (tap positions and weight indices) is cached for the last K, D, view and
%   image size, so a series of images only pays for the interpolation.

if nargin < 4 || isempty(view)
	view = 'same';
end
H = size(img_in, 1);
W = size(img_in, 2);
C = size(img_in, 3);
in_class = class(img_in);

switch view
	case 'valid'
		newK = camcal.optimal_camera_matrix(K, D, [H W], 0);
	case 'full'
		newK = camcal.optimal_camera_matrix(K, D, [H W], 1);
	otherwise
		newK = K;
end

P = 3;   % zero border: taps outside the image read 0 (BORDER_CONSTANT)
map = cached_map(K, D, newK, H, W, P);

fixed_point = isa(img_in, 'uint8');
if isa(img_in, 'double')
	acc_class = 'double';   % as OpenCV (double sums)
else
	% uint16 / single: float sums as OpenCV. uint8: integer sums of pixel * fixed-point
	% weight; every partial sum stays below 255 * 1.6 * 2^15 < 2^24, so single is exact
	acc_class = 'single';
end

% weight of tap k for weight index wi, looked up in OpenCV's 2D weight table (a 1D
% interpolant 'nearest' is a multi-threaded lookup)
wtab = cast(weight_table(fixed_point), acc_class);
Fw = cell(1, 16);
for k = 1:16
	Fw{k} = griddedInterpolant(wtab(:,k), 'nearest');
end

img_out = zeros(H, W, C, in_class);
padded = zeros(H + 2 * P, W + 2 * P, acc_class);
block_rows = max(1, floor(block_pixels() / W));
for ch = 1:C
	padded(P+1:P+H, P+1:P+W) = cast(img_in(:,:,ch), acc_class);
	% image lookups with 'nearest' at integer positions: exact pixel values, multi-threaded
	Fimg = griddedInterpolant(padded, 'nearest', 'nearest');
	for r0 = 1:block_rows:H
		rows = r0:min(r0 + block_rows - 1, H);
		R0 = single(map.R0(rows,:));
		C0 = single(map.C0(rows,:));
		wi = single(map.wi(rows,:));
		Cn = cell(1, 4);
		for n = 0:3
			Cn{n + 1} = C0 + n;
		end
		% sum as OpenCV remapBicubic: one partial sum per kernel row, then added up
		acc = zeros(size(R0), acc_class);
		for m = 0:3
			Rm = R0 + m;
			row_sum = zeros(size(R0), acc_class);
			for n = 0:3
				row_sum = row_sum + Fimg(Rm, Cn{n + 1}) .* Fw{m * 4 + n + 1}(wi);
			end
			acc = acc + row_sum;
		end
		out = cast_like_opencv(acc, in_class, fixed_point);
		out(~map.inside(rows,:)) = 0;
		img_out(rows, :, ch) = out;
	end
end
end

% =====================================================================
function map = cached_map(K, D, newK, H, W, P)
% undistortion map as initUndistortRectifyMap (CV_32FC1) and the remap tap positions:
% R0, C0  padded row / column (1-based) of tap (0, 0)
% wi      row of the 2D weight table (fy * 32 + fx + 1)
% inside  all 16 taps inside the padded image (else the output pixel is 0, also for NaN)
% R0, C0, wi are integers, kept as uint16 (half the memory of single: the map stays in memory
% for the session, in every parallel worker), single for images larger than 65000 px
persistent cache_key cache_map
key = [K(:); D(:); newK(:); H; W; P];
if ~isempty(cache_key) && isequal(cache_key, key)
	map = cache_map;
	return
end
map_class = 'uint16';
if max(H, W) + 2 * P + 4 > 65535
	map_class = 'single';
end
map.R0 = zeros(H, W, map_class);
map.C0 = zeros(H, W, map_class);
map.wi = zeros(H, W, map_class);
map.inside = false(H, W);
block_rows = max(1, floor(2^21 / W));
cols = 0:W-1;
for r0 = 0:block_rows:H-1
	rows = r0:min(r0 + block_rows, H) - 1;
	[jj, ii] = meshgrid(cols, rows);
	[xd, yd] = camcal.distort_normalized((jj - newK(1,3)) / newK(1,1), (ii - newK(2,3)) / newK(2,2), D);
	u = single(K(1,1) * xd + K(1,3));
	v = single(K(2,2) * yd + K(2,3));
	% remap: source position on the 1/32 pixel grid (cvRound = round half to even)
	X = round_half_even(double(u * single(32)));
	Y = round_half_even(double(v * single(32)));
	ix = floor(X / 32);
	iy = floor(Y / 32);
	sx = ix - 1;   % first tap (0-based)
	sy = iy - 1;
	inside = sx >= -P & sx <= W - 1 & sy >= -P & sy <= H - 1;
	R0 = sy + P + 1;
	C0 = sx + P + 1;
	wi = (Y - 32 * iy) * 32 + (X - 32 * ix) + 1;
	R0(~inside) = 1;
	C0(~inside) = 1;
	wi(~inside) = 1;
	map.R0(rows + 1,:) = cast(R0, map_class);
	map.C0(rows + 1,:) = cast(C0, map_class);
	map.wi(rows + 1,:) = cast(wi, map_class);
	map.inside(rows + 1,:) = inside;
end
cache_key = key;
cache_map = map;
end

% =====================================================================
function n = block_pixels()
% pixels per processing block: large blocks keep the per-call overhead of the lookups low
% (26 MP image: 2^18 px 2.0 s, 2^21 px 1.1 s, 2^23 px 1.05 s); 2^21: about 100 MB of
% temporaries instead of 400 MB (parallel workers)
n = 2^21;
end

% =====================================================================
function wtab = weight_table(fixed_point)
% 2D bicubic weights for the 32 x 32 sub-pixel positions (OpenCV initInterTab2D).
% Row (fy * 32 + fx + 1), column (ky * 4 + kx + 1). Float weights (products of the
% single precision 1D weights), or for uint8 the fixed-point weights (scale 2^15) with
% OpenCV's correction of the sum.
tab1 = zeros(32, 4, 'single');
A = single(-0.75);
for i = 0:31
	x = single(i) / single(32);
	c0 = ((A * (x + 1) - 5 * A) * (x + 1) + 8 * A) * (x + 1) - 4 * A;
	c1 = ((A + 2) * x - (A + 3)) * x * x + 1;
	c2 = ((A + 2) * (1 - x) - (A + 3)) * (1 - x) * (1 - x) + 1;
	c3 = single(1) - c0 - c1 - c2;
	tab1(i + 1,:) = [c0 c1 c2 c3];
end
wtab = zeros(32 * 32, 16);
scale = 32768;   % INTER_REMAP_COEF_SCALE
for i = 0:31
	for j = 0:31
		w = zeros(4, 4, 'single');
		for k1 = 1:4
			for k2 = 1:4
				w(k1, k2) = tab1(i + 1, k1) * tab1(j + 1, k2);
			end
		end
		if fixed_point
			iw = round_half_even(double(w * single(scale)));
			iw = min(max(iw, -32768), 32767);
			diff_sum = sum(iw(:)) - scale;
			if diff_sum ~= 0
				% correct the sum on the largest / smallest of the 4 centre weights
				mk = [3 3];
				Mk = [3 3];
				for k1 = 3:4
					for k2 = 3:4
						if iw(k1, k2) < iw(mk(1), mk(2))
							mk = [k1 k2];
						elseif iw(k1, k2) > iw(Mk(1), Mk(2))
							Mk = [k1 k2];
						end
					end
				end
				if diff_sum < 0
					iw(Mk(1), Mk(2)) = iw(Mk(1), Mk(2)) - diff_sum;
				else
					iw(mk(1), mk(2)) = iw(mk(1), mk(2)) - diff_sum;
				end
			end
			w2 = iw;
		else
			w2 = double(w);
		end
		row = i * 32 + j + 1;
		for k1 = 1:4
			for k2 = 1:4
				wtab(row, (k1 - 1) * 4 + k2) = w2(k1, k2);
			end
		end
	end
end
end

function out = cast_like_opencv(acc, in_class, fixed_point)
if fixed_point
	% FixedPtCast<int, uchar, 15>: (sum + 2^14) >> 15, saturated
	out = uint8(min(max(floor((acc + 16384) / 32768), 0), 255));
	return
end
switch in_class
	case 'uint16'
		% saturate_cast<ushort>(float): round half to even
		out = uint16(min(max(round_half_even(acc), 0), 65535));
	case 'single'
		out = single(acc);
	otherwise
		out = acc;
end
end

function r = round_half_even(v)
r = round(v);
ties = abs(v - fix(v)) == 0.5;
r(ties) = 2 * round(v(ties) / 2);
end
