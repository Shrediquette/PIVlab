function [xy, valid] = pixel_to_plane(cam, pix, planePose)
% Intersect the viewing rays of image pixels with a plane.
% pix:       N-by-2 pixel coordinates [x y] of camera cam (see simulate.camera)
% planePose: rigidtform3d, plane coordinates -> world (the plane is z = 0 in plane coordinates)
% Returns the N-by-2 plane coordinates [x y] and a flag for rays that hit
% the plane in front of the camera.
n = size(pix, 1);
if strcmp(cam.type, 'ortho')
    % rays parallel to world z
    origin = [pix / cam.scale + cam.origin, zeros(n, 1)];
    direction = [0 0 1];
    in_front = true;
else
    ray_cam = [normalized_undistorted(cam.intrinsics, pix), ones(n, 1)];
    R = cam.pose.R;
    origin = (-R' * cam.pose.Translation(:))'; % camera centre
    direction = ray_cam * R; % rotate rays to world coordinates
    in_front = false;
end
% plane: point planePose.Translation, normal = third axis of planePose
normal = planePose.R(:, 3)';
P0 = planePose.Translation;
s = ((P0 - origin) * normal') ./ (direction * normal');
X = origin + s .* direction;
Xp = (X - P0) * planePose.R; % world -> plane coordinates
xy = Xp(:, 1:2);
valid = s > 0 | in_front;
end

function xn = normalized_undistorted(intr, pix)
% Remove lens distortion (fixed-point iteration, same model as world2img /
% undistortImage) and return normalized camera coordinates.
% Many pixels (e.g. rendering a whole image): exact on a grid of every 4th pixel, cubic
% interpolation in between (the distortion is smooth: error < 1e-6 px).
n = size(pix, 1);
distorted = any(intr.RadialDistortion) || any(intr.TangentialDistortion);
if n > 50000 && distorted
    step = 4;
    lo = floor(min(pix, [], 1)) - 2 * step;
    hi = ceil(max(pix, [], 1)) + 2 * step;
    gx = lo(1):step:hi(1) + step;
    gy = lo(2):step:hi(2) + step;
    if numel(gx) * numel(gy) < n / 4
        [GX, GY] = ndgrid(gx, gy);
        g = normalized_undistorted(intr, [GX(:), GY(:)]);
        Fx = griddedInterpolant(GX, GY, reshape(g(:, 1), size(GX)), 'cubic');
        Fy = griddedInterpolant(GX, GY, reshape(g(:, 2), size(GX)), 'cubic');
        xn = [Fx(pix(:, 1), pix(:, 2)), Fy(pix(:, 1), pix(:, 2))];
        return
    end
end
f = intr.FocalLength;
c = intr.PrincipalPoint;
yd = (pix(:, 2) - c(2)) / f(2);
xd = (pix(:, 1) - c(1) - intr.Skew * yd) / f(1);
k = [intr.RadialDistortion(:)', 0];
p = intr.TangentialDistortion;
x = xd;
y = yd;
if ~any(k) && ~any(p)
    xn = [x, y];
    return
end
for iteration = 1:20
    r2 = x.^2 + y.^2;
    radial = 1 + k(1) * r2 + k(2) * r2.^2 + k(3) * r2.^3;
    dx = 2 * p(1) * x .* y + p(2) * (r2 + 2 * x.^2);
    dy = p(1) * (r2 + 2 * y.^2) + 2 * p(2) * x .* y;
    x_new = (xd - dx) ./ radial;
    y_new = (yd - dy) ./ radial;
    change = max(abs([x_new - x; y_new - y]));
    x = x_new;
    y = y_new;
    if change < 1e-12
        break
    end
end
xn = [x, y];
end
