function out = combineCameras(imgs, boards, board, opts)
%COMBINECAMERAS Two cameras side by side combined into ONE larger image set (larger field of view, u and v).
%   out = pivlab.combineCameras(imgs, boards, board)
%   out = pivlab.combineCameras(imgs, boards, board, Name=Value)
%
%   imgs    1x2 cell, image sets of camera 1 and 2 with their lens calibration, as for pivlab.stereo:
%             imgs{k} = pivlab.preprocess(pivlab.readImages(files_k, "pairwise"), Camera=lens_file_k)
%           Both cameras must have the same number of images (recorded at the same time).
%   boards  1x2 cell, image (or image file) of ONE ChArUco board in the light sheet, taken by both cameras
%           at the same moment. The board reaches into both views; it does not have to fill them (best: one
%           large board over both views, at least about a third of each view).
%   board   ChArUco board: PatternDims, CheckerSize [mm], MarkerSize [mm], MarkerFamily, OriginCheckerColor
%
%   Name=value options
%   Calibration  stereo.defaults().calibration fields for experts (PixelSize, CornerFilter, ...)
%   Sheet        true (default): measure the light sheet position from the disparity in the overlap of both
%                cameras (fov.measure_sheet) and map both cameras onto the sheet, so the particle images match
%                at the seam; false: the board is taken as the sheet
%   Disparity    stereo.defaults().disparity fields for experts (Pairs, InterrogationArea, ...)
%   Verbose      true (default) / false: print the report (fov.report)
%
%   out is ONE normal 2D image set: every image is the combination of both cameras on the grid of the board
%   (lens undistortion and projective transform per camera, hard seam in the middle of the overlap, the part
%   no camera sees is 0). Use it like any image set: pivlab.preprocess (keeps the cameras; default mask = the
%   part no camera sees), pivlab.analyze, pivlab.filter, pivlab.toMetric (DeltaT is enough, the scale comes
%   from the calibration), pivlab.getImage, pivlab.display.
%   out.fov_calib   the calibration (stereo.calibrate); out.fov_report: the report lines
%   The combined image is aligned to the board: x along the board x axis, y along the board y axis.
%
%   Example
%       for k = 1:2
%           imgs{k} = pivlab.readImages(files{k}, "pairwise");
%           imgs{k} = pivlab.preprocess(imgs{k}, Camera=lens_files{k});
%       end
%       board = struct('PatternDims',[23 40],'CheckerSize',10,'MarkerSize',7, ...
%           'MarkerFamily',"DICT_4X4_1000",'OriginCheckerColor',"black");
%       imgs = pivlab.combineCameras(imgs, {"board_cam1.tif", "board_cam2.tif"}, board);
%       imgs = pivlab.preprocess(imgs, CLAHE=true);
%       res = pivlab.analyze(imgs);
%       res = pivlab.filter(res);
%       res = pivlab.toMetric(res, DeltaT=0.001);
%
%   See also pivlab.stereo, stereo.calibrate, fov.maps, fov.report
arguments
    imgs (1,2) cell
    boards (1,2) cell
    board (1,1) struct
    opts.Calibration struct = struct()
    opts.Sheet (1,1) logical = true
    opts.Disparity struct = struct()
    opts.Verbose (1,1) logical = true
end
if numel(imgs{1}.filepath) ~= numel(imgs{2}.filepath)
    error('pivlab:combineCameras:frames', 'Both cameras must have the same number of images (%d and %d).', ...
        numel(imgs{1}.filepath), numel(imgs{2}.filepath));
end
if imgs{1}.sequencer ~= imgs{2}.sequencer
    error('pivlab:combineCameras:sequencing', 'Both cameras must have the same sequencing.');
end
d = stereo.defaults();
d.calibration = merged(d.calibration, opts.Calibration, 'calibration');
d.disparity = merged(d.disparity, opts.Disparity, 'disparity');
cal = d.calibration;
cal.Use = "fov"; % explicit call: always the larger field of view
calib = stereo.calibrate({imgs{1}.cam, imgs{2}.cam}, boards, board, cal);
if opts.Sheet
    calib = fov.measure_sheet(imgs, calib, d, opts.Verbose);
end

F = fov.maps(calib);
F.src = import.frame_list(imgs{2});
out = imgs{1};
out.cam = import.cam_settings(fov=F);
out.imageSize = F.size;
out.preprocess = [];
out.background = [];
if isfield(out, 'mask')
    out.mask = {};
end
out.fov_calib = calib;
out.fov_report = fov.report(calib);
if opts.Verbose
    fprintf('Two cameras combined:\n');
    fprintf('  %s\n', out.fov_report{:});
end
end

function s = merged(s, given, group)
% expert settings: fields of stereo.defaults().(group), unknown names are an error
names = fieldnames(given);
for n = 1:numel(names)
    if ~isfield(s, names{n})
        error('pivlab:combineCameras:settings', 'Unknown %s setting "%s".', group, names{n});
    end
    s.(names{n}) = given.(names{n});
end
end
