function [u, v, w] = flow_field(flow, x, y)
% Flow fields of the synthetic image generator, evaluated at arbitrary
% points x, y. Returns the displacement u, v, w of a particle at (x, y).
% Units: pixels for the 2D GUI flows, world units (e.g. mm) for stereo.
%
% flow: struct with the field "type" and the parameters of that type:
%   'rankine':    v0 (max displacement), R0 (core radius), c1 = [x y], c2 = [x y], double (true/false)
%   'oseen':      v0, t (time), c1, c2, double
%   'shift':      shift (v displacement)
%   'rotation':   rotation (max displacement), imageSize = [height width]
%   'membrane':   imageSize = [height width]
%   'uniform':    u, v (constant displacement)
%   'vortex_jet': Rankine vortex (v0, R0, c1) with a Gaussian out-of-plane jet
%                 in its centre: w_max (w in the centre), jet radius = R0
% Optional for every type:
%   w: constant out-of-plane displacement (added to w)
% A double vortex is counter-rotating (second vortex is subtracted).
%
% Example:
%   flow.type = 'shift';
%   flow.shift = 5;
%   [u, v] = simulate.flow_field(flow, x, y);

w = zeros(size(x));
switch lower(flow.type)
    case {'rankine', 'oseen'}
        [u, v] = vortex(flow, x - flow.c1(1), y - flow.c1(2));
        if flow.double
            [u2, v2] = vortex(flow, x - flow.c2(1), y - flow.c2(2));
            u = u - u2;
            v = v - v2;
        end
    case 'shift'
        u = zeros(size(x));
        v = zeros(size(x)) + flow.shift;
    case 'rotation'
        % solid body rotation around the image centre, max displacement at the
        % edge of the longer image side (same scale in x and y)
        r_max = max(flow.imageSize) / 2;
        u = (y - (flow.imageSize(1) + 1) / 2) / r_max * flow.rotation;
        v = -(x - (flow.imageSize(2) + 1) / 2) / r_max * flow.rotation;
    case 'membrane'
        xs = -3 + 6 * (x - 1) / (flow.imageSize(2) - 1);
        ys = -3 + 6 * (y - 1) / (flow.imageSize(1) - 1);
        u = peaks(xs, ys) / 3;
        v = peaks(ys, xs) / 3;
    case 'uniform'
        u = zeros(size(x)) + flow.u;
        v = zeros(size(x)) + flow.v;
    case 'vortex_jet'
        dx = x - flow.c1(1);
        dy = y - flow.c1(2);
        [u, v] = rankine(dx, dy, flow.v0, flow.R0);
        w = flow.w_max * exp(-(dx.^2 + dy.^2) / flow.R0^2);
    otherwise
        error('simulate:flow_field:unknownType', 'Unknown flow type "%s".', flow.type)
end
if isfield(flow, 'w')
    w = w + flow.w;
end
end

function [u, v] = vortex(flow, dx, dy)
if strcmpi(flow.type, 'rankine')
    [u, v] = rankine(dx, dy, flow.v0, flow.R0);
else
    [u, v] = oseen(dx, dy, flow.v0 * 3, flow.t);
end
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
