function calib = on_sheet(calib, plane)
%ON_SHEET The alignment of two combined cameras moved from the board onto the light sheet.
%   calib = fov.on_sheet(calib, plane)
%   calib  stereo.calibrate (calib.use = "fov"), also one that was moved before (it always starts from the board)
%   plane  [a b c]: the light sheet is the plane z = a + b*x + c*y (board coordinates [mm], z > 0 behind the
%          board, away from the cameras); [0 0 0] = the board itself
% Each output pixel (x, y) is the point (x, y, z(x, y)) of the light sheet: calib.tform{k} maps camera pixels
% onto the sheet instead of the board. A point on the sheet is seen by camera k where the line from the camera
% centre through it meets the board, so the new transform is the board transform followed by a projective
% transform (central projection between two planes); fov.maps, fov.owner_map and stereo.measure_disparity use
% it unchanged. The output grid (calib.Ravg) stays; the views, the overlap and the mask are those on the sheet.
%   calib.board_tform  the transforms onto the board (kept); calib.sheet_plane = plane
if ~isfield(calib, 'board_tform') || isempty(calib.board_tform)
    calib.board_tform = calib.tform;
end
a = plane(1);
b = plane(2);
c = plane(3);
for k = 1:2
    C = calib.centre(k, :);
    D = -C(3); % distance of camera k from the board (in front: z < 0)
    % sheet point (x, y, z) -> board point (C + (P - C) * D / (D + z)), homogeneous, with z = a + b x + c y
    H = [D + C(1) * b, C(1) * c, C(1) * a; ...
        C(2) * b, D + C(2) * c, C(2) * a; ...
        b, c, D + a];
    calib.tform{k} = projtform2d(H \ calib.board_tform{k}.A);
end
calib.sheet_plane = plane;
calib.grid_info.views = stereo.view_polygons(calib.tform, calib.image_size, calib.cams);
calib.grid_info.overlap = intersect(calib.grid_info.views{1}, calib.grid_info.views{2});
calib.mask = stereo.coverage_mask(calib);
end
