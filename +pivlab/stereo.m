function res = stereo(imgs, boards, board, opts)
%STEREO Stereo-PIV analysis: stereo calibration, disparity correction, PIV of both cameras, U, V, W.
%   res = pivlab.stereo(imgs, boards, board)
%   res = pivlab.stereo(imgs, boards, board, Name=Value)
%
%   imgs    1x2 cell, image sets of camera 1 and 2 with their lens calibration, e.g.
%             imgs{k} = pivlab.preprocess(pivlab.readImages(files_k, "pairwise"), Camera=lens_file_k)
%           Both cameras must have the same number of image pairs (recorded at the same time).
%   boards  1x2 cell, image (or image file) of the ChArUco board in the light sheet, camera 1 and 2.
%           A camera on the other side of the light sheet sees the board from behind (transparent board);
%           this is detected automatically.
%   board   ChArUco board: PatternDims, CheckerSize [mm], MarkerSize [mm], MarkerFamily, OriginCheckerColor
%
%   Name=value options
%   Settings  PIVlab settings (pivlab.defaults / pivlab.loadSettings): image pre-processing, PIV and the
%             Stereo-PIV panel (group stereo). The same settings are used for both cameras.
%   Stereo    stereo settings (stereo.defaults) for experts; missing fields come from Settings / the defaults
%   Roi       [x y width height] in the common (rectified) image, [] = automatic (inside the overlap of both
%             views). A given region of interest also limits the disparity measurement.
%   Verbose   true (default) / false
%
%   res is a normal PIVlab result (like pivlab.analyze) of U, V, with the out-of-plane component in res.w
%   (positive away from camera 1, i.e. away from the cameras when both are on the same side), in px per image
%   pair of the common grid. As in the GUI after ANALYZE, the result is not validated yet: use pivlab.filter
%   (it validates both cameras and makes U, V, W again; velocity limits act on U, V and the 3D magnitude),
%   pivlab.toMetric (DeltaT is enough, the scale comes from the stereo calibration), pivlab.derive ("w",
%   3D "magnitude"), pivlab.temporal, pivlab.display (Overlay="w"), pivlab.saveSession (opens in the GUI).
%   res.stereo: calib, disparity, cameras (the 2D results of both cameras), images, roi, settings,
%   residual (how well both cameras fit one 3D velocity, px), sheet_z_mm, mm_per_px.
%
%   Example
%       for k = 1:2
%           imgs{k} = pivlab.readImages(files{k}, "pairwise");
%           imgs{k} = pivlab.preprocess(imgs{k}, Camera=lens_files{k});
%       end
%       board = struct('PatternDims',[23 24],'CheckerSize',10,'MarkerSize',7, ...
%           'MarkerFamily',"DICT_4X4_1000",'OriginCheckerColor',"black");
%       res = pivlab.stereo(imgs, {"board_cam1.tif", "board_cam2.tif"}, board);
%       res = pivlab.filter(res);
%       res = pivlab.toMetric(res, DeltaT=0.001);
%       pivlab.display(res, Overlay="w");
%
%   See also pivlab.filter, pivlab.toMetric, stereo.calibrate, stereo.measure_disparity, stereo.defaults
arguments
    imgs (1,2) cell
    boards (1,2) cell
    board (1,1) struct
    opts.Settings struct = struct()
    opts.Stereo struct = struct()
    opts.Roi = []
    opts.Verbose (1,1) logical = true
end
verbose = opts.Verbose;
S = opts.Settings;
if isempty(fieldnames(S))
    S = pivlab.defaults();
end
st = stereo_settings(S, opts.Stereo);

calib = stereo.calibrate({imgs{1}.cam, imgs{2}.cam}, boards, board, st.calibration);
if verbose
    fprintf('Stereo calibration: output grid %d x %d px, %.4f mm per px, board corners rejected: %s\n', ...
        calib.Ravg.ImageSize(2), calib.Ravg.ImageSize(1), calib.Ravg.PixelExtentInWorldX, mat2str(calib.n_rejected));
    report = stereo.geometry_report(calib);
    fprintf('  %s\n', report{:});
end

% pre-processing (background in raw camera coordinates) for the rectified images
imgs = stereo.rectified_images(imgs, calib, []);
disparity_roi = opts.Roi; % a given region of interest also limits the disparity measurement
if isempty(disparity_roi)
    disparity_roi = stereo.auto_roi(~calib.mask, 2); % as the GUI after the stereo calibration
end
for k = 1:2
    imgs{k} = pivlab.preprocess(imgs{k}, Camera=imgs{k}.cam, Roi="none", Mask="none", Settings=S, Verbose=verbose);
    imgs{k}.preprocess.Roi = disparity_roi;
end
disparity = stereo.measure_disparity(imgs, calib, st, verbose);
imgs = stereo.rectified_images(imgs, calib, disparity);
roi = opts.Roi;
if isempty(roi)
    margin = ceil(max(abs([disparity.u_full(:); disparity.v_full(:)])) / 2) + 2;
    roi = stereo.auto_roi(~calib.mask, margin);
end
if verbose
    fprintf('Stereo PIV: region of interest %s\n', mat2str(roi));
end
cams = cell(1, 2);
for k = 1:2
    imgs{k}.preprocess.Roi = roi;
    if verbose
        fprintf('Camera %d:\n', k);
    end
    cams{k} = pivlab.analyze(imgs{k}, Settings=S, Parallel=st.Parallel, Verbose=verbose);
end
disparity.report = stereo.disparity_report(calib, disparity); % as the GUI shows it in the Stereo-PIV panel
info = struct('calib', calib, 'disparity', disparity, 'images', {imgs}, 'roi', roi, 'stereo_settings', st, ...
    'board', board, 'boards', {boards});
res = stereo_result(cams, info, [], S);
end
