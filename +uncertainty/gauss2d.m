function g = gauss2d(Ny, Nx)
% 2D Gaussian kernel: g = exp(-2*(2r/(Nx-1))^2), so g(edge)=exp(-2).
% Adapted from Wieneke (2013) disparity_uncertainty package.
if nargin < 2, Nx = Ny; end
[X, Y] = meshgrid(-(Nx-1)/2 : (Nx-1)/2, -(Ny-1)/2 : (Ny-1)/2);
r = sqrt(X.^2 + Y.^2) / (Nx-1) * 2;
g = exp(-2 * r.^2);
end
