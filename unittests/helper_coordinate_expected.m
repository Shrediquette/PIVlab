function E = helper_coordinate_expected(F, x_axis_direction, y_axis_direction, dt)
%HELPER_COORDINATE_EXPECTED Expected derived quantities of the test flow (helper_coordinate_flow) in the
%   coordinate system of the user, derived from the axis directions only.
%   x_axis_direction 1 = right, 2 = left; y_axis_direction 1 = down, 2 = up (as in the GUI).
%   dt: time step in s (calibrated) or 1 (per frame).
%   E.sx, E.sy  +1 if x points right / y points up on the screen, else -1
%   E.z         direction of z = x cross y: +1 toward the viewer (camera), -1 away from it
%   E.vorticity, E.divergence, E.strain, E.q, and E.name (text for messages)
E.sx = 1;
if x_axis_direction == 2
    E.sx = -1;
end
E.sy = -1;
if y_axis_direction == 2
    E.sy = 1;
end
% unit vectors of x and y in screen coordinates (right, up, toward the viewer); z = x cross y
ex = [E.sx 0 0];
ey = [0 E.sy 0];
ez = cross(ex, ey);
E.z = ez(3);
E.vorticity = 2 * F.omega * E.z / dt;   % rotation around z: counter-clockwise on screen is + if z points to the viewer
E.divergence = 2 * F.a / dt;
E.strain = 2 * F.s / dt;
E.q = (F.omega^2 - F.a^2 - F.s^2) / dt^2;
xnames = {'right', 'left'};
ynames = {'down', 'up'};
E.name = sprintf('x %s, y %s', xnames{x_axis_direction}, ynames{y_axis_direction});
end
