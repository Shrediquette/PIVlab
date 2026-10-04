function [u, v, w] = flow_field(type, x, y, p)
% Analytic 2D flow fields of the synthetic image generator, evaluated at
% arbitrary points x, y (pixel coordinates, pixel centres at 1..n).
% Returns the displacement u, v (and w = 0) of a particle at (x, y).
%
% type: 'rankine', 'oseen', 'shift', 'rotation' or 'membrane'
% p:    struct with the parameters of the selected type:
%   rankine:  v0 (max displacement), R0 (core radius), c1 = [x y], c2 = [x y], double (true/false)
%   oseen:    v0, t (time), c1, c2, double
%   shift:    shift (v displacement)
%   rotation: rotation (max displacement), imageSize = [height width]
%   membrane: imageSize = [height width]
% A double vortex is counter-rotating (second vortex is subtracted).

switch lower(type)
    case {'rankine', 'oseen'}
        if strcmpi(type, 'rankine')
            vortex = @(dx, dy) rankine(dx, dy, p.v0, p.R0);
        else
            vortex = @(dx, dy) oseen(dx, dy, p.v0 * 3, p.t);
        end
        [u, v] = vortex(x - p.c1(1), y - p.c1(2));
        if p.double
            [u2, v2] = vortex(x - p.c2(1), y - p.c2(2));
            u = u - u2;
            v = v - v2;
        end
    case 'shift'
        u = zeros(size(x));
        v = zeros(size(x)) + p.shift;
    case 'rotation'
        % solid body rotation around the image centre, max displacement at the
        % edge of the longer image side (same scale in x and y)
        r_max = max(p.imageSize) / 2;
        u = (y - (p.imageSize(1) + 1) / 2) / r_max * p.rotation;
        v = -(x - (p.imageSize(2) + 1) / 2) / r_max * p.rotation;
    case 'membrane'
        xs = -3 + 6 * (x - 1) / (p.imageSize(2) - 1);
        ys = -3 + 6 * (y - 1) / (p.imageSize(1) - 1);
        u = peaks(xs, ys) / 3;
        v = peaks(ys, xs) / 3;
    otherwise
        error('simulate:flow_field:unknownType', 'Unknown flow type "%s".', type)
end
w = zeros(size(x));
end

function [u, v] = rankine(dx, dy, v0, R0)
r = hypot(dx, dy);
uo = v0 * R0 ./ r;              % potential vortex outside the core
inside = r <= R0;
uo(inside) = v0 * r(inside) / R0; % solid body rotation inside the core
[u, v] = tangential(uo, dx, dy, r);
end

function [u, v] = oseen(dx, dy, v0, t)
r = hypot(dx, dy) / 100;
uo = v0 ./ (2 * pi * r) .* (1 - exp(-r.^2 / (4 * t))); % viscosity = 1
[u, v] = tangential(uo, dx, dy, r);
end

function [u, v] = tangential(uo, dx, dy, r)
% velocity magnitude uo perpendicular to the radius
o = atan2(dy, dx);
u = -uo .* sin(o);
v = uo .* cos(o);
u(r == 0) = 0;
v(r == 0) = 0;
end
