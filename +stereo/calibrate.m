function calib = calibrate(cams, boards, board, opts)
%CALIBRATE Stereo calibration from a ChArUco board in the light sheet, seen by both cameras.
%   calib = stereo.calibrate(cams, boards, board)
%   calib = stereo.calibrate(cams, boards, board, opts)
%   cams    1x2 cell, camera settings with the lens calibration of camera 1 and 2
%           (import.cam_settings, e.g. imgs.cam after pivlab.preprocess(imgs, Camera=...))
%   boards  1x2 cell, image of the board in the light sheet (raw camera image or file name)
%   board   ChArUco board: PatternDims, CheckerSize [mm], MarkerSize [mm], MarkerFamily,
%           OriginCheckerColor (as for simulate.charuco_image)
%   opts    stereo.defaults().calibration (PixelSize, CornerFilter, BoardFromBehind)
%
% The cameras may be on the same side of the light sheet or on opposite sides. A camera behind the
% board sees it mirrored (transparent board, or a board printed on both sides with the back side
% as the mirror image of the front): the board is then detected in the mirrored image. By default
% (opts.BoardFromBehind = []) both ways are tried and the one with more corners is used.
%
%   World coordinates = board coordinates in mm, seen from camera 1: x right, y down, z into the board
%   (away from camera 1). If camera 1 sees the board from behind, the board coordinates are turned by
%   180 degrees about the y axis (x -> -x, z -> -z), so camera 1 is always in front (z < 0).
%   calib contains
%     cams{k}          lens calibration of camera k (undistorted image: view 'same', no rectification)
%     tform{k}         projective transform, undistorted image px -> world (mm)
%     image_points{k}, world_points{k}   detected board corners (undistorted px, mm)
%     n_rejected       corners rejected by the corner filter, per camera
%     extrinsics{k}, centre (2x3)        camera poses, camera centres [mm]
%     board_from_behind  [1x2 logical] camera k saw the board mirrored (from its back side)
%     opposite_sides   true: the cameras are on opposite sides of the light sheet
%     Ravg             common output grid (imref2d, mm): square pixels, cropped to the overlap
%     grid_info        pixel size, footprint of a camera pixel, overlap and views (polyshapes)
%     mask             true where not both cameras see the sheet (PIVlab mask convention)
%     image_size{k}    raw image size of camera k
if nargin < 4 || isempty(opts)
    d = stereo.defaults();
    opts = d.calibration;
end
from_behind = [];
if isfield(opts, 'BoardFromBehind')
    from_behind = opts.BoardFromBehind;
end
if ~isempty(from_behind) && numel(from_behind) ~= 2
    error('stereo:calibrate', 'BoardFromBehind must be [] (automatic) or one value per camera, e.g. [false true].');
end
calib.cams = cell(1, 2);
calib.tform = cell(1, 2);
calib.image_points = cell(1, 2);
calib.world_points = cell(1, 2);
calib.extrinsics = cell(1, 2);
calib.n_rejected = [0 0];
calib.centre = zeros(2, 3);
calib.image_size = cell(1, 2);
calib.board_from_behind = [false false];
calib.board = board;
for k = 1:2
    cam = cams{k};
    if ~cam.use_calibration
        error('stereo:calibrate', 'Camera %d has no lens calibration.', k);
    end
    cam.view = 'same';
    cam.use_rectification = 0;
    cam.rectification_tform = [];
    if isfield(cam, 'stereo_map')
        cam.stereo_map = [];
    end
    target = boards{k};
    if ischar(target) || isstring(target)
        target = imread(target);
    end
    if size(target, 3) > 1
        target = rgb2gray(target);
    end
    calib.image_size{k} = size(target, 1, 2);
    target = imadjust(preproc.cam_undistort_with(target, cam));
    side = [];
    if ~isempty(from_behind)
        side = logical(from_behind(k));
    end
    [ip, wp, calib.n_rejected(k), calib.board_from_behind(k)] = detect_board(target, board, opts.CornerFilter, side);
    if isempty(ip)
        if isempty(side)
            error('stereo:calibrate', ['No ChArUco board corners found in the board image of camera %d ' ...
                '(also not in the mirrored image, i.e. seen from behind).'], k);
        end
        error('stereo:calibrate', 'No ChArUco board corners found in the board image of camera %d.', k);
    end
    if size(ip, 1) < 8
        error('stereo:calibrate', 'Only %d board corners found for camera %d, at least 8 are needed.', size(ip, 1), k);
    end
    calib.cams{k} = cam;
    calib.image_points{k} = ip;
    calib.world_points{k} = wp;
