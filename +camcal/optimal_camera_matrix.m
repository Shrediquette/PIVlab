function newK = optimal_camera_matrix(K, D, imageSize, alpha)
%OPTIMAL_CAMERA_MATRIX Camera matrix of the undistorted image, port of OpenCV getOptimalNewCameraMatrix.
%   newK = camcal.optimal_camera_matrix(K, D, imageSize, alpha)
%   K          3x3 intrinsic matrix (OpenCV layout), D distortion vector (up to 14 elements)
%   imageSize  [rows cols]; the new image has the same size
%   alpha      0: only valid pixels (inscribed rectangle, OutputView "valid")
%              1: all source pixels (circumscribed rectangle, OutputView "full")
%
%   centerPrincipalPoint = false (as PIVlab used it with OpenCV).

[inner, outer] = undistort_rectangles(K, D, imageSize);
w = imageSize(2);
h = imageSize(1);

fx0 = (w - 1) / inner(3);
fy0 = (h - 1) / inner(4);
cx0 = -fx0 * inner(1);
cy0 = -fy0 * inner(2);

fx1 = (w - 1) / outer(3);
fy1 = (h - 1) / outer(4);
cx1 = -fx1 * outer(1);
cy1 = -fy1 * outer(2);

newK = [fx0 * (1 - alpha) + fx1 * alpha, 0, cx0 * (1 - alpha) + cx1 * alpha;
	0, fy0 * (1 - alpha) + fy1 * alpha, cy0 * (1 - alpha) + cy1 * alpha;
	0, 0, 1];
end

function [inner, outer] = undistort_rectangles(K, D, imageSize)
% port of OpenCV getUndistortRectangles (no R, no new camera matrix: normalized coordinates).
% inner / outer = [x y width height]; outer from all N x N points, inner from the border points
N = 9;
step_x = (imageSize(2) - 1) / (N - 1);
step_y = (imageSize(1) - 1) / (N - 1);
pts = zeros(N * N, 2);
gx = zeros(N * N, 1);
gy = zeros(N * N, 1);
k = 0;
for y = 0:N-1
	for x = 0:N-1
		k = k + 1;
		pts(k,:) = [x * step_x, y * step_y];
		gx(k) = x;
		gy(k) = y;
	end
end
xn = camcal.undistort_points(pts, K, D, 5);

big = double(realmax('single'));   % FLT_MAX, as double (single would make min/max single)
iX0 = -big; iX1 = big;
iY0 = -big; iY1 = big;
oX0 = big; oX1 = -big;
oY0 = big; oY1 = -big;
for k = 1:size(xn, 1)
	px = xn(k,1);
	py = xn(k,2);
	oX0 = min(oX0, px);
	oX1 = max(oX1, px);
	oY0 = min(oY0, py);
	oY1 = max(oY1, py);
	if gx(k) == 0
		iX0 = max(iX0, px);
	end
	if gx(k) == N - 1
		iX1 = min(iX1, px);
	end
	if gy(k) == 0
		iY0 = max(iY0, py);
	end
	if gy(k) == N - 1
		iY1 = min(iY1, py);
	end
end
inner = [iX0, iY0, iX1 - iX0, iY1 - iY0];
outer = [oX0, oY0, oX1 - oX0, oY1 - oY0];
end
