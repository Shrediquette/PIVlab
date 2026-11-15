function E = helper_truth_expected(T, C, x, y, image_size)
%HELPER_TRUTH_EXPECTED Expected values in the units and axes of the user, from the analytic field
%   T (helper_truth_field) and the case C (helper_truth_cases), at the pixel positions x, y.
%   image_size [height width] in px (for the default origin of flipped axes).
%
%   E.x, E.y        coordinates (m or px), with the origin of the case
%   E.u, E.v, E.w   velocity components along x, y, z (z = x cross y; w: stereo component)
%   E.magnitude     sqrt(u^2 + v^2),  E.magnitude3  sqrt(u^2 + v^2 + w^2)
%   E.direction     atan2d(v, u)
%   E.vorticity     dv/dx - du/dy             E.divergence  du/dx + dv/dy
%   E.strain        du/dx - dv/dy (simple strain rate)
%   E.qcriterion    -0.5*(ux^2 + vy^2) - uy*vx
%   E.shear         sqrt(2*(ux^2 + vy^2 + 2*(0.5*(uy + vx))^2))
%   E.fv            factor px/frame -> velocity unit (without sign)
%   All derivatives are taken in the user's coordinates, written out by hand from the axis signs.
H = image_size(1);
W = image_size(2);
sx = C.sx;
sy = C.sy;
% pixel position of the origin
if isempty(C.origin)
    x0 = 0;
    if C.xdir == 2
        x0 = W;
    end
    y0 = 0;
    if C.ydir == 2
        y0 = H;
    end
else
    x0 = C.origin(1);
    y0 = C.origin(2);
end
E.x = sx * (x - x0) * C.calxy;
E.y = sy * (-(y - y0)) * C.calxy;      % -(y - y0): upward on the screen
fv = C.calxy / C.t;
E.fv = fv;
E.u = sx * T.U * fv;
E.v = sy * T.V * fv;
E.w = sx * sy * (-T.w) * fv;            % T.w is positive away from the camera
E.magnitude = sqrt(E.u.^2 + E.v.^2);
E.magnitude3 = sqrt(E.u.^2 + E.v.^2 + E.w.^2);
E.direction = atan2d(E.v, E.u);
% gradients in the user's coordinates (the spatial scale cancels, the time step stays)
z = sx * sy;
dux = T.ux / C.t;
dvy = T.vy / C.t;
duy = z * T.uy / C.t;
dvx = z * T.vx / C.t;
E.vorticity = dvx - duy;
E.divergence = dux + dvy;
E.strain = dux - dvy;
E.qcriterion = -0.5 * (dux.^2 + dvy.^2) - duy .* dvx;
E.shear = sqrt(2 * (dux.^2 + dvy.^2 + 2 * (0.5 * (duy + dvx)).^2));
end
