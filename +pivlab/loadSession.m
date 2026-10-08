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
%   Example
%       res = pivlab.loadSession("PIVlab_session.mat");
%       m = pivlab.temporal(res, "mean");
%       pivlab.display(m, Overlay="magnitude");
%
%   See also pivlab.saveSession, pivlab.loadSettings
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
rl = L.resultslist;
if isempty(rl)
    error('pivlab:loadSession:empty','The session contains no analysis results.');
end
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

% image set (the image files may not exist on this computer)
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
if isfield(L,'cam_use_calibration') && isequal(double(L.cam_use_calibration), 1) ...
        && isfield(L,'cameraParams') && ~isempty(L.cameraParams)
    imgs.cam = camera_from_source(file, [], []);
end
imgs.preprocess = s.preprocess;
imgs.background = [];
if ~isempty(getf(L,'bg_img_A',[]))
    imgs.background = struct('A',L.bg_img_A,'B',L.bg_img_B,'mode',s.preprocess.Background);
end
imgs.mask = getf(L,'masks_in_frame',{});

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
res = refresh_units(res);
end

function v = getf(S, name, default)
if isfield(S,name) && ~isempty(S.(name))
    v = S.(name);
else
    v = default;
end
end
