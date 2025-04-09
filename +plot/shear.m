function out=shear(x,y,u,v)
%original code until 3.10
%{
hx = x(1,:);
hy = y(:,1);
[junk, py] = gradient(u, hx, hy);
[qx, junk] = gradient(v, hx, hy);
out= qx+py;
%}

%New code, 'Shear rate (magnitude of the rate-of-strain tensor)'
%based on discussion with https://github.com/CSFrom
%x is a 2D matrix containing the x-coordinates of every node
%y is a 2D matrix containing the y-coordinates of every node
%u is a 2D matrix containing the velocities in x direction at every node
%v is a 2D matrix containing the velocities in y direction at every node

dx=x(1,:);
dy=y(:,1);

[dux_dx, dux_dy] = gradient(u, dx, dy);
[duy_dx, duy_dy] = gradient(v, dx, dy);

% where the components of the rate-of-strain tensor components
Dxx = dux_dx; 
Dyy = duy_dy;

Dxy = 0.5 * (dux_dy + duy_dx); % Only Dxy since it is symmetric by definition (also the sum of diagonals, Dxy + Dyx = dux_dy + duy_dx).

%Compute the magnitude of the rate-of-strain tensor, i.e.,
out = sqrt(2 * (Dxx.^2 + Dyy.^2 + 2 * Dxy.^2));
