function xn = undistort_points(p, K, D, iterations)
%UNDISTORT_POINTS Ideal normalized coordinates of distorted image points (OpenCV model).
%   xn = camcal.undistort_points(p, K, D)
%   xn = camcal.undistort_points(p, K, D, iterations)
%   p   [n x 2] image points
%   K   3x3 intrinsic matrix (OpenCV layout), D distortion vector (up to 14 elements)
%   xn  [n x 2] normalized coordinates x = X/Z, y = Y/Z without distortion
%
%   Port of OpenCV undistortPoints: removes the sensor tilt exactly and the lens
%   distortion by fixed-point iteration. Default: 5 iterations, as OpenCV.

if nargin < 4
	iterations = 5;
end
d = zeros(1, 14);
d(1:numel(D)) = D(:)';

x_raw = (p(:,1) - K(1,3)) / K(1,1);
y_raw = (p(:,2) - K(2,3)) / K(2,2);
x = x_raw;
y = y_raw;
if d(13) ~= 0 || d(14) ~= 0
	[~, T_inv] = camcal.tilt_matrix(d(13), d(14));
	w = T_inv(3,1) * x + T_inv(3,2) * y + T_inv(3,3);
	xt = (T_inv(1,1) * x + T_inv(1,2) * y + T_inv(1,3)) ./ w;
	yt = (T_inv(2,1) * x + T_inv(2,2) * y + T_inv(2,3)) ./ w;
	x = xt;
	y = yt;
end

x0 = x;
y0 = y;
active = true(size(x));
for it = 1:iterations
	r2 = x .^ 2 + y .^ 2;
	icdist = (1 + ((d(8) * r2 + d(7)) .* r2 + d(6)) .* r2) ./ (1 + ((d(5) * r2 + d(2)) .* r2 + d(1)) .* r2);
	% OpenCV: a negative icdist stops the iteration and returns the raw normalized point
	bad = active & icdist < 0;
	x(bad) = x_raw(bad);
	y(bad) = y_raw(bad);
	active = active & ~bad;
	delta_x = 2 * d(3) * x .* y + d(4) * (r2 + 2 * x .^ 2) + d(9) * r2 + d(10) * r2 .^ 2;
	delta_y = d(3) * (r2 + 2 * y .^ 2) + 2 * d(4) * x .* y + d(11) * r2 + d(12) * r2 .^ 2;
	x_new = (x0 - delta_x) .* icdist;
	y_new = (y0 - delta_y) .* icdist;
	x(active) = x_new(active);
	y(active) = y_new(active);
end
xn = [x y];
end
