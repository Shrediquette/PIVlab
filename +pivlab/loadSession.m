function [res, s] = loadSession(file)
%LOADSESSION Load the results of a PIVlab session file (saved in the GUI or with pivlab.saveSession).
%   [res, s] = pivlab.loadSession(file)
%   res  result struct like from pivlab.analyze / pivlab.filter, including the calibration,
%        the validated and (if present) smoothed data and the temporal statistics frames
%        (res.isMean). Use it with pivlab.derive, pivlab.temporal, pivlab.display, ...
%   s    the settings stored in the session (as pivlab.loadSettings returns them)
%   The camera calibration of the session (lens undistortion, rectification) is restored too
%   (res.images.cam), so images shown or read later are corrected like in the GUI.
%
%   Stereo-PIV session: res is a stereo result like from pivlab.stereo, with U, V, W (res.w) as in the GUI,
%   and res.stereo with the stereo calibration, the disparity correction and the 2D results and image sets
%   of both cameras, so the result can be validated again (pivlab.filter) or saved (pivlab.saveSession).
%
%   Example
%       res = pivlab.loadSession("PIVlab_session.mat");
%       m = pivlab.temporal(res, "mean");
%       pivlab.display(m, Overlay="magnitude");
%
%   See also pivlab.saveSession, pivlab.loadSettings, pivlab.stereo
arguments
    file {mustBeTextScalar}
end
file = char(file);
[session, message] = import.read_session_file(file);
if isempty(session)
    error('pivlab:loadSession:notSession','%s: %s', file, message);
end
s = gui_settings_to_api(session.settings, pivlab.defaults());
s = session_extras(s, session.data);
L = session.data;
stereo_session = isfield(L, 'stereomode') && isequal(L.stereomode, 1);
rl = L.resultslist;
if isempty(rl)
    error('pivlab:loadSession:empty','The session contains no analysis results.');
end
[p, tv_raw, tv, corr, has_smoothed, cols] = results_from_list(rl);
n = numel(cols);
imgs = image_set(L, s, file, ~stereo_session);

res = struct();
res.x = []; res.y = []; res.u = []; res.v = [];
res.typevector = tv;
res.u_raw = []; res.v_raw = [];
res.typevector_raw = tv_raw;
res.correlation_map = corr;
res.uncertainty = [];
res.units = "px/frame";
c = s.calibration;
for f = {'calu','calv','calxy','offset_x_true','offset_y_true'}
    if isfield(L, f{1}) && ~isempty(L.(f{1})), c.(f{1}) = double(L.(f{1})); end
end
if isfield(L,'displacement_only') && ~isempty(L.displacement_only)
    c.displacement_only = logical(L.displacement_only);
end
res.calibration = c;
res.filtered = any(~cellfun(@isempty, rl(7,cols)));
res.smoothed = has_smoothed;
res.derived = struct();
ismean = getf(L,'ismean',[]);
res.isMean = false(n,1);
if ~isempty(ismean)
    im = false(1,size(rl,2)); im(1:numel(ismean)) = ismean(:)' == 1;
    res.isMean = im(cols)';
end
labels = strings(n,1);
for i = 1:n
    k = 2*cols(i)-1;
    if k <= numel(imgs.filename)
        a = string(imgs.filename{k});
        labels(i) = a;
        if ~res.isMean(i) && k+1 <= numel(imgs.filename)
            labels(i) = erase(a,"A: ") + " & " + erase(string(imgs.filename{k+1}),"B: ");
        end
    end
end
res.frameLabels = labels;
res.pairs = cols;
res.px = p;
res.images = imgs;
res.settings = s;
res.session = string(file);
if stereo_session
    res = add_stereo(res, L, s, session.settings, rl, cols, file);
end
res = refresh_units(res);
end

function [p, tv_raw, tv, corr, has_smoothed, cols] = results_from_list(rl)
% velocity fields, vector types and correlation of a PIVlab result list (GUI rows 1-15)
if size(rl,1) < 15
    rl{15,end} = [];
end
cols = find(~cellfun(@isempty, rl(1,:)));
if isempty(cols)
    error('pivlab:loadSession:empty','The session contains no analysis results.');
end
n = numel(cols);
x = rl{1,cols(1)}; y = rl{2,cols(1)};
sz = size(x);
cls = class(rl{3,cols(1)});
blank = zeros([sz n], cls);
p = struct('x',x,'y',y,'u',blank,'v',blank,'u_raw',blank,'v_raw',blank,'u2',[],'v2',[], ...
    'u_smoothed',[],'v_smoothed',[],'uncertainty',[]);
tv_raw = zeros([sz n], 'like', rl{5,cols(1)});
tv = tv_raw;
for c = cols
    if ~isempty(rl{9,c})
        tv = zeros([sz n], 'like', rl{9,c});
        break
    end
