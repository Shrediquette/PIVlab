function parity_run(outdir, scenarios, root)
%PARITY_RUN Drive the PIVlab GUI through many scenarios and store every output.
%   parity_run(outdir)                    all scenarios, PIVlab of this repository
%   parity_run(outdir, scenarios)         cellstr of scenario names or 'all'
%   parity_run(outdir, scenarios, root)   PIVlab folder to test (e.g. a git worktree of HEAD)
% Each scenario saves <name>.mat (numbers, appdata, control snapshots, graphics data)
% and PNGs of the PIVlab window. parity_compare(dirA,dirB) compares two runs.
% Run it in a fresh MATLAB (e.g. matlab -batch), see parity_check and README.md.
here = fileparts(mfilename('fullpath'));
if nargin < 3 || isempty(root)
    root = fileparts(fileparts(here));
end
if nargin < 2 || isempty(scenarios), scenarios = 'all'; end
if ~exist(outdir,'dir'), mkdir(outdir); end
% PIVlab writes into these files / folders / preferences while it runs: restore them afterwards
settings_file = fullfile(root,'PIVlab_settings_default.mat'); % PIVlab 3.x
settings_backup = '';
if isfile(settings_file)
    settings_backup = [tempname '.mat'];
    copyfile(settings_file, settings_backup);
end
prefs = struct(); % preferences of PIVlab 4 (gui.set_preference): start without them
if ispref('PIVlab')
    prefs = getpref('PIVlab');
    rmpref('PIVlab');
end
% same colour theme for every version (PIVlab 3.x: group PIVlab_ad), so screenshots can be compared
dark_3x = [];
if ispref('PIVlab_ad','dark_mode_theme'), dark_3x = getpref('PIVlab_ad','dark_mode_theme'); end
setpref('PIVlab','dark_mode_theme',1);
setpref('PIVlab_ad','dark_mode_theme',1);
lic_mex = fullfile(root,'+plot',['fastLICFunction.' mexext]);
had_mex = isfile(lic_mex);
fmats = fullfile(root,'+wOFV','Filter matrices');
had_fmats = isfolder(fmats);
cleanup = onCleanup(@() restore(settings_backup, settings_file, prefs, dark_3x, lic_mex, had_mex, fmats, had_fmats));
cd(root); addpath(root); addpath(fullfile(here,'mocks'),'-begin');
setappdata(0,'PIVlabTestMode',true);
warning('off','all');
all_sc = {'pair_fft_full','pair_fft_parallel','tr_fft_color','tr_bg_min','algo_dcc','algo_ensemble','algo_ofv', ...
    'fft_variants','preproc_variants','validation_variants','calibration_variants','display_variants', ...
    'session_settings_roundtrip','video_import','camera_undistortion','multitiff'};
if ischar(scenarios) && strcmp(scenarios,'all'), scenarios = all_sc; end
logf = fopen(fullfile(outdir,'log.txt'),'a');
fid = fopen(fullfile(outdir,'root.txt'),'w'); fprintf(fid,'%s',root); fclose(fid); % lets parity_compare ignore the folder
for k = 1:numel(scenarios)
    name = scenarios{k};
    S = struct(); t0 = tic;
    try
        S = feval(['sc_' name], outdir, root);
        status = 'OK';
    catch err
        status = ['ERROR: ' err.message ' @ ' err.stack(1).name ':' num2str(err.stack(1).line)];
        S.error = status;
    end
    S.runtime = toc(t0);
    save(fullfile(outdir,[name '.mat']),'-struct','S');
    msg = sprintf('SCENARIO %s %s (%.1f s)\n', name, status, S.runtime);
    fprintf('%s', msg); fprintf(logf,'%s',msg);
    close_pivlab();
end
fclose(logf);
rmpath(fullfile(here,'mocks'));
end

function restore(settings_backup, settings_file, prefs, dark_3x, lic_mex, had_mex, fmats, had_fmats)
try, close_pivlab(); catch, end
if ~isempty(settings_backup)
    copyfile(settings_backup, settings_file);
    delete(settings_backup);
end
if ispref('PIVlab'), rmpref('PIVlab'); end
f = fieldnames(prefs);
for k = 1:numel(f), setpref('PIVlab', f{k}, prefs.(f{k})); end
if isempty(dark_3x)
    if ispref('PIVlab_ad','dark_mode_theme'), rmpref('PIVlab_ad','dark_mode_theme'); end
else
    setpref('PIVlab_ad','dark_mode_theme',dark_3x);
end
if ~had_mex && isfile(lic_mex)
    clear('mex');
    try, delete(lic_mex); catch, end
end
if ~had_fmats && isfolder(fmats)
    try, rmdir(fmats,'s'); catch, end
end
end

