function Q = qcrit(x, y, u, v)
% Based on equations discussed with chatgpt. Validated using paraview.
% Compute grid spacing
dx = x(1,2) - x(1,1);
dy = y(2,1) - y(1,1);  % Works for meshgrid-style x/y

% Account for image-style y-axis (increasing downward)
[dudy, dudx] = gradient(u, -dy, dx);
[dvdy, dvdx] = gradient(v, -dy, dx);

% Rotation rate (vorticity component)
[curlz,~] = curl(x,y,u,v);

% Strain rate components
Sxx = dudx;
Syy = dvdy;
Sxy = 0.5 * (dudy + dvdx);

% Strain rate magnitude squared
S2 = Sxx.^2 + 2*Sxy.^2 + Syy.^2;

% Q-criterion
Q = 0.5 * (curlz.^2 - S2);