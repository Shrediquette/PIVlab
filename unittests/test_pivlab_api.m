function tests = test_pivlab_api
%TEST_PIVLAB_API Tests of the command-line API (+pivlab) and its parity with the PIVlab GUI.
%   Run with: results = runtests('unittests/test_pivlab_api.m')
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(projectRoot);
testCase.TestData.ProjectRoot = projectRoot;
testCase.TestData.Dir = tempname(tempdir);
mkdir(testCase.TestData.Dir);
testCase.TestData.Files = jetFiles(projectRoot, 3);
setappdata(0, 'PIVlabTestMode', true);
% the PIVlab GUI stores preferences (last folder etc.): start without them, restore them afterwards
testCase.TestData.Preferences = clear_preferences();
end

function teardownOnce(testCase)
closePIVlab();
restore_preferences(testCase.TestData.Preferences);
if isappdata(0, 'PIVlabTestMode')
    rmappdata(0, 'PIVlabTestMode');
end
try
    rmdir(testCase.TestData.Dir, 's');
catch
end
close all force
end

%% ------------------------------------------------------------------ API alone
function test_workflow_with_defaults(testCase)
imgs = pivlab.readImages(fullfile(testCase.TestData.ProjectRoot,'Example_data','Jet_000*.jpg'), "pairwise");
imgs = pivlab.readImages(imgs.files(1:4), "pairwise");
testCase.verifyEqual(imgs.pairs, 2);
imgs = pivlab.preprocess(imgs);
res = pivlab.analyze(imgs);
testCase.verifyEqual(size(res.u,3), 2);
testCase.verifyEqual(size(res.x), size(res.u(:,:,1)));
testCase.verifyTrue(any(isfinite(res.u(:))));
res = pivlab.filter(res);
testCase.verifyTrue(res.filtered);
res = pivlab.toMetric(res, DeltaT=0.001, PxPerMeter=1234);
testCase.verifyEqual(res.units, "m/s");
testCase.verifyEqual(res.x, res.px.x/1234, 'RelTol', 1e-12);
[res, vort] = pivlab.derive(res, "vorticity");
testCase.verifyEqual(size(vort), size(res.u));
m = pivlab.temporal(res, "mean");
testCase.verifyEqual(size(m.u,3), 1);
plain_mean = mean(res.u,3,'omitnan');
ok = isfinite(m.u);   % pivlab.temporal sets vectors with < 25 % valid data to NaN (like the GUI)
testCase.verifyEqual(double(m.u(ok)), double(plain_mean(ok)), 'AbsTol', 1e-5);   % single precision
fig = pivlab.display(m, Overlay="magnitude");
testCase.verifyTrue(isgraphics(fig));
close(fig);
end

function test_sequencing(testCase)
files = testCase.TestData.Files;
imgs = pivlab.readImages(files, "pairwise");
testCase.verifyEqual(imgs.pairs, 3);
testCase.verifyEqual(imgs.filepath(1:2), files(1:2));
imgs = pivlab.readImages(files, "timeresolved");
testCase.verifyEqual(imgs.pairs, 5);
testCase.verifyEqual(imgs.filepath(2:3), files([2 2]));
imgs = pivlab.readImages(files, "reference");
testCase.verifyEqual(imgs.pairs, 5);
testCase.verifyEqual(imgs.filepath([1 3 5]), files([1 1 1]));
end

function test_defaults_are_the_gui_defaults(testCase)
s = pivlab.defaults();
D = gui.default_settings;
testCase.verifyEqual(s.analysis.InterrogationArea, D.analysis.pass1_size);
testCase.verifyEqual(s.analysis.Step, D.analysis.pass1_step);
testCase.verifyEqual(s.filter.StdevThreshold, D.analysis.stdev_thresh);
testCase.verifyEqual(s.filter.LocalMedianThreshold, D.analysis.loc_med_thresh);
testCase.verifyEqual(s.preprocess.CLAHE, logical(D.analysis.clahe_enable));
testCase.verifyEqual(s.preprocess.CLAHESize, D.analysis.clahe_size);
end