end
corr = nan([sz n]);
has_smoothed = false;
for i = 1:n
    c = cols(i);
    p.u_raw(:,:,i) = rl{3,c}; p.v_raw(:,:,i) = rl{4,c};
    tv_raw(:,:,i) = rl{5,c};
    if ~isempty(rl{7,c})
        p.u(:,:,i) = rl{7,c}; p.v(:,:,i) = rl{8,c}; tv(:,:,i) = rl{9,c};
    else
        p.u(:,:,i) = rl{3,c}; p.v(:,:,i) = rl{4,c}; tv(:,:,i) = rl{5,c};
    end
    if ~isempty(rl{10,c})
        has_smoothed = true;
    end
    if ~isempty(rl{12,c}), corr(:,:,i) = rl{12,c}; end
    if ~isempty(rl{13,c})
        if isempty(p.u2), p.u2 = nan([sz n],'like',rl{13,c}); p.v2 = p.u2; end
        p.u2(:,:,i) = rl{13,c}; p.v2(:,:,i) = rl{14,c};
    end
    if ~isempty(rl{15,c})
        if isempty(p.uncertainty), p.uncertainty = nan([sz n],'like',rl{15,c}); end
        p.uncertainty(:,:,i) = rl{15,c};
    end
end
if has_smoothed
    p.u_smoothed = p.u; p.v_smoothed = p.v;
    for i = 1:n
        if ~isempty(rl{10,cols(i)})
            p.u_smoothed(:,:,i) = rl{10,cols(i)}; p.v_smoothed(:,:,i) = rl{11,cols(i)};
        end
    end
end
end

function imgs = image_set(L, s, file, with_camera)
% image set of the session data L (the image files may not exist on this computer). with_camera: the camera
% calibration (lens undistortion, rectification) of the session (2D); stereo-PIV: stereo.rectified_images
imgs = struct();
imgs.files = string(unique(L.filepath,'stable'));
seqnames = ["timeresolved","pairwise","reference"];
seq = 1;
if isfield(L,'sequencer') && ~isempty(L.sequencer), seq = L.sequencer; end
imgs.sequencing = seqnames(seq+1);
imgs.sequencer = seq;
imgs.multitiff = isfield(L,'multitiff') && isequal(L.multitiff,1);
imgs.pcopanda_dbl_image = isfield(L,'pcopanda_dbl_image') && isequal(double(L.pcopanda_dbl_image),1);
imgs.filepath = L.filepath;
imgs.framenum = getf(L,'framenum',ones(numel(L.filepath),1));
imgs.framepart = getf(L,'framepart',[]);
imgs.filename = getf(L,'filename',cellstr(L.filepath));
imgs.pairs = numel(L.filepath)/2;
imsize = getf(L,'expected_image_size',[]);
if isempty(imsize), imsize = getf(L,'size_of_the_image',[]); end
imgs.imageSize = imsize(1:min(2,end));
% camera calibration (lens undistortion, rectification) exactly as used in the session
imgs.cam = import.cam_settings();
if with_camera && isfield(L,'cam_use_calibration') && isequal(double(L.cam_use_calibration), 1) ...
        && isfield(L,'cameraParams') && ~isempty(L.cameraParams)
    imgs.cam = camera_from_source(file, [], []);
end
imgs.preprocess = s.preprocess;
imgs.background = [];
if ~isempty(getf(L,'bg_img_A',[]))
    imgs.background = struct('A',L.bg_img_A,'B',L.bg_img_B,'mode',s.preprocess.Background);
end
imgs.mask = getf(L,'masks_in_frame',{});
end

function res = add_stereo(res, L, s, G, rl, cols, file)
% stereo-PIV session: W (rows 16 / 17 of the result list), the 2D results and image sets of both cameras, the
% stereo calibration and the disparity correction (res.stereo, as pivlab.stereo gives it)
n = numel(cols);
sz = size(res.px.x);
w = nan([sz n]);
w_smoothed = [];
for i = 1:n
    if size(rl,1) >= 16 && ~isempty(rl{16,cols(i)})
        w(:,:,i) = rl{16,cols(i)};
    end
end
if res.smoothed
    w_smoothed = w;
    for i = 1:n
        if size(rl,1) >= 17 && ~isempty(rl{17,cols(i)})
            w_smoothed(:,:,i) = rl{17,cols(i)};
        end
    end
end
res.px.w = w;
res.px.w_raw = w;
res.px.w_smoothed = w_smoothed;
calib = L.stereo_calib;
disparity = getf(L,'stereo_disparity',[]);
active = getf(L,'stereo_active_camera',1);
state = getf(L,'stereo_cam_state',{struct(), struct()});
% data of each camera: the camera shown when the session was saved is in L, the other one in stereo_cam_state
cams = cell(1, 2);
images = cell(1, 2);
camera_lists = cell(1, 2);
boards = cell(1, 2);
for k = 1:2
    if k == active
        Lk = L;
    else
        Lk = state{k};
        Lk.sequencer = getf(L,'sequencer',1); % one sequencing style for both cameras
    end
    images{k} = image_set(Lk, s, file, false);
    camera_lists{k} = getf(Lk,'stereo_result',[]);
    boards{k} = getf(Lk,'cam_selected_rectification_image',[]);
