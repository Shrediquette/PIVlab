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
end

function teardownOnce(testCase)
closePIVlab();
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
V = load(which('PIVlab_settings_default.mat'));
testCase.verifyEqual(s.analysis.InterrogationArea, str2double(V.intarea));
testCase.verifyEqual(s.analysis.Step, str2double(V.stepsize));
testCase.verifyEqual(s.filter.StdevThreshold, str2double(V.stdev_thresh));
testCase.verifyEqual(s.filter.LocalMedianThreshold, str2double(V.loc_med_thresh));
testCase.verifyEqual(s.preprocess.CLAHE, logical(V.clahe_enable));
testCase.verifyEqual(s.preprocess.CLAHESize, str2double(V.clahe_size));
end

function test_loadSettings_detects_the_file_type(testCase)
[~, t] = pivlab.loadSettings(which('PIVlab_settings_default.mat'));
testCase.verifyEqual(t, 'settings');
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

%% ------------------------------------------------------------------ API vs. GUI
function test_api_results_equal_gui_results(testCase)
files = testCase.TestData.Files;
% GUI
startPIVlab();
loadImagesInGui(files, 1);
h = gui.gethand;
gui.quick4_Callback([],[]);
set(h.intarea,'String','64'); piv.intarea_Callback(h.intarea,[],[]);
set(h.step,'String','32'); piv.step_Callback(h.step,[],[]);
set(h.checkbox26,'Value',1); set(h.edit50,'String','32'); piv.pass2_checkbox_Callback(h.checkbox26,[],[]);
set(h.checkbox27,'Value',1); set(h.edit51,'String','16'); piv.pass3_checkbox_Callback(h.checkbox27,[],[]);
set(h.update_display_checkbox,'Value',0);
gui.quick5_Callback([],[]);
piv.AnalyzeAll_Callback([],[],[]);
set(h.stdev_check,'Value',1); set(h.stdev_thresh,'String','6');
set(h.loc_median,'Value',1); set(h.loc_med_thresh,'String','2.5'); set(h.interpol_missing,'Value',1);
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
