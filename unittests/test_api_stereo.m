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

% stereo residual filter (2026-11-17): the vectors with |residual| of the raw 3D result above the threshold
gui.put('velrect', []);
residual_thresh = prctile(abs(res.stereo.residual_raw(:)), 80);
set(h.residual_enable, 'Value', 1);
set(h.residual_thresh, 'String', num2str(residual_thresh, 10));
validate.apply_filter_all_Callback;
gui_residual = gui.retr('resultslist');
set(h.residual_enable, 'Value', 0);
by_residual = pivlab.filter(res, Settings=S, VelocityLimits="none", ResidualFilter=true, ResidualThreshold=residual_thresh, Verbose=false);
verify_same(testCase, gui_residual, by_residual, [7 8 16], 'after the residual filter');
plain = pivlab.filter(res, Settings=S, VelocityLimits="none", Verbose=false);
verifyGreaterThan(testCase, nnz(by_residual.typevector == 2), nnz(plain.typevector == 2), 'the residual filter removed nothing');
above = abs(res.stereo.residual_raw) > residual_thresh;
verifyTrue(testCase, all(by_residual.typevector(above) == 2), 'vectors above the residual threshold not removed');
verifyError(testCase, @() pivlab.filter(res.stereo.cameras{1}, ResidualFilter=true, Verbose=false), 'pivlab:filter:residual');

% local median filter of W (2026-11-18)
set(h.w_median_enable, 'Value', 1);
set(h.w_median_thresh, 'String', '1.5');
validate.apply_filter_all_Callback;
gui_w_median = gui.retr('resultslist');
set(h.w_median_enable, 'Value', 0);
by_w_median = pivlab.filter(res, Settings=S, VelocityLimits="none", WMedianFilter=true, WMedianThreshold=1.5, Verbose=false);
verify_same(testCase, gui_w_median, by_w_median, [7 8 16], 'after the median filter of W');
verifyGreaterThan(testCase, nnz(by_w_median.typevector == 2), nnz(plain.typevector == 2), 'the median filter of W removed nothing');
verifyError(testCase, @() pivlab.filter(res.stereo.cameras{1}, WMedianFilter=true, Verbose=false), 'pivlab:filter:residual');

% W limits (2026-11-18): the middle 60 % of the raw W of all frames are kept
W = res.px.w_raw * calibrate.w_factor(res.calibration.calu, res.calibration.calv);
w_limits = prctile(W(:), [20 80]);
set(h.w_limit_enable, 'Value', 1);
set(h.w_limit_min, 'String', num2str(w_limits(1), 10));
set(h.w_limit_max, 'String', num2str(w_limits(2), 10));
validate.apply_filter_all_Callback;
gui_w_limits = gui.retr('resultslist');
set(h.w_limit_enable, 'Value', 0);
by_w_limits = pivlab.filter(res, Settings=S, VelocityLimits="none", WLimitFilter=true, WLimits=w_limits, Verbose=false);
verify_same(testCase, gui_w_limits, by_w_limits, [7 8 16], 'after the W limits');
outside_w = W < w_limits(1) | W > w_limits(2);
verifyTrue(testCase, all(by_w_limits.typevector(outside_w) == 2), 'vectors outside the W limits not removed');
swapped = pivlab.filter(res, Settings=S, VelocityLimits="none", WLimitFilter=true, WLimits=fliplr(w_limits), Verbose=false);
verifyEqual(testCase, swapped.typevector, by_w_limits.typevector, 'WLimits [max min] differ from [min max]');
verifyError(testCase, @() pivlab.filter(res, WLimitFilter=true, WLimits=1, Verbose=false), 'pivlab:filter:limits');
verifyError(testCase, @() pivlab.filter(res.stereo.cameras{1}, WLimitFilter=true, Verbose=false), 'pivlab:filter:residual');
% 2D results ignore the stereo filters from a settings file (only an explicit request is an error)
S_stereo = S;
S_stereo.filter.ResidualFilter = true;
S_stereo.filter.WMedianFilter = true;
S_stereo.filter.WLimitFilter = true;
cam_with = pivlab.filter(res.stereo.cameras{1}, Settings=S_stereo, VelocityLimits="none", Verbose=false);
cam_without = pivlab.filter(res.stereo.cameras{1}, Settings=S, VelocityLimits="none", Verbose=false);
verifyEqual(testCase, cam_with.typevector, cam_without.typevector, '2D result: stereo filters from the settings changed it');
gui.put('velrect', [limits(1) limits(3) limits(2) - limits(1) limits(4) - limits(3)]);
validate.apply_filter_all_Callback; % back to the validation with the velocity limits (compared below)

% calibration: the scale of the stereo calibration, DeltaT
set(h.time_inp, 'String', '2');
calibrate.apply_cali_Callback;
metric = pivlab.toMetric(filtered, DeltaT=0.002, Verbose=false);
verifyEqual(testCase, metric.calibration.calu, gui.retr('calu'), 'RelTol', 1e-12, 'calu');
verifyEqual(testCase, metric.units, "m/s");
verifyEqual(testCase, metric.w, filtered.px.w * calibrate.w_factor(gui.retr('calu'), gui.retr('calv')), 'RelTol', 1e-12, 'w in m/s (along z = x cross y)');

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

