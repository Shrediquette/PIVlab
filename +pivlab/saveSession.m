function saveSession(res, file, opts)
%SAVESESSION Save results as a PIVlab session that can be opened (and changed) in the PIVlab GUI.
%   pivlab.saveSession(res, file) writes the image list, the pre-processing / analysis / filter
%   settings, the calibration, the raw, validated and smoothed vector fields, the masks and the
%   region of interest of res into a PIVlab session file ("File -> Load session" in PIVlab).
%   The image files must still exist when the session is opened in the GUI.
%   The camera calibration (pivlab.preprocess, Camera option) is saved too, so the GUI shows and
%   analyses the corrected images.
%   Values you changed by hand in res.u / res.v are saved as the validated data.
%
%   Name=value options
%   Verbose   true (default) / false: print the file name
%
%   Example
%       res = pivlab.filter(pivlab.analyze(imgs));
%       pivlab.saveSession(res, "my_analysis.mat");
%       PIVlab_GUI   % then File -> Load session
%
%   See also pivlab.loadSession, pivlab.loadSettings
arguments
    res (1,1) struct
    file {mustBeTextScalar}
    opts.Verbose (1,1) logical = true
end
[res, edited] = take_user_edits(res);
if edited.filtered
    res.filtered = true;   % hand-edited values are stored as validated data (resultslist rows 7-9)
end
file = char(file);
[folder, name, ext] = fileparts(file);
if isempty(ext), ext = '.mat'; end
if isempty(folder), folder = pwd; end
file = fullfile(folder, [name ext]);

% settings (in the types of the GUI settings) and session data, see export.write_session_file
G = api_to_gui_settings(res.settings);
cal = res.calibration;
G.calibration.x_axis_direction = cal.x_axis_direction;
G.calibration.y_axis_direction = cal.y_axis_direction;
G.calibration.realdist = cal.realdist;
G.calibration.time_inp = cal.time_inp;
G.calibration_data.pointscali = cal.pointscali;
V = struct();
V.calxy = cal.calxy; V.calu = cal.calu; V.calv = cal.calv;
V.offset_x_true = cal.offset_x_true; V.offset_y_true = cal.offset_y_true;
V.pointscali = cal.pointscali;
V.displacement_only = double(cal.displacement_only);

imgs = res.images;
p = res.px;
n = size(p.u,3);

%% results
rl = cell(15, n);
for i = 1:n
    rl{1,i} = p.x;
    rl{2,i} = p.y;
    rl{3,i} = p.u_raw(:,:,i);
    rl{4,i} = p.v_raw(:,:,i);
    rl{5,i} = res.typevector_raw(:,:,i);
    if res.filtered
        rl{7,i} = p.u(:,:,i);
        rl{8,i} = p.v(:,:,i);
        rl{9,i} = res.typevector(:,:,i);
    end
    if res.smoothed && ~isempty(p.u_smoothed)
        rl{10,i} = p.u_smoothed(:,:,i);
        rl{11,i} = p.v_smoothed(:,:,i);
    end
    if ~all(isnan(res.correlation_map(:,:,i)),'all')
        rl{12,i} = res.correlation_map(:,:,i);
    end
    if ~isempty(p.u2)
        rl{13,i} = p.u2(:,:,i);
        rl{14,i} = p.v2(:,:,i);
    end
    if ~isempty(p.uncertainty)
        rl{15,i} = p.uncertainty(:,:,i);
    end
end
V.resultslist = rl;

%% image list: two entries per frame (A and B image)
filepath = cell(2*n,1); filename = cell(2*n,1);
framenum = ones(2*n,1); framepart = zeros(2*n,2);
for i = 1:n
    pr = res.pairs(min(i,numel(res.pairs)));
    for k = 0:1
        src = 2*pr-1+k;
        filepath{2*i-1+k} = imgs.filepath{src};
        framenum(2*i-1+k) = imgs.framenum(src);
        if ~isempty(imgs.framepart)
            framepart(2*i-1+k,:) = imgs.framepart(src,:);
        else
            framepart(2*i-1+k,:) = [1 imgs.imageSize(1)];
        end
        if res.isMean(i)
            filename{2*i-1+k} = char(res.frameLabels(i));
        else
            filename{2*i-1+k} = imgs.filename{src};
        end
    end
