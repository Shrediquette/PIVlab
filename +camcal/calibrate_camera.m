function [K, D, rvecs, tvecs, info] = calibrate_camera(imagePoints, worldPoints, imageSize, opts)
%CALIBRATE_CAMERA Camera calibration from planar boards, pure MATLAB (OpenCV camera model).
%   [K, D, rvecs, tvecs, info] = camcal.calibrate_camera(imagePoints, worldPoints, imageSize)
%   [K, D, rvecs, tvecs, info] = camcal.calibrate_camera(imagePoints, worldPoints, imageSize, opts)
%
%   imagePoints  [M x 2 x numImages] detected board points, NaN = not detected
%   worldPoints  [M x 2] board coordinates (z = 0)
%   imageSize    [rows cols]
%   opts         struct, all fields optional:
%     .tilted          false   true: also estimate the sensor tilt tauX, tauY (Scheimpflug)
%     .K_init          []      3x3 start value (OpenCV layout); [] = estimated from the boards
%     .D_init          []      start distortion [k1 k2 p1 p2] or 14 elements (tauX, tauY in 13:14)
%     .fix_tilt        false   keep tauX, tauY at the values in D_init(13:14)
%     .max_iterations  30      Levenberg-Marquardt iterations (OpenCV default: 30)
%
%   K       3x3 intrinsic matrix [fx 0 cx; 0 fy cy; 0 0 1] (OpenCV layout)
%   D       1x14 distortion vector [k1 k2 p1 p2 0 0 0 0 0 0 0 0 tauX tauY]
%   rvecs   [numUsedViews x 3] rotation vectors (camera = R * X + t)
%   tvecs   [numUsedViews x 3] translation vectors
%   info    struct: rms (px), iterations, used_views (logical, per input image)
%
%   Same model, free parameters and start values as the OpenCV call it replaces
%   (calibrateCamera with CALIB_FIX_K3..K6, CALIB_FIX_S1_S2_S3_S4, optional
%   CALIB_TILTED_MODEL / CALIB_FIX_TAUX_TAUY / CALIB_USE_INTRINSIC_GUESS).
%   The Levenberg-Marquardt steps, damping and stop rules follow OpenCV CvLevMarq, so the
%   result matches OpenCV also where the fit is not converged after 30 iterations (tilted
%   model: the error is very flat along tilt <-> principal point).

if nargin < 4
	opts = struct();
end
tilted = get_option(opts, 'tilted', false);
K_init = get_option(opts, 'K_init', []);
D_init = get_option(opts, 'D_init', []);
fix_tilt = get_option(opts, 'fix_tilt', false);
max_iterations = get_option(opts, 'max_iterations', 30);

% ---- views with at least 4 valid points (same rule as the OpenCV MEX files)
numImages = size(imagePoints, 3);
used_views = false(numImages, 1);
views = struct('W', {}, 'm', {});
for v = 1:numImages
	valid = ~isnan(imagePoints(:,1,v)) & ~isnan(imagePoints(:,2,v));
	if sum(valid) >= 4
		used_views(v) = true;
		k = numel(views) + 1;
		views(k).W = [worldPoints(valid,:) zeros(sum(valid), 1)];
		views(k).m = imagePoints(valid,:,v);
	end
end
V = numel(views);
if V < 3
	error('PIVlab:calibration:views', 'Not enough valid images for calibration.');
end

% ---- start values of the intrinsics: [fx fy cx cy k1 k2 p1 p2 tauX tauY]
intr = zeros(1, 10);
if isempty(K_init)
	K0 = init_intrinsics(views, imageSize);
	intr(1:4) = [K0(1,1) K0(2,2) K0(1,3) K0(2,3)];
else
	intr(1:4) = [K_init(1,1) K_init(2,2) K_init(1,3) K_init(2,3)];
	d = zeros(1, 14);
	d(1:min(numel(D_init), 14)) = D_init(1:min(numel(D_init), 14));
	intr(5:8) = d(1:4);
	if tilted
		intr(9:10) = d(13:14);
	end
end

free_intr = true(1, 10);
if ~tilted || fix_tilt
	free_intr(9:10) = false;
end

% ---- start values of the board poses: homography + pose-only refinement
ext = zeros(V, 6);
for v = 1:V
	[rvec, tvec] = init_pose(views(v), intr);
	ext(v,:) = [rvec tvec];
	% as findExtrinsicCameraParams2: 20 iterations, FLT_EPSILON
	[~, ext(v,:)] = levenberg_marquardt(intr, ext(v,:), views(v), false(1, 10), 20, eps('single'));
end

