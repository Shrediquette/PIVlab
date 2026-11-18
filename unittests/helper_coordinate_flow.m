function F = helper_coordinate_flow(folder)
%HELPER_COORDINATE_FLOW Linear test flow with known vorticity, divergence and strain, for the tests of
%   the coordinate system (x, y, z right-handed, z = x cross y).
%   F = helper_coordinate_flow()          parameters only
%   F = helper_coordinate_flow(folder)    also writes one particle image pair of the flow into folder
%                                         (F.files: {A; B})
%
%   Seen on the screen (X to the right, Y up, both from the image centre, in px), the displacement
%   per image pair is
%       U = -omega*Y + (a+s)*X        (to the right)
%       V =  omega*X + (a-s)*Y        (upward)
%   omega > 0: counter-clockwise rotation on the screen. With the default axes (x right, y up) this gives
%   vorticity 2*omega, divergence 2*a, simple strain rate du/dx - dv/dy = 2*s and
%   Q = omega^2 - a^2 - s^2 (per frame, per frame^2).
%   F.size [height width], F.xc, F.yc: centre in pixel coordinates (y down).
%   The pixel displacements of PIVlab (v positive downward) come from helper_coordinate_flow_field.
F.size = [512 512];
F.xc = (F.size(2) + 1) / 2;
F.yc = (F.size(1) + 1) / 2;
F.omega = 0.012;
F.a = 0.004;
F.s = 0.003;
F.files = {};
if nargin < 1
    return
end
[x, y] = meshgrid(1:4:F.size(2) + 4, 1:4:F.size(1) + 4);
[u, v] = helper_coordinate_flow_field(F, x, y);
[A, B] = simulate.gui_images(x, y, u, v, ImageSize=F.size, Particles=60000, Diameter=3, ...
    DiameterVariation=0.5, Seed=7);
F.files = {fullfile(folder, 'coordinate_flow_A.png'); fullfile(folder, 'coordinate_flow_B.png')};
imwrite(A, F.files{1});
imwrite(B, F.files{2});
end
