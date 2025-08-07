function Q = qcrit(x, y, u, v)
% Based on equations discussed with and tuned by Giorgio M. Validated using paraview.
% Compute grid spacing
dx = x(1,2) - x(1,1);
dy = y(2,1) - y(1,1);  % Works for meshgrid-style x/y

[ux,uy]=gradient(double(u),dx,dy);
[vx,vy]=gradient(double(v),dx,dy);
Q = 0.5 * (0.5 * (vx - uy).^2 - ux.^2 - vy.^2 - 2 * (0.5 * (uy + vx)).^2);