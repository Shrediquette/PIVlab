function phi = gabor2D(self)
% This function is for internal use only. It may change or be removed in a
% future release.

%   Copyright 2018-2020 The MathWorks, Inc.

Nx = self.XSizePad;
Ny = self.YSizePad;
sigma = self.SigmaPhi;
offset = [0 0];
% Create mesh grid. Result is Ny-by-Nx matrices for both X and Y
% X has Ny rows where the elements of X are repeated across the columns
% Y as Nx columns where the elements of Y are repeated in each column
[X,Y] = meshgrid(1:Nx,1:Ny);
X = X - ceil(Nx/2) - 1;
Y = Y - ceil(Ny/2) - 1;
X = X - offset(1);
Y = Y - offset(2);
% Sifre, equation 2.41
% curv = np.dot(R, np.dot(D, R_inv)) / ( 2 * sigma * sigma)
D = [1/sigma^2, 0 ; 0 1/sigma^2];
S = X.* ( D(1,1)*X + D(1,2)*Y) + Y.*(D(2,1)*X + D(2,2)*Y);
% Normalization
Gaussian = exp(-S/2);
% sigma*sigma/slant is the square root of the determinant of the
% covariance matrix. For the scaling function the standard deviation
% in the x-direction and y-direction are the same.
normfactor = 2*pi*sigma*sigma;
phi = 1/normfactor*fftshift(Gaussian);


if (strcmpi(self.Precision, 'single'))
    phi = single(phi);
end

end
