function tests = test_truth_filter
%TEST_TRUTH_FILTER Vector validation (pivlab.filter) with outliers at known positions in an analytic
%   field: the outliers and only the outliers are removed (local median, standard deviation filter,
%   velocity limits in the user's units for all axis settings), and the interpolation brings back the
%   true values. No PIVlab window.
%   Run with: run_pivlab_tests('test_truth_filter')
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
helper_setup_once(testCase);
F = helper_truth_flow('linear');
res = helper_truth_result(F, testCase.TestData.Dir, 2, false);
x = double(res.px.x);
y = double(res.px.y);
T = helper_truth_field(F, x, y);
% outliers (px per frame) at known positions, not next to each other and not at the border
pos = [4 5; 8 13; 11 7; 15 15; 6 10];
idx = sub2ind(size(x), pos(:, 1), pos(:, 2));
du = [6; -7; 5; -6; 8];
dv = [-5; 6; 7; -8; 5];
u = T.u;
v = T.v;
u(idx) = u(idx) + du;
v(idx) = v(idx) + dv;
res = helper_truth_set(res, cat(3, u, T.u), cat(3, v, T.v), []);
testCase.TestData.F = F;
testCase.TestData.T = T;
testCase.TestData.Res = res;
testCase.TestData.idx = idx;
testCase.TestData.du = du;
testCase.TestData.dv = dv;
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

function test_local_median_finds_exactly_the_outliers(testCase)
D = testCase.TestData;
x = double(D.Res.px.x);
y = double(D.Res.px.y);
C = helper_truth_cases('short');
for k = 1:numel(C)
    c = C(k);
    r = helper_truth_calibrate(D.Res, c);
    f = pivlab.filter(r, StdevCheck=false, LocalMedian=true, Verbose=false);
    expected = ones(size(x));
    expected(D.idx) = 2;
    testCase.verifyEqual(f.typevector(:, :, 1), expected, [c.name ': removed vectors = the outliers']);
    testCase.verifyEqual(f.typevector(:, :, 2), ones(size(x)), [c.name ': no vector removed in the clean frame']);
    % the interpolation of a linear field brings back the true values
    E = helper_truth_expected(D.T, c, x, y, D.F.size);
    helper_truth_verify(testCase, f.u(:, :, 1), E.u, 2e-3, [c.name ': interpolated u']);
    helper_truth_verify(testCase, f.v(:, :, 1), E.v, 2e-3, [c.name ': interpolated v']);
    % the unfiltered result keeps the outliers
    testCase.verifyEqual(f.u_raw(D.idx), r.u_raw(D.idx), [c.name ': u_raw keeps the outliers']);
end
end

function test_stdev_filter(testCase)
% outliers of 100 px are far outside mean +- 8 std of the field
D = testCase.TestData;
x = double(D.Res.px.x);
r = D.Res;
u = r.px.u;
v = r.px.v;
u(D.idx(1:2)) = 100;
v(D.idx(1:2)) = -100;
r = helper_truth_set(r, u, v, []);
f = pivlab.filter(r, StdevCheck=true, StdevThreshold=8, LocalMedian=false, Interpolate=false, Verbose=false);
expected = ones(size(x));
expected(D.idx(1:2)) = 2;
% the outliers of setupOnce (5 to 8 px) are within 8 std (the 100 px ones make std large)
testCase.verifyEqual(f.typevector(:, :, 1), expected, 'stdev filter removes the 100 px vectors only');
testCase.verifyTrue(all(isnan(f.u(D.idx(1:2)))), 'removed vectors are NaN without interpolation');
end

function test_velocity_limits_in_user_units(testCase)
% limits are given in the units and axes of the user: an outlier that is fast in +x (user) is
% removed with umax, for every axis setting
D = testCase.TestData;
x = double(D.Res.px.x);
y = double(D.Res.px.y);
C = helper_truth_cases();
for k = 1:numel(C)
    c = C(k);
    r = helper_truth_calibrate(D.Res, c);
    E = helper_truth_expected(D.T, c, x, y, D.F.size);
    ru = r.u(:, :, 1);
    rv = r.v(:, :, 1);
    lim = [min(E.u(:)) max(E.u(:)) min(E.v(:)) max(E.v(:))];
    pad = 0.05 * [-(lim(2) - lim(1)) (lim(2) - lim(1)) -(lim(4) - lim(3)) (lim(4) - lim(3))];
    lim = lim + pad;
    f = pivlab.filter(r, StdevCheck=false, LocalMedian=false, VelocityLimits=lim, Interpolate=false, Verbose=false);
    outside = ru < lim(1) | ru > lim(2) | rv < lim(3) | rv > lim(4);
    testCase.verifyTrue(any(outside(:)), [c.name ': test setup: some outliers are outside the limits']);
    testCase.verifyEqual(f.typevector(:, :, 1) == 2, outside, [c.name ': removed = outside the limits']);
    testCase.verifyEqual(nnz(f.typevector(:, :, 2) == 2), 0, [c.name ': clean frame within the limits']);
    % only umax: removes exactly the vectors that are faster than umax along the user's x
    umax = max(E.u(:)) + 0.5 * E.fv;
    big = 1e6 * max(abs(lim));
    f = pivlab.filter(r, StdevCheck=false, LocalMedian=false, VelocityLimits=[-big umax -big big], Interpolate=false, Verbose=false);
    testCase.verifyEqual(f.typevector(:, :, 1) == 2, ru > umax, [c.name ': umax in user units']);
end
end

function test_one_sided_velocity_limits_with_inf(testCase)
% a one-sided limit written with Inf ([-Inf umax -Inf Inf]) must work like a very large limit
D = testCase.TestData;
r = D.Res;
umax = max(r.u(:, :, 2), [], 'all') + 0.5;
expected = r.u(:, :, 1) > umax;
f = pivlab.filter(r, StdevCheck=false, LocalMedian=false, VelocityLimits=[-Inf umax -Inf Inf], Interpolate=false, Verbose=false);
testCase.verifyEqual(f.typevector(:, :, 1) == 2, expected, 'VelocityLimits with -Inf / Inf: umax still removes the fast vectors');
end
