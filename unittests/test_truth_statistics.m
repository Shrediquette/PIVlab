function tests = test_truth_statistics
%TEST_TRUTH_STATISTICS Temporal statistics (pivlab.temporal, "Plot -> Temporal derivatives") against
%   values computed by hand from a known time series, for all axis settings and calibrations:
%   mean, sum, standard deviation and TKE of u, v and w, their units and signs, derived quantities of
%   statistics frames, the 25 % rule for invalid vectors, phase averages. No PIVlab window.
%   Run with: run_pivlab_tests('test_truth_statistics')
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
helper_setup_once(testCase);
F = helper_truth_flow('linear');
n = 8;
res = helper_truth_result(F, testCase.TestData.Dir, n, true);
% time series: field + a different uniform fluctuation per frame (px per frame)
k = reshape(1:n, 1, 1, n);
a = 0.4 * sin(2 * pi * k / n) + 0.1 * k / n;            % u
b = -0.3 * cos(2 * pi * k / n) + 0.05 * (k / n).^2;     % v (PIVlab, downward)
c = 0.2 * sin(4 * pi * k / n + 0.3);                    % w (away from the camera)
x = double(res.px.x);
y = double(res.px.y);
T = helper_truth_field(F, x, y);
res = helper_truth_set(res, T.u + a, T.v + b, T.w + c);
testCase.TestData.F = F;
testCase.TestData.T = T;
testCase.TestData.Res = res;
testCase.TestData.a = squeeze(a);
testCase.TestData.b = squeeze(b);
testCase.TestData.c = squeeze(c);
testCase.TestData.n = n;
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

function test_mean_and_sum(testCase)
D = testCase.TestData;
x = double(D.Res.px.x);
y = double(D.Res.px.y);
C = helper_truth_cases();
for k = 1:numel(C)
    c = C(k);
    r = helper_truth_calibrate(D.Res, c);
    E = helper_truth_expected(D.T, c, x, y, D.F.size);
    % mean: like a velocity. PIVlab v (down) + b -> screen V - b
    m = pivlab.temporal(r, "mean");
    helper_truth_verify(testCase, m.u, E.u + c.sx * mean(D.a) * E.fv, 1e-12, [c.name ': mean u']);
    helper_truth_verify(testCase, m.v, E.v - c.sy * mean(D.b) * E.fv, 1e-12, [c.name ': mean v']);
    helper_truth_verify(testCase, m.w, E.w - c.sx * c.sy * mean(D.c) * E.fv, 1e-12, [c.name ': mean w']);
    testCase.verifyEqual(m.frameLabels, "MEAN of frames 1:" + D.n, [c.name ': label']);
    testCase.verifyEqual(m.units, c.units, [c.name ': units of the mean']);
    % derived quantities of the mean frame: the fluctuations are uniform, the gradients stay
    [~, q] = pivlab.derive(m, "vorticity");
    helper_truth_verify(testCase, q, E.vorticity, 1e-5, [c.name ': vorticity of the mean'], [], max(abs(E.vorticity(:))));
    [~, q] = pivlab.derive(m, "magnitude");
    mu = E.u + c.sx * mean(D.a) * E.fv;
    mv = E.v - c.sy * mean(D.b) * E.fv;
    mw = E.w - c.sx * c.sy * mean(D.c) * E.fv;
    helper_truth_verify(testCase, q, sqrt(mu.^2 + mv.^2 + mw.^2), 1e-12, [c.name ': 3D magnitude of the mean']);
    % sum: like a velocity
    s = pivlab.temporal(r, "sum");
    helper_truth_verify(testCase, s.u, D.n * E.u + c.sx * sum(D.a) * E.fv, 1e-12, [c.name ': sum u']);
    helper_truth_verify(testCase, s.v, D.n * E.v - c.sy * sum(D.b) * E.fv, 1e-12, [c.name ': sum v']);
    helper_truth_verify(testCase, s.w, D.n * E.w - c.sx * c.sy * sum(D.c) * E.fv, 1e-12, [c.name ': sum w']);
end
end

