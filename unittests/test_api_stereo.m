%% Tests of stereo-PIV in the command-line API (pivlab.stereo and the pivlab functions with W)
%
% A synthetic stereo recording with known ground truth (helper_stereo_synthetic_case) goes through the PIVlab
% window and through the API: both must give the same U, V, W (shared cores stereo.combine_cameras and
% stereo.limit_test).
%
% Run with:
%   runtests('unittests/test_api_stereo.m')

function tests = test_api_stereo
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
helper_setup_once(testCase);
testCase.TestData.case = helper_stereo_synthetic_case(fullfile(testCase.TestData.Dir, 'api_stereo_case'), 4, 0);
end

function teardownOnce(testCase)
helper_teardown_once(testCase);
end

function test_gui_equals_api(testCase)
% the same recording, settings and disparity settings through the GUI and through pivlab.stereo:
% identical U, V, W after ANALYZE, after the validation with 3D velocity limits, and in m/s
c = testCase.TestData.case;
folder = testCase.TestData.Dir;
helper_start_pivlab();
h = gui.gethand;
helper_stereo_gui_calibrate(c);
set(h.pass1_size, 'String', '64'); piv.intarea_Callback(h.pass1_size, [], []);
set(h.pass1_step, 'String', '32'); piv.step_Callback(h.pass1_step, [], []);
set(h.pass2_enable, 'Value', 1); set(h.pass2_size, 'String', '32'); piv.pass2_checkbox_Callback(h.pass2_enable, [], []);
set(h.update_display_checkbox, 'Value', 0);
piv.AnalyzeAll_Callback;
gui_analyzed = gui.retr('resultslist');
export.save_session_function(folder, 'api_stereo_gui.mat');
S = pivlab.loadSettings(fullfile(folder, 'api_stereo_gui.mat'));
st = stereo.settings_from_gui(h);

% API: the same images, lens calibrations and boards
imgs = cell(1, 2);
for k = 1:2
    imgs{k} = pivlab.readImages(c.files{k}, "pairwise");
    imgs{k} = pivlab.preprocess(imgs{k}, Camera=c.lens{k}, CameraView="same", Verbose=false); % lens only:
    % pivlab.stereo pre-processes the rectified images with the settings S
end
res = pivlab.stereo(imgs, c.boards, c.board, Settings=S, Stereo=st, Verbose=false);
verifyEqual(testCase, res.units, "px/frame");
verifyFalse(testCase, res.filtered);
verify_same(testCase, gui_analyzed, res, [3 4 16], 'after ANALYZE');

% validation with velocity limits (on U, V of the 3D result) and the default filters
U = res.px.u_raw;
limits = [prctile(U(:), 10) prctile(U(:), 90) -1000 1000];
gui.put('velrect', [limits(1) limits(3) limits(2) - limits(1) limits(4) - limits(3)]);
validate.apply_filter_all_Callback;
gui_validated = gui.retr('resultslist');
filtered = pivlab.filter(res, Settings=S, VelocityLimits=limits, Verbose=false);
verifyTrue(testCase, filtered.filtered);
verifyGreaterThan(testCase, nnz(filtered.typevector == 2), 0, 'the limits removed nothing');
verify_same(testCase, gui_validated, filtered, [7 8 16], 'after the validation');

% calibration: the scale of the stereo calibration, DeltaT
set(h.time_inp, 'String', '2');
calibrate.apply_cali_Callback;
metric = pivlab.toMetric(filtered, DeltaT=0.002, Verbose=false);
verifyEqual(testCase, metric.calibration.calu, gui.retr('calu'), 'RelTol', 1e-12, 'calu');
verifyEqual(testCase, metric.units, "m/s");
verifyEqual(testCase, metric.w, filtered.px.w * abs(gui.retr('calu')), 'RelTol', 1e-12, 'w in m/s');

