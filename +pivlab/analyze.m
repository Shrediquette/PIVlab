function res = analyze(imgs, opts)
%ANALYZE Run the PIV analysis on all image pairs.
%   res = pivlab.analyze(imgs) analyzes the image set from pivlab.readImages /
%   pivlab.preprocess with PIVlab's default settings (multipass FFT window deformation,
%   64 px windows with 50 % overlap in the first pass, 32 px in the second pass).
%
%   Name=value options (empty = value from Settings, or the PIVlab default)
%   Algorithm               "fft"      multipass FFT window deformation (default)
%                           "ensemble" ensemble correlation (one result for all pairs)
%                           "dcc"      single pass direct cross-correlation
%                           "ofv"      wavelet-based optical flow
%   InterrogationArea       window size of the first pass in pixels
%   Step                    vector spacing of the first pass in pixels
%   Passes                  number of passes (1...4)
%   PassSizes               window sizes of pass 2, 3 and 4, e.g. [32 16 16]
%   SubpixelFinder          "gauss3point" or "gauss2d"
%   DisableAutocorrelation  true/false, suppress the auto-correlation peak (first pass)
%   Robustness              "standard", "high" or "extreme" (correlation robustness in PIVlab)
%   RepeatLastPass          true/false, repeat the last pass until the result converges
%   RepeatLastPassThreshold stop criterion for RepeatLastPass (default 0.025)
%   Uncertainty             true/false, compute the uncertainty map (fft only)
%   OFVSmoothness, OFVPyramidLevels, OFVMedianFilter   optical flow parameters
%   Parallel                true/false, use a parallel pool (Parallel Computing Toolbox, fft and dcc)
%   Pairs                   indices of the image pairs to analyze (default: all)
%   Verbose                 true (default) / false: print progress messages
%   Settings                settings struct from pivlab.defaults or pivlab.loadSettings
%
%   Not every option is used by every algorithm (e.g. Passes is not used by "dcc", Parallel not
%   by "ensemble"). A warning tells you when an option you set has no effect.
%
%   res is a struct with the results of all pairs (third dimension = pair):
%     res.x, res.y              vector positions in pixels (2-D, the same for all pairs)
%     res.u, res.v              displacements in pixels per image pair
%     res.typevector            1 = valid, 0 = masked (later: 2 = filtered/interpolated)
%     res.correlation_map       correlation coefficient of every vector
%     res.units                 "px/frame"
%   Pass res on to pivlab.filter, pivlab.toMetric, pivlab.derive, pivlab.display,
%   pivlab.saveSession.
%
%   Example
%       imgs = pivlab.preprocess(pivlab.readImages("Example_data/Jet_*.jpg","pairwise"));
%       res = pivlab.analyze(imgs, InterrogationArea=64, Passes=3, PassSizes=[32 16 16]);
%
%   See also pivlab.readImages, pivlab.preprocess, pivlab.filter
arguments
    imgs (1,1) struct
    opts.Algorithm = []
    opts.InterrogationArea = []
    opts.Step = []
    opts.Passes = []
    opts.PassSizes = []
    opts.SubpixelFinder = []
    opts.DisableAutocorrelation = []
    opts.Robustness = []
    opts.RepeatLastPass = []
    opts.RepeatLastPassThreshold = []
    opts.Uncertainty = []
    opts.OFVSmoothness = []
    opts.OFVPyramidLevels = []
    opts.OFVMedianFilter = []
    opts.Parallel = []
    opts.Pairs = []
    opts.Verbose (1,1) logical = true
    opts.Settings struct = struct()
end
pairs = opts.Pairs;
verbose = opts.Verbose;
opts = rmfield(opts, {'Pairs','Verbose'});
[ana, s] = resolve_options('analysis', opts);
if isempty(imgs.preprocess)
    imgs = pivlab.preprocess(imgs, Settings=s, Verbose=verbose);
end
s.preprocess = imgs.preprocess;
s.preprocess.Mask = [];
ana.Algorithm = lower(string(ana.Algorithm));
if ~ismember(ana.Algorithm, ["fft","ensemble","dcc","ofv"])
    error('pivlab:analyze:algorithm','Algorithm must be "fft", "ensemble", "dcc" or "ofv".');