%% ===================== scenarios =====================
function S = sc_pair_fft_full(outdir, root)
start_pivlab(1);
load_images(jet_paths(root,3), 1);
set_roi_masks();
background(2);
configure_piv(1,'fourPass');
S.t_analyze = analyze();
S.raw = gui.retr('resultslist');
S.bg_A = gui.retr('bg_img_A'); S.bg_B = gui.retr('bg_img_B');
calibration(10, 100, 1, 1);
S.cal = cal_snapshot();
validation(struct());
S.validated = gui.retr('resultslist');
% all derived parameters, no smoothing
h = hand();
set(h.smooth_mode,'Value',1); plot.smooth_mode_Callback(h.smooth_mode);
for d = 2:13
    rng(0);
    derive_all(d);
    S.png.(sprintf('deriv%02d',d)) = shot(outdir, sprintf('pair_fft_full_deriv%02d',d));
    S.ax.(sprintf('deriv%02d',d)) = axis_snapshot();
end
S.derived_nosmooth = gui.retr('derived');
% 2D smoothing
set(h.smooth_mode,'Value',2); set(h.smooth_param,'String','0.3'); plot.smooth_mode_Callback(h.smooth_mode);
derive_all(2);
S.derived_smooth2d = gui.retr('derived'); S.rl_smooth2d = gui.retr('resultslist');
% 2D + temporal smoothing
set(h.smooth_mode,'Value',4); set(h.temporal_window,'String','3'); plot.smooth_mode_Callback(h.smooth_mode);
derive_all(3);
S.derived_smooth2dt = gui.retr('derived'); S.rl_smooth2dt = gui.retr('resultslist');
set(h.smooth_mode,'Value',1); plot.smooth_mode_Callback(h.smooth_mode);
% temporal operations: mean, sum, stdev, tke (append)
ops = [1 0 2 3];
for o = ops
    set(h.selectedFramesMean,'String','1:3'); set(h.append_replace,'Value',1);
    plot.temporal_operation_Callback([],[],o); drawnow;
end
set(h.selectedFramesMean,'String','[1;2:3]'); set(h.append_replace,'Value',1);
plot.temporal_operation_Callback([],[],1); drawnow;
S.temporal_rl = gui.retr('resultslist'); S.temporal_filename = gui.retr('filename');
S.temporal_masks = gui.retr('masks_in_frame'); S.temporal_ismean = gui.retr('ismean');
for d = [2 3 4]
    derive_all(d);
    for fr = 4:size(gui.retr('resultslist'),2)
        select_frame(fr);
        S.ax.(sprintf('temporal_f%d_d%d',fr,d)) = axis_snapshot();
    end
end
S.derived_temporal = gui.retr('derived');
S.png.temporal_mean_mag = shot(outdir,'pair_fft_full_temporal');
% exports
expdir = fullfile(outdir,'pair_fft_full_exports'); if ~exist(expdir,'dir'), mkdir(expdir); end
set(h.export_mat_derivatives,'Value',0);
export.mat_file_save(1,'export_frame1.mat',expdir,1);
export.mat_file_save(1,'export_all.mat',expdir,2);
set(h.export_mat_derivatives,'Value',1);
export.mat_file_save(1,'export_all_deriv.mat',expdir,2);
for ty = [1 3 4]
    try
        export.file_save(1,sprintf('export_type%d',ty),expdir,ty);
    catch err
        S.(sprintf('file_save_err%d',ty)) = err.message;
    end
end
S.exports = read_folder(expdir);
S.appdata = appdata_snapshot();
S.controls = control_snapshot();
end

function S = sc_pair_fft_parallel(outdir, root)
start_pivlab(2);
S.parallel = gui.retr('parallel');
load_images(jet_paths(root,3), 1);
set_roi_masks();
background(2);
configure_piv(1,'fourPass');
S.t_analyze = analyze();
S.raw = gui.retr('resultslist');
validation(struct());
S.validated = gui.retr('resultslist');
% bigger timing case: 10 pairs default settings
load_images(jet_paths(root,10), 1);
configure_piv(1,'twoPass');
S.t_analyze10 = analyze();
S.raw10 = gui.retr('resultslist');
validation(struct());
S.validated10 = gui.retr('resultslist');
end

function S = sc_tr_fft_color(outdir, root)
start_pivlab(1);
load_images(fuert_paths(root,21), 0);
S.filepath = gui.retr('filepath'); S.filename = gui.retr('filename');
S.framenum = gui.retr('framenum'); S.framepart = gui.retr('framepart');
configure_piv(1,'twoPass');
S.t_analyze = analyze();
S.raw = gui.retr('resultslist');
validation(struct());
S.validated = gui.retr('resultslist');
derive_all(3);
S.derived = gui.retr('derived');
select_frame(5);
S.ax_f5 = axis_snapshot(); S.png = shot(outdir,'tr_fft_color_f5');
end

function S = sc_tr_bg_min(outdir, root)
start_pivlab(1);
load_images(fuert_paths(root,8), 0);
background(3);
S.bg_A = gui.retr('bg_img_A'); S.bg_B = gui.retr('bg_img_B');
configure_piv(1,'twoPass');
S.t_analyze = analyze();
S.raw = gui.retr('resultslist');
% pairwise background mean on Jet + reference sequencing file list
load_images(jet_paths(root,4), 2);
S.ref_filepath = gui.retr('filepath'); S.ref_framenum = gui.retr('framenum');
end