% derived parameters with spatial smoothing (frame 1): w component and 3D magnitude
set(h.smooth_mode, 'Value', 2);
set(h.smooth_param, 'String', '0.5');
set(h.interpol_missing, 'Value', 1);
plot.derivative_calc(1, 14, 0); % w component
plot.derivative_calc(1, 3, 0);  % magnitude (3D)
gui_derived = gui.retr('derived');
[smoothed, w_map] = pivlab.derive(metric, "w", Smoothing="spatial", SmoothingStrength=0.5);
[~, magnitude_map] = pivlab.derive(smoothed, "magnitude", Smoothing="spatial", SmoothingStrength=0.5);
verifyEqual(testCase, w_map(:, :, 1), gui_derived{13, 1}, 'AbsTol', 1e-12, 'w component, smoothed');
verifyEqual(testCase, magnitude_map(:, :, 1), gui_derived{2, 1}, 'AbsTol', 1e-12, '3D magnitude, smoothed');
verifyNotEmpty(testCase, smoothed.px.w_smoothed, 'smoothed w');

% temporal mean with W (unsmoothed data)
set(h.smooth_mode, 'Value', 1);
plot.derivative_calc(1, 14, 0); % removes the smoothed rows
set(h.selectedFramesMean, 'String', '1:4');
set(h.append_replace, 'Value', 1);
plot.temporal_operation_Callback([], [], 1);
gui_mean = gui.retr('resultslist');
m = pivlab.temporal(metric, "mean");
verifyEqual(testCase, m.px.w, gui_mean{16, 5}, 'AbsTol', 1e-12, 'mean of W');
verifyEqual(testCase, m.px.u, gui_mean{3, 5}, 'AbsTol', 1e-12, 'mean of U');
end

function test_sessions_gui_api_gui(testCase)
% GUI session -> pivlab.loadSession (U, V, W, cameras; validating again gives the GUI result) ->
% pivlab.saveSession -> GUI: the same result list, both cameras, validation works in the GUI.
% The Stereo-PIV panel settings come with the session (settings group stereo): pivlab.stereo with them
% repeats the GUI analysis.
c = testCase.TestData.case;
folder = testCase.TestData.Dir;
helper_start_pivlab();
h = gui.gethand;
helper_stereo_gui_calibrate(c);
set(h.pass1_size, 'String', '64'); piv.intarea_Callback(h.pass1_size, [], []);
set(h.pass1_step, 'String', '32'); piv.step_Callback(h.pass1_step, [], []);
set(h.pass2_enable, 'Value', 1); set(h.pass2_size, 'String', '32'); piv.pass2_checkbox_Callback(h.pass2_enable, [], []);
set(h.stereo_disp_passes, 'String', '2');
set(h.update_display_checkbox, 'Value', 0);
piv.AnalyzeAll_Callback;
% freehand velocity limits (outline in the u-v plane): come with the session (VelocityLimitsFreehand)
analyzed = gui.retr('resultslist');
U = cell2mat(analyzed(3, :));
outline = [prctile(U(:), 10) -1000; prctile(U(:), 90) -1000; prctile(U(:), 90) 1000; prctile(U(:), 10) 1000];
gui.put('velrect_freehand', outline);
validate.apply_filter_all_Callback;
gui_list = gui.retr('resultslist');
file_a = fullfile(folder, 'stereo_gui_a.mat');
export.save_session_function(folder, 'stereo_gui_a.mat');
% settings of the Stereo-PIV panel in the API settings
S = pivlab.loadSettings(file_a);
verifyEqual(testCase, S.stereo.Passes, 2, 'disparity passes of the panel');
verifyEqual(testCase, S.stereo.Pairs, 0, 'automatic number of pairs');
verifyEqual(testCase, S.filter.VelocityLimitsFreehand, outline, 'freehand velocity limits');
% load: U, V, W as in the GUI, both cameras
[res, s] = pivlab.loadSession(file_a);
verifyTrue(testCase, res.filtered);
verifyNotEmpty(testCase, res.stereo.cameras, 'camera results');
verify_same(testCase, gui_list, res, [7 8 16], 'loaded GUI session');
again = pivlab.filter(res, Settings=s, Verbose=false);
verify_same(testCase, gui_list, again, [7 8 16], 'validated again in the API');
plain = pivlab.filter(res, Settings=s, VelocityLimitsFreehand="none", Verbose=false);
verifyGreaterThan(testCase, nnz(again.typevector == 2), nnz(plain.typevector == 2), 'the freehand limits removed nothing');
% save and open in the GUI
file_b = fullfile(folder, 'stereo_api_b.mat');
pivlab.saveSession(again, file_b, Verbose=false);
helper_close_pivlab();
helper_start_pivlab();
import.load_session_Callback(1, file_b);
verifyEqual(testCase, gui.retr('stereomode'), 1, 'not a stereo session in the GUI');
state = gui.retr('stereo_cam_state');
verifyEqual(testCase, numel(state{2}.filepath), numel(gui.retr('filepath')), 'images of camera 2');
verify_same(testCase, gui.retr('resultslist'), again, [7 8 16], 'API session in the GUI');
validate.apply_filter_all_Callback; % the GUI can validate again (2D results of both cameras in the session)
verify_same(testCase, gui.retr('resultslist'), again, [7 8 16], 'API session validated in the GUI');
% pivlab.stereo with the session settings only (no Stereo option): the same as the GUI analysis
imgs = cell(1, 2);
for k = 1:2
    imgs{k} = pivlab.readImages(c.files{k}, "pairwise");
    imgs{k} = pivlab.preprocess(imgs{k}, Camera=c.lens{k}, CameraView="same", Verbose=false);
