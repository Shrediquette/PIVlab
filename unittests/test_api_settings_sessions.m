function tests = test_api_settings_sessions
%TEST_API_SETTINGS_SESSIONS Command-line API: pivlab.defaults, pivlab.loadSettings, pivlab.saveSession,
%   pivlab.loadSession. No PIVlab window is opened (sessions of the API in the GUI:
%   test_apigui_results).
%   Run with: results = runtests('unittests/test_api_settings_sessions.m')
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
helper_setup_once(testCase);
testCase.TestData.Files = helper_files('jet', 3);
% one analysed result that several tests start from
imgs = pivlab.preprocess(pivlab.readImages(testCase.TestData.Files, "pairwise"), Verbose=false);
testCase.TestData.Imgs = imgs;
testCase.TestData.Res = pivlab.analyze(imgs, Verbose=false);
end

function teardownOnce(testCase)
helper_teardown_once(testCase);
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

function test_defaults_and_loadSettings(testCase)
s = pivlab.defaults();
groups = {'preprocess','analysis','filter','calibration','derive','display'};
for k = 1:numel(groups)
    testCase.verifyTrue(isfield(s, groups{k}), groups{k});
end
% every analysis option of pivlab.analyze is in the defaults (and the other way round)
names = fieldnames(s.analysis);
testCase.verifyTrue(all(ismember({'Algorithm','InterrogationArea','Step','Passes','PassSizes','SubpixelFinder', ...
    'DisableAutocorrelation','Robustness','RepeatLastPass','RepeatLastPassThreshold','Uncertainty', ...
    'OFVSmoothness','OFVPyramidLevels','OFVMedianFilter','Parallel'}, names)));
% the defaults run as they are
pivlab.analyze(testCase.TestData.Imgs, Settings=s, Pairs=1, Verbose=false);
% optical flow defaults = the GUI defaults (3 pyramid levels, smoothness 40, no median filter)
testCase.verifyEqual(s.analysis.OFVPyramidLevels, 3);
testCase.verifyEqual(s.analysis.OFVSmoothness, 40);
testCase.verifyEqual(s.analysis.OFVMedianFilter, "off");
% settings file written by the GUI code
G = gui.default_settings;
G.analysis.pass1_size = 80;
G.analysis.pass1_step = 40;
G.analysis.algorithm_selection = 2;
G.analysis.highpass_enable = 1;
G.analysis.ofv_pyramid_levels = 1;   % popup '5' '4' '3' '2' '1': 5 levels
G.analysis.ofv_median = 3;           % '5x5'
G.analysis.ofv_eta = 55;
f = fullfile(testCase.TestData.Dir, 'gui_settings.mat');
export.write_settings_file(f, G);
[s, t] = pivlab.loadSettings(f);
testCase.verifyEqual(t, 'settings');
testCase.verifyEqual(s.analysis.InterrogationArea, 80);
testCase.verifyEqual(s.analysis.Step, 40);
testCase.verifyEqual(s.analysis.Algorithm, "ensemble");
testCase.verifyTrue(logical(s.preprocess.Highpass));
testCase.verifyEqual(s.analysis.OFVPyramidLevels, 5);
testCase.verifyEqual(s.analysis.OFVMedianFilter, "5x5");
testCase.verifyEqual(s.analysis.OFVSmoothness, 55);
testCase.verifyEqual(s.source, string(f));
% and back: an API session carries the optical flow settings into the GUI settings
s.analysis.Algorithm = "fft";
r = pivlab.analyze(testCase.TestData.Imgs, Settings=s, Pairs=1, Verbose=false);
sf = fullfile(testCase.TestData.Dir, 'ofv_settings_session.mat');
pivlab.saveSession(r, sf, Verbose=false);
session = import.read_session_file(sf);
A = session.settings.analysis;
testCase.verifyEqual([A.ofv_pyramid_levels A.ofv_median A.ofv_eta], [1 3 55]);
% loadSettings accepts string and char
testCase.verifyEqual(pivlab.loadSettings(string(f)).analysis.Step, 40);
% files that are not settings
testCase.verifyEqual(helper_error_id('pivlab.loadSettings', fullfile(testCase.TestData.Dir, 'nope.mat')), 'pivlab:loadSettings:notFound');
x = 1; %#ok<NASGU>
other = fullfile(testCase.TestData.Dir, 'other.mat');
save(other, 'x');
testCase.verifyEqual(helper_error_id('pivlab.loadSettings', other), 'pivlab:loadSettings:unknownFile');
u_original = {1}; u_filtered = {1}; typevector_original = {1}; %#ok<NASGU>
exported = fullfile(testCase.TestData.Dir, 'exported.mat');
save(exported, 'u_original', 'u_filtered', 'typevector_original');
testCase.verifyEqual(helper_error_id('pivlab.loadSettings', exported), 'pivlab:loadSettings:noSettings');
% PIVlab 3.x settings file (variables of the GUI controls)
clahe_enable = 1; clahe_size = 64; intarea = 64; stepsize = 32; %#ok<NASGU>
old = fullfile(testCase.TestData.Dir, 'old_settings.mat');
save(old, 'clahe_enable', 'clahe_size', 'intarea', 'stepsize');
[id, msg] = helper_error_id('pivlab.loadSettings', old);
testCase.verifyNotEmpty(id);
testCase.verifySubstring(lower(msg), 'pivlab');
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