function S = sc_algo_dcc(outdir, root)
start_pivlab(1);
load_images(jet_paths(root,2), 1);
configure_piv(3,'singlePass');
S.t_analyze = analyze();
S.raw = gui.retr('resultslist');
end

function S = sc_algo_ensemble(outdir, root)
start_pivlab(1);
load_images(jet_paths(root,4), 1);
set_roi_masks();
configure_piv(2,'twoPass');
S.t_analyze = analyze();
S.raw = gui.retr('resultslist');
validation(struct());
S.validated = gui.retr('resultslist');
end

function S = sc_algo_ofv(outdir, root)
start_pivlab(1);
load_images(jet_paths(root,1), 1);
configure_piv(4,'singlePass');
S.t_analyze = analyze();
S.raw = gui.retr('resultslist');
end

function S = sc_fft_variants(outdir, root)
start_pivlab(1);
load_images(jet_paths(root,1), 1);
h = hand();
variants = {
    'corrq2',      @() set_popup(h.correlation_robustness,2,@piv.CorrQuality)
    'corrq3',      @() set_popup(h.correlation_robustness,3,@piv.CorrQuality)
    'subpix2',     @() set(h.subpixel_estimator,'Value',2)
    'maskauto',    @() set(h.disable_autocorrelation,'Value',1)
    'repeatlast',  @() set_repeat_last(h)
    'uncertainty', @() set(h.uncertainty_enable,'Value',1)
    };
for k = 1:size(variants,1)
    configure_piv(1,'threePass');
    set(h.correlation_robustness,'Value',1);
    variants{k,2}();
    S.(variants{k,1}).t = analyze();
    rl = gui.retr('resultslist');
    S.(variants{k,1}).rl = rl(:,1);
    reset_variant(h);
end
end

function S = sc_preproc_variants(outdir, root)
start_pivlab(1);
load_images(jet_paths(root,1), 1);
h = hand();
variants = {'clahe_off','highpass','intenscap','wiener','autolimit_off','all_on'};
for k = 1:numel(variants)
    set(h.clahe_enable,'Value',1); set(h.clahe_size,'String','64');
    set(h.highpass_enable,'Value',0); set(h.highpass_size,'String','15');
    set(h.intenscap_enable,'Value',0);
    set(h.wiener_enable,'Value',0); set(h.wiener_size,'String','15');
    set(h.autolimit_enable,'Value',1);
    switch variants{k}
        case 'clahe_off', set(h.clahe_enable,'Value',0);
        case 'highpass', set(h.highpass_enable,'Value',1); set(h.highpass_size,'String','20');
        case 'intenscap', set(h.intenscap_enable,'Value',1);
        case 'wiener', set(h.wiener_enable,'Value',1); set(h.wiener_size,'String','5');
        case 'autolimit_off', set(h.autolimit_enable,'Value',0); set(h.minintens,'String','0.05'); set(h.maxintens,'String','0.8');
        case 'all_on', set(h.highpass_enable,'Value',1); set(h.intenscap_enable,'Value',1); set(h.wiener_enable,'Value',1);
    end
    configure_piv(1,'twoPass');
    S.(variants{k}).t = analyze();
    rl = gui.retr('resultslist');
    S.(variants{k}).rl = rl(:,1);
end
% preview image of the preprocessing (what the GUI shows)
gui.quick3_Callback([],[]);
try
    preproc.preview_preprocess_Callback([],[],[]); drawnow;
    S.ax_preview = axis_snapshot();
catch err
    S.preview_err = err.message;
end
end

function S = sc_validation_variants(outdir, root)
start_pivlab(1);
load_images(jet_paths(root,2), 1);
configure_piv(1,'twoPass');
analyze();
S.raw = gui.retr('resultslist');
calibration(10, 100, 1, 1);
vars = {
    'default',   struct()
    'nostdev',   struct('stdev_enable',0)
    'nomedian',  struct('loc_median_enable',0)
    'nointerp',  struct('interpol_missing',0)
    'velrect',   struct('velrect',[-0.002 -0.002 0.004 0.004])
    'corrfilt',  struct('corr_filter_enable',1,'corr_filter_thresh','0.6')
    'notch',     struct('notch_enable',1,'notch_L_thresh','-0.001','notch_H_thresh','0.001')
    'contrast',  struct('contrast_filter_enable',1,'contrast_filter_thresh','0.003')
    'bright',    struct('bright_filter_enable',1,'bright_filter_thresh','0.003')
    };
for k = 1:size(vars,1)
    validation(vars{k,2});
    rl = gui.retr('resultslist');
    S.(vars{k,1}) = rl(7:9,:);
    S.([vars{k,1} '_disc']) = get_string_safe('discarded');
