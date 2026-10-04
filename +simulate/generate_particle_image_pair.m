function [A, B] = generate_particle_image_pair(displacement_v, noise, opts)
% Generate a synthetic PIV image pair with a known uniform displacement.
% Displacement is applied in the v (y/vertical) direction only.
%
% [A, B] = generate_particle_image_pair(displacement_v, noise)
% [A, B] = generate_particle_image_pair(displacement_v, noise, img_size=600, partAm=10000, ...)
%
% Outputs A and B are double matrices in [0,1], ready for piv.piv_FFTmulti.
% Uses the same particle model as the GUI (see simulate.gui_images).
arguments
    displacement_v  (1,1) double   % known v-displacement [px], applied to image B
    noise           (1,1) double   % Gaussian noise variance (0 = no noise)
    opts.img_size   (1,1) double = 1600
    opts.partAm     (1,1) double = 150000
    opts.Z          (1,1) double = 0.5    % laser sheet thickness parameter
    opts.dt         (1,1) double = 4      % mean particle diameter [px]
    opts.ddt        (1,1) double = 0.25   % particle diameter std deviation
end
[A, B] = simulate.gui_images([opts.img_size opts.img_size], @(x,y,z) deal(0*x, 0*x + displacement_v), ...
    Particles=opts.partAm, SheetThickness=opts.Z, Diameter=opts.dt, DiameterVariation=opts.ddt, Noise=noise);
A = mat2gray(A);
B = mat2gray(B);
end
