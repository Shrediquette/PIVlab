function api_vs_gui_more(basedir)
%API_VS_GUI_MORE Further GUI reference scenarios repeated through the pivlab.* API.
root = fileparts(fileparts(fileparts(mfilename('fullpath')))); % PIVlab folder of this repository
cd(root); addpath(root);
ok = true;
J = @(n) jet(root,n);
F = @(n) fuert(root,n);

%% time-resolved colour images (tr_fft_color)
B = load(fullfile(basedir,'tr_fft_color.mat'));
B.filepath = to_this_root(B.filepath, basedir, root);
imgs = pivlab.readImages(F(21), "timeresolved");
ok = check('tr filepath', imgs.filepath, B.filepath) && ok;
ok = check('tr framenum', imgs.framenum, B.framenum) && ok;
ok = check('tr framepart', imgs.framepart, B.framepart) && ok;
ok = check('tr filename', imgs.filename, B.filename) && ok;
res = pivlab.analyze(pivlab.preprocess(imgs), Passes=2, PassSizes=[32 32 32]);
ok = cmp_rl('tr raw', res, B.raw, 'raw') && ok;
res = pivlab.filter(res, StdevThreshold=7, LocalMedianThreshold=3);
ok = cmp_rl('tr validated', res, B.validated, 'filtered') && ok;
[~, mag] = pivlab.derive(res, "magnitude");
ok = check('tr magnitude frame 5', mag(:,:,5), B.derived{2,5}) && ok;

%% minimum background, time resolved (tr_bg_min)
B = load(fullfile(basedir,'tr_bg_min.mat'));
imgs = pivlab.preprocess(pivlab.readImages(F(8), "timeresolved"), Background="min");
ok = check('bg min A', imgs.background.A, B.bg_A) && ok;
ok = check('bg min B', imgs.background.B, B.bg_B) && ok;
res = pivlab.analyze(imgs, Passes=2, PassSizes=[32 32 32]);
ok = cmp_rl('bg min raw', res, B.raw, 'raw') && ok;
imgs = pivlab.readImages(J(4), "reference");
ok = check('reference filepath', imgs.filepath, to_this_root(B.ref_filepath, basedir, root)) && ok;

%% DCC (algo_dcc)
B = load(fullfile(basedir,'algo_dcc.mat'));
res = pivlab.analyze(pivlab.preprocess(pivlab.readImages(J(2), "pairwise")), Algorithm="dcc", Passes=1);
ok = cmp_rl('dcc raw', res, B.raw, 'raw') && ok;

%% ensemble (algo_ensemble)
B = load(fullfile(basedir,'algo_ensemble.mat'));
imgs = pivlab.preprocess(pivlab.readImages(J(4), "pairwise"), Roi=[20 20 300 220], Mask=masks());
res = pivlab.analyze(imgs, Algorithm="ensemble", Passes=2, PassSizes=[32 32 32]);
ok = check('ensemble u', res.px.u_raw, B.raw{3,1}) && ok;
ok = check('ensemble v', res.px.v_raw, B.raw{4,1}) && ok;
ok = check('ensemble typevector', res.typevector_raw, B.raw{5,1}) && ok;
ok = check('ensemble corr', res.correlation_map, B.raw{12,1}) && ok;
res = pivlab.filter(res, StdevThreshold=7, LocalMedianThreshold=3);
ok = check('ensemble validated u', res.px.u, B.validated{7,1}) && ok;

%% FFT variants on pair 1 (fft_variants)
B = load(fullfile(basedir,'fft_variants.mat'));
imgs = pivlab.preprocess(pivlab.readImages(J(1), "pairwise"));
base = {'Passes',3,'PassSizes',[32 16 16]};
V = {'corrq2',{'Robustness',"high"}; 'corrq3',{'Robustness',"extreme"}; 'subpix2',{'SubpixelFinder',"gauss2d"}; ...
     'maskauto',{'DisableAutocorrelation',true}; 'repeatlast',{'RepeatLastPass',true,'RepeatLastPassThreshold',0.025}; ...
     'uncertainty',{'Uncertainty',true}};
for k = 1:size(V,1)
    args = [base V{k,2}];
    res = pivlab.analyze(imgs, args{:});
    rl = B.(V{k,1}).rl;
    ok = check([V{k,1} ' u'], res.px.u_raw, rl{3}) && ok;
    ok = check([V{k,1} ' v'], res.px.v_raw, rl{4}) && ok;
    if ~isempty(rl{15})
        ok = check([V{k,1} ' uncertainty'], res.px.uncertainty, rl{15}) && ok;
    end