end
images = stereo.rectified_images(images, calib, stereo.full_disparity(calib, disparity));
roi = getf(L,'roirect',[]);
for k = 1:2
    images{k}.preprocess.Roi = roi;
end
has_cameras = ~isempty(camera_lists{1}) && ~isempty(camera_lists{2});
if has_cameras
    for k = 1:2
        [cp, ctv_raw, ctv, ccorr, ~, ccols] = results_from_list(camera_lists{k});
        cp.u_smoothed = []; cp.v_smoothed = [];
        cam = struct();
        cam.x = []; cam.y = []; cam.u = []; cam.v = [];
        cam.typevector = ctv;
        cam.u_raw = []; cam.v_raw = [];
        cam.typevector_raw = ctv_raw;
        cam.correlation_map = ccorr;
        cam.uncertainty = [];
        cam.units = "px/frame";
        cam.calibration = res.calibration;
        cam.filtered = any(~cellfun(@isempty, camera_lists{k}(7,ccols)));
        cam.smoothed = false;
        cam.derived = struct();
        cam.frameLabels = strings(numel(ccols),1);
        cam.isMean = false(numel(ccols),1);
        cam.pairs = ccols;
        cam.px = cp;
        cam.images = images{k};
        cam.settings = s;
        cams{k} = refresh_units(cam);
    end
    res.filtered = cams{1}.filtered || cams{2}.filtered;
    % the GUI result list holds the validated U, V also in rows 3 / 4: the raw 3D result is made from the raw
    % camera results (pivlab.filter tests the velocity limits on it, as the GUI)
    raw = cell(1, 2);
    for k = 1:2
        raw{k} = struct('x', cams{k}.px.x, 'y', cams{k}.px.y, 'u', cams{k}.px.u_raw, 'v', cams{k}.px.v_raw, ...
            'typevector', cams{k}.typevector_raw, 'correlation', cams{k}.correlation_map);
    end
    st = stereo_settings(s);
    Cr = stereo.combine_cameras(raw{1}, raw{2}, calib, disparity, st.reconstruction);
    residual_raw = nan([sz n]);
    for i = 1:n
        j = find(cams{1}.pairs == cols(i), 1);
        if ~res.isMean(i) && ~isempty(j)
            res.px.u_raw(:,:,i) = Cr.U(:,:,j);
            res.px.v_raw(:,:,i) = Cr.V(:,:,j);
            res.px.w_raw(:,:,i) = Cr.W(:,:,j);
            res.typevector_raw(:,:,i) = Cr.typevector(:,:,j);
            residual_raw(:,:,i) = Cr.residual(:,:,j);
        end
    end
else
    st = stereo_settings(s);
    residual_raw = nan([sz n]);
end
stereo_vel = getf(L,'stereo_vel',[]);
residual = nan([sz n]);
sheet_z_mm = []; mm_per_px = [calib.Ravg.PixelExtentInWorldX, calib.Ravg.PixelExtentInWorldY]; x_mm = []; y_mm = [];
if ~isempty(stereo_vel)
    for i = 1:n
        if isfield(stereo_vel, 'residual') && cols(i) <= size(stereo_vel.residual, 3)
            residual(:,:,i) = stereo_vel.residual(:,:,cols(i));
        end
    end
    sheet_z_mm = stereo_vel.sheet_z_mm;
    mm_per_px = stereo_vel.mm_per_px;
    x_mm = stereo_vel.x_mm;
    y_mm = stereo_vel.y_mm;
end
res.images = images{1}; % camera 1, rectified and disparity-corrected (display, image size)
res.stereo = struct('calib', calib, 'disparity', disparity, 'cameras', {cams}, 'images', {images}, 'roi', roi, ...
    'settings', st, 'residual', residual, 'residual_raw', residual_raw, 'sheet_z_mm', sheet_z_mm, ...
    'mm_per_px', mm_per_px, 'x_mm', x_mm, 'y_mm', y_mm, 'board', board_of(G), 'boards', {boards});
end

function board = board_of(G)
% ChArUco board definition of the camera calibration panels (as stereo.board_from_gui)
C = struct();
if isfield(G, 'calibration')
    C = G.calibration;
end
defaults = gui.default_settings;
D = defaults.calibration;
names = {'calib_rows', 'calib_columns', 'calib_checkersize', 'calib_markersize', 'calib_origincolor'};
for k = 1:numel(names)
    if ~isfield(C, names{k}) || isempty(C.(names{k}))
        C.(names{k}) = D.(names{k});
    end
end
colours = ["black", "white"];
board.PatternDims = [double(C.calib_rows), double(C.calib_columns)];
board.CheckerSize = double(C.calib_checkersize);
board.MarkerSize = double(C.calib_markersize);
board.MarkerFamily = "DICT_4X4_1000";
board.OriginCheckerColor = colours(min(max(double(C.calib_origincolor), 1), 2));
end

function v = getf(S, name, default)
if isfield(S,name) && ~isempty(S.(name))
    v = S.(name);
else
    v = default;
end
end