function test_loadSettings_detects_the_file_type(testCase)
G = gui.default_settings;
G.analysis.pass1_size = 96;
G.calibration_data = struct('pointscali', [10 10; 110 10]);
G.calibration.realdist = 10;
G.calibration.time_inp = 100;
f = fullfile(testCase.TestData.Dir, 'detect_settings.mat');
export.write_settings_file(f, G);
[s, t] = pivlab.loadSettings(f);
testCase.verifyEqual(t, 'settings');
testCase.verifyEqual(s.analysis.InterrogationArea, 96);
testCase.verifyEqual(s.calibration.calxy, 1e-4, 'AbsTol', 1e-15); % 10 mm on 100 px
imgs = pivlab.preprocess(pivlab.readImages(testCase.TestData.Files(1:2), "pairwise"), Roi=[50 60 400 300]);
res = pivlab.analyze(imgs, InterrogationArea=48, Step=24, Passes=1);
f = fullfile(testCase.TestData.Dir, 'detect_session.mat');
pivlab.saveSession(res, f);
[s, t] = pivlab.loadSettings(f);
testCase.verifyEqual(t, 'session');
testCase.verifyEqual(s.analysis.InterrogationArea, 48);
testCase.verifyEqual(s.analysis.Step, 24);
testCase.verifyEqual(s.analysis.Passes, 1);
testCase.verifyEqual(s.preprocess.Roi, [50 60 400 300]);
end

function test_session_roundtrip_api(testCase)
imgs = pivlab.preprocess(pivlab.readImages(testCase.TestData.Files, "pairwise"));
res = pivlab.toMetric(pivlab.filter(pivlab.analyze(imgs)), DeltaT=0.002, PxPerMeter=5000);
f = fullfile(testCase.TestData.Dir, 'roundtrip.mat');
pivlab.saveSession(res, f);
r = pivlab.loadSession(f);
testCase.verifyEqual(r.px.u, res.px.u);
testCase.verifyEqual(r.px.u_raw, res.px.u_raw);
testCase.verifyEqual(r.typevector, res.typevector);
testCase.verifyEqual(r.u, res.u);
testCase.verifyEqual(r.calibration.calu, res.calibration.calu);
end

function test_hand_edits_are_used(testCase)
% values changed by hand in res.u / res.v are used by all following functions
imgs = pivlab.preprocess(pivlab.readImages(testCase.TestData.Files, "pairwise"), Verbose=false);
res = pivlab.filter(pivlab.analyze(imgs, Verbose=false), Verbose=false);
res = pivlab.toMetric(res, DeltaT=0.002, PxPerMeter=5000, Verbose=false);
before = res.px.u;
res.u(1:3,1:3,2) = 0.5;                     % change a few vectors of pair 2 (m/s)
res.v(1:3,1:3,2) = 0.5;
m = pivlab.temporal(res, "mean");
testCase.verifyEqual(double(m.u(2,2)), double(mean(res.u(2,2,:),'omitnan')), 'AbsTol', 1e-6);
[res2, vort] = pivlab.derive(res, "magnitude");
testCase.verifyEqual(double(vort(2,2,2)), 0.5*sqrt(2), 'AbsTol', 1e-6);
% unchanged values stay exactly as computed
unchanged = true(size(before)); unchanged(1:3,1:3,2) = false;
testCase.verifyEqual(res2.px.u(unchanged), before(unchanged));
% the edit survives a new calibration (half the time step -> twice the velocity)
res3 = pivlab.toMetric(res, DeltaT=0.001, PxPerMeter=5000, Verbose=false);
testCase.verifyEqual(double(res3.u(2,2,2)), 1.0, 'AbsTol', 1e-6);
% and is saved in a session
f = fullfile(testCase.TestData.Dir, 'edited.mat');
pivlab.saveSession(res, f, Verbose=false);
r = pivlab.loadSession(f);
testCase.verifyEqual(double(r.u(2,2,2)), 0.5, 'AbsTol', 1e-6);
% pivlab.filter starts from the raw data again and says so
lastwarn('');
pivlab.filter(res, Verbose=false);
[~, id] = lastwarn;
testCase.verifyEqual(id, 'pivlab:filter:editsReplaced');
% adding / removing frames is not allowed
res.u(:,:,end) = [];
id = '';
try
    pivlab.temporal(res, "mean");
