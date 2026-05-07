function [A, B] = generate_particle_image_pair(displacement_v, noise, opts)
% Generate a synthetic PIV image pair with a known uniform displacement.
% Displacement is applied in the v (y/vertical) direction only.
%
% [A, B] = generate_particle_image_pair(displacement_v, noise)
% [A, B] = generate_particle_image_pair(displacement_v, noise, img_size=600, partAm=10000, ...)
%
% Outputs A and B are double matrices in [0,1], ready for piv.piv_FFTmulti.
arguments
    displacement_v  (1,1) double   % known v-displacement [px], applied to image B
    noise           (1,1) double   % Gaussian noise variance (0 = no noise)
    opts.img_size   (1,1) double = 1600
    opts.partAm     (1,1) double = 150000
    opts.Z          (1,1) double = 0.5    % laser sheet thickness parameter
    opts.dt         (1,1) double = 4      % mean particle diameter [px]
    opts.ddt        (1,1) double = 0.25   % particle diameter std deviation
end

img_size = opts.img_size;
partAm   = opts.partAm;
Z        = opts.Z;
dt       = opts.dt;
ddt      = opts.ddt;

z0_pre = randn(partAm, 1);
z1_pre = randn(partAm, 1);
% z_move=0: no out-of-plane loss, simplifies to z0=z0_pre, z1=z1_pre
z0 = z0_pre * 0.5 + z1_pre * 0.5;
z1 = z1_pre * 0.5 + z0_pre * 0.5;

I0 = 255 * exp(-(Z^2 ./ (0.125 * z0.^2)));
I0(I0 > 255) = 255;  I0(I0 < 0) = 0;

I1 = 255 * exp(-(Z^2 ./ (0.125 * z1.^2)));
I1(I1 > 255) = 255;  I1(I1 < 0) = 0;

d  = dt + randn(partAm, 1) / 2 * ddt;
d(d < 0) = 0;
rd = -8.0 ./ d.^2;

x0 = rand(partAm, 1) * img_size;
y0 = rand(partAm, 1) * img_size;

% Image A particle extents
xlimit1 = max(floor(x0 - d/2), 1);
xlimit2 = min(ceil(x0  + d/2), img_size);
ylimit1 = max(floor(y0 - d/2), 1);
ylimit2 = min(ceil(y0  + d/2), img_size);

% Image B particle extents (shifted by +displacement_v in y)
xlimit3 = max(floor(x0 - d/2), 1);
xlimit4 = min(ceil(x0  + d/2), img_size);
ylimit3 = max(floor(y0 - d/2 + displacement_v), 1);
ylimit4 = min(ceil(y0  + d/2 + displacement_v), img_size);

A = zeros(img_size, img_size);
B = zeros(img_size, img_size);

for n = 1:partAm
    r = rd(n);
    for j = xlimit1(n):xlimit2(n)
        rj = (j - x0(n))^2;
        for i = ylimit1(n):ylimit2(n)
            A(i, j) = A(i, j) + I0(n) * exp((rj + (i - y0(n))^2) * r);
        end
    end
    for j = xlimit3(n):xlimit4(n)
        for i = ylimit3(n):ylimit4(n)
            B(i, j) = B(i, j) + I1(n) * exp((-(j - x0(n))^2 - (i - y0(n) - displacement_v)^2) * -r);
        end
    end
end

A(A > 255) = 255;
B(B > 255) = 255;

if noise > 0
    A = imnoise(uint8(A), 'gaussian', 0, noise);
    B = imnoise(uint8(B), 'gaussian', 0, noise);
else
    A = uint8(A);
    B = uint8(B);
end

A = mat2gray(A);
B = mat2gray(B);
end
