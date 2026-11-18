function F = helper_truth_flow(name, image_size)
%HELPER_TRUTH_FLOW Analytic test flows for the truth-based tests (test_truth_*).
%   F = helper_truth_flow(name)
%   F = helper_truth_flow(name, image_size)     image_size [height width] in px (default [320 320])
%
%   name  'linear'     uniform flow + rotation + expansion + strain (all gradients constant)
%         'quadratic'  velocities are quadratic in x and y (gradients change in space)
%         'oseen'      Oseen vortex (known vorticity and circulation)
%         'uniform'    uniform flow (for extraction and filter tests)
%
%   The flow is defined in screen coordinates: X to the right, Y upward on the screen, both in
%   pixels from the centre (F.xc, F.yc) of the image. Velocities are in px per frame.
%   Every flow also has an out-of-plane component W (px per frame, positive away from the camera),
%   W = F.w0 + F.wx*X + F.wy*Y, used for the stereo quantities.
%   helper_truth_field gives the velocities and their gradients at any pixel position.
if nargin < 2
    image_size = [320 320];
end
F.name = name;
F.size = image_size;
F.xc = image_size(2) / 2 + 0.5;      % between two vectors of the usual grids: no vector at r = 0
F.yc = image_size(1) / 2 + 0.5;
F.u0 = 0;
F.v0 = 0;
F.omega = 0;     % linear: rotation
F.a = 0;         % linear: expansion
F.s = 0;         % linear: strain
F.b = [0 0 0];   % quadratic: U = u0 + b1*X^2 + b2*Y^2 + b3*X*Y
F.c = [0 0 0];   % quadratic: V = v0 + c1*X^2 + c2*Y^2 + c3*X*Y
F.gamma = 0;     % oseen: circulation in px^2 per frame
F.rc = 1;        % oseen: core radius in px
F.w0 = 0.6;
F.wx = 0.002;
F.wy = -0.001;
switch name
    case 'linear'
        F.u0 = 0.8;
        F.v0 = -0.5;
        F.omega = 0.004;
        F.a = 0.002;
        F.s = 0.003;
    case 'quadratic'
        F.u0 = 0.3;
        F.v0 = 0.6;
        F.b = [1.2e-5 -0.8e-5 0.6e-5];
        F.c = [-0.7e-5 1.1e-5 -0.9e-5];
    case 'oseen'
        F.gamma = 600;
        F.rc = 64;
    case 'uniform'
        F.u0 = 1.3;
        F.v0 = 0.7;
    otherwise
        error('helper_truth_flow: unknown flow "%s"', name);
end
end
