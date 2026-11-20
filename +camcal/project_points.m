function p = project_points(X, rvec, tvec, K, D)
%PROJECT_POINTS Project 3D points into the image with the OpenCV camera model.
%   p = camcal.project_points(X, rvec, tvec, K, D)
%   X     [n x 3] points in board / world coordinates
%   rvec  rotation vector (Rodrigues), camera = R * X + t
%   tvec  translation vector
%   K     3x3 intrinsic matrix in OpenCV layout [fx 0 cx; 0 fy cy; 0 0 1]
%   D     distortion vector, up to 14 elements in OpenCV order
%         [k1 k2 p1 p2 k3 k4 k5 k6 s1 s2 s3 s4 tauX tauY]
%   p     [n x 2] image points (same pixel convention as the calibration input)
%
%   Same formula as OpenCV projectPoints, including the tilted sensor
%   (Scheimpflug) model of CALIB_TILTED_MODEL.

R = camcal.rotvec_to_matrix(rvec);
Xc = R * X' + tvec(:);
x = (Xc(1,:) ./ Xc(3,:))';
y = (Xc(2,:) ./ Xc(3,:))';
[xd, yd] = camcal.distort_normalized(x, y, D);
p = [K(1,1) * xd + K(1,3), K(2,2) * yd + K(2,3)];
end