end
if calib.board_from_behind(1)
    % camera 1 defines the front: turn the board coordinates by 180 deg about the y axis (x -> -x, z -> -z)
    for k = 1:2
        calib.world_points{k}(:, 1) = -calib.world_points{k}(:, 1);
    end
end
for k = 1:2
    ip = calib.image_points{k};
    wp = calib.world_points{k};
    calib.tform{k} = fitgeotform2d(ip, wp, 'projective');
    extr = estimateExtrinsics(ip, wp, pinhole_intrinsics(calib.cams{k}, calib.image_size{k}));
    pose = extr2pose(extr);
    calib.centre(k, :) = pose.Translation;
    calib.extrinsics{k} = extr;
end
calib.opposite_sides = stereo.opposite_sides(calib);
[calib.Ravg, calib.grid_info] = stereo.square_grid(calib.tform, calib.image_size, opts.PixelSize);
% mask: output pixels that are outside the view of one camera
H = calib.Ravg.ImageSize(1);
W = calib.Ravg.ImageSize(2);
both = true(H, W);
for k = 1:2
    [vx, vy] = boundary(calib.grid_info.views{k});
    [ix, iy] = worldToIntrinsic(calib.Ravg, vx, vy);
    both = both & poly2mask(ix, iy, H, W);
end
calib.mask = ~both;
end

function [ip, wp, n_rejected, mirrored] = detect_board(target, board, corner_filter, side)
% Board corners in the undistorted board image; side = [] tries the image as it is and mirrored (board
% seen from behind) and keeps the one with more corners, side = false / true uses only one of them.
% ip: image points in the (not mirrored) image, wp: board coordinates [mm]
all_wp = patternWorldPoints("charuco-board", board.PatternDims, board.CheckerSize);
if isempty(side)
    tries = [false true];
else
    tries = side;
end
ip = [];
wp = [];
n_rejected = 0;
mirrored = false;
for t = 1:numel(tries)
    img = target;
    if tries(t)
        img = fliplr(target);
    end
    p = preproc.cam_detectCharucoBoardPoints_scaled(img, board.PatternDims, char(board.MarkerFamily), ...
        board.CheckerSize, board.MarkerSize, 'MinMarkerID', 0, 'OriginCheckerColor', char(board.OriginCheckerColor), ...
        'RefineCorners', true, 'ResolutionPerBit', 16, 'MarkerSizeRange', [0.005 1]);
    if isempty(p) || all(isnan(p(:)))
        continue
    end
    if tries(t)
        p(:, 1) = size(target, 2) + 1 - p(:, 1); % back to the coordinates of the image as recorded
    end
    w = all_wp;
    w(isnan(p)) = NaN;
    p = rmmissing(p);
    w = rmmissing(w);
    n_bad = 0;
    if corner_filter && size(p, 1) >= 8
        % max distance 0.1 checker: a wrong marker ID moves a corner by whole checkers
        [p, w, n_bad] = stereo.filter_corners(p, w, 0.1 * board.CheckerSize);
    end
    if size(p, 1) > size(ip, 1)
        ip = p;
        wp = w;
        n_rejected = n_bad;
        mirrored = tries(t);
    end
    if isempty(side) && ~tries(t) && size(ip, 1) >= 0.5 * size(all_wp, 1)
        break % more than half of the board found as it is: a mirrored board can not give that
    end
end
end

function intrinsics = pinhole_intrinsics(cam, image_size)
% camera matrix of the undistorted image (for the camera pose)
if cam.use_tilted_model && ~isempty(cam.K_opencv)
    K = cam.K_opencv; % opencv_undistort with view 'same' keeps K; 0-based pixel indices
    intrinsics = cameraIntrinsics([K(1, 1) K(2, 2)], [K(1, 3) K(2, 3)] + 1, image_size);
elseif isa(cam.cameraParams, 'cameraParameters')
    intrinsics = cam.cameraParams.Intrinsics;
else
    intrinsics = cam.cameraParams;
end
end