catch err
    id = err.identifier;
end
testCase.verifyEqual(id, 'pivlab:editedResult:size');
end

function test_none_clears_roi_and_mask(testCase)
imgs = pivlab.readImages(testCase.TestData.Files(1:2), "pairwise");
s = pivlab.defaults();
s.preprocess.Roi = [50 60 400 300];
m = false(imgs.imageSize); m(100:200, 100:200) = true;
p = pivlab.preprocess(imgs, Settings=s, Mask=m, Verbose=false);
testCase.verifyEqual(p.preprocess.Roi, [50 60 400 300]);
testCase.verifyTrue(islogical(p.mask));
p = pivlab.preprocess(imgs, Settings=s, Roi="none", Mask="none", Verbose=false);
testCase.verifyEmpty(p.preprocess.Roi);
testCase.verifyEmpty(p.mask);
end

function test_verbose_false_is_silent(testCase)
files = testCase.TestData.Files(1:2);
% (no background subtraction here: with only 2 pairs it removes most particles, and piv_FFTmulti
% then prints a data quality warning, which Verbose=false deliberately does not hide)
out = evalc(['imgs = pivlab.preprocess(pivlab.readImages(files, "pairwise"), Verbose=false); ' ...
    'res = pivlab.analyze(imgs, Verbose=false); res = pivlab.filter(res, Verbose=false); ' ...
    'res = pivlab.toMetric(res, DeltaT=0.001, PxPerMeter=1000, Verbose=false); ' ...
    'pivlab.saveSession(res, fullfile(tempdir, "pivlab_silent.mat"), Verbose=false); ' ...
    'res = pivlab.analyze(imgs, Algorithm="ensemble", Verbose=false);']);
testCase.verifyEmpty(strtrim(out));
delete(fullfile(tempdir, 'pivlab_silent.mat'));
end

function test_warnings_for_options_without_effect(testCase)
imgs = pivlab.preprocess(pivlab.readImages(testCase.TestData.Files(1:2), "pairwise"), Verbose=false);
lastwarn('');
pivlab.analyze(imgs, Algorithm="dcc", Passes=3, Verbose=false);
[~, id] = lastwarn;
testCase.verifyEqual(id, 'pivlab:analyze:noEffect');
lastwarn('');
pivlab.analyze(imgs, Algorithm="dcc", Passes=1, Parallel=false, Verbose=false);   % harmless values
[~, id] = lastwarn;
testCase.verifyEmpty(id);
% most vectors removed (limits in px/frame, far too small) -> warning
res = pivlab.analyze(imgs, Verbose=false);
lastwarn('');
pivlab.filter(res, VelocityLimits=[-0.01 0.01 -0.01 0.01], Verbose=false);
[~, id] = lastwarn;
testCase.verifyEqual(id, 'pivlab:filter:manyRemoved');
end

