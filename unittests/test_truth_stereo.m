function tests = test_truth_stereo
%TEST_TRUTH_STEREO Stereo-PIV through the API (pivlab.stereo -> filter -> toMetric -> derive / temporal)
%   against the ground truth of helper_stereo_synthetic_case, for three camera layouts (side by side,
%   one above the other, camera 2 behind the board = board seen from behind) and all axis settings,
%   in px/frame and in m/s: coordinates, u, v, w (sign along z = x cross y), 3D magnitude, vorticity,
%   temporal mean and standard deviation of w. No PIVlab window (about 40 s).
%   Run with: run_pivlab_tests('test_truth_stereo')
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
helper_setup_once(testCase);
layouts = {'side', 'vertical', 'opposite'};
S = pivlab.defaults();
S.analysis.InterrogationArea = 64;
S.analysis.Step = 32;
S.analysis.Passes = 3;
S.analysis.PassSizes = [32 16 16];
st = stereo.defaults();
st.disparity.InterrogationArea = 128;
st.disparity.PassSize2 = 64;
for i = 1:numel(layouts)
    c = helper_stereo_synthetic_case(fullfile(testCase.TestData.Dir, layouts{i}), 3, 0, layouts{i});
    imgs = cell(1, 2);
    for k = 1:2
        imgs{k} = pivlab.readImages(c.files{k}, "pairwise");
        imgs{k} = pivlab.preprocess(imgs{k}, Camera=c.lens{k}, CameraView="same", Verbose=false);
    end
    res = pivlab.stereo(imgs, c.boards, c.board, Settings=S, Stereo=st, Verbose=false);
    res = pivlab.filter(res, Settings=S, Verbose=false);
    testCase.TestData.(layouts{i}).res = res;
    testCase.TestData.(layouts{i}).T = helper_truth_stereo_field(res.px.x, res.px.y, res.stereo.calib, c);
end
end

function teardownOnce(testCase)
helper_teardown_once(testCase);
end

function setup(testCase)
helper_truth_log(testCase, 'start');
end

function teardown(testCase)
helper_truth_log(testCase, 'end');
end

function test_side_by_side(testCase)
check_layout(testCase, 'side');
end

function test_one_above_the_other(testCase)
check_layout(testCase, 'vertical');
end

function test_board_seen_from_behind(testCase)
testCase.verifyTrue(any(testCase.TestData.opposite.res.stereo.calib.board_from_behind), ...
    'test setup: one camera sees the board from behind');
check_layout(testCase, 'opposite');
end

%% ------------------------------------------------------------------ local functions

function check_layout(testCase, layout)
% measured: rms error of the mean of 3 pairs about 1 % of the largest displacement
D = testCase.TestData.(layout);
res = D.res;
T = D.T;
x = double(res.px.x);
y = double(res.px.y);
sz = res.images.imageSize;
mm = res.stereo.mm_per_px(1);
C = stereo_cases(mm);
for k = 1:numel(C)
    c = C(k);
    name = [layout ', ' c.name];
    r = helper_truth_calibrate(res, c);
    E = helper_truth_expected(T, c, x, y, sz);
    testCase.verifyEqual(r.units, c.units, [name ': units']);
    helper_verify_near(testCase, r.calibration.calxy, c.calxy, 'RelTol', 1e-5, [name ': scale of the stereo calibration']);
    helper_truth_verify(testCase, r.x, E.x, 1e-5, [name ': x']);
    helper_truth_verify(testCase, r.y, E.y, 1e-5, [name ': y']);
    ok = ~isnan(T.U) & ~isnan(T.V) & ~isnan(T.w);
    vmax = max(abs([E.u(ok); E.v(ok); E.w(ok)]));
    um = mean(r.u, 3);
    vm = mean(r.v, 3);
    wm = mean(r.w, 3);
    verify_rms(testCase, um, E.u, ok, 0.03 * vmax, [name ': u']);
    verify_rms(testCase, vm, E.v, ok, 0.03 * vmax, [name ': v']);
    verify_rms(testCase, wm, E.w, ok, 0.03 * vmax, [name ': w']);
    % the sign of w: positive along z = x cross y
    cw = corrcoef(wm(ok & ~isnan(wm)), E.w(ok & ~isnan(wm)));
    testCase.verifyGreaterThan(cw(1, 2), 0.95, [name ': w correlates with the true w (sign along z)']);
    % 3D magnitude
    [~, m] = pivlab.derive(r, "magnitude");
    verify_rms(testCase, mean(m, 3), E.magnitude3, ok, 0.03 * vmax, [name ': 3D magnitude']);
    % vorticity (truth: the same central differences of the true field)
    [~, m] = pivlab.derive(r, "vorticity");
    m = mean(m, 3);
    inner = ok;
    inner([1 end], :) = false;
    inner(:, [1 end]) = false;
    gmax = max(abs(E.vorticity(inner)));
    verify_rms(testCase, m, E.vorticity, inner, 0.15 * gmax, [name ': vorticity']);
    cv = corrcoef(m(inner & ~isnan(m)), E.vorticity(inner & ~isnan(m)));
    testCase.verifyGreaterThan(cv(1, 2), 0.9, [name ': vorticity correlates with the truth (sign along z)']);
    % temporal statistics of w: the mean is the true w, the scatter is the PIV noise
    tm = pivlab.temporal(r, "mean");
    verify_rms(testCase, tm.w, E.w, ok, 0.03 * vmax, [name ': temporal mean of w']);
    ts = pivlab.temporal(r, "std");
    testCase.verifyLessThan(median(ts.w(ok), 'omitnan'), 0.03 * vmax, [name ': std of w (PIV noise only)']);
    testCase.verifyGreaterThanOrEqual(min(ts.w(:)), 0, [name ': std of w is not negative']);
end
end

function C = stereo_cases(mm_per_px)
% 4 axis settings, uncalibrated (px/frame) and DeltaT only (m/s, scale of the stereo calibration)
base = helper_truth_cases('short');   % px (1-4) and orig (5-8)
C = base(1:4);
for k = 5:8
    c = base(k);
    c.kind = 'stereo';
    c.dt = 0.002;
    c.px_per_m = [];
    c.origin = [];
    c.calxy = mm_per_px / 1000;
    c.t = 0.002;
    c.units = "m/s";
    c.name = strrep(c.name, 'orig', 'stereo m/s');
    C(k) = c;
end
end

function verify_rms(testCase, actual, expected, ok, tol, name)
a = double(actual(ok));
e = double(expected(ok));
valid = ~isnan(a);
testCase.verifyGreaterThan(nnz(valid), 0.8 * numel(a), [name ': at least 80 % valid vectors']);
err = sqrt(mean((a(valid) - e(valid)).^2));
testCase.verifyLessThanOrEqual(err, tol, sprintf('%s: rms error %.3g (tolerance %.3g)', name, err, tol));
end
