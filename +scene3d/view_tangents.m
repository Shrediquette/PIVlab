function [tan_h, tan_v] = view_tangents(ax, angle)
%VIEW_TANGENTS Half-angle tangents of the view of ax, horizontally and vertically.
%   [tan_h, tan_v] = scene3d.view_tangents(ax)          for ax.CameraViewAngle
%   [tan_h, tan_v] = scene3d.view_tangents(ax, angle)   for the view angle angle [deg]
% The view angle is for the shorter side of the axes.
if nargin < 2
    angle = ax.CameraViewAngle;
end
pos = getpixelposition(ax);
w = max(pos(3), 1);
h = max(pos(4), 1);
t = tand(angle / 2);
tan_h = t * max(1, w / h);
tan_v = t * max(1, h / w);
end
