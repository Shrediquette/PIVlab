function F = maps(calib)
%MAPS Everything import.read_frame needs to combine two cameras into one larger image (cam.fov), except
%the frame list of camera 2 (F.src), which the caller adds.
%   F = fov.maps(calib)
%   calib  stereo.calibrate with calib.use = "fov" (grid covering both views)
%   F.owner    uint8, size of calib.Ravg: 1 / 2 = the camera that gives this pixel, 0 = no camera sees it
%   F.map{k}   x, y: raw-image position (camera k) of the pixels with owner k (single column vectors, in the
%              order of find(F.owner == k)); lens model and projective transform of the calibration
%   F.size     [height width] of the combined image
%   F.mm_per_px  size of one output pixel [mm]
%   F.coarse   Fx{k}, Fy{k}: interpolants (row, column of the combined image) of the raw-image position in
%              camera k over the WHOLE combined grid (sampled on every 8th pixel), for the display at screen
%              resolution (import.read_frame_display)
%   F.src      [] here: frame list of camera 2 (import.frame_list), in the same order as the frames of camera 1;
%              set by pivlab.combineCameras, and by import.cam_settings(FromGUI=true) from gui.retr('fov_src2')
% Each output pixel is taken from the camera that sees it farther from the border of its view (hard seam
% in the middle of the overlap, no blending). Only the pixels a camera gives are interpolated from it,
% so combining costs about as much as rectifying one image of the combined size.
F.owner = fov.owner_map(calib);
F.size = calib.Ravg.ImageSize;
F.mm_per_px = calib.Ravg.PixelExtentInWorldX;
F.map = cell(1, 2);
for k = 1:2
    [yo, xo] = find(F.owner == k);
    pd = raw_positions(calib, k, xo, yo);
    F.map{k} = struct('x', pd(:, 1), 'y', pd(:, 2));
end
% every 8th pixel, both cameras everywhere (the display interpolates linearly, also next to the seam)
rows = unique([1:8:F.size(1), F.size(1)]);
cols = unique([1:8:F.size(2), F.size(2)]);
[xo, yo] = meshgrid(cols, rows);
F.coarse = struct('Fx', {cell(1, 2)}, 'Fy', {cell(1, 2)});
for k = 1:2
    pd = raw_positions(calib, k, xo(:), yo(:));
    F.coarse.Fx{k} = griddedInterpolant({rows, cols}, reshape(pd(:, 1), numel(rows), numel(cols)), 'linear', 'nearest');
    F.coarse.Fy{k} = griddedInterpolant({rows, cols}, reshape(pd(:, 2), numel(rows), numel(cols)), 'linear', 'nearest');
end
F.src = [];
end

function pd = raw_positions(calib, k, xo, yo)
% raw-image position (single, [x y]) in camera k of the combined-image pixels xo, yo
[xw, yw] = intrinsicToWorld(calib.Ravg, xo(:), yo(:));
pu = transformPointsInverse(calib.tform{k}, [xw, yw]);
pd = single(stereo.distort_points(pu, calib.cams{k}));
end
