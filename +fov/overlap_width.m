function [width, along_x, warnings] = overlap_width(views, overlap, px_per_mm)
%OVERLAP_WIDTH Width of the overlap of two camera views side by side (or above each other).
%   [width, along_x] = fov.overlap_width(views, overlap)
%   [width, along_x, warnings] = fov.overlap_width(views, overlap, px_per_mm)
%   views     1x2 cell, polyshape of the view of camera 1 and 2 (board or sheet coordinates, mm)
%   overlap   polyshape, intersection of both views (may be empty)
%   width     [mm] extent of the overlap along the line between both view centres; 0 without overlap
%   along_x   true when the cameras are side by side (the line between the view centres is closer to x than to
%             y): the overlap is then a part of the image width, else of the image height
%   warnings  (with px_per_mm, camera pixels per mm) report lines for a missing or small overlap: an
%             interrogation window plus margin (about 100 px) is recommended
% Used by fov.report and by the report of the particle image generator (simulate.geometry_report_3d).
[c1x, c1y] = centroid(views{1});
[c2x, c2y] = centroid(views{2});
direction = [c2x - c1x, c2y - c1y] / norm([c2x - c1x, c2y - c1y]);
along_x = abs(direction(1)) >= abs(direction(2));
width = 0;
if overlap.NumRegions > 0
    s = overlap.Vertices * direction';
    width = max(s) - min(s);
end
warnings = {};
if nargin < 3
    return
end
if width == 0
    warnings{end + 1} = 'Warning: the views do not overlap, the gap between them is masked.';
elseif width * px_per_mm < 64
    warnings{end + 1} = 'Warning: small overlap: an interrogation window plus margin (about 100 px) is recommended.';
end
end