function test_camera_sources(testCase)
imgs = pivlab.readImages(distortionFiles(testCase.TestData.ProjectRoot, 2), "pairwise");
raw_size = imgs.imageSize;
cp = cameraModel(raw_size);
% cameraParameters object, view "valid" (default): black borders cut away, so smaller than "full"
p = pivlab.preprocess(imgs, Camera=cp, Verbose=false);
testCase.verifyEqual(p.cam.view, 'valid');
testCase.verifyEqual(p.cam.use_calibration, 1);
testCase.verifyNotEqual(p.imageSize, raw_size);
testCase.verifyEqual(size(pivlab.getImage(p, 1)), p.imageSize);
full = pivlab.preprocess(imgs, Camera=cp, CameraView="full", Verbose=false);
testCase.verifyTrue(all(p.imageSize < full.imageSize));
% view "same": size of the input image
p = pivlab.preprocess(imgs, Camera=cp, CameraView="same", Verbose=false);
testCase.verifyEqual(p.imageSize, raw_size);
% camera calibration file saved in the GUI ("Save camera parameters")
cameraParams = cp;
cam_selected_target_images = {};
cam_use_tilted_model = false;
cam_tilted_D = [];
cam_K_opencv = [];
f = fullfile(testCase.TestData.Dir, 'camera_calibration.mat');
save(f, "cameraParams", "cam_selected_target_images", "cam_use_tilted_model", "cam_tilted_D", "cam_K_opencv");
q = pivlab.preprocess(imgs, Camera=f, CameraView="same", Verbose=false);
verifySameCamera(testCase, q.cam, p.cam);
testCase.verifyEqual(pivlab.getImage(q, 1), pivlab.getImage(p, 1));
% pre-processing without the Camera option: no camera calibration (default, like every option
% that is not given), also when the images were corrected before
k = pivlab.preprocess(q, Highpass=true, Verbose=false);
testCase.verifyEqual(k.cam.use_calibration, 0);
testCase.verifyEqual(k.imageSize, raw_size);
% "none" switches the undistortion off again
n = pivlab.preprocess(q, Camera="none", Verbose=false);
testCase.verifyEqual(n.cam.use_calibration, 0);
testCase.verifyEqual(n.imageSize, raw_size);
% wrong use
testCase.verifyEqual(preprocessError(imgs, 'CameraView', "same"), 'pivlab:preprocess:camera');
testCase.verifyEqual(preprocessError(imgs, 'Camera', cp, 'CameraView', "big"), 'pivlab:preprocess:cameraView');
testCase.verifyEqual(preprocessError(imgs, 'Camera', cp, 'Rectification', true), 'pivlab:preprocess:rectification');
testCase.verifyEqual(preprocessError(imgs, 'Camera', testCase.TestData.Files{1}), 'pivlab:preprocess:cameraFile');
% a session without camera calibration
jet = pivlab.preprocess(pivlab.readImages(testCase.TestData.Files(1:2), "pairwise"), Verbose=false);
s = fullfile(testCase.TestData.Dir, 'no_camera.mat');
pivlab.saveSession(pivlab.analyze(jet, Verbose=false), s, Verbose=false);
testCase.verifyEqual(preprocessError(imgs, 'Camera', s), 'pivlab:preprocess:noCameraCalibration');
r = pivlab.loadSession(s);
testCase.verifyEqual(r.images.cam.use_calibration, 0);
end

%% ------------------------------------------------------------------ API vs. GUI
function test_camera_session_roundtrip_and_gui(testCase)
% undistortion + rectification: saved in a session, loaded by the API and by the GUI
files = distortionFiles(testCase.TestData.ProjectRoot, 2);
raw = pivlab.readImages(files, "pairwise");
a = 3*pi/180;
rect = affine2d([cos(a) sin(a) 0; -sin(a) cos(a) 0; 0 0 1]);
imgs = pivlab.preprocess(raw, Camera=cameraModel(raw.imageSize), CameraView="same", Rectification=rect, Verbose=false);
res = pivlab.analyze(imgs, Verbose=false);
f = fullfile(testCase.TestData.Dir, 'camera_session.mat');
pivlab.saveSession(res, f, Verbose=false);
% API: loadSession and the session as Camera source give the same camera calibration
r = pivlab.loadSession(f);
verifySameCamera(testCase, r.images.cam, imgs.cam);
p = pivlab.preprocess(raw, Camera=f, Verbose=false);
verifySameCamera(testCase, p.cam, imgs.cam);
testCase.verifyEqual(p.imageSize, imgs.imageSize);
p = pivlab.preprocess(raw, Camera=f, Rectification=false, Verbose=false);
testCase.verifyEqual(p.cam.use_rectification, 0);
testCase.verifyEqual(p.cam.view, 'same');
% GUI: undistortion and rectification are switched on, and the analysis gives the same result
startPIVlab();
import.load_session_Callback(1, f); drawnow;
h = gui.gethand;
testCase.verifyEqual(gui.retr('cam_use_calibration'), 1);
testCase.verifyEqual(gui.retr('cam_use_rectification'), 1);
testCase.verifyEqual(h.calib_viewtype.Value, 2);
verifySameCamera(testCase, import.cam_settings(FromGUI=true), imgs.cam);
set(h.update_display_checkbox,'Value',0);
piv.AnalyzeAll_Callback([],[],[]);
rl = gui.retr('resultslist');
for k = 1:2
    testCase.verifyEqual(rl{3,k}, res.px.u_raw(:,:,k), sprintf('raw u, pair %d', k));
    testCase.verifyEqual(rl{4,k}, res.px.v_raw(:,:,k), sprintf('raw v, pair %d', k));
