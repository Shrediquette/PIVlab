function c = flow_origin_3d(g, type, diameter)
% Position [x y] in sheet coordinates of the flow simulations of the 3D particle image generator,
% in the light sheet, in the view of the upstream camera (the view that starts furthest left; the flow
% goes in +x), vertically in the middle of that view:
%   'sphere': sphere centre, one diameter or a fifth of the view width from its left edge
%   'jet':    centre of the nozzle exit, at the left edge of that view
% g: simulate.geometry_3d
xmin = inf;
ox = [];
oy = [];
for k = 1:numel(g.views)
    [x, y] = boundary(g.views(k));
    if ~isempty(x) && min(x) < xmin
        xmin = min(x);
        ox = x;
        oy = y;
    end
end
if isempty(ox)
    ox = g.region(1:2);
    oy = g.region(3:4);
end
if strcmp(type, 'jet')
    c = [min(ox), (min(oy) + max(oy)) / 2];
else
    c = [min(ox) + max(diameter, 0.2 * (max(ox) - min(ox))), (min(oy) + max(oy)) / 2];
end
end
