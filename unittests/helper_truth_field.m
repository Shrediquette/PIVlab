function T = helper_truth_field(F, x, y)
%HELPER_TRUTH_FIELD Velocities and velocity gradients of a test flow (helper_truth_flow) at the
%   pixel positions x, y (image pixels: x to the right, y downward).
%   T.u, T.v      displacement in px per frame as stored inside PIVlab (u right, v DOWN)
%   T.w           out-of-plane displacement in px per frame, positive away from the camera
%                 (like the stereo reconstruction)
%   T.U, T.V      the same in screen coordinates (U right, V UP)
%   T.ux, T.uy, T.vx, T.vy   dU/dX, dU/dY, dV/dX, dV/dY in screen coordinates (1 per frame)
%   T.X, T.Y      screen coordinates of the points (px from the flow centre, Y up)
X = x - F.xc;
Y = -(y - F.yc);
switch F.name
    case {'linear', 'uniform'}
        U = F.u0 - F.omega * Y + (F.a + F.s) * X;
        V = F.v0 + F.omega * X + (F.a - F.s) * Y;
        ux = (F.a + F.s) + zeros(size(X));
        uy = -F.omega + zeros(size(X));
        vx = F.omega + zeros(size(X));
        vy = (F.a - F.s) + zeros(size(X));
    case 'quadratic'
        b = F.b;
        c = F.c;
        U = F.u0 + b(1) * X.^2 + b(2) * Y.^2 + b(3) * X .* Y;
        V = F.v0 + c(1) * X.^2 + c(2) * Y.^2 + c(3) * X .* Y;
        ux = 2 * b(1) * X + b(3) * Y;
        uy = 2 * b(2) * Y + b(3) * X;
        vx = 2 * c(1) * X + c(3) * Y;
        vy = 2 * c(2) * Y + c(3) * X;
    case 'oseen'
        % tangential velocity v_theta = gamma / (2 pi r) * (1 - exp(-r^2/rc^2)), counter-clockwise
        % on the screen; U = -g*Y, V = g*X with g = v_theta / r
        r2 = X.^2 + Y.^2;
        r = sqrt(r2);
        e = exp(-r2 / F.rc^2);
        g = F.gamma / (2 * pi) * (1 - e) ./ r2;
        dg = F.gamma / (2 * pi) * ((2 * r / F.rc^2) .* e ./ r2 - 2 * (1 - e) ./ r.^3);   % dg/dr
        U = -g .* Y;
        V = g .* X;
        ux = -dg .* (X ./ r) .* Y;
        uy = -g - dg .* Y.^2 ./ r;
        vx = g + dg .* X.^2 ./ r;
        vy = dg .* X .* Y ./ r;
    otherwise
        error('helper_truth_field: unknown flow "%s"', F.name);
end
T.X = X;
T.Y = Y;
T.U = U;
T.V = V;
T.u = U;
T.v = -V;
T.w = F.w0 + F.wx * X + F.wy * Y;
T.ux = ux;
T.uy = uy;
T.vx = vx;
T.vy = vy;
end
