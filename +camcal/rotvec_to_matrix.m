function R = rotvec_to_matrix(rvec)
%ROTVEC_TO_MATRIX Rotation matrix from a rotation vector (Rodrigues, OpenCV convention).
%   R = camcal.rotvec_to_matrix(rvec)

r = rvec(:);
theta = norm(r);
if theta < 1e-12
	% first order: R = I + [r]x
	R = [1 -r(3) r(2); r(3) 1 -r(1); -r(2) r(1) 1];
	return
end
k = r / theta;
Kx = [0 -k(3) k(2); k(3) 0 -k(1); -k(2) k(1) 0];
R = eye(3) + sin(theta) * Kx + (1 - cos(theta)) * (Kx * Kx);
end
