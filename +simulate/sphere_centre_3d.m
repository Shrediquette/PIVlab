function c = sphere_centre_3d(g, diameter)
% Centre [x y] of the sphere of the flow 'sphere' of the 3D particle image generator, in sheet
% coordinates: in the light sheet, near the left edge of the overlap of the camera views (one
% diameter or a fifth of the overlap width from its edge), vertically in the middle.
% g: simulate.geometry_3d
[ox, oy] = boundary(g.overlap);
if isempty(ox)
    ox = g.region(1:2);
    oy = g.region(3:4);
end
c = [min(ox) + max(diameter, 0.2 * (max(ox) - min(ox))), (min(oy) + max(oy)) / 2];
end