end
end

function S = sc_calibration_variants(outdir, root)
start_pivlab(1);
load_images(jet_paths(root,1), 1);
configure_piv(1,'twoPass');
analyze();
validation(struct());
h = hand();
cases = {
    'normal',   10, 100, 1, 1
    'xflip',    10, 100, 2, 1
    'yflip',    10, 100, 1, 2
    'bothflip', 10, 100, 2, 2
    'disponly', 10,   0, 1, 1
    };
for k = 1:size(cases,1)
    calibration(cases{k,2}, cases{k,3}, cases{k,4}, cases{k,5});
    c = cases{k,1};
    S.(c).cal = cal_snapshot();
    for d = [2 3 4 5 6 11]
        derive_all(d);
        S.(c).(sprintf('d%d',d)) = gui.retr('derived');
    end
    derive_all(2);
    S.(c).ax = axis_snapshot();
    S.(c).derivchoice = get(h.derivchoice,'String');
    expdir = fullfile(outdir,['calib_' c]); if ~exist(expdir,'dir'), mkdir(expdir); end
    export.mat_file_save(1,'exp.mat',expdir,1);
    try, export.file_save(1,'exp',expdir,1); catch, end
    try, export.file_save(1,'exp',expdir,4); catch, end
    S.(c).exports = read_folder(expdir);
end
% offsets
calibration(10, 100, 1, 1);
gui.put('points_offsetx',[100 100 5]); gui.put('points_offsety',[100 200 3]);
try
    calibrate.apply_cali_Callback([],[],[]);
catch
end
S.offset.cal = cal_snapshot();
expdir = fullfile(outdir,'calib_offset'); if ~exist(expdir,'dir'), mkdir(expdir); end
export.mat_file_save(1,'exp.mat',expdir,1);
S.offset.exports = read_folder(expdir);
end

function S = sc_display_variants(outdir, root)
start_pivlab(1);
load_images(jet_paths(root,2), 1);
set_roi_masks();
configure_piv(1,'twoPass');
analyze();
validation(struct());
derive_all(2);
h = hand();
base = control_snapshot();
V = {
    'default',        {}
    'cmap_hsv',       {'colormap_choice',2}
    'cmap_hsb',       {'colormap_choice',4}
    'cmap_gray',      {'colormap_choice',11}
    'cmap_plasma',    {'colormap_choice',16}
    'cmap_steps',     {'colormap_steps',5}
    'opacity50',      {'colormapopacity','50'}
    'cbar_none',      {'colorbarpos',1}
    'cbar_south',     {'colorbarpos',2}
    'cbar_north',     {'colorbarpos',3}
    'cbar_west',      {'colorbarpos',5}
    'cbar_fmt2',      {'colorbarnumberformat',2}
    'cbar_fmt3',      {'colorbarnumberformat',3}
    'bg_black',       {'displ_image',2}
    'bg_white',       {'displ_image',3}
    'enhance',        {'enhance_images',1}
    'manual_scale',   {'autoscaler',0,'mapscale_min','-0.5','mapscale_max','0.5'}
    'nth2',           {'nthvect','2'}
    'manual_vecscale',{'autoscale_vec',0,'vectorscale','5'}
    'vecwidth',       {'vecwidth','2'}
    'uniform',        {'uniform_vector_scale',1}
    'power',          {'power_vector_scale',1,'power_vector_scale_factor','0.5'}
    'derivcolor',     {'deriv_color',3}
    'refvec',         {'ref_vect_pos',2}
    'masktransp',     {'masktransp','50'}
    'maskpreview',    {'mask_edit_mode',2}
    'highp_vectors',  {'highp_vectors',1}
    };
for k = 1:size(V,1)
    restore_controls(base);
    args = V{k,2};
    for a = 1:2:numel(args)
        set_control(h.(args{a}), args{a+1});
    end
    gui.sliderdisp(gui.retr('pivlab_axis')); drawnow;
    S.ax.(V{k,1}) = axis_snapshot();
    S.png.(V{k,1}) = shot(outdir, ['display_' V{k,1}]);
end
% vectors only (displaywhat 1) with several valid colours incl. magnitude
restore_controls(base);
derive_all(1);
ncol = numel(get(h.valid_color,'String'));
for c = [1 2 ncol]
    set(h.valid_color,'Value',c);
    gui.sliderdisp(gui.retr('pivlab_axis')); drawnow;
    S.ax.(sprintf('vec_color%d',c)) = axis_snapshot();
    S.png.(sprintf('vec_color%d',c)) = shot(outdir, sprintf('display_veccolor%d',c));
end
set(h.colorbarpos,'Value',4); set(h.valid_color,'Value',ncol);
gui.sliderdisp(gui.retr('pivlab_axis')); drawnow;
S.ax.vec_magnitude_cbar = axis_snapshot();
% LIC
restore_controls(base);
rng(0); derive_all(10);
S.ax.lic = axis_snapshot(); S.png.lic = shot(outdir,'display_lic');
S.derived_lic = gui.retr('derived');
end

