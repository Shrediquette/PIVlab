function pd = distort_points(pu, cam)
%DISTORT_POINTS Lens distortion of undistorted image points (inverse of the lens undistortion).
%   pd = stereo.distort_points(pu, cam)
%   pu   [n x 2] pixel coordinates in the undistorted image (MATLAB convention: pixel centres
%        at integers), as made by preproc.cam_undistort_with with view 'same'
%   cam  camera settings (import.cam_settings). Without lens calibration pd = pu.
%   pd   [n x 2] position of these points in the raw camera image
%   Two lens models, like PIVlab's camera calibration:
%   - MATLAB model (cam.cameraParams): radial k1..k3 and tangential p1, p2, skew
%   - OpenCV model with tilted sensor (Scheimpflug, cam.use_tilted_model): cam.K_opencv and the
%     distortion vector cam.tilted_D (k1 k2 p1 p2 k3 k4 k5 k6 s1 s2 s3 s4 tauX tauY), exactly as
%     opencv_undistort (initUndistortRectifyMap) uses them
if ~cam.use_calibration
    pd = pu;
    return
end
if cam.use_tilted_model && ~isempty(cam.tilted_D) && ~isempty(cam.K_opencv)
    pd = distort_opencv(pu, cam.K_opencv, cam.tilted_D);
else
    params = cam.cameraParams;
    if isa(params, 'cameraParameters')
        intrinsics = params.Intrinsics;
    else
        intrinsics = params;
    end
    pd = distort_matlab(pu, intrinsics);
end
end

function pd = distort_matlab(pu, intrinsics)
% MATLAB's camera model: radial (k1, k2, k3) and tangential (p1, p2) distortion, K = [fx s cx; 0 fy cy; 0 0 1]
K = intrinsics.K;
fx = K(1, 1); s = K(1, 2); cx = K(1, 3);
fy = K(2, 2); cy = K(2, 3);
k = intrinsics.RadialDistortion;
if numel(k) < 3
    k(3) = 0;
end
p = intrinsics.TangentialDistortion;
y = (pu(:, 2) - cy) / fy;
x = (pu(:, 1) - cx - s * y) / fx;
r2 = x .^ 2 + y .^ 2;
radial = 1 + k(1) * r2 + k(2) * r2 .^ 2 + k(3) * r2 .^ 3;
xd = x .* radial + 2 * p(1) * x .* y + p(2) * (r2 + 2 * x .^ 2);
yd = y .* radial + p(1) * (r2 + 2 * y .^ 2) + 2 * p(2) * x .* y;
pd = [fx * xd + s * yd + cx, fy * yd + cy];
end

function pd = distort_opencv(pu, K, D)
% OpenCV's rational + thin prism + tilted sensor model. opencv_undistort works on 0-based pixel
% indices: MATLAB coordinate = index + 1 in the undistorted and in the raw image.
d = zeros(1, 14);
d(1:numel(D)) = D(:)';
k1 = d(1); k2 = d(2); p1 = d(3); p2 = d(4); k3 = d(5); k4 = d(6); k5 = d(7); k6 = d(8);
s1 = d(9); s2 = d(10); s3 = d(11); s4 = d(12);
fx = K(1, 1); fy = K(2, 2); cx = K(1, 3); cy = K(2, 3);
x = (pu(:, 1) - 1 - cx) / fx;
y = (pu(:, 2) - 1 - cy) / fy;
r2 = x .^ 2 + y .^ 2;
kr = (1 + ((k3 * r2 + k2) .* r2 + k1) .* r2) ./ (1 + ((k6 * r2 + k5) .* r2 + k4) .* r2);
xd = x .* kr + 2 * p1 * x .* y + p2 * (r2 + 2 * x .^ 2) + s1 * r2 + s2 * r2 .^ 2;
yd = y .* kr + p1 * (r2 + 2 * y .^ 2) + 2 * p2 * x .* y + s3 * r2 + s4 * r2 .^ 2;
T = tilt_matrix(d(13), d(14));
xt = T(1, 1) * xd + T(1, 2) * yd + T(1, 3);
yt = T(2, 1) * xd + T(2, 2) * yd + T(2, 3);
zt = T(3, 1) * xd + T(3, 2) * yd + T(3, 3);
zt(zt == 0) = 1;
pd = [fx * xt ./ zt + cx + 1, fy * yt ./ zt + cy + 1];
end

function T = tilt_matrix(tau_x, tau_y)
% OpenCV computeTiltProjectionMatrix
cx = cos(tau_x); sx = sin(tau_x);
cy = cos(tau_y); sy = sin(tau_y);
rot_x = [1 0 0; 0 cx sx; 0 -sx cx];
rot_y = [cy 0 -sy; 0 1 0; sy 0 cy];
rot_xy = rot_y * rot_x;
proj_z = [rot_xy(3, 3) 0 -rot_xy(1, 3); 0 rot_xy(3, 3) -rot_xy(2, 3); 0 0 1];
T = proj_z * rot_xy;
end