function test_saveSession_options(testCase)
res = testCase.TestData.Res;
f = fullfile(testCase.TestData.Dir, 'verbose.mat');
out = evalc('pivlab.saveSession(res, f);');
testCase.verifySubstring(out, 'verbose.mat');
out = evalc('pivlab.saveSession(res, f, Verbose=false);');
testCase.verifyEmpty(strtrim(out));
% string file name, result without filter / calibration
pivlab.saveSession(res, string(f), Verbose=false);
r = pivlab.loadSession(string(f));
testCase.verifyEqual(r.px.u_raw, res.px.u_raw);
testCase.verifyEqual(r.units, "px/frame");
[id, msg] = helper_error_id('pivlab.loadSession', fullfile(testCase.TestData.Dir, 'nope.mat'));
testCase.verifyNotEmpty(id);
testCase.verifySubstring(msg, 'nope.mat');
% a settings file is not a session
G = gui.default_settings;
sf = fullfile(testCase.TestData.Dir, 'only_settings.mat');
export.write_settings_file(sf, G);
testCase.verifyEqual(helper_error_id('pivlab.loadSession', sf), 'pivlab:loadSession:notSession');
end

function test_session_with_everything(testCase)
% ROI, masks per pair, background, camera undistortion, calibration with origin and flipped axes,
% velocity limits, smoothing -> saveSession -> loadSession (the same session in the GUI:
% test_apigui_results/test_api_session_with_everything_in_gui)
[res, imgs, f, roi, lim] = helper_api_session_everything(testCase.TestData.Dir);
[r, s] = pivlab.loadSession(f);
testCase.verifyEqual(r.px.u_raw, res.px.u_raw);
testCase.verifyEqual(r.px.u, res.px.u);
testCase.verifyEqual(r.px.u_smoothed, res.px.u_smoothed);
testCase.verifyTrue(r.smoothed);
testCase.verifyEqual(r.typevector, res.typevector);
helper_verify_near(testCase, r.u, res.u, 'RelTol', 1e-12);
helper_verify_near(testCase, r.x, res.x, 'RelTol', 1e-12);
testCase.verifyEqual(r.units, "m/s");
testCase.verifyEqual(r.images.preprocess.Roi, roi);
testCase.verifyEqual(r.images.background.A, imgs.background.A);
helper_verify_same_camera(testCase, r.images.cam, imgs.cam);
testCase.verifyEqual(s.preprocess.Roi, roi);
testCase.verifyEqual(s.preprocess.Background, "mean");
testCase.verifyTrue(logical(s.preprocess.Highpass));
testCase.verifyEqual(s.analysis.Passes, 3);
helper_verify_near(testCase, s.filter.VelocityLimits, lim, 'AbsTol', 1e-12);
testCase.verifyEqual(s.derive.Smoothing, "spatial");
% the mask of every pair is back (masked vectors stay masked)
testCase.verifyEqual(r.typevector_raw == 0, res.typevector_raw == 0);
% the loaded result is analysed again with its own settings: same raw result
again = pivlab.analyze(pivlab.preprocess(r.images, Camera=f, Settings=s, Mask=r.images.mask, Verbose=false), Settings=s, Verbose=false);
testCase.verifyEqual(again.px.u_raw, res.px.u_raw);
end