function S = sc_session_settings_roundtrip(outdir, root)
start_pivlab(1);
load_images(jet_paths(root,2), 1);
set_roi_masks();
background(2);
configure_piv(1,'threePass');
analyze();
calibration(10, 100, 1, 1);
validation(struct());
derive_all(2);
sdir = fullfile(outdir,'session'); if ~exist(sdir,'dir'), mkdir(sdir); end
export.save_session_function(sdir,'session.mat');
mock_file('put', sdir, 'settings.mat');
export.save_settings_Callback([],[],[]);
S.session_vars = who('-file', fullfile(sdir,'session.mat'));
S.settings_vars = who('-file', fullfile(sdir,'settings.mat'));
S.settings_content = load(fullfile(sdir,'settings.mat'));
S.controls_before = control_snapshot();
S.appdata_before = appdata_snapshot();
close_pivlab();
% load session in fresh GUI
start_pivlab(1);
import.load_session_Callback(1, fullfile(sdir,'session.mat')); drawnow;
S.controls_session = control_snapshot();
S.appdata_session = appdata_snapshot();
gui.sliderdisp(gui.retr('pivlab_axis')); drawnow;
S.ax_session = axis_snapshot(); S.png_session = shot(outdir,'session_loaded');
close_pivlab();
% load settings in fresh GUI (through the menu callback, uigetfile mocked)
start_pivlab(1);
mock_file('get', sdir, 'settings.mat');
import.load_settings_Callback([],[],[]); drawnow;
S.controls_settings = control_snapshot();
S.appdata_settings = appdata_snapshot();
end

