function saveSession(res, file)
%SAVESESSION Save results as a PIVlab session that can be opened (and changed) in the PIVlab GUI.
%   pivlab.saveSession(res, file) writes the image list, the pre-processing / analysis / filter
%   settings, the calibration, the raw, validated and smoothed vector fields, the masks and the
%   region of interest of res into a PIVlab session file ("File -> Load session" in PIVlab).
%   The image files must still exist when the session is opened in the GUI.
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
end
file = char(file);
[folder, name, ext] = fileparts(file);
if isempty(ext), ext = '.mat'; end
if isempty(folder), folder = pwd; end
file = fullfile(folder, [name ext]);

V = settings_to_gui_vars(res.settings);
V.calxy = res.calibration.calxy; V.calu = res.calibration.calu; V.calv = res.calibration.calv;
V.offset_x_true = res.calibration.offset_x_true; V.offset_y_true = res.calibration.offset_y_true;
V.x_axis_direction = res.calibration.x_axis_direction; V.y_axis_direction = res.calibration.y_axis_direction;
V.realdist_string = num2str(res.calibration.realdist);
V.time_inp_string = num2str(res.calibration.time_inp);
V.pointscali = res.calibration.pointscali;
V.displacement_only = double(res.calibration.displacement_only);

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
[V.pathname, ~] = fileparts(filepath{1});
V.sessionpath = [folder filesep];

%% pre-processing, masks, region of interest
V.roirect = [];
if ~isempty(imgs.preprocess) && isfield(imgs.preprocess,'Roi')
    V.roirect = imgs.preprocess.Roi;
end
V.bg_img_A = []; V.bg_img_B = []; V.bg_mode = 1;
if ~isempty(imgs.background)
    V.bg_img_A = imgs.background.A;
    V.bg_img_B = imgs.background.B;
    V.bg_mode = 2 + double(imgs.background.mode == "min");
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
V.toggler = 0;
V.manualdeletion = [];
V.wasdisabled = zeros(0,1,'uint8');   % no saved enable state: PIVlab keeps its current one
V.PathName = [folder filesep];
V.FileName = [name ext];
save(file, '-struct', 'V', '-v7.3');
fprintf('Session saved: %s\n', file);
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
