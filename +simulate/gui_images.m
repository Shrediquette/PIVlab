function [A, B] = gui_images(imageSize, flow, opts)
% Image pair with the parameters of PIVlab's synthetic image generator panel
% (orthographic camera, units = pixels). Returns uint8 images.
% flow: [u,v,w] = flow(x,y,z) in-plane displacement [px] (w is ignored and replaced by the out-of-plane motion)
%
% The particles fill a slab of thickness 2 (relative units). The laser sheet
% thickness is relative to this slab: a thinner sheet illuminates fewer
% particles, but each of them receives more light. The out-of-plane motion
% is given in percent of the sheet thickness.
arguments
    imageSize (1,2) double            % [height width]
    flow                              % function handle
    opts.Particles (1,1) double = 200000
    opts.SheetThickness (1,1) double = 0.5
    opts.OutOfPlane (1,1) double = 0  % [% of the sheet thickness]
    opts.Diameter (1,1) double = 3
    opts.DiameterVariation (1,1) double = 1
    opts.Noise (1,1) double = 0
    opts.Seed double = []
end
sheet = opts.SheetThickness;
w = opts.OutOfPlane / 100 * sheet;
out = simulate.particle_images(ImageSize=imageSize, Flow=@(x,y,z) with_w(flow, x, y, z, w), ...
    Particles=opts.Particles * min(sheet, 1), SheetThickness=sheet, PeakIntensity=80 / sheet, ...
    Diameter=opts.Diameter, DiameterVariation=opts.DiameterVariation, Noise=opts.Noise, Seed=opts.Seed);
A = out.A{1};
B = out.B{1};
end

function [u, v, w] = with_w(flow, x, y, z, w_displ)
[u, v] = flow(x, y, z);
w = zeros(size(x)) + w_displ;
end
