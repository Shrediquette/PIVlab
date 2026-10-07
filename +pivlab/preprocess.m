function imgs = preprocess(imgs, opts)
%PREPROCESS Choose the image pre-processing (contrast enhancement, background removal, ROI, mask).
%   imgs = pivlab.preprocess(imgs) uses PIVlab's default pre-processing:
%   CLAHE (contrast limited adaptive histogram equalization) and automatic intensity stretching.
%
%   The images are not filtered and stored here: the filters are applied to every image pair
%   during pivlab.analyze, exactly as in the PIVlab GUI. This keeps memory use low for long
%   image series. Use pivlab.getImage(imgs, k) to look at a pre-processed image.
%   Only a background image (Background="mean" or "min") is computed here, because it needs
%   all images of the series.
%
%   Name=value options (empty = value from Settings, or the PIVlab default)
%   CLAHE              true/false  contrast limited adaptive histogram equalization
%   CLAHESize          tile size in pixels (default 64)
%   Highpass           true/false  high-pass filter (removes low-frequency background)
%   HighpassSize       kernel size in pixels (default 15)
%   IntensityCapping   true/false  limit very bright spots
%   Wiener             true/false  Wiener2 denoising + low-pass
%   WienerSize         kernel size in pixels
%   AutoLimit          true/false  stretch the intensity of every image automatically
%   MinIntensity, MaxIntensity     fixed intensity limits (0...1), used when AutoLimit is false
%   Background         "none" | "mean" | "min"  subtract the mean or minimum intensity image
%   Roi                region of interest [x y width height] in pixels,
%                      "none" = whole image (also when Settings contain a region of interest)
%   Mask               logical image (true = masked, same mask for every pair), a cell array
%                      with one logical image per pair, or PIVlab mask objects (masks_in_frame),
%                      "none" = no mask
%   Camera             camera calibration (lens undistortion, optional rectification), like the
%                      camera calibration panels of the PIVlab GUI:
%                      - a camera calibration file saved in PIVlab ("Save camera parameters")
%                      - a PIVlab session: its camera calibration and rectification, as they were
%                        used in the session
%                      - a cameraParameters / cameraIntrinsics object (Computer Vision Toolbox)
%                      - "none": no undistortion
%                      Default: keep the camera calibration of imgs (none after readImages).
%                      The camera calibration itself is made in the PIVlab GUI (visual feedback).
%   CameraView         "valid" (cut away black borders, default), "same" (same size as the input
%                      image) or "full" (include black borders); default from the session
%   Rectification      true / false, or a 2-D transformation (e.g. projtform2d) from the undistorted
%                      to the rectified image. Default: as in the session, else none.
%   Verbose            true (default) / false: print progress messages
%   Settings           settings struct from pivlab.defaults or pivlab.loadSettings
%
%   With a camera calibration, all following steps (Roi, Mask, analysis, display) use the corrected
%   images; imgs.imageSize is the size of the corrected image.
%
%   Example
%       imgs = pivlab.readImages("Example_data/Jet_*.jpg", "pairwise");
%       imgs = pivlab.preprocess(imgs, Highpass=true, Background="min");
%       imgs = pivlab.preprocess(imgs, Camera="my_session.mat");   % undistortion + rectification
%
%   See also pivlab.readImages, pivlab.analyze, pivlab.getImage
arguments
    imgs (1,1) struct
    opts.CLAHE = []
    opts.CLAHESize = []
    opts.Highpass = []
    opts.HighpassSize = []
    opts.IntensityCapping = []
    opts.Wiener = []
    opts.WienerSize = []
    opts.AutoLimit = []
    opts.MinIntensity = []
    opts.MaxIntensity = []
    opts.Background = []
    opts.Roi = []
    opts.Mask = []
    opts.Camera = []
    opts.CameraView = []
    opts.Rectification = []
    opts.Verbose (1,1) logical = true
    opts.Settings struct = struct()
end
verbose = opts.Verbose;
camera = opts.Camera;
camera_view = opts.CameraView;
rectification = opts.Rectification;
opts = rmfield(opts, {'Verbose', 'Camera', 'CameraView', 'Rectification'});

% camera calibration first: region of interest and mask refer to the corrected image
if isempty(camera) && (~isempty(camera_view) || ~isempty(rectification))
    error('pivlab:preprocess:camera', 'CameraView and Rectification need the Camera option.');
end
if ~isempty(camera)
    imgs.cam = camera_from_source(camera, camera_view, rectification);
    first = import.read_frame(imgs, 1, imgs.cam, []);
    imgs.imageSize = [size(first,1) size(first,2)];
    if verbose && imgs.cam.use_calibration
        what = 'lens undistortion';
        if imgs.cam.use_rectification
            what = [what ' and rectification'];
        end
        fprintf('Camera calibration: %s (view "%s"), corrected image size %d x %d pixels.\n', ...
            what, imgs.cam.view, imgs.imageSize(2), imgs.imageSize(1));
    end
end

p = resolve_options('preprocess', opts);
% "none" switches a region of interest or a mask off (also one that came in through Settings)
if is_none(p.Roi)
    p.Roi = [];
end
if is_none(p.Mask)
    p.Mask = [];
end
p.Background = lower(string(p.Background));
if ~ismember(p.Background, ["none","mean","min"])
    error('pivlab:preprocess:background','Background must be "none", "mean" or "min".');
end
if ~isempty(p.Roi)
    p.Roi = round(double(p.Roi(:)'));
    sz = imgs.imageSize;
    if numel(p.Roi) ~= 4 || any(p.Roi(1:2) < 1) || p.Roi(1)+p.Roi(3) > sz(2) || p.Roi(2)+p.Roi(4) > sz(1)
        error('pivlab:preprocess:roi', ...
            'Roi must be [x y width height] inside the image (%d x %d pixels).', sz(2), sz(1));
    end
end
imgs.mask = check_mask(p.Mask, imgs);
p.Mask = [];
imgs.preprocess = p;

imgs.background = [];
if p.Background ~= "none"
    if imgs.sequencer == 2
        error('pivlab:preprocess:background', ...
            'Background removal is only available with "pairwise" and "timeresolved" sequencing.');
    end
    operation = 2;
    if p.Background == "min"
        operation = 3;
    end
    if verbose
        fprintf('Computing %s intensity background image from %d images...\n', p.Background, numel(imgs.filepath));
    end
    [A, B, msg] = preproc.compute_background(imgs, imgs.sequencer, operation, imgs.cam);
    if ~isempty(msg)
        error('pivlab:preprocess:background', '%s', msg);
    end
    imgs.background = struct('A', A, 'B', B, 'mode', p.Background);
end
end

function tf = is_none(value)
tf = (ischar(value) || isstring(value)) && strcmpi(value, "none");
end

function m = check_mask(m, imgs)
% returns {} (no mask), a logical image, or a cell with one entry per pair
if isempty(m)
    m = {};
    return
end
sz = imgs.imageSize;
if islogical(m) || isnumeric(m)
    if ~isequal(size(m,1,2), sz)
        error('pivlab:preprocess:mask','The mask must have the size of the images (%d x %d).', sz(1), sz(2));
    end
    m = logical(m);
elseif ~iscell(m)
    error('pivlab:preprocess:mask','Mask must be a logical image or a cell array (one entry per image pair).');
end
end
