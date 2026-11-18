function tests = test_truth_calibration
%TEST_TRUTH_CALIBRATION Calibration against values written out by hand, for all axis settings and
%   calibrations of helper_truth_cases: calibration factors, units, coordinates (also with a user
%   origin), velocities, w and uncertainty. Exact analytic field, no PIV error, no PIVlab window.
%   Run with: run_pivlab_tests('test_truth_calibration')
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
helper_setup_once(testCase);
F = helper_truth_flow('linear');
testCase.TestData.F = F;
testCase.TestData.Res = helper_truth_result(F, testCase.TestData.Dir, 2, true);
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

function test_factors_and_units(testCase)
C = helper_truth_cases();
for k = 1:numel(C)
    c = C(k);
    r = helper_truth_calibrate(testCase.TestData.Res, c);
    cal = r.calibration;
    helper_verify_near(testCase, cal.calxy, c.calxy, 'RelTol', 1e-12, [c.name ': calxy']);
    % inside PIVlab v is positive downward: calv converts it to the user's y direction
    helper_verify_near(testCase, cal.calu, c.sx * c.calxy / c.t, 'RelTol', 1e-12, [c.name ': calu']);
    helper_verify_near(testCase, cal.calv, -c.sy * c.calxy / c.t, 'RelTol', 1e-12, [c.name ': calv']);
    testCase.verifyEqual(r.units, c.units, [c.name ': units']);
    testCase.verifyEqual(logical(cal.displacement_only), strcmp(c.kind, 'disp'), [c.name ': displacement only']);
    testCase.verifyEqual([cal.x_axis_direction cal.y_axis_direction], [c.xdir c.ydir], [c.name ': axis settings']);
end
end

function test_coordinates(testCase)
F = testCase.TestData.F;
C = helper_truth_cases();
x = double(testCase.TestData.Res.px.x);
y = double(testCase.TestData.Res.px.y);
T = helper_truth_field(F, x, y);
for k = 1:numel(C)
    c = C(k);
    r = helper_truth_calibrate(testCase.TestData.Res, c);
    E = helper_truth_expected(T, c, x, y, F.size);
    helper_truth_verify(testCase, r.x, E.x, 1e-6, [c.name ': x']);
    helper_truth_verify(testCase, r.y, E.y, 1e-6, [c.name ': y']);
end
end

function test_velocities_w_uncertainty(testCase)
F = testCase.TestData.F;
C = helper_truth_cases();
x = double(testCase.TestData.Res.px.x);
y = double(testCase.TestData.Res.px.y);
T = helper_truth_field(F, x, y);
for k = 1:numel(C)
    c = C(k);
    r = helper_truth_calibrate(testCase.TestData.Res, c);
    E = helper_truth_expected(T, c, x, y, F.size);
    for f = 1:2
        helper_truth_verify(testCase, r.u(:, :, f), E.u, 1e-12, sprintf('%s: u, frame %d', c.name, f));
        helper_truth_verify(testCase, r.v(:, :, f), E.v, 1e-12, sprintf('%s: v, frame %d', c.name, f));
        helper_truth_verify(testCase, r.u_raw(:, :, f), E.u, 1e-12, sprintf('%s: u_raw, frame %d', c.name, f));
        helper_truth_verify(testCase, r.v_raw(:, :, f), E.v, 1e-12, sprintf('%s: v_raw, frame %d', c.name, f));
        helper_truth_verify(testCase, r.w(:, :, f), E.w, 1e-12, sprintf('%s: w, frame %d', c.name, f));
    end
    % uncertainty is a length per time like the velocity, always positive
    helper_truth_verify(testCase, r.uncertainty, testCase.TestData.Res.px.uncertainty * E.fv, 1e-12, [c.name ': uncertainty']);
end
end

function test_user_origin_from_known_points(testCase)
% GUI "set offsets": the user clicks a pixel and types its true x (and y) coordinate in mm.
% That pixel must then have exactly these coordinates, for all axis settings.
sz = [320 320];
[x, y] = meshgrid(16:16:304, 16:16:304);
px_x = [101.5 40 0];
px_y = [70 233.25 0];
true_x_mm = 12.5;
true_y_mm = -3.75;
for xd = 1:2
    for yd = 1:2
        cal = calibrate.compute_calibration([0 0; 300 400], 50, 2, xd, yd, [px_x(1:2) true_x_mm], ...
            [px_y(1:2) true_y_mm], sz);
        name = sprintf('x dir %d, y dir %d', xd, yd);
        helper_verify_near(testCase, cal.calxy, 0.05 / 500, 'RelTol', 1e-12, [name ': calxy of a diagonal reference']);
        [xc, ~] = calibrate.apply_xy(px_x(1), px_x(2), cal, sz);
        [~, yc] = calibrate.apply_xy(px_y(1), px_y(2), cal, sz);
        helper_verify_near(testCase, xc, true_x_mm / 1000, 'AbsTol', 1e-12, [name ': x at the x reference pixel']);
        helper_verify_near(testCase, yc, true_y_mm / 1000, 'AbsTol', 1e-12, [name ': y at the y reference pixel']);
        % the whole grid: x grows along the chosen direction from the reference pixel
        [xc, yc] = calibrate.apply_xy(x, y, cal, sz);
        sx = 1 - 2 * (xd == 2);
        sy = -1 + 2 * (yd == 2);
        helper_truth_verify(testCase, xc, true_x_mm / 1000 + sx * (x - px_x(1)) * cal.calxy, 1e-12, [name ': x grid']);
        helper_truth_verify(testCase, yc, true_y_mm / 1000 - sy * (y - px_y(2)) * cal.calxy, 1e-12, [name ': y grid']);
    end
end
end

function test_calibration_can_be_repeated(testCase)
% toMetric always starts from the pixel data: calibrating twice equals calibrating once
F = testCase.TestData.F;
C = helper_truth_cases();
x = double(testCase.TestData.Res.px.x);
y = double(testCase.TestData.Res.px.y);
T = helper_truth_field(F, x, y);
first = helper_truth_calibrate(testCase.TestData.Res, C(15));   % ref, x left, y down
for k = [1 8 18]
    r = helper_truth_calibrate(first, C(k));
    E = helper_truth_expected(T, C(k), x, y, F.size);
    helper_truth_verify(testCase, r.x, E.x, 1e-6, [C(k).name ' after ' C(15).name ': x']);
    helper_truth_verify(testCase, r.v(:, :, 1), E.v, 1e-12, [C(k).name ' after ' C(15).name ': v']);
    helper_truth_verify(testCase, r.w(:, :, 1), E.w, 1e-12, [C(k).name ' after ' C(15).name ': w']);
end
end