% velocity limits and W limits in m/s from a calibrated session, applied to the result in px/frame (settings:
% LimitUnits "calibrated"). The y axis points upwards (calv < 0, also calv = -1 in px/frame): the converted
% limits had the wrong sign before 2026-11-18.
verifyLessThan(testCase, gui.retr('calv'), 0, 'test case: y axis not upwards');
verifyEqual(testCase, res.calibration.calv, -1, 'test case: px/frame result without the axis direction');
raw = stereo.reconstruct_results(true);
U_ms = cat(3, raw{3, :}) * gui.retr('calu');
V_ms = cat(3, raw{4, :}) * gui.retr('calv');
u_ms = prctile(U_ms(:), [5 95]);
v_ms = prctile(V_ms(:), [5 95]);
gui.put('velrect', [u_ms(1) v_ms(1) diff(u_ms) diff(v_ms)]);
W_ms = cat(3, raw{16, :}) * calibrate.w_factor(gui.retr('calu'), gui.retr('calv'));
w_limits_ms = prctile(W_ms(:), [20 80]);
set(h.w_limit_enable, 'Value', 1);
set(h.w_limit_min, 'String', num2str(w_limits_ms(1), 10));
set(h.w_limit_max, 'String', num2str(w_limits_ms(2), 10));
validate.apply_filter_all_Callback;
gui_w_ms = gui.retr('resultslist');
export.save_session_function(folder, 'api_stereo_w_limits.mat');
S_ms = pivlab.loadSettings(fullfile(folder, 'api_stereo_w_limits.mat'));
verifyEqual(testCase, S_ms.filter.LimitUnits, "calibrated");
verifyEqual(testCase, S_ms.filter.WLimits, w_limits_ms, 'RelTol', 1e-9, 'W limits in the settings');
by_settings = pivlab.filter(res, Settings=S_ms, Verbose=false);
verifyEqual(testCase, by_settings.units, "px/frame");
verify_same(testCase, gui_w_ms, by_settings, [7 8 16], 'velocity and W limits in m/s on a px/frame result');
% the same limits as a freehand outline
gui.put('velrect', []);
gui.put('velrect_freehand', [u_ms(1) v_ms(1); u_ms(2) v_ms(1); u_ms(2) v_ms(2); u_ms(1) v_ms(2)]);
validate.apply_filter_all_Callback;
gui_freehand = gui.retr('resultslist');
export.save_session_function(folder, 'api_stereo_freehand.mat');
S_fh = pivlab.loadSettings(fullfile(folder, 'api_stereo_freehand.mat'));
verify_same(testCase, gui_freehand, pivlab.filter(res, Settings=S_fh, Verbose=false), [7 8 16], 'freehand limits in m/s on a px/frame result');
gui.put('velrect_freehand', []);
set(h.w_limit_enable, 'Value', 0);
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
set(h.stereo_disp_mode, 'Value', 2);   % "Settings: Manual": the panel values are used (Automatic: defaults)
stereo.disparity_mode_Callback;
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

function test_w_median_finds_spikes(testCase)
% stereo.limit_test, median test of W: finds single spikes in a smooth W field (also next to a masked area and
% at the border), not the smooth field, not the masked vectors; the W limits are inclusive
[X, Y] = meshgrid(1:30, 1:20);
W = 0.5 * sin(X / 6) + 0.3 * cos(Y / 5);
noise = 0.02 * (mod(X .* 7 + Y .* 13, 5) - 2); % deterministic, small
W = W + noise;
spikes = false(size(W));
spikes(5, 7) = true; spikes(12, 20) = true; spikes(1, 1) = true; spikes(20, 30) = true; spikes(10, 14) = true;
W_spiky = W;
W_spiky(spikes) = W(spikes) + [3; -2.5; 4; -3; 2];
W_spiky(9:11, 10:12) = NaN; % masked area next to the spike at (10, 14)
filters = struct('residual_thresh', [], 'w_median_thresh', 3, 'w_limits', []);
Z = zeros(size(W));
found = stereo.limit_test(Z, Z, Z, [], [], [], Z, W_spiky, filters);
verifyEqual(testCase, found, spikes, 'median test of W: spikes not found exactly');
verifyFalse(testCase, any(stereo.limit_test(Z, Z, Z, [], [], [], Z, W, filters), 'all'), 'median test of W: smooth field rejected');
filters = struct('residual_thresh', [], 'w_median_thresh', [], 'w_limits', [-0.2 0.4]);
out = stereo.limit_test(Z, Z, W, [], [], [], Z, W, filters);
verifyEqual(testCase, out, W < -0.2 | W > 0.4, 'W limits');
verifyFalse(testCase, any(stereo.limit_test(Z, Z, W, [], [], [], Z, W), 'all'), 'without stereo filters something was rejected');
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
