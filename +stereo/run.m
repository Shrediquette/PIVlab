function result = run(imgs, boards, board, opts)
%RUN Complete stereo-PIV evaluation: calibration, disparity correction, PIV of both cameras, 3D reconstruction.
%   result = stereo.run(imgs, boards, board)
%   result = stereo.run(imgs, boards, board, Name=Value)
%
%   imgs    1x2 cell, image sets of camera 1 and 2 with their lens calibration, e.g.
%             imgs{k} = pivlab.preprocess(pivlab.readImages(files_k, "pairwise"), Camera=calibration_file_k)
%           Both cameras must have the same number of image pairs (recorded simultaneously).
%   boards  1x2 cell, image (or image file) of the ChArUco board in the light sheet, camera 1 and 2
%   board   ChArUco board: PatternDims, CheckerSize [mm], MarkerSize [mm], MarkerFamily, OriginCheckerColor
%
%   Name=value options
%   Settings  PIVlab settings (pivlab.defaults / pivlab.loadSettings): image pre-processing, PIV,
%             vector validation and smoothing. The same settings are used for both cameras.
%   Stereo    stereo settings (stereo.defaults); missing fields get the default value
%   Roi       [x y width height] in the rectified images, [] = automatic (rectangle in the overlap).
%             A given region of interest is used for the disparity measurement and the PIV.
%   Verbose   true (default) / false
%
%   result.calib      stereo calibration (stereo.calibrate)
%   result.disparity  disparity correction (stereo.measure_disparity, without the full-size maps)
%   result.roi        region of interest of the PIV
%   result.res        1x2 cell, PIV results of both cameras (pivlab result structs)
%   result.vel        U, V, W [px per image pair] on the vector grid (stereo.reconstruct);
%                     vel.mm_per_px converts to mm. x right, y down, W positive away from the cameras.
%
%   Example
%       s = pivlab.defaults();
%       for k = 1:2
%           imgs{k} = pivlab.readImages(files{k}, "pairwise");
%           imgs{k} = pivlab.preprocess(imgs{k}, Camera=lens_files{k});
%       end
%       board = struct('PatternDims',[23 24],'CheckerSize',10,'MarkerSize',7, ...
%           'MarkerFamily',"DICT_4X4_1000",'OriginCheckerColor',"black");
%       result = stereo.run(imgs, {"board_cam1.tif", "board_cam2.tif"}, board, Settings=s);
%
%   See also stereo.defaults, stereo.calibrate, stereo.measure_disparity, stereo.reconstruct
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
st = complete_settings(opts.Stereo, stereo.defaults());

calib = stereo.calibrate({imgs{1}.cam, imgs{2}.cam}, boards, board, st.calibration);
if verbose
    fprintf('Stereo calibration: output grid %d x %d px, %.4f mm per px, board corners rejected: %s\n', ...
        calib.Ravg.ImageSize(2), calib.Ravg.ImageSize(1), calib.Ravg.PixelExtentInWorldX, mat2str(calib.n_rejected));
end

% pre-processing (background in raw camera coordinates) for the rectified images
imgs = stereo.rectified_images(imgs, calib, []);
for k = 1:2
    imgs{k} = pivlab.preprocess(imgs{k}, Camera=imgs{k}.cam, Roi="none", Mask="none", Settings=S, Verbose=verbose);
    imgs{k}.preprocess.Roi = opts.Roi; % a given region of interest also limits the disparity measurement
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
res = cell(1, 2);
for k = 1:2
    imgs{k}.preprocess.Roi = roi;
    if verbose
        fprintf('Camera %d:\n', k);
    end
    res{k} = pivlab.analyze(imgs{k}, Settings=S, Parallel=st.Parallel, Verbose=verbose);
    res{k} = pivlab.filter(res{k}, Settings=S, Verbose=verbose);
    if lower(string(S.derive.Smoothing)) ~= "none"
        res{k} = pivlab.derive(res{k}, "u", Settings=S); % smoothed field in res.px.u_smoothed
    end
end
vel = stereo.reconstruct(res{1}, res{2}, calib, disparity, st.reconstruction);

result.settings = S;
result.stereo_settings = st;
result.calib = calib;
result.disparity = rmfield(disparity, {'u_full', 'v_full', 'xq', 'yq'}); % the full-size maps are large
result.roi = roi;
result.res = res;
result.vel = vel;
end

function s = complete_settings(given, defaults)
% the given settings, missing groups and fields from the defaults
s = defaults;
names = fieldnames(given);
for n = 1:numel(names)
    if ~isfield(defaults, names{n})
        error('stereo:run', 'Unknown stereo setting "%s".', names{n});
    end
    if isstruct(given.(names{n}))
        fields = fieldnames(given.(names{n}));
        for f = 1:numel(fields)
            if ~isfield(defaults.(names{n}), fields{f})
                error('stereo:run', 'Unknown stereo setting "%s.%s".', names{n}, fields{f});
            end
            s.(names{n}).(fields{f}) = given.(names{n}).(fields{f});
        end
    else
        s.(names{n}) = given.(names{n});
    end
end
end