end

%% pre-processing variants (preproc_variants)
B = load(fullfile(basedir,'preproc_variants.mat'));
raw = pivlab.readImages(J(1), "pairwise");
P = {'clahe_off',{'CLAHE',false}; 'highpass',{'Highpass',true,'HighpassSize',20}; 'intenscap',{'IntensityCapping',true}; ...
     'wiener',{'Wiener',true,'WienerSize',5}; 'autolimit_off',{'AutoLimit',false,'MinIntensity',0.05,'MaxIntensity',0.8}; ...
     'all_on',{'Highpass',true,'IntensityCapping',true,'Wiener',true,'WienerSize',15}};
for k = 1:size(P,1)
    imgs = pivlab.preprocess(raw, P{k,2}{:});
    res = pivlab.analyze(imgs, Passes=2, PassSizes=[32 32 32]);
    rl = B.(P{k,1}).rl;
    ok = check([P{k,1} ' u'], res.px.u_raw, rl{3}) && ok;
end

%% validation variants (validation_variants), calibrated 10 mm / 100 px, 100 ms
B = load(fullfile(basedir,'validation_variants.mat'));
res0 = pivlab.analyze(pivlab.preprocess(pivlab.readImages(J(2), "pairwise")), Passes=2, PassSizes=[32 32 32]);
res0 = pivlab.toMetric(res0, ReferenceDistance=[100 0.01], DeltaT=0.1);
base = {'StdevThreshold',7,'LocalMedianThreshold',3};
W = {'default',{}; 'nostdev',{'StdevCheck',false}; 'nomedian',{'LocalMedian',false}; 'nointerp',{'Interpolate',false}; ...
     'velrect',{'VelocityLimits',[-0.002 0.002 -0.002 0.002]}; 'corrfilt',{'CorrelationFilter',true,'CorrelationThreshold',0.6}; ...
     'notch',{'NotchFilter',true,'NotchLimits',[-0.001 0.001]}; 'contrast',{'ContrastFilter',true,'ContrastThreshold',0.003}; ...
     'bright',{'BrightnessFilter',true,'BrightnessThreshold',0.003}};
for k = 1:size(W,1)
    args = [base W{k,2}];
    res = pivlab.filter(res0, args{:});
    G = B.(W{k,1});
    for f = 1:2
        ok = check(sprintf('%s u %d',W{k,1},f), res.px.u(:,:,f), G{1,f}) && ok;
        ok = check(sprintf('%s typevector %d',W{k,1},f), res.typevector(:,:,f), G{3,f}) && ok;
    end
end

%% calibration variants (calibration_variants)
B = load(fullfile(basedir,'calibration_variants.mat'));
res0 = pivlab.analyze(pivlab.preprocess(pivlab.readImages(J(1), "pairwise")), Passes=2, PassSizes=[32 32 32]);
res0 = pivlab.filter(res0, StdevThreshold=7, LocalMedianThreshold=3);
C = {'normal',0.1,"right","down"; 'xflip',0.1,"left","down"; 'yflip',0.1,"right","up"; 'bothflip',0.1,"left","up"; 'disponly',0,"right","down"};
names = ["vorticity","magnitude","u","v","divergence"];
idx = [2 3 4 5 6];
for k = 1:size(C,1)
    res = pivlab.toMetric(res0, ReferenceDistance=[100 0.01], DeltaT=C{k,2}, XAxis=C{k,3}, YAxis=C{k,4});
    G = B.(C{k,1});
    ok = check([C{k,1} ' calu'], res.calibration.calu, G.cal.calu) && ok;
    ok = check([C{k,1} ' calv'], res.calibration.calv, G.cal.calv) && ok;
    for j = 1:numel(names)
        [~, mp] = pivlab.derive(res, names(j));
        ok = check(sprintf('%s %s', C{k,1}, names(j)), mp(:,:,1), G.(sprintf('d%d',idx(j))){idx(j)-1,1}) && ok;
    end
    [~, dirmap] = pivlab.derive(res, "direction");
    ok = check([C{k,1} ' direction'], dirmap(:,:,1), G.d11{10,1}) && ok;
end

%% session and settings written by the GUI (session_settings_roundtrip)
B = load(fullfile(basedir,'session_settings_roundtrip.mat'));
sdir = fullfile(basedir,'session');
if isempty(import.read_session_file(fullfile(sdir,'session.mat')))
    % the reference is older than the PIVlab 4 file format, its files cannot be read anymore
    fprintf('API_SKIP session and settings files: saved in the format of PIVlab 3.x\n');