end
fresh = pivlab.filter(pivlab.stereo(imgs, c.boards, c.board, Settings=S, Verbose=false), Settings=S, Verbose=false);
verify_same(testCase, gui_list, fresh, [7 8 16], 'pivlab.stereo with the session settings');
end

function test_display_w_and_residual(testCase)
% pivlab.display: w component and reconstruction residual as colour maps; derive "w" needs a stereo result
c = testCase.TestData.case;
imgs = cell(1, 2);
for k = 1:2
    imgs{k} = pivlab.readImages(c.files{k}, "pairwise");
    imgs{k} = pivlab.preprocess(imgs{k}, Camera=c.lens{k}, CameraView="same", Verbose=false);
end
S = pivlab.defaults();
S.analysis.InterrogationArea = 64;
S.analysis.Step = 32;
S.analysis.Passes = 2;
S.analysis.PassSizes = [32 16 16];
res = pivlab.filter(pivlab.stereo(imgs, c.boards, c.board, Settings=S, Verbose=false), Settings=S, Verbose=false);
for overlay = ["w", "residual"]
    fig = pivlab.display(res, Overlay=overlay);
    bar = findobj(fig, 'Type', 'ColorBar');
    verifyNotEmpty(testCase, bar, overlay + ": no colour bar");
    verifyTrue(testCase, contains(string(bar.Label.String), ["w component", "Reconstruction residual"]), string(bar.Label.String));
    close(fig);
end
plain = rmfield(res, 'stereo');
plain.px = rmfield(plain.px, {'w', 'w_raw', 'w_smoothed'});
verifyError(testCase, @() pivlab.derive(plain, "w"), 'pivlab:derive:notAvailable');
end

function verify_same(testCase, resultslist, res, rows, when)
% the rows of the GUI result list (U, V, W) and the API result: identical, also the vector types
n = size(res.px.u, 3);
verifyEqual(testCase, size(resultslist, 2), n, [when ': number of image pairs']);
for i = 1:n
    verifyEqual(testCase, double(resultslist{rows(1), i}), double(res.px.u(:, :, i)), 'AbsTol', 1e-10, sprintf('%s: U, pair %d', when, i));
    verifyEqual(testCase, double(resultslist{rows(2), i}), double(res.px.v(:, :, i)), 'AbsTol', 1e-10, sprintf('%s: V, pair %d', when, i));
    verifyEqual(testCase, double(resultslist{rows(3), i}), double(res.px.w(:, :, i)), 'AbsTol', 1e-10, sprintf('%s: W, pair %d', when, i));
    verifyEqual(testCase, double(resultslist{9, i}), double(res.typevector(:, :, i)), sprintf('%s: vector types, pair %d', when, i));
end
end
