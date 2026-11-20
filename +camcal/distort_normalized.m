function [xd, yd] = distort_normalized(x, y, D)
%DISTORT_NORMALIZED Apply the OpenCV lens distortion and sensor tilt to normalized coordinates.
%   [xd, yd] = camcal.distort_normalized(x, y, D)
%   x, y    ideal normalized coordinates (X/Z, Y/Z), any size
%   D       distortion vector, up to 14 elements in OpenCV order
%           [k1 k2 p1 p2 k3 k4 k5 k6 s1 s2 s3 s4 tauX tauY]
%   xd, yd  distorted normalized coordinates (pixel = f * xd + c)
%
%   Same formula as OpenCV projectPoints / initUndistortRectifyMap.

d = zeros(1, 14);
d(1:numel(D)) = D(:)';

r2 = x .^ 2 + y .^ 2;
kr = (1 + ((d(5) * r2 + d(2)) .* r2 + d(1)) .* r2) ./ (1 + ((d(8) * r2 + d(7)) .* r2 + d(6)) .* r2);
xd = x .* kr + 2 * d(3) * x .* y + d(4) * (r2 + 2 * x .^ 2) + d(9) * r2 + d(10) * r2 .^ 2;
yd = y .* kr + d(3) * (r2 + 2 * y .^ 2) + 2 * d(4) * x .* y + d(11) * r2 + d(12) * r2 .^ 2;

if d(13) ~= 0 || d(14) ~= 0
	T = camcal.tilt_matrix(d(13), d(14));
	w = T(3,1) * xd + T(3,2) * yd + T(3,3);
	xt = (T(1,1) * xd + T(1,2) * yd + T(1,3)) ./ w;
	yt = (T(2,1) * xd + T(2,2) * yd + T(2,3)) ./ w;
	xd = xt;
	yd = yt;
end
end