function test_std_and_tke(testCase)
D = testCase.TestData;
x = double(D.Res.px.x);
one = ones(size(x));
C = helper_truth_cases();
for k = 1:numel(C)
    c = C(k);
    r = helper_truth_calibrate(D.Res, c);
    fv = c.calxy / c.t;
    % standard deviation: positive, in velocity units, independent of the axis directions
    s = pivlab.temporal(r, "std");
    helper_truth_verify(testCase, s.u, std(D.a) * fv * one, 1e-9, [c.name ': std u']);
    helper_truth_verify(testCase, s.v, std(D.b) * fv * one, 1e-9, [c.name ': std v']);
    helper_truth_verify(testCase, s.w, std(D.c) * fv * one, 1e-9, [c.name ': std w']);
    [~, q] = pivlab.derive(s, "u");
    helper_truth_verify(testCase, q, std(D.a) * fv * one, 1e-9, [c.name ': derive u of the std frame']);
    [~, q] = pivlab.derive(s, "w");
    helper_truth_verify(testCase, q, std(D.c) * fv * one, 1e-9, [c.name ': derive w of the std frame']);
    % TKE = 0.5 * variance, in velocity units squared, never negative
    t = pivlab.temporal(r, "tke");
    helper_truth_verify(testCase, t.u, 0.5 * var(D.a) * fv^2 * one, 1e-9, [c.name ': TKE u']);
    helper_truth_verify(testCase, t.v, 0.5 * var(D.b) * fv^2 * one, 1e-9, [c.name ': TKE v']);
    helper_truth_verify(testCase, t.w, 0.5 * var(D.c) * fv^2 * one, 1e-9, [c.name ': TKE w']);
    [~, q] = pivlab.derive(t, "magnitude");
    total = 0.5 * (var(D.a) + var(D.b) + var(D.c)) * fv^2;
    helper_truth_verify(testCase, q, total * one, 1e-9, [c.name ': total TKE (magnitude of the TKE frame)']);
end
end

function test_units_of_statistics(testCase)
% the unit text of a TKE frame is the velocity unit squared, std and mean keep the velocity unit
D = testCase.TestData;
C = helper_truth_cases('short');
for k = 1:numel(C)
    c = C(k);
    r = helper_truth_calibrate(D.Res, c);
    s = pivlab.temporal(r, "std");
    testCase.verifyEqual(s.units, c.units, [c.name ': units of the std frame']);
    t = pivlab.temporal(r, "tke");
    testCase.verifyEqual(t.units, "(" + c.units + ")^2", [c.name ': units of the TKE frame']);
end
end

function test_invalid_vectors_25_percent_rule(testCase)
% a vector with less than 25 % valid measurements is NaN in mean, std and TKE;
% more than 50 % interpolated: typevector 2 (interpolated) in the statistics frame
D = testCase.TestData;
r = D.Res;
tv = ones(size(r.typevector));
tv(5, 7, 1:6) = 2;     % 2 of 8 valid = 25 % -> not enough (mean of typevector = 1.75)
tv(9, 3, 1:5) = 2;     % 3 of 8 valid -> kept, but marked interpolated
tv(12, 12, 1:3) = 2;   % 5 of 8 valid -> kept, valid
tv(2, 2, :) = 0;       % masked in all frames
r.typevector = tv;
for op = ["mean", "std", "tke"]
    m = pivlab.temporal(r, op);
    testCase.verifyTrue(isnan(m.u(5, 7)) && isnan(m.v(5, 7)) && isnan(m.w(5, 7)), op + ": vector with 25 % valid measurements is NaN");
    testCase.verifyFalse(isnan(m.u(9, 3)), op + ": vector with 37.5 % valid measurements is kept");
    testCase.verifyEqual(m.typevector(9, 3), 2, op + ": more than 50 % interpolated -> interpolated");
    testCase.verifyEqual(m.typevector(12, 12), 1, op + ": 62.5 % valid -> valid");
    testCase.verifyEqual(m.typevector(2, 2), 0, op + ": masked in all frames -> masked");
end
s = pivlab.temporal(r, "sum");
testCase.verifyFalse(isnan(s.u(5, 7)), 'sum: no 25 % rule');
end

function test_phase_average(testCase)
D = testCase.TestData;
x = double(D.Res.px.x);
y = double(D.Res.px.y);
C = helper_truth_cases('short');
sel = {1:2:D.n, 2:2:D.n};
for k = 1:numel(C)
    c = C(k);
    r = helper_truth_calibrate(D.Res, c);
    E = helper_truth_expected(D.T, c, x, y, D.F.size);
    m = pivlab.temporal(r, "mean", Frames=sel);
    testCase.verifyEqual(size(m.u, 3), 2, [c.name ': two phase averages']);
    for p = 1:2
        helper_truth_verify(testCase, m.u(:, :, p), E.u + c.sx * mean(D.a(sel{p})) * E.fv, 1e-12, sprintf('%s: phase %d mean u', c.name, p));
        helper_truth_verify(testCase, m.v(:, :, p), E.v - c.sy * mean(D.b(sel{p})) * E.fv, 1e-12, sprintf('%s: phase %d mean v', c.name, p));
    end
    s = pivlab.temporal(r, "std", Frames=sel);
    helper_truth_verify(testCase, s.u(:, :, 2), std(D.a(sel{2})) * E.fv * ones(size(x)), 1e-9, [c.name ': phase 2 std u']);
end
end
