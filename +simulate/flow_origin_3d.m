function c = flow_origin_3d(g, type, diameter)
% Position [x y] in sheet coordinates of the flow simulations of the 3D particle image generator,
% both in the light sheet, vertically in the middle of the overlap of the camera views:
%   'sphere': sphere centre, one diameter or a fifth of the overlap width from its left edge
%   'jet':    centre of the nozzle exit, at the left edge of all camera views (the jet goes in +x)
% g: simulate.geometry_3d
[ox, oy] = boundary(g.overlap);
if isempty(ox)
    ox = g.region(1:2);
    oy = g.region(3:4);
end
if strcmp(type, 'jet')
    c = [g.region(1), (min(oy) + max(oy)) / 2];
else
    c = [min(ox) + max(diameter, 0.2 * (max(ox) - min(ox))), (min(oy) + max(oy)) / 2];
end
end