function S = sc_video_import(outdir, root)
% video file read on the fly (time-resolved), incl. background image from the video
here = fileparts(mfilename('fullpath'));
start_pivlab(1);
vfile = fullfile(root,'Example_data','example_video.mp4');
setappdata(0,'parity_video_selection', video_selection(vfile, (1:6)'));
addpath(fullfile(here,'mocks_video'),'-begin');
try
    import.loadvideobutton_Callback([],[],[]); drawnow;
catch err
    rmpath(fullfile(here,'mocks_video'));
    rethrow(err);
end
rmpath(fullfile(here,'mocks_video'));
rmappdata(0,'parity_video_selection');
S.filepath = gui.retr('filepath'); S.filename = gui.retr('filename');
S.video_frame_selection = gui.retr('video_frame_selection');
S.expected_image_size = gui.retr('expected_image_size');
configure_piv(1,'twoPass');
S.t_analyze = analyze();
S.raw = gui.retr('resultslist');
validation(struct());
S.validated = gui.retr('resultslist');
derive_all(3);
S.derived = gui.retr('derived');
S.ax = axis_snapshot(); S.png = shot(outdir,'video_import');
background(2);
S.bg_A = gui.retr('bg_img_A'); S.bg_B = gui.retr('bg_img_B');
S.t_analyze_bg = analyze();
S.raw_bg = gui.retr('resultslist');
end

function S = sc_camera_undistortion(outdir, root)
% lens undistortion (+ rectification) of the fisheye example images, serial and parallel
files = cell(8,1);
for i = 1:4
    files{2*i-1} = fullfile(root,'Example_data','worst_case_distortion',sprintf('PIVlab_%04d_A.jpg',i-1));
    files{2*i}   = fullfile(root,'Example_data','worst_case_distortion',sprintf('PIVlab_%04d_B.jpg',i-1));
end
for cores = [1 2]
    if cores == 1, tag = 'serial'; else, tag = 'parallel'; end
    start_pivlab(cores);
    load_images(files, 1);
    set_camera_model(2);   % view 'same'
    configure_piv(1,'twoPass');
    S.(tag).t_analyze = analyze();
    S.(tag).undistorted = gui.retr('resultslist');
    if cores == 1
        S.ax_undistorted = axis_snapshot(); S.png_undistorted = shot(outdir,'camera_undistorted');
        background(2);
        S.bg_A = gui.retr('bg_img_A'); S.bg_B = gui.retr('bg_img_B');
        S.(tag).t_analyze_bg = analyze();
        S.(tag).undistorted_bg = gui.retr('resultslist');
        h = hand(); set(h.bg_subtract,'Value',1); gui.put('bg_img_A',[]); gui.put('bg_img_B',[]);
        % rectification: small rotation of the undistorted image
        a = 3*pi/180;
        gui.put('rectification_tform', affine2d([cos(a) sin(a) 0; -sin(a) cos(a) 0; 0 0 1]));
        gui.put('cam_use_rectification',1);
        S.(tag).t_analyze_rect = analyze();
        S.(tag).rectified = gui.retr('resultslist');
        S.ax_rectified = axis_snapshot(); S.png_rectified = shot(outdir,'camera_rectified');
    end
end
end

function S = sc_multitiff(outdir, root)
% multi-page TIFF files: pairwise over two files, time resolved within one file
jet = jet_paths(root, 3);
stack1 = fullfile(outdir,'stack1.tif');
stack2 = fullfile(outdir,'stack2.tif');
for k = 1:4
    if k == 1, mode = 'overwrite'; else, mode = 'append'; end
    imwrite(imread(jet{k}), stack1, 'WriteMode', mode);
end
imwrite(imread(jet{5}), stack2, 'WriteMode', 'overwrite');
imwrite(imread(jet{6}), stack2, 'WriteMode', 'append');
start_pivlab(1);
load_multitiff({stack1; stack2}, 1);
S.pairwise_filepath = gui.retr('filepath'); S.pairwise_framenum = gui.retr('framenum');
S.pairwise_filename = gui.retr('filename');
configure_piv(1,'twoPass');
S.t_analyze = analyze();
S.pairwise_raw = gui.retr('resultslist');
load_multitiff({stack1}, 0);
S.tr_filepath = gui.retr('filepath'); S.tr_framenum = gui.retr('framenum');
S.t_analyze_tr = analyze();
S.tr_raw = gui.retr('resultslist');
end

%% ===================== GUI helpers =====================
function sel = video_selection(vfile, frames)
% what the "Import" button of the video import dialog (import.vid_import) stores for these frames
[vpath, vname, vext] = fileparts(vfile);
video_pathname = [vpath filesep];
filename = [vname vext];
out = frames(1);
for i = 2:numel(frames)
    out(end+1,1) = frames(i); %#ok<AGROW>
    out(end+1,1) = frames(i); %#ok<AGROW>
end
out(end) = [];
if mod(numel(out),2) == 1
    out(end) = [];
end
sel.filename = cell(numel(out),1);
sel.filepath = cell(numel(out),1);
for j = 1:numel(out)
    if mod(j,2) == 1
        sel.filename{j} = ['A:[' int2str(out(j)) ']' filename];
    else
        sel.filename{j} = ['B:[' int2str(out(j)) ']' filename];
    end
    sel.filepath{j} = fullfile(video_pathname, filename);
end
sel.pathname = video_pathname;
sel.video_frame_selection = out;
end

function set_camera_model(viewtype)
% strong barrel distortion, similar to the fisheye lens of the worst_case_distortion images
sz = gui.retr('expected_image_size');
f = 0.9*sz(2);
K = [f 0 sz(2)/2; 0 f sz(1)/2; 0 0 1];
cp = cameraParameters('K', K, 'RadialDistortion', [-0.25 0.06], 'ImageSize', sz);
h = hand();
h.calib_viewtype.Value = viewtype;
gui.put('cameraParams', cp);
gui.put('cam_use_calibration', 1);
gui.put('cam_use_rectification', 0);
gui.put('cam_use_tilted_model', false);
end

function load_multitiff(paths, sequencer)
gui.put('sequencer',sequencer); gui.put('multitiff',1); gui.put('video_selection_done',0);
ps = struct('name',paths(:),'isdir',num2cell(false(numel(paths),1)));
import.loadimgsbutton_Callback([],[],0,ps); drawnow;
end

function start_pivlab(cores)
close_pivlab();
PIVlab_GUI(cores); drawnow;
gui.put('batchModeActive',1);
hgui = getappdata(0,'hgui');
set(hgui,'Units','pixels','Position',[20 40 1600 1000]); drawnow;
try, gui.MainWindow_ResizeFcn(hgui); catch, end
drawnow;
end

function close_pivlab()
hgui = getappdata(0,'hgui');
if ~isempty(hgui) && ishghandle(hgui)
    try, gui.put('batchModeActive',1); catch, end
    try, delete(hgui); catch, close(hgui,'force'); end
end
setappdata(0,'hgui',[]);
try, close(findall(0,'Type','figure'),'force'); catch, end
end

function p = jet_paths(root,n)
p = cell(2*n,1);
for i = 1:n
    p{2*i-1} = fullfile(root,'Example_data',sprintf('Jet_%04dA.jpg',i));
    p{2*i}   = fullfile(root,'Example_data',sprintf('Jet_%04dB.jpg',i));
end
end

function p = fuert_paths(root,n)
p = cell(n,1);
for i = 1:n, p{i} = fullfile(root,'Example_data',sprintf('Fuerteventura_%06d.jpeg',i-1)); end
end

function load_images(paths, sequencer)
gui.put('sequencer',sequencer); gui.put('multitiff',0); gui.put('video_selection_done',0);
ps = struct('name',paths(:),'isdir',num2cell(false(numel(paths),1)));
import.loadimgsbutton_Callback([],[],0,ps); drawnow;
end

function set_roi_masks()
sz = gui.retr('expected_image_size');
roi = [20 20 min(sz(2)-40,300) min(sz(1)-40,220)];
gui.put('roirect',roi);
rng(1);
m = cell(1,3);
m{1} = {'ROI_object_rectangle',[25+randi(8) 25+randi(8) 40 35]};
m{2} = {'ROI_object_polygon',[120 90;155 95;150 130;115 125]};
m{3} = cell(0);
gui.put('masks_in_frame',m);
end

function background(mode)
h = hand();
gui.quick3_Callback([],[]);
set(h.bg_subtract,'Value',mode);
preproc.generate_BG_img(); drawnow;
end

function configure_piv(algo, passMode)
h = hand();
gui.quick4_Callback([],[]);
set(h.algorithm_selection,'Value',algo);
piv.algorithm_selection_Callback(h.algorithm_selection,[],[]);
set(h.pass1_size,'String','64'); piv.intarea_Callback(h.pass1_size,[],[]);
set(h.pass1_step,'String','32'); piv.step_Callback(h.pass1_step,[],[]);
set(h.subpixel_estimator,'Value',1);
n = find(strcmp(passMode,{'singlePass','twoPass','threePass','fourPass'}));
cb = {h.pass2_enable,h.pass3_enable,h.pass4_enable}; ed = {h.pass2_size,h.pass3_size,h.pass4_size};
fn = {@piv.pass2_checkbox_Callback,@piv.pass3_checkbox_Callback,@piv.pass4_checkbox_Callback};
vals = {'32','16','16'};
for k = 1:3
    set(cb{k},'Value',double(n>k)); set(ed{k},'String',vals{k}); fn{k}(cb{k},[],[]);
end
set(h.update_display_checkbox,'Value',0);
drawnow;
end

function t = analyze()
h = hand();
gui.quick5_Callback([],[]); drawnow;
set(h.update_display_checkbox,'Value',0);
t0 = tic; piv.AnalyzeAll_Callback([],[],[]); drawnow; t = toc(t0);
end

function calibration(realdist, time, xdir, ydir)
h = hand();
gui.quick6_Callback([],[]);
gui.put('pointscali',[10 10; 110 10]);
set(h.realdist,'String',num2str(realdist));
set(h.time_inp,'String',num2str(time));
set(h.x_axis_direction,'Value',xdir); set(h.y_axis_direction,'Value',ydir);
calibrate.apply_cali_Callback([],[],[]); drawnow;
end

function validation(opts)
h = hand();
d = struct('stdev_enable',1,'stdev_thresh','7','loc_median_enable',1,'loc_med_thresh','3','interpol_missing',1, ...
    'corr_filter_enable',0,'notch_enable',0,'contrast_filter_enable',0,'bright_filter_enable',0);
f = fieldnames(opts);
for k = 1:numel(f), d.(f{k}) = opts.(f{k}); end
gui.put('velrect',[]);
f = fieldnames(d);
for k = 1:numel(f)
    if strcmp(f{k},'velrect'), gui.put('velrect',d.velrect); continue; end
    if isfield(h,f{k}), set_control(h.(f{k}), d.(f{k})); end
end
validate.apply_filter_all_Callback([],[],[]); drawnow;
end

function derive_all(d)
h = hand();
plot.derivs_Callback([],[],[]);
set(h.derivchoice,'Value',d); plot.derivchoice_Callback(h.derivchoice);
plot.apply_deriv_all_Callback([],[],[]); drawnow;
select_frame(1);
end

function select_frame(fr)
h = hand();
set(h.fileselector,'Value',fr);
gui.fileselector_Callback(h.fileselector,[],[]);
gui.sliderdisp(gui.retr('pivlab_axis')); drawnow;
end

function h = hand()
% handles of the PIVlab window. Older PIVlab versions (before the Tag renaming) get the
% current names as additional fields, so the same scenarios run on both versions.
h = gui.gethand;
R = tag_renames();
for k = 1:numel(R.old)
    if ~isfield(h, R.new{k}) && isfield(h, R.old{k})
        h.(R.new{k}) = h.(R.old{k});
    end
end
end

function R = tag_renames()
% old and new Tags of the renamed controls (tag_renames.csv)
persistent T
if isempty(T)
    here = fileparts(mfilename('fullpath'));
    lines = readlines(fullfile(here, 'tag_renames.csv'));
    T.old = {}; T.new = {};
    for k = 2:numel(lines)
        p = split(strtrim(lines(k)), ',');
        if numel(p) == 2
            T.old{end+1} = char(p(1)); T.new{end+1} = char(p(2));
        end
    end
end
R = T;
end

function set_popup(hc, val, cb)
set(hc,'Value',val);
try, cb(hc,[],[]); catch, end
end

function set_repeat_last(h)
set(h.repeat_last_enable,'Value',1); set(h.repeat_last_threshold,'String','0.025');
end

function reset_variant(h)
set(h.correlation_robustness,'Value',1); set(h.subpixel_estimator,'Value',1); set(h.disable_autocorrelation,'Value',0);
set(h.repeat_last_enable,'Value',0); set(h.uncertainty_enable,'Value',0);
end

function set_control(hc, val)
if ischar(val) || isstring(val)
    set(hc,'String',val);
else
    set(hc,'Value',val);
end
end

function s = get_string_safe(tag)
h = hand();
if isfield(h,tag), s = get(h.(tag),'String'); else, s = ''; end
end

function mock_file(kind, p, f)
setappdata(0,'parity_mock_file',{p,f});
setappdata(0,'parity_mock_kind',kind);
end

%% ===================== snapshots =====================
function C = cal_snapshot()
C = struct();
for n = {'calu','calv','calxy','offset_x_true','offset_y_true','displacement_only','pointscali'}
    C.(n{1}) = gui.retr(n{1});
end
end

function A = appdata_snapshot()
hgui = getappdata(0,'hgui');
all = getappdata(hgui);
skip = {'UsedByGUIData_m','existing_handles','handle_toolprogress_bg','handle_toolprogress_fg','pivlab_axis', ...
    'video_reader_object','hgui','PIVlab_capture_resources'};
A = struct();
f = fieldnames(all);
for k = 1:numel(f)
    if any(strcmp(f{k},skip)), continue; end
    v = all.(f{k});
    if isnumeric(v) || islogical(v) || ischar(v) || iscell(v) || isstring(v) || (isstruct(v) && isempty(fieldnames(v)))
        A.(f{k}) = v;
    end
end
end

function C = control_snapshot()
hgui = getappdata(0,'hgui');
c = findall(hgui,'Type','uicontrol');
R = tag_renames();
C = struct();
for k = 1:numel(c)
    t = get(c(k),'Tag');
    if isempty(t) || ~isvarname(t), continue; end
    idx = find(strcmp(R.old, t), 1);
    if ~isempty(idx), t = R.new{idx}; end % older PIVlab: store under the current Tag
    C.(t) = struct('String',{get(c(k),'String')},'Value',get(c(k),'Value'),'Visible',char(string(get(c(k),'Visible'))), ...
        'Enable',char(string(get(c(k),'Enable'))));
end
end

function restore_controls(C)
hgui = getappdata(0,'hgui');
h = hand();
f = fieldnames(C);
for k = 1:numel(f)
    if ~isfield(h,f{k}), continue; end
    hc = h.(f{k});
    if numel(hc) ~= 1 || ~strcmp(get(hc,'Type'),'uicontrol'), continue; end
    st = get(hc,'Style');
    if any(strcmp(st,{'edit','text'}))
        set(hc,'String',C.(f{k}).String);
    elseif any(strcmp(st,{'checkbox','popupmenu','radiobutton','listbox','togglebutton'}))
        try, set(hc,'Value',C.(f{k}).Value); catch, end
    end
end
end

function G = axis_snapshot()
ax = gui.retr('pivlab_axis');
fig = ancestor(ax,'figure');
G = struct();
G.XLim = get(ax,'XLim'); G.YLim = get(ax,'YLim'); G.CLim = get(ax,'CLim');
G.ax_colormap = colormap(ax); G.fig_colormap = get(fig,'Colormap');
ch = allchild(ax);
items = cell(numel(ch),1);
props = {'CData','AlphaData','AlphaDataMapping','CDataMapping','XData','YData','ZData','UData','VData','Color', ...
    'LineWidth','Marker','MarkerSize','String','Position','Tag','Visible','FaceColor','EdgeColor','LineStyle','FontSize','BackgroundColor'};
for k = 1:numel(ch)
    it = struct('Type',get(ch(k),'Type'));
    for p = props
        if isprop(ch(k),p{1})
            v = get(ch(k),p{1});
            if isa(v,'matlab.lang.OnOffSwitchState'), v = char(v); end
            it.(p{1}) = v;
        end
    end
    items{k} = it;
end
G.children = items;
cb = findall(fig,'Type','colorbar');
cbs = cell(numel(cb),1);
for k = 1:numel(cb)
    cbs{k} = struct('Location',cb(k).Location,'Ticks',cb(k).Ticks,'TickLabels',{cb(k).TickLabels}, ...
        'Label',cb(k).Label.String,'Limits',cb(k).Limits,'Tag',cb(k).Tag,'Colormap',colormap(cb(k)));
end
G.colorbars = cbs;
end

function f = shot(outdir, name)
ax = gui.retr('pivlab_axis');
fig = ancestor(ax,'figure');
drawnow;
fr = getframe(fig);
f = fullfile(outdir,[name '.png']);
imwrite(fr.cdata, f);
end

function R = read_folder(d)
R = struct('name',{},'bytes',{},'content',{});
L = dir(d);
for k = 1:numel(L)
    if L(k).isdir, continue; end
    fn = fullfile(d,L(k).name);
    [~,~,e] = fileparts(fn);
    switch lower(e)
        case '.mat', c = load(fn);
        otherwise
            fid = fopen(fn,'r'); c = fread(fid,inf,'*uint8')'; fclose(fid);
    end
    R(end+1) = struct('name',L(k).name,'bytes',L(k).bytes,'content',c); %#ok<AGROW>
end
end


