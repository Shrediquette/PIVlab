function mask = coverage_mask(calib)
%COVERAGE_MASK Output pixels that are not covered by the camera views (PIVlab mask convention: true = masked).
%   mask = stereo.coverage_mask(calib)
%   calib  stereo.calibrate (Ravg, grid_info.views, use)
%   stereo-PIV: outside the view of one camera; larger field of view (calib.use = "fov"): outside both views
H = calib.Ravg.ImageSize(1);
W = calib.Ravg.ImageSize(2);
in = false(H, W, 2);
for k = 1:2
    [vx, vy] = boundary(calib.grid_info.views{k});
    [ix, iy] = worldToIntrinsic(calib.Ravg, vx, vy);
    in(:, :, k) = poly2mask(ix, iy, H, W);
end
if calib.use == "fov"
    mask = ~any(in, 3);
else
    mask = ~all(in, 3);
end
end
