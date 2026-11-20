function [T, T_inv, dT_dtauX, dT_dtauY] = tilt_matrix(tauX, tauY)
%TILT_MATRIX Projection matrix of a tilted image sensor (Scheimpflug), as in OpenCV.
%   [T, T_inv, dT_dtauX, dT_dtauY] = camcal.tilt_matrix(tauX, tauY)
%   tauX, tauY  sensor tilt about the x and y axis in radians
%   T           3x3 matrix applied to distorted normalized coordinates [x; y; 1]
%   T_inv       inverse of T
%   dT_dtauX, dT_dtauY   derivatives of T
%
%   Port of computeTiltProjectionMatrix (OpenCV calib3d, distortion_model.hpp).

ctx = cos(tauX);
stx = sin(tauX);
cty = cos(tauY);
sty = sin(tauY);
rot_x = [1 0 0; 0 ctx stx; 0 -stx ctx];
rot_y = [cty 0 -sty; 0 1 0; sty 0 cty];
rot_xy = rot_y * rot_x;
proj_z = [rot_xy(3,3) 0 -rot_xy(1,3); 0 rot_xy(3,3) -rot_xy(2,3); 0 0 1];
T = proj_z * rot_xy;

if nargout > 1
	inv_z = 1 / rot_xy(3,3);
	inv_proj_z = [inv_z 0 inv_z * rot_xy(1,3); 0 inv_z inv_z * rot_xy(2,3); 0 0 1];
	T_inv = rot_xy' * inv_proj_z;
end
if nargout > 2
	d_rot_xy = rot_y * [0 0 0; 0 -stx ctx; 0 -ctx -stx];
	d_proj_z = [d_rot_xy(3,3) 0 -d_rot_xy(1,3); 0 d_rot_xy(3,3) -d_rot_xy(2,3); 0 0 0];
	dT_dtauX = proj_z * d_rot_xy + d_proj_z * rot_xy;
	d_rot_xy = [-sty 0 -cty; 0 0 0; cty 0 -sty] * rot_x;
	d_proj_z = [d_rot_xy(3,3) 0 -d_rot_xy(1,3); 0 d_rot_xy(3,3) -d_rot_xy(2,3); 0 0 0];
	dT_dtauY = proj_z * d_rot_xy + d_proj_z * rot_xy;
end
end