end
V.filepath = filepath;
V.filename = filename;
V.framenum = framenum;
V.framepart = framepart;
V.sequencer = imgs.sequencer;
V.multitiff = double(imgs.multitiff);
V.pcopanda_dbl_image = double(imgs.pcopanda_dbl_image);
V.ismean = double(res.isMean(:));
V.video_selection_done = 0;
V.expected_image_size = imgs.imageSize;
V.size_of_the_image = imgs.imageSize;

%% camera calibration (lens undistortion, rectification), as the GUI stores it
cam = imgs.cam;
V.cam_use_calibration = double(cam.use_calibration);
V.cam_use_rectification = double(cam.use_rectification);
V.cameraParams = cam.cameraParams;
V.rectification_tform = cam.rectification_tform;
V.cam_use_tilted_model = logical(cam.use_tilted_model);
V.cam_tilted_D = cam.tilted_D;
V.cam_K_opencv = cam.K_opencv;
G.calibration.calib_usecalibration = double(cam.use_calibration);
G.calibration.calib_userectification = double(cam.use_rectification);
G.calibration.calib_use_tilted_model = double(cam.use_tilted_model);
view_names = {'valid', 'same', 'full'};
G.calibration.calib_viewtype = find(strcmp(view_names, cam.view));

%% pre-processing, masks, region of interest
V.roirect = [];
if ~isempty(imgs.preprocess) && isfield(imgs.preprocess,'Roi')
    V.roirect = imgs.preprocess.Roi;
end
V.bg_img_A = []; V.bg_img_B = []; G.analysis.bg_subtract = 1;
if ~isempty(imgs.background)
    V.bg_img_A = imgs.background.A;
    V.bg_img_B = imgs.background.B;
    G.analysis.bg_subtract = 2 + double(imgs.background.mode == "min");
end
V.masks_in_frame = session_masks(res, n);
V.velrect = [];
lim = res.settings.filter.VelocityLimits;
if ~isempty(lim)
    V.velrect = [lim(1) lim(3) lim(2)-lim(1) lim(4)-lim(3)];
end

%% state of the GUI
V.derived = [];
V.displaywhat = 1;
V.subtr_u = 0; V.subtr_v = 0;
V.manualdeletion = [];
view = struct('panel', '', 'frame', 1, 'toggler', 0, 'xzoomlimit', [], 'yzoomlimit', [], 'ui_mode', '');
export.write_session_file(file, G, V, view);
if opts.Verbose
    fprintf('Session saved: %s\n', file);
end
end

function M = session_masks(res, n)
% PIVlab mask objects for every frame
M = cell(1, n);
imgs = res.images;
if ~isfield(imgs,'mask') || isempty(imgs.mask)
    M = [];
    return
end
colors = parula(7);
for i = 1:n
    if res.isMean(i) && isfield(res,'sourcePairs')
        pairs = res.sourcePairs{i};
    else
        pairs = res.pairs(min(i,numel(res.pairs)));
    end
    if islogical(imgs.mask) || isnumeric(imgs.mask)
        b = logical(imgs.mask);
    else
        if numel(pairs) == 1 && numel(imgs.mask) >= pairs && iscell(imgs.mask{pairs})
            M{i} = imgs.mask{pairs};      % PIVlab mask objects: keep them
            continue
        end
        b = [];
        for pr = pairs(:)'
            m = {};
            if numel(imgs.mask) >= pr, m = imgs.mask{pr}; end
            if isempty(m)
                bb = false(imgs.imageSize);
            elseif islogical(m) || isnumeric(m)
                bb = logical(m);
            else
                bb = logical(mask.convert_masks_to_binary(imgs.imageSize, m));
            end
            if isempty(b), b = bb; else, b = b & bb; end
        end
    end
    B = bwboundaries(b, 'noholes');
    rows = cell(numel(B), 5);
    for k = 1:numel(B)
        [~, guid] = fileparts(tempname);
        rows(k,:) = {'ROI_object_external', fliplr(B{k}), colors(mod(k-1,6)+1,:), '', guid};
    end
    M{i} = rows;
end
end