end
closePIVlab();
end

function test_tilted_camera_model_in_every_analysis(testCase)
% the tilted camera model (Scheimpflug) is used by every path: GUI parallel analysis, background
% images, ensemble, image size after switching the calibration on. (Serial and parallel results differ
% in the last digits anyway - worker processes calculate with one thread - so parallel is compared
% with parallel.)
files = distortionFiles(testCase.TestData.ProjectRoot, 2);
raw = pivlab.readImages(files, "pairwise");
cp = cameraModel(raw.imageSize);
sz = raw.imageSize;
f = 0.9*sz(2);
cameraParams = cp;
cam_selected_target_images = {'target.jpg'};
cam_use_tilted_model = true;
cam_tilted_D = [-0.25 0.06 0 0 0 0 0 0 0 0 0 0 0.03 0.02];   % k1 k2 ... tauX tauY
cam_K_opencv = [f 0 sz(2)/2; 0 f sz(1)/2; 0 0 1];
file = fullfile(testCase.TestData.Dir, 'tilted_calibration.mat');
save(file, "cameraParams", "cam_selected_target_images", "cam_use_tilted_model", "cam_tilted_D", "cam_K_opencv");
% API
imgs = pivlab.preprocess(raw, Camera=file, Verbose=false);
testCase.verifyTrue(imgs.cam.use_tilted_model);
plain = pivlab.preprocess(raw, Camera=cp, Verbose=false);
testCase.verifyNotEqual(pivlab.getImage(imgs, 1), pivlab.getImage(plain, 1));   % the tilt is applied
res = pivlab.analyze(imgs, Passes=2, PassSizes=[32 32 32], Parallel=true, Verbose=false);
ens = pivlab.analyze(imgs, Algorithm="ensemble", Passes=2, PassSizes=[32 32 32], Verbose=false);
bg = pivlab.preprocess(imgs, Camera=file, Background="mean", Verbose=false);   % (Camera has to be given again)
% GUI with parallel processing
startPIVlab(2);
loadImagesInGui(files, 1);
h = gui.gethand;
gui.put('cameraParams', cameraParams);
gui.put('cam_selected_target_images', cam_selected_target_images);
gui.put('cam_use_tilted_model', cam_use_tilted_model);
gui.put('cam_tilted_D', cam_tilted_D);
gui.put('cam_K_opencv', cam_K_opencv);
h.calib_viewtype.Value = 1;
h.calib_usecalibration.Value = 1;
preproc.cam_enable_cam_calib_Callback('calib_viewtype', [], []); drawnow;
testCase.verifyEqual(gui.retr('expected_image_size'), imgs.imageSize, 'image size after switching on');
for algorithm = 1:2   % 1 = FFT window deformation (parallel loop), 2 = ensemble
    gui.quick4_Callback([],[]);
    set(h.algorithm_selection,'Value',algorithm); piv.algorithm_selection_Callback(h.algorithm_selection,[],[]);
    set(h.pass1_size,'String','64'); piv.intarea_Callback(h.pass1_size,[],[]);
    set(h.pass1_step,'String','32'); piv.step_Callback(h.pass1_step,[],[]);
    set(h.pass2_enable,'Value',1); set(h.pass2_size,'String','32'); piv.pass2_checkbox_Callback(h.pass2_enable,[],[]);
    set(h.pass3_enable,'Value',0); piv.pass3_checkbox_Callback(h.pass3_enable,[],[]);
    set(h.update_display_checkbox,'Value',0);
    gui.quick5_Callback([],[]);
    piv.AnalyzeAll_Callback([],[],[]); drawnow;
    rl = gui.retr('resultslist');
    if algorithm == 1
        for k = 1:2
            testCase.verifyEqual(rl{3,k}, res.px.u_raw(:,:,k), sprintf('parallel GUI raw u, pair %d', k));
            testCase.verifyEqual(rl{4,k}, res.px.v_raw(:,:,k), sprintf('parallel GUI raw v, pair %d', k));
        end
    else
        testCase.verifyEqual(rl{3,1}, ens.px.u_raw, 'ensemble u');
        testCase.verifyEqual(rl{4,1}, ens.px.v_raw, 'ensemble v');
    end
