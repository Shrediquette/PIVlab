function [x, y] = circle_outline(center, radius)
% Outline of a circle as a polygon with 360 sides (for poly2mask): circle masks (mask.combine,
% mask.convert_masks_to_binary) and circle areas of the extraction (extract.convert_roi_to_binary).
%   center  [x y] in pixels, radius in pixels; x, y: 361 x 1, the first point is repeated at the end
%   A polygon with floor(sqrt(2*pi*r)) sides, as used before, made the area too small (6.5 % at
%   r = 16 px, 3 % at r = 40 px).
angle = linspace(0, 2*pi, 361)';
x = center(1) + sin(angle) * radius;
y = center(2) + cos(angle) * radius;
end