% ---- joint refinement of intrinsics and all poses (calibrateCamera: DBL_EPSILON)
[intr, ext, iterations, sse] = levenberg_marquardt(intr, ext, views, free_intr, max_iterations, eps);

K = [intr(1) 0 intr(3); 0 intr(2) intr(4); 0 0 1];
D = zeros(1, 14);
D(1:4) = intr(5:8);
D(13:14) = intr(9:10);
rvecs = ext(:,1:3);
tvecs = ext(:,4:6);

total_points = 0;
for v = 1:V
	total_points = total_points + size(views(v).m, 1);
end
info.rms = sqrt(sse / total_points);
info.iterations = iterations;
info.used_views = used_views;
end

% =====================================================================
function value = get_option(opts, name, default)
if isfield(opts, name) && ~isempty(opts.(name))
	value = opts.(name);
else
	value = default;
end
end

% =====================================================================
function K = init_intrinsics(views, imageSize)
% Port of OpenCV initIntrinsicParams2D: principal point in the image centre, focal
% lengths from the vanishing points of the board homographies.
cx = (imageSize(2) - 1) * 0.5;
cy = (imageSize(1) - 1) * 0.5;
V = numel(views);
A = zeros(2 * V, 2);
b = zeros(2 * V, 1);
for i = 1:V
	H = homography(views(i).W(:,1:2), views(i).m);
	H(1,:) = H(1,:) - H(3,:) * cx;
	H(2,:) = H(2,:) - H(3,:) * cy;
	h = H(:,1);
	w = H(:,2);
	d1 = (h + w) * 0.5;
	d2 = (h - w) * 0.5;
	h = h / norm(h);
	w = w / norm(w);
	d1 = d1 / norm(d1);
	d2 = d2 / norm(d2);
	A(2*i-1,:) = [h(1) * w(1), h(2) * w(2)];
	A(2*i,:) = [d1(1) * d2(1), d1(2) * d2(2)];
	b(2*i-1) = -h(3) * w(3);
	b(2*i) = -d1(3) * d2(3);
end
f = A \ b;
fx = sqrt(abs(1 / f(1)));
fy = sqrt(abs(1 / f(2)));
K = [fx 0 cx; 0 fy cy; 0 0 1];
end

% =====================================================================
function [rvec, tvec] = init_pose(view, intr)
% Planar case of OpenCV findExtrinsicCameraParams2: homography between the board and the
% undistorted normalized image points, decomposed into rotation and translation.
K = [intr(1) 0 intr(3); 0 intr(2) intr(4); 0 0 1];
D = zeros(1, 14);
D(1:4) = intr(5:8);
D(13:14) = intr(9:10);
xn = camcal.undistort_points(view.m, K, D);
H = homography(view.W(:,1:2), xn);
n1 = norm(H(:,1));
n2 = norm(H(:,2));
r1 = H(:,1) / max(n1, eps);
r2 = H(:,2) / max(n2, eps);
tvec = (H(:,3) * (2 / max(n1 + n2, eps)))';
R = [r1 r2 cross(r1, r2)];
rvec = camcal.matrix_to_rotvec(R);
end

% =====================================================================
function H = homography(src, dst)
% Homography dst ~ H * src as OpenCV findHomography (method 0): points as float32,
% normalized DLT, then 10 Levenberg-Marquardt iterations on the transfer error in dst;
% scaled so that H(3,3) = 1.
src = double(single(src));
dst = double(single(dst));
[src_n, Ts] = normalize_points(src);
[dst_n, Td] = normalize_points(dst);
n = size(src, 1);
A = zeros(2 * n, 9);
for i = 1:n
	X = src_n(i,1);
	Y = src_n(i,2);
	u = dst_n(i,1);
	w = dst_n(i,2);
	A(2*i-1,:) = [X Y 1 0 0 0 -u*X -u*Y -u];
	A(2*i,:) = [0 0 0 X Y 1 -w*X -w*Y -w];
end
[~, ~, Vs] = svd(A, 0);
Hn = reshape(Vs(:,9), 3, 3)';
H = Td \ Hn * Ts;
H = H / H(3,3);

