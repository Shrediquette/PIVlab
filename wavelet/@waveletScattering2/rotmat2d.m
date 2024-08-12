function [R,Rinv] = rotmat2d(theta)
%   This function is for internal use only. It may change or be removed
%   in a future release. 
%   Return the rotation matrix for a
%   given input theta in radians. This is rotation by a positive angle,
%   $r_{\theta}$

%   Copyright 2018-2020 The MathWorks, Inc.

validateattributes(theta,{'numeric'},{'finite','nonempty','scalar'},...
    'rotmat2d','theta');
R = [cos(theta) -sin(theta) ; sin(theta) cos(theta)];
% Orthogonal matrix with real-valued elements (adjoint is inverse)
Rinv = R';