end
gui.quick3_Callback([],[]);
set(h.bg_subtract,'Value',2);
preproc.generate_BG_img(); drawnow;
testCase.verifyEqual(gui.retr('bg_img_A'), bg.background.A, 'background A');
testCase.verifyEqual(gui.retr('bg_img_B'), bg.background.B, 'background B');
closePIVlab();
end

function test_api_results_equal_gui_results(testCase)
files = testCase.TestData.Files;
% GUI
startPIVlab();
loadImagesInGui(files, 1);
h = gui.gethand;
gui.quick4_Callback([],[]);
set(h.pass1_size,'String','64'); piv.intarea_Callback(h.pass1_size,[],[]);
set(h.pass1_step,'String','32'); piv.step_Callback(h.pass1_step,[],[]);
set(h.pass2_enable,'Value',1); set(h.pass2_size,'String','32'); piv.pass2_checkbox_Callback(h.pass2_enable,[],[]);
set(h.pass3_enable,'Value',1); set(h.pass3_size,'String','16'); piv.pass3_checkbox_Callback(h.pass3_enable,[],[]);
set(h.update_display_checkbox,'Value',0);
gui.quick5_Callback([],[]);
piv.AnalyzeAll_Callback([],[],[]);
set(h.stdev_enable,'Value',1); set(h.stdev_thresh,'String','6');
set(h.loc_median_enable,'Value',1); set(h.loc_med_thresh,'String','2.5'); set(h.interpol_missing,'Value',1);
validate.apply_filter_all_Callback([],[],[]);
rl = gui.retr('resultslist');
closePIVlab();
% API
imgs = pivlab.preprocess(pivlab.readImages(files, "pairwise"));
res = pivlab.analyze(imgs, InterrogationArea=64, Step=32, Passes=3, PassSizes=[32 16 16]);
res = pivlab.filter(res, StdevThreshold=6, LocalMedianThreshold=2.5);
for k = 1:3
    testCase.verifyEqual(res.px.u_raw(:,:,k), rl{3,k}, sprintf('raw u, pair %d', k));
    testCase.verifyEqual(res.px.v_raw(:,:,k), rl{4,k}, sprintf('raw v, pair %d', k));
    testCase.verifyEqual(res.px.u(:,:,k), rl{7,k}, sprintf('filtered u, pair %d', k));
    testCase.verifyEqual(res.typevector(:,:,k), rl{9,k}, sprintf('typevector, pair %d', k));
end
end

function test_api_session_opens_in_gui(testCase)
files = testCase.TestData.Files;
imgs = pivlab.preprocess(pivlab.readImages(files, "pairwise"), Roi=[40 40 800 600]);
res = pivlab.toMetric(pivlab.filter(pivlab.analyze(imgs)), DeltaT=0.001, PxPerMeter=2000);
f = fullfile(testCase.TestData.Dir, 'for_gui.mat');
pivlab.saveSession(res, f);
startPIVlab();
import.load_session_Callback(1, f); drawnow;
rl = gui.retr('resultslist');
testCase.verifyEqual(size(rl,2), 3);
testCase.verifyEqual(rl{7,2}, res.px.u(:,:,2));
testCase.verifyEqual(gui.retr('calu'), res.calibration.calu);
testCase.verifyEqual(gui.retr('roirect'), [40 40 800 600]);
% the GUI can display and re-analyse the session
h = gui.gethand;
set(h.fileselector,'Value',2); gui.fileselector_Callback(h.fileselector,[],[]);
gui.sliderdisp(gui.retr('pivlab_axis')); drawnow;
set(h.update_display_checkbox,'Value',0);
piv.AnalyzeAll_Callback([],[],[]);
rl2 = gui.retr('resultslist');
testCase.verifyEqual(rl2{3,1}, res.px.u_raw(:,:,1));
closePIVlab();
end