% refinement of h(1:8) with h(9) = 1
h = reshape(H', 9, 1);
h = h(1:8);
lambda = 1e-3;
[e, J] = homography_error(h, src, dst);
for it = 1:10
	JtJ = J' * J;
	A = JtJ;
	A(1:9:end) = diag(JtJ) * (1 + lambda);
	h_new = h - A \ (J' * e);
	[e_new, J_new] = homography_error(h_new, src, dst);
	if sum(e_new .^ 2) <= sum(e .^ 2)
		h = h_new;
		e = e_new;
		J = J_new;
		lambda = lambda / 10;
	else
		lambda = lambda * 10;
	end
end
H = reshape([h; 1], 3, 3)';
end

function [e, J] = homography_error(h, src, dst)
n = size(src, 1);
X = src(:,1);
Y = src(:,2);
w = 1 ./ (h(7) * X + h(8) * Y + 1);
xi = (h(1) * X + h(2) * Y + h(3)) .* w;
yi = (h(4) * X + h(5) * Y + h(6)) .* w;
e = reshape([xi - dst(:,1), yi - dst(:,2)]', [], 1);
J = zeros(2 * n, 8);
J(1:2:end, 1:3) = [X .* w, Y .* w, w];
J(1:2:end, 7:8) = [-X .* w .* xi, -Y .* w .* xi];
J(2:2:end, 4:6) = [X .* w, Y .* w, w];
J(2:2:end, 7:8) = [-X .* w .* yi, -Y .* w .* yi];
end

function [pn, T] = normalize_points(p)
% OpenCV runKernel: per axis, mean absolute deviation scaled to 1
c = mean(p, 1);
s = 1 ./ max(mean(abs(p - c), 1), eps);
T = [s(1) 0 -s(1) * c(1); 0 s(2) -s(2) * c(2); 0 0 1];
pn = [s(1) * (p(:,1) - c(1)), s(2) * (p(:,2) - c(2))];
end

% =====================================================================
function [intr, ext, iterations, sse] = levenberg_marquardt(intr, ext, views, free_intr, max_iterations, epsilon)
% Levenberg-Marquardt over the free intrinsics and all board poses (6 per view), with the
% logic of OpenCV CvLevMarq: lambda = 10^lambdaLg10 (start -3, range -16..16), diagonal of
% JtJ multiplied by (1 + lambda), a step is accepted when the error does not increase
% (then lambdaLg10 - 1), otherwise lambdaLg10 + 1 and a new step from the same point.
% Stop after max_iterations accepted steps or when |param - prev| / |prev| < epsilon.
% Normal equations are built per view (each view only depends on its own pose and the
% shared intrinsics).
lambda_lg10 = -3;
[JtJ, Jtr, sse] = normal_equations(intr, ext, views, free_intr);
iterations = 0;
idx_intr = find(free_intr);
nf = numel(idx_intr);
V = numel(views);
for it = 1:max_iterations
	iterations = it;
	accepted = false;
	while ~accepted
		A = JtJ;
		A(1:size(A,1)+1:end) = diag(JtJ) * (1 + 10 ^ lambda_lg10);
		dx = -svd_solve(A, Jtr);
		intr_new = intr;
		intr_new(idx_intr) = intr(idx_intr) + dx(1:nf)';
		ext_new = ext + reshape(dx(nf+1:end), 6, V)';
		sse_new = total_error(intr_new, ext_new, views);
		if sse_new <= sse
			accepted = true;
		else
			lambda_lg10 = lambda_lg10 + 1;
			if lambda_lg10 > 16
				% no step reduces the error (OpenCV would keep the worse step here)
				return
			end
		end
	end
	lambda_lg10 = max(lambda_lg10 - 1, -16);
	step = norm(dx) / max(norm([intr ext(:)']), realmin);
	intr = intr_new;
	ext = ext_new;
	sse = sse_new;
	if step < epsilon || it == max_iterations
		return
	end
	[JtJ, Jtr, sse] = normal_equations(intr, ext, views, free_intr);
end
end

function x = svd_solve(A, b)
% Solution of A x = b as OpenCV solve(..., DECOMP_SVD): singular values below
% 2 * DBL_EPSILON * sum(singular values) are dropped. JtJ mixes pixels, millimetres and
% radians; dropping its tiny singular values damps the steps along the flat directions of
% the tilted model, exactly as in OpenCV.
[U, S, V] = svd(A);
w = diag(S);
keep = w > 2 * eps * sum(w);
x = V(:, keep) * ((U(:, keep)' * b) ./ w(keep));
end

function [JtJ, Jtr, sse] = normal_equations(intr, ext, views, free_intr)
idx_intr = find(free_intr);
nf = numel(idx_intr);
V = numel(views);
n = nf + 6 * V;
JtJ = zeros(n, n);
Jtr = zeros(n, 1);
sse = 0;
for v = 1:V
	[Ji, Je, r] = view_jacobian(intr, ext(v,:), views(v), idx_intr);
	sse = sse + sum(r .^ 2);
	e = nf + 6 * (v - 1) + (1:6);
	if nf > 0
		JtJ(1:nf, 1:nf) = JtJ(1:nf, 1:nf) + Ji' * Ji;
		JtJ(1:nf, e) = Ji' * Je;
		JtJ(e, 1:nf) = Je' * Ji;
		Jtr(1:nf) = Jtr(1:nf) + Ji' * r;
	end
	JtJ(e, e) = Je' * Je;
	Jtr(e) = Je' * r;
end
end

function sse = total_error(intr, ext, views)
sse = 0;
for v = 1:numel(views)
	r = view_residual(intr, ext(v,:), views(v));
	sse = sse + sum(r .^ 2);
end
end

function r = view_residual(intr, ext_v, view)
% residuals [du1 dv1 du2 dv2 ...]' (projection minus detection)
p = project_view(intr, ext_v, view.W);
e = p - view.m;
r = reshape(e', [], 1);
end

function p = project_view(intr, ext_v, W)
K = [intr(1) 0 intr(3); 0 intr(2) intr(4); 0 0 1];
D = zeros(1, 14);
D(1:4) = intr(5:8);
D(13:14) = intr(9:10);
p = camcal.project_points(W, ext_v(1:3), ext_v(4:6), K, D);
end

function [Ji, Je, r] = view_jacobian(intr, ext_v, view, idx_intr)
% Analytic Jacobian of the residuals of one view (as OpenCV projectPoints):
% Ji for the free intrinsics [fx fy cx cy k1 k2 p1 p2 tauX tauY](idx_intr), Je for
% [rvec tvec]. r: residuals. Rows interleaved [u1 v1 u2 v2 ...].
fx = intr(1); fy = intr(2); cx = intr(3); cy = intr(4);
k1 = intr(5); k2 = intr(6); p1 = intr(7); p2 = intr(8);
[R, dRdr] = rodrigues_jacobian(ext_v(1:3));
W = view.W;
n = size(W, 1);
Xc = W * R' + ext_v(4:6);
iz = 1 ./ Xc(:,3);
x = Xc(:,1) .* iz;
y = Xc(:,2) .* iz;

r2 = x .^ 2 + y .^ 2;
kr = 1 + (k2 * r2 + k1) .* r2;
xd = x .* kr + 2 * p1 * x .* y + p2 * (r2 + 2 * x .^ 2);
yd = y .* kr + p1 * (r2 + 2 * y .^ 2) + 2 * p2 * x .* y;

[T, ~, dTx, dTy] = camcal.tilt_matrix(intr(9), intr(10));
a = T(1,1) * xd + T(1,2) * yd + T(1,3);
b = T(2,1) * xd + T(2,2) * yd + T(2,3);
w = T(3,1) * xd + T(3,2) * yd + T(3,3);
iw = 1 ./ w;
xt = a .* iw;
yt = b .* iw;
r = reshape([fx * xt + cx - view.m(:,1), fy * yt + cy - view.m(:,2)]', [], 1);

% d(xt, yt) / d(xd, yd)
dxt_dxd = (T(1,1) - xt * T(3,1)) .* iw;
dxt_dyd = (T(1,2) - xt * T(3,2)) .* iw;
dyt_dxd = (T(2,1) - yt * T(3,1)) .* iw;
dyt_dyd = (T(2,2) - yt * T(3,2)) .* iw;

% d(xd, yd) / d(x, y)
dkr = 2 * (k1 + 2 * k2 * r2);
dxd_dx = kr + x .* dkr .* x + 2 * p1 * y + 6 * p2 * x;
dxd_dy = x .* dkr .* y + 2 * p1 * x + 2 * p2 * y;
dyd_dx = y .* dkr .* x + 2 * p1 * x + 2 * p2 * y;
dyd_dy = kr + y .* dkr .* y + 6 * p1 * y + 2 * p2 * x;

% d(u, v) / d(x, y)
du_dx = fx * (dxt_dxd .* dxd_dx + dxt_dyd .* dyd_dx);
du_dy = fx * (dxt_dxd .* dxd_dy + dxt_dyd .* dyd_dy);
dv_dx = fy * (dyt_dxd .* dxd_dx + dyt_dyd .* dyd_dx);
dv_dy = fy * (dyt_dxd .* dxd_dy + dyt_dyd .* dyd_dy);

% all intrinsics, then the free ones
Jall_u = zeros(n, 10);
Jall_v = zeros(n, 10);
Jall_u(:,1) = xt;
Jall_v(:,2) = yt;
Jall_u(:,3) = 1;
Jall_v(:,4) = 1;
% distortion: d(xd, yd)/dk
dxd = [x .* r2, x .* r2 .^ 2, 2 * x .* y, r2 + 2 * x .^ 2];
dyd = [y .* r2, y .* r2 .^ 2, r2 + 2 * y .^ 2, 2 * x .* y];
for k = 1:4
	Jall_u(:,4+k) = fx * (dxt_dxd .* dxd(:,k) + dxt_dyd .* dyd(:,k));
	Jall_v(:,4+k) = fy * (dyt_dxd .* dxd(:,k) + dyt_dyd .* dyd(:,k));
end
% tilt: d/dtau of (T1 v / T3 v)
da = dTx(1,1) * xd + dTx(1,2) * yd + dTx(1,3);
db = dTx(2,1) * xd + dTx(2,2) * yd + dTx(2,3);
dw = dTx(3,1) * xd + dTx(3,2) * yd + dTx(3,3);
Jall_u(:,9) = fx * (da - xt .* dw) .* iw;
Jall_v(:,9) = fy * (db - yt .* dw) .* iw;
da = dTy(1,1) * xd + dTy(1,2) * yd + dTy(1,3);
db = dTy(2,1) * xd + dTy(2,2) * yd + dTy(2,3);
dw = dTy(3,1) * xd + dTy(3,2) * yd + dTy(3,3);
Jall_u(:,10) = fx * (da - xt .* dw) .* iw;
Jall_v(:,10) = fy * (db - yt .* dw) .* iw;

Ji = zeros(2 * n, numel(idx_intr));
Ji(1:2:end,:) = Jall_u(:, idx_intr);
Ji(2:2:end,:) = Jall_v(:, idx_intr);

% pose: d(x, y)/dXc, dXc/dr = dR/dr * W, dXc/dt = I
dx_dXc = [iz, zeros(n, 1), -x .* iz];
dy_dXc = [zeros(n, 1), iz, -y .* iz];
Je = zeros(2 * n, 6);
for k = 1:3
	dXc = W * dRdr(:,:,k)';
	dx = sum(dx_dXc .* dXc, 2);
	dy = sum(dy_dXc .* dXc, 2);
	Je(1:2:end, k) = du_dx .* dx + du_dy .* dy;
	Je(2:2:end, k) = dv_dx .* dx + dv_dy .* dy;
end
for k = 1:3
	dx = dx_dXc(:,k);
	dy = dy_dXc(:,k);
	Je(1:2:end, 3+k) = du_dx .* dx + du_dy .* dy;
	Je(2:2:end, 3+k) = dv_dx .* dx + dv_dy .* dy;
end
end

function [R, dRdr] = rodrigues_jacobian(rvec)
% rotation matrix and its derivatives dR/dr_k (3x3x3), port of OpenCV Rodrigues
r = rvec(:);
theta = norm(r);
dRdr = zeros(3, 3, 3);
if theta < eps
	R = eye(3);
	dRdr(:,:,1) = [0 0 0; 0 0 -1; 0 1 0];
	dRdr(:,:,2) = [0 0 1; 0 0 0; -1 0 0];
	dRdr(:,:,3) = [0 -1 0; 1 0 0; 0 0 0];
	return
end
c = cos(theta);
s = sin(theta);
c1 = 1 - c;
itheta = 1 / theta;
r = r * itheta;
rrt = r * r';
r_x = [0 -r(3) r(2); r(3) 0 -r(1); -r(2) r(1) 0];
R = c * eye(3) + c1 * rrt + s * r_x;
% OpenCV: drrt and d_r_x_ for each component, rows of the 3x9 Jacobian (row-major R)
drrt = [r(1)+r(1) r(2) r(3) r(2) 0 0 r(3) 0 0;
	0 r(1) 0 r(1) r(2)+r(2) r(3) 0 r(3) 0;
	0 0 r(1) 0 0 r(2) r(1) r(2) r(3)+r(3)];
d_r_x = [0 0 0 0 0 -1 0 1 0;
	0 0 1 0 0 0 -1 0 0;
	0 -1 0 1 0 0 0 0 0];
I9 = [1 0 0 0 1 0 0 0 1];
rrt9 = reshape(rrt', 1, 9);
rx9 = reshape(r_x', 1, 9);
for i = 1:3
	ri = r(i);
	a0 = -s * ri;
	a1 = (s - 2 * c1 * itheta) * ri;
	a2 = c1 * itheta;
	a3 = (c - s * itheta) * ri;
	a4 = s * itheta;
	J = a0 * I9 + a1 * rrt9 + a2 * drrt(i,:) + a3 * rx9 + a4 * d_r_x(i,:);
	dRdr(:,:,i) = reshape(J, 3, 3)';
end
end