end
warn_options_without_effect(opts, ana.Algorithm);
ana.PassSizes = [ana.PassSizes(:)' repmat(ana.PassSizes(end), 1, 3-numel(ana.PassSizes))];
k = kernel_settings(imgs.preprocess, ana);
if isempty(pairs)
    pairs = 1:imgs.pairs;
end
pairs = pairs(:)';
if any(pairs < 1 | pairs > imgs.pairs | pairs ~= round(pairs))
    error('pivlab:analyze:pairs','Pairs must be between 1 and %d.', imgs.pairs);
end

t0 = tic;
switch ana.Algorithm
    case {"fft","dcc"}
        R = run_pairs(imgs, pairs, k, logical(ana.Parallel), verbose);
    case "ensemble"
        R = run_ensemble(imgs, pairs, k, verbose);
    case "ofv"
        R = run_ofv(imgs, pairs, k, ana, verbose);
end
if verbose
    fprintf('PIV analysis (%s) of %d image pair(s) finished in %.1f s.\n', ana.Algorithm, numel(pairs), toc(t0));
end

res = new_result(R, imgs, s);
if ana.Algorithm == "ensemble"
    res.frameLabels = "Ensemble of pairs " + pairs(1) + "-" + pairs(end);
else
    res.frameLabels = pair_labels(imgs, pairs);
end
res.pairs = pairs;
end

%% ------------------------------------------------------------------
function warn_options_without_effect(opts, algorithm)
% Warn when the user sets an option that the chosen algorithm does not use.
% Column 2: the algorithms that use the option. Column 3: a value that does nothing anyway
% (no warning for it, e.g. Parallel=false).
rules = {
    'InterrogationArea',       ["fft","ensemble","dcc"], []
    'Step',                    ["fft","ensemble","dcc"], []
    'Passes',                  ["fft","ensemble"],       1
    'PassSizes',               ["fft","ensemble"],       []
    'SubpixelFinder',          ["fft","ensemble","dcc"], []
    'DisableAutocorrelation',  ["fft","ensemble"],       false
    'Robustness',              ["fft","ensemble"],       "standard"
    'RepeatLastPass',          "fft",                    false
    'RepeatLastPassThreshold', "fft",                    []
    'Uncertainty',             "fft",                    false
    'OFVSmoothness',           "ofv",                    []
    'OFVPyramidLevels',        "ofv",                    []
    'OFVMedianFilter',         "ofv",                    []
    'Parallel',                ["fft","dcc"],            false
    };
for k = 1:size(rules,1)
    name = rules{k,1};
    value = opts.(name);
    if isempty(value) || ismember(algorithm, rules{k,2})
        continue
    end
    harmless = rules{k,3};
    if isstring(harmless)
        if strcmpi(string(value), harmless)
            continue
        end
    elseif ~isempty(harmless) && (isnumeric(value) || islogical(value))
        if isequal(double(value), double(harmless))
            continue
        end
    end
    warning('pivlab:analyze:noEffect', '%s has no effect with Algorithm="%s".', name, algorithm);
end
end

function R = run_pairs(imgs, pairs, k, parallel, verbose)
n = numel(pairs);
R = cell(1,n);
cam = imgs.cam;
bg = imgs.background;
masks = cell(1,n);
for i = 1:n
    masks{i} = mask_of_pair(imgs, pairs(i));
end
if parallel
    misc.pivparpool('open');
    if verbose
        fprintf('Analyzing %d image pairs in parallel...\n', n);
    end
    src = struct('filepath',{imgs.filepath},'framenum',imgs.framenum,'framepart',imgs.framepart);
    parfor i = 1:n
        p = pairs(i);
        image1 = import.read_frame(src, 2*p-1, cam, bg); %#ok<PFBNS>
        image2 = import.read_frame(src, 2*p, cam, bg);
        R{i} = piv.analyze_pair(image1, image2, masks{i}, k);
    end
else
    report = unique(round(linspace(1,n,min(n,10))));
    for i = 1:n
        p = pairs(i);
        image1 = import.read_frame(imgs, 2*p-1, cam, bg);
        image2 = import.read_frame(imgs, 2*p, cam, bg);
        R{i} = piv.analyze_pair(image1, image2, masks{i}, k);
        if verbose && ismember(i, report)
            fprintf('  pair %d of %d done\n', i, n);
        end
    end
end
end

function R = run_ensemble(imgs, pairs, k, verbose)
sel = reshape([2*pairs-1; 2*pairs], [], 1);
converted_mask = cell(numel(pairs),1);
for i = 1:numel(pairs)
    m = mask_of_pair(imgs, pairs(i));
    if ~islogical(m)
        m = mask.convert_masks_to_binary(imgs.imageSize, m);
    end
    converted_mask{i} = m;
end
bgA = []; bgB = [];
if ~isempty(imgs.background)
    bgA = imgs.background.A; bgB = imgs.background.B;
end
[x, y, u, v, typevector, correlation_map] = piv.piv_FFTensemble( ...
    filepath=imgs.filepath(sel), interrogationarea=k.interrogationarea, ...
    autolimit=k.autolimit, framenum=imgs.framenum(sel), framepart=imgs.framepart(sel,:), ...
    video_frame_selection=[], bg_img_A=bgA, bg_img_B=bgB, ...
    clahe=k.clahe, highp=k.highp, intenscap=k.intenscap, ...
    clahesize=k.clahesize, highpsize=k.highpsize, ...
    wienerwurst=k.wienerwurst, wienerwurstsize=k.wienerwurstsize, ...
    roi_inpt=k.roirect, converted_mask=converted_mask, ...
    step=k.step, subpixfinder=k.subpixfinder, passes=k.passes, ...
    int2=k.int2, int3=k.int3, int4=k.int4, mask_auto=k.mask_auto, ...
    imdeform=k.imdeform, repeat=k.repeat, do_pad=k.do_pad, ...
    use_gui=false, cam=imgs.cam, verbose=verbose);
if verbose
    fprintf('\n'); % piv_FFTensemble prints one dot per image pair
end
R = {struct('x',x,'y',y,'u',u,'v',v,'typevector',typevector,'correlation_map',correlation_map, ...
    'u2',[],'v2',[],'umap',[])};
end

function R = run_ofv(imgs, pairs, k, ana, verbose)
addpath(genpath(fullfile(fileparts(fileparts(mfilename('fullpath'))),'OptimizationSolvers')));
eta = 10^(ana.OFVSmoothness*0.1 - 5);
PydLev = ana.OFVPyramidLevels;
medf = lower(string(ana.OFVMedianFilter));
if medf == "off"
    MedFiltFlag = false; MedFiltSize = [3,3];
else
    MedFiltFlag = true; sz = sscanf(medf,'%dx%d')'; MedFiltSize = sz;
end
roirect = k.roirect;
first = import.read_frame(imgs, 1, imgs.cam, imgs.background);
if isempty(roirect)
    roirect = [1,1,size(first,2)-1,size(first,1)-1];
end
tempImg = first(roirect(2):roirect(2)+roirect(4)-1,roirect(1):roirect(1)+roirect(3)-1);
PatchSize = 2^floor(log2(min(size(tempImg))));
Fmats = wOFV.getFmatPyramid(PatchSize,PydLev);
vartheta = ones(size(tempImg));
n = numel(pairs);
R = cell(1,n);
k.roirect = roirect;
for i = 1:n
    p = pairs(i);
    image1 = piv.prepare_image(import.read_frame(imgs, 2*p-1, imgs.cam, imgs.background), k);
    image2 = piv.prepare_image(import.read_frame(imgs, 2*p, imgs.cam, imgs.background), k);
    m = mask_of_pair(imgs, p);
    if ~islogical(m)
        m = mask.convert_masks_to_binary(size(image1(:,:,1)), m);
    end
    [x,y,u,v,typevector] = wOFV.RunMain_DatasetProc(image1,image2,m,roirect,eta,vartheta,MedFiltFlag,MedFiltSize,PydLev,Fmats,PatchSize);
    R{i} = struct('x',x,'y',y,'u',u,'v',v,'typevector',typevector,'correlation_map',zeros(size(x)), ...
        'u2',[],'v2',[],'umap',[]);
    if verbose
        fprintf('  pair %d of %d done\n', i, n);
    end
end
end

function m = mask_of_pair(imgs, p)
m = {};
if ~isfield(imgs,'mask') || isempty(imgs.mask)
    return
end
if islogical(imgs.mask)
    m = imgs.mask;
elseif iscell(imgs.mask) && numel(imgs.mask) >= p
    m = imgs.mask{p};
    if isnumeric(m) && ~isempty(m)
        m = logical(m);
    end
end
end

function labels = pair_labels(imgs, pairs)
labels = strings(numel(pairs),1);
for i = 1:numel(pairs)
    a = erase(string(imgs.filename{2*pairs(i)-1}), "A: ");
    b = erase(string(imgs.filename{2*pairs(i)}), "B: ");
    labels(i) = a + " & " + b;
end
end
