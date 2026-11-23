function fit_view(ax, direction, P)
%FIT_VIEW Looks along -direction at the centre of the scene, from the distance at which all its points are
% in view (perspective, view angle 30 degrees, vertical: scene3d.up).
%   scene3d.fit_view(ax, direction)      board, cameras, floor feet and extra points of the scene
%   scene3d.fit_view(ax, direction, P)   the points P (N x 3, axes of the results)
if nargin < 3
    P = scene3d.view_points(ax);
end
if isempty(P)
    return
end
direction = direction / norm(direction);
target = (min(P, [], 1) + max(P, [], 1)) / 2;
u = scene3d.up(ax);
v = u - dot(u, direction) * direction;
if norm(v) < 1e-6 % looking along the vertical
    alt = circshift(u, 1);
    v = alt - dot(alt, direction) * direction;
end
v = v / norm(v);
right = cross(direction, v);
[tan_h, tan_v] = scene3d.view_tangents(ax, 30);
tan_v = 0.86 * tan_v; % room for the header line and the buttons
tan_h = 0.92 * tan_h;
q = P - target;
along = q * direction';
distance = max(along + max(abs(q * v') / tan_v, abs(q * right') / tan_h));
camproj(ax, 'perspective');
set(ax, 'CameraTarget', target, 'CameraPosition', target + distance * direction, 'CameraUpVector', v, 'CameraViewAngle', 30);
end