%% ------------------------------------------------------------------ helpers
function f = jetFiles(root, n)
f = cell(2*n,1);
for i = 1:n
    f{2*i-1} = fullfile(root,'Example_data',sprintf('Jet_%04dA.jpg',i));
    f{2*i}   = fullfile(root,'Example_data',sprintf('Jet_%04dB.jpg',i));
end
end

function f = distortionFiles(root, n)
% fisheye example images (strong barrel distortion)
f = cell(2*n,1);
for i = 1:n
    f{2*i-1} = fullfile(root,'Example_data','worst_case_distortion',sprintf('PIVlab_%04d_A.jpg',i-1));
    f{2*i}   = fullfile(root,'Example_data','worst_case_distortion',sprintf('PIVlab_%04d_B.jpg',i-1));
end
end

function cp = cameraModel(sz)
% strong barrel distortion, similar to the fisheye lens of the worst_case_distortion images
f = 0.9*sz(2);
K = [f 0 sz(2)/2; 0 f sz(1)/2; 0 0 1];
cp = cameraParameters('K', K, 'RadialDistortion', [-0.25 0.06], 'ImageSize', sz);
end

function verifySameCamera(testCase, a, b)
% camera settings: equal, the camera model compared by its lens parameters (a cameraParameters
% object read from a file differs in empty, unused properties)
testCase.verifyEqual(rmfield(a, 'cameraParams'), rmfield(b, 'cameraParams'));
names = {'K', 'RadialDistortion', 'TangentialDistortion', 'ImageSize'};
for k = 1:numel(names)
    testCase.verifyEqual(a.cameraParams.(names{k}), b.cameraParams.(names{k}), names{k});
end
end

function id = preprocessError(imgs, varargin)
% identifier of the error of pivlab.preprocess(imgs, varargin{:}), '' if there is none
id = '';
try
    pivlab.preprocess(imgs, varargin{:}, 'Verbose', false);
catch err
    id = err.identifier;
end
end

function startPIVlab(cores)
% cores > 1: the GUI analyses in parallel
if nargin < 1
    cores = 1;
end
closePIVlab();
PIVlab_GUI(cores); drawnow;
gui.put('batchModeActive',1);
end

function closePIVlab()
hgui = getappdata(0,'hgui');
if ~isempty(hgui) && ishghandle(hgui)
    try, gui.put('batchModeActive',1); catch, end
    try, delete(hgui); catch, close(hgui,'force'); end
end
setappdata(0,'hgui',[]);
end

function loadImagesInGui(paths, sequencer)
gui.put('sequencer',sequencer); gui.put('multitiff',0); gui.put('video_selection_done',0);
ps = struct('name',paths(:),'isdir',num2cell(false(numel(paths),1)));
import.loadimgsbutton_Callback([],[],0,ps); drawnow;
end

function prefs = clear_preferences()
% the user's PIVlab preferences (gui.set_preference): saved, then removed, so the tests start
% like a first start of PIVlab. Also saved in a file: if a test run is stopped before its end,
% load(fullfile(tempdir,'PIVlab_preferences_backup.mat')) and restore_preferences(prefs) bring
% them back.
prefs = struct();
if ispref('PIVlab')
    prefs = getpref('PIVlab');
    rmpref('PIVlab');
end
backup = fullfile(tempdir, 'PIVlab_preferences_backup.mat');
if ~isfile(backup)   % a backup of a stopped run is not overwritten with the cleared preferences
    save(backup, 'prefs');
end
end

function restore_preferences(prefs)
if ispref('PIVlab')
    rmpref('PIVlab');
end
names = fieldnames(prefs);
for k = 1:numel(names)
    setpref('PIVlab', names{k}, prefs.(names{k}));
end
backup = fullfile(tempdir, 'PIVlab_preferences_backup.mat');
if isfile(backup)
    delete(backup);
end
end
