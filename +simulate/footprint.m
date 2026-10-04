function xy = footprint(cam, planePose)
% Outline of the field of view of camera cam (see simulate.camera) on a plane,
% as an N-by-2 polygon in plane coordinates (e.g. for bounding boxes or polyarea).
% planePose: rigidtform3d, plane coordinates -> world (default: identity)
if nargin < 2
    planePose = rigidtform3d;
end
h = cam.imageSize(1);
w = cam.imageSize(2);
s = linspace(0, 1, 20)';
xs = 0.5 + s * w;
ys = 0.5 + s * h;
border = [xs, 0 * s + 0.5; 0 * s + w + 0.5, ys; flip(xs), 0 * s + h + 0.5; 0 * s + 0.5, flip(ys)];
[xy, valid] = simulate.pixel_to_plane(cam, border, planePose);
xy = xy(valid, :);
end