else
    [s, t] = pivlab.loadSettings(fullfile(sdir,'settings.mat'));
    ok = check('settings file type', t, 'settings') && ok;
    ok = check('settings passes', s.analysis.Passes, 3) && ok;
    ok = check('settings pass sizes', s.analysis.PassSizes(1:2), [32 16]) && ok;
    ok = check('settings stdev', s.filter.StdevThreshold, 7) && ok;
    [s, t] = pivlab.loadSettings(fullfile(sdir,'session.mat'));
    ok = check('session file type', t, 'session') && ok;
    ok = check('session roi', s.preprocess.Roi, B.appdata_before.roirect) && ok;
    ok = check('session background', s.preprocess.Background, "mean") && ok;
    r = pivlab.loadSession(fullfile(sdir,'session.mat'));
    rl = B.appdata_before.resultslist;
    ok = check('loadSession u raw', r.px.u_raw(:,:,2), rl{3,2}) && ok;
    ok = check('loadSession u filtered', r.px.u(:,:,2), rl{7,2}) && ok;
    ok = check('loadSession calu', r.calibration.calu, B.appdata_before.calu) && ok;
    ok = check('loadSession units', r.units, "m/s") && ok;
    % re-analyse the session images with the session settings -> same raw result
    imgs = pivlab.preprocess(pivlab.readImages(J(2), "pairwise"), Settings=s, Mask=masks());
    res = pivlab.analyze(imgs, Settings=s);
    ok = check('settings from session -> same analysis', res.px.u_raw(:,:,1), rl{3,1}) && ok;
end

if ok
    fprintf('API_VS_GUI_MORE: ALL IDENTICAL\n');
else
    fprintf('API_VS_GUI_MORE: DIFFERENCES FOUND\n');
end
end

function ok = cmp_rl(name, res, rl, which)
ok = true;
n = size(res.px.u,3);
if n ~= size(rl,2)
    fprintf('  DIFF  %s: %d vs %d frames\n', name, n, size(rl,2)); ok = false; return
end
for k = 1:n
    if strcmp(which,'raw')
        a = isequaln(res.px.u_raw(:,:,k), rl{3,k}) && isequaln(res.px.v_raw(:,:,k), rl{4,k}) && isequaln(res.typevector_raw(:,:,k), rl{5,k}) ...
            && isequaln(res.correlation_map(:,:,k), rl{12,k});
    else
        a = isequaln(res.px.u(:,:,k), rl{7,k}) && isequaln(res.px.v(:,:,k), rl{8,k}) && isequaln(res.typevector(:,:,k), rl{9,k});
    end
    if ~a
        fprintf('  DIFF  %s frame %d\n', name, k); ok = false;
    end
end
if ok, fprintf('  same  %s (%d frames)\n', name, n); end
end

function ok = check(name, a, b)
ok = isequaln(a, b);
if ok
    fprintf('  same  %s\n', name);
elseif isnumeric(a) && isnumeric(b) && isequal(size(a),size(b))
    d = abs(double(a(:))-double(b(:))); d(isnan(d)) = inf;
    fprintf('  DIFF  %s: %d of %d differ, max %g (class %s / %s)\n', name, nnz(d>0), numel(a), max(d), class(a), class(b));
else
    fprintf('  DIFF  %s: size %s / %s, class %s / %s\n', name, mat2str(size(a)), mat2str(size(b)), class(a), class(b));
end
end

function m = masks()
rng(1);
m = cell(1,3);
m{1} = {'ROI_object_rectangle',[25+randi(8) 25+randi(8) 40 35]};
m{2} = {'ROI_object_polygon',[120 90;155 95;150 130;115 125]};
m{3} = cell(0);
end

function p = jet(root,n)
p = cell(2*n,1);
for i = 1:n
    p{2*i-1} = fullfile(root,'Example_data',sprintf('Jet_%04dA.jpg',i));
    p{2*i}   = fullfile(root,'Example_data',sprintf('Jet_%04dB.jpg',i));
end
end

function p = fuert(root,n)
p = cell(n,1);
for i = 1:n, p{i} = fullfile(root,'Example_data',sprintf('Fuerteventura_%06d.jpeg',i-1)); end
end


function p = to_this_root(p, basedir, root)
% file paths of a reference run made in another PIVlab folder (e.g. a git worktree)
f = fullfile(basedir,'root.txt');
if isfile(f)
    p = strrep(p, strtrim(fileread(f)), root);
end
end
