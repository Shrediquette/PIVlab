function [A, B] = gui_images(X, Y, U, V, opts)
% Image pair with the parameters of PIVlab's synthetic image generator panel
% (orthographic camera, units = pixels). Returns uint8 images.
% X, Y: grid of the displacement field in pixel coordinates (meshgrid)
% U, V: in-plane displacement on the grid [px], e.g. from simulate.flow_field
%
% The particles fill a slab of thickness 2 (relative units). The laser sheet
% thickness is relative to this slab: a thinner sheet illuminates fewer
% particles, but each of them receives more light. The out-of-plane motion
% is given in percent of the sheet thickness.
arguments
    X double
    Y double
    U double
    V double
    opts.ImageSize double = []        % [height width]; default: size(U), i.e. one grid point per pixel
    opts.Particles (1,1) double = 200000
    opts.SheetThickness (1,1) double = 0.5
    opts.OutOfPlane (1,1) double = 0  % [% of the sheet thickness]
    opts.Diameter (1,1) double = 3
    opts.DiameterVariation (1,1) double = 1
    opts.Noise (1,1) double = 0
    opts.Seed double = []
end
imageSize = opts.ImageSize;
if isempty(imageSize)
    imageSize = size(U);
end
sheet = opts.SheetThickness;
W = zeros(size(U)) + opts.OutOfPlane / 100 * sheet;
out = simulate.particle_images(ImageSize=imageSize, X=X, Y=Y, U=U, V=V, W=W, ...
    Particles=opts.Particles * min(sheet, 1), SheetThickness=sheet, PeakIntensity=80 / sheet, ...
    Diameter=opts.Diameter, DiameterVariation=opts.DiameterVariation, Noise=opts.Noise, Seed=opts.Seed);
A = out.A{1};
B = out.B{1};
end
