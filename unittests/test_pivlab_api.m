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

%% ------------------------------------------------------------------ API vs. GUI
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

function startPIVlab()
closePIVlab();
PIVlab_GUI(1); drawnow;
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
% like a first start of PIVlab
prefs = struct();
if ispref('PIVlab')
    prefs = getpref('PIVlab');
    rmpref('PIVlab');
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
end
