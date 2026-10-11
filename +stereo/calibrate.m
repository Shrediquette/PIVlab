function calib = calibrate(cams, boards, board, opts)
%CALIBRATE Stereo calibration from a ChArUco board in the light sheet, seen by both cameras.
%   calib = stereo.calibrate(cams, boards, board)
%   calib = stereo.calibrate(cams, boards, board, opts)
%   cams    1x2 cell, camera settings with the lens calibration of camera 1 and 2
%           (import.cam_settings, e.g. imgs.cam after pivlab.preprocess(imgs, Camera=...))
%   boards  1x2 cell, image of the board in the light sheet (raw camera image or file name)
%   board   ChArUco board: PatternDims, CheckerSize [mm], MarkerSize [mm], MarkerFamily,
%           OriginCheckerColor (as for simulate.charuco_image)
%   opts    stereo.defaults().calibration (PixelSize, CornerFilter)
%
%   World coordinates = board coordinates in mm: x right, y down, z into the board (away from the
%   cameras). calib contains
%     cams{k}          lens calibration of camera k (undistorted image: view 'same', no rectification)
%     tform{k}         projective transform, undistorted image px -> world (mm)
%     image_points{k}, world_points{k}   detected board corners (undistorted px, mm)
%     n_rejected       corners rejected by the corner filter, per camera
%     extrinsics{k}, centre (2x3)        camera poses, camera centres [mm]
%     Ravg             common output grid (imref2d, mm): square pixels, cropped to the overlap
%     grid_info        pixel size, footprint of a camera pixel, overlap and views (polyshapes)
%     mask             true where not both cameras see the sheet (PIVlab mask convention)
%     image_size{k}    raw image size of camera k
if nargin < 4 || isempty(opts)
    d = stereo.defaults();
    opts = d.calibration;
end
calib.cams = cell(1, 2);
calib.tform = cell(1, 2);
calib.image_points = cell(1, 2);
calib.world_points = cell(1, 2);
calib.extrinsics = cell(1, 2);
calib.n_rejected = [0 0];
calib.centre = zeros(2, 3);
calib.image_size = cell(1, 2);
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
    ip = preproc.cam_detectCharucoBoardPoints_scaled(target, board.PatternDims, char(board.MarkerFamily), ...
        board.CheckerSize, board.MarkerSize, 'MinMarkerID', 0, 'OriginCheckerColor', char(board.OriginCheckerColor), ...
        'RefineCorners', true, 'ResolutionPerBit', 16, 'MarkerSizeRange', [0.005 1]);
    if isempty(ip) || all(isnan(ip(:)))
        error('stereo:calibrate', 'No ChArUco board corners found in the board image of camera %d.', k);
    end
    wp = patternWorldPoints("charuco-board", board.PatternDims, board.CheckerSize);
    wp(isnan(ip)) = NaN;
    ip = rmmissing(ip);
    wp = rmmissing(wp);
    if opts.CornerFilter
        % max distance 0.1 checker: a wrong marker ID moves a corner by whole checkers
        [ip, wp, calib.n_rejected(k)] = stereo.filter_corners(ip, wp, 0.1 * board.CheckerSize);
    end
    if size(ip, 1) < 8
        error('stereo:calibrate', 'Only %d board corners found for camera %d, at least 8 are needed.', size(ip, 1), k);
    end
    calib.tform{k} = fitgeotform2d(ip, wp, 'projective');
    extr = estimateExtrinsics(ip, wp, pinhole_intrinsics(cam, calib.image_size{k}));
    pose = extr2pose(extr);
    calib.centre(k, :) = pose.Translation;
    calib.cams{k} = cam;
    calib.image_points{k} = ip;
    calib.world_points{k} = wp;
    calib.extrinsics{k} = extr;
end
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
