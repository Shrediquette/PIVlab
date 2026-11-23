function owner = owner_map(calib)
%OWNER_MAP Which camera gives each pixel of the combined image (hard seam in the middle of the overlap).
%   owner = fov.owner_map(calib)
%   calib  stereo.calibrate (calib.Ravg, calib.grid_info.views)
%   owner  uint8, size of calib.Ravg: 1 or 2, 0 where no camera sees the sheet
% A pixel seen by both cameras goes to the camera that sees it farther from the border of its view. In the
% overlap of two cameras side by side, the seam is then the middle line of the overlap.
H = calib.Ravg.ImageSize(1);
W = calib.Ravg.ImageSize(2);
d = zeros(H, W, 2, 'single');
for k = 1:2
    [vx, vy] = boundary(calib.grid_info.views{k});
    [ix, iy] = worldToIntrinsic(calib.Ravg, vx, vy);
    in = poly2mask(ix, iy, H, W);
    dk = bwdist(~in); % distance to the border of the view, 0 outside
    dk(~in) = -1;
    d(:, :, k) = dk;
end
owner = zeros(H, W, 'uint8');
owner(d(:, :, 1) >= 0 & d(:, :, 1) >= d(:, :, 2)) = 1;
owner(d(:, :, 2) >= 0 & d(:, :, 2) > d(:, :, 1)) = 2;
end
