function tests = test_core_coordinate_system
%TEST_CORE_COORDINATE_SYSTEM x, y, z form a right-handed coordinate system (z = x cross y) for all four
%   axis settings of the calibration, calibrated and in pixels: vorticity, the other derived quantities,
%   w (stereo-PIV), the coordinates and the texts. Analytic test flow, no PIV, no PIVlab window.
%   Run with: results = runtests('unittests/test_core_coordinate_system.m')
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
helper_setup_once(testCase);
end

function teardownOnce(testCase)
helper_teardown_once(testCase);
end

function test_defaults_are_x_right_y_up(testCase)
d = gui.default_settings();
testCase.verifyEqual(d.calibration.x_axis_direction, 1);
testCase.verifyEqual(d.calibration.y_axis_direction, 2);
[calu, calv] = calibrate.uncalibrated_factors(1, 2);
testCase.verifyEqual([calu calv], [1 -1]);
[calu, calv] = calibrate.uncalibrated_factors(2, 1);
testCase.verifyEqual([calu calv], [-1 1]);
s = pivlab.defaults();
testCase.verifyEqual([s.calibration.x_axis_direction s.calibration.y_axis_direction], [1 2]);
testCase.verifyEqual([s.calibration.calu s.calibration.calv], [1 -1]);
end

function test_derived_quantities_calibrated(testCase)
check_all_axis_settings(testCase, 0.002, 5000);
end

function test_derived_quantities_in_pixels(testCase)
check_all_axis_settings(testCase, 1, 1);
end

function test_coordinates(testCase)
F = helper_coordinate_flow();
H = F.size(1);
W = F.size(2);
[x, y] = meshgrid(16:16:496, 16:16:496);
for xd = 1:2
    for yd = 1:2
        E = helper_coordinate_expected(F, xd, yd, 1);
        cal = calibrate.compute_calibration([0 0; 5000 0], 1000, 2, xd, yd, [], [], F.size);
        [xc, yc] = calibrate.apply_xy(x, y, cal, F.size);
        % x grows in the direction set by the user, the origin is the image corner where both start
        testCase.verifyEqual(sign(xc(1, 2) - xc(1, 1)), E.sx, [E.name ': x direction']);
        testCase.verifyEqual(sign(yc(1, 1) - yc(2, 1)), E.sy, [E.name ': y direction (+1 = up)']);
        if xd == 1
            helper_verify_near(testCase, xc, x / 5000, 'AbsTol', 1e-12);
        else
            helper_verify_near(testCase, xc, (W - x) / 5000, 'AbsTol', 1e-12);
        end
        if yd == 1
            helper_verify_near(testCase, yc, y / 5000, 'AbsTol', 1e-12);
        else
            helper_verify_near(testCase, yc, (H - y) / 5000, 'AbsTol', 1e-12);
        end
    end
end
end

function test_w_along_z(testCase)
% stereo-PIV: W of the reconstruction is positive away from the cameras (image coordinates x right,
% y down). The w of the user is positive along z = x cross y.
F = helper_coordinate_flow();
[x, y] = meshgrid(16:16:496, 16:16:496);
[u, v] = helper_coordinate_flow_field(F, x, y);
W_away = 0.7 + zeros(size(x));   % px per frame, away from the cameras
for xd = 1:2
    for yd = 1:2
        E = helper_coordinate_expected(F, xd, yd, 0.002);
        cal = calibrate.compute_calibration([0 0; 5000 0], 1000, 2, xd, yd, [], [], F.size);
        opts.w = W_away;
        w = plot.compute_derived(x, y, u, v, 14, cal, opts);
        % z toward the viewer (E.z = +1) means: w is positive toward the cameras, i.e. -W_away
        expected = -E.z * 0.7 / 5000 / 0.002;
        helper_verify_near(testCase, w, expected + zeros(size(w)), 'RelTol', 1e-12);
        testCase.verifyEqual(calibrate.w_factor(cal.calu, cal.calv), -E.z * abs(cal.calu), [E.name ': w_factor']);
        % the 3D magnitude does not depend on the axes
        m = plot.compute_derived(x, y, u, v, 3, cal, opts);
        m0 = sqrt((u * cal.calu).^2 + (v * cal.calv).^2 + (W_away * abs(cal.calu)).^2);
        helper_verify_near(testCase, m, m0, 'RelTol', 1e-12);
        % text of the exports
        positive = stereo.w_direction([], calibrate.w_factor(cal.calu, cal.calv));
        if E.z > 0
            testCase.verifyEqual(positive, 'toward the cameras', E.name);
        else
            testCase.verifyEqual(positive, 'away from the cameras', E.name);
        end
    end
end
testCase.verifyEqual(stereo.w_direction([]), 'away from the cameras', 'W of the reconstruction');
end

function test_statistic_factors(testCase)
% temporal statistics: mean/sum like velocities, standard deviation |cal|, TKE cal^2 (never negative)
for calu = [-0.5 0.5]
    for calv = [-0.25 0.25]
        f = calibrate.statistic_factors(calu, calv, 'mean');
        testCase.verifyEqual([f.u f.v f.w], [calu calv calibrate.w_factor(calu, calv)]);
        f = calibrate.statistic_factors(calu, calv, '');
        testCase.verifyEqual([f.u f.v f.w], [calu calv calibrate.w_factor(calu, calv)]);
        f = calibrate.statistic_factors(calu, calv, "std");
        testCase.verifyEqual([f.u f.v f.w], abs([calu calv calu]));
        f = calibrate.statistic_factors(calu, calv, "tke");
        testCase.verifyEqual([f.u f.v f.w], [calu calv calu].^2);
    end
end
% total TKE of a frame (magnitude): sum of the components in velocity units squared
[x, y] = meshgrid(16:16:496, 16:16:496);
tu = 2 + zeros(size(x)); tv = 3 + zeros(size(x)); tw = 5 + zeros(size(x));
cal = calibrate.compute_calibration([0 0; 5000 0], 1000, 2, 2, 2, [], [], [512 512]);   % x left, y up
opts.statistic = 'tke';
opts.w = tw;
total = plot.compute_derived(x, y, tu, tv, 3, cal, opts);
helper_verify_near(testCase, total, (2 + 3 + 5) * cal.calu^2 + zeros(size(x)), 'RelTol', 1e-12);
end

%% ------------------------------------------------------------------ local functions

function check_all_axis_settings(testCase, dt, px_per_m)
% dt in s and px_per_m; dt = 1 and px_per_m = 1: uncalibrated (px, px/frame)
F = helper_coordinate_flow();
[x, y] = meshgrid(16:16:496, 16:16:496);
[u, v] = helper_coordinate_flow_field(F, x, y);
inner = false(size(x));
inner(2:end-1, 2:end-1) = true;
shear_default = [];
for xd = 1:2
    for yd = 1:2
        E = helper_coordinate_expected(F, xd, yd, dt);
        if px_per_m == 1
            [cal.calu, cal.calv] = calibrate.uncalibrated_factors(xd, yd);
            cal.calxy = 1;
            cal.x_axis_direction = xd;
            cal.y_axis_direction = yd;
        else
            cal = calibrate.compute_calibration([0 0; px_per_m 0], 1000, dt * 1000, xd, yd, [], [], F.size);
        end
        f = 1 / (px_per_m * dt);                          % px/frame -> velocity unit
        % velocity components of the user: along the user's axes
        u_user = E.sx * u * f;
        v_user = E.sy * (-v) * f;                         % -v: upward on the screen
        verify_map(testCase, plot.compute_derived(x, y, u, v, 4, cal), u_user, inner, [E.name ': u']);
        verify_map(testCase, plot.compute_derived(x, y, u, v, 5, cal), v_user, inner, [E.name ': v']);
        verify_map(testCase, plot.compute_derived(x, y, u, v, 3, cal), sqrt(u_user.^2 + v_user.^2), inner, [E.name ': magnitude']);
        verify_map(testCase, plot.compute_derived(x, y, u, v, 11, cal), atan2d(v_user, u_user), inner, [E.name ': direction']);
        % gradients (linear field: exact)
        verify_map(testCase, plot.compute_derived(x, y, u, v, 2, cal), E.vorticity + zeros(size(x)), inner, [E.name ': vorticity']);
        verify_map(testCase, plot.compute_derived(x, y, u, v, 6, cal), E.divergence + zeros(size(x)), inner, [E.name ': divergence']);
        verify_map(testCase, plot.compute_derived(x, y, u, v, 9, cal), E.strain + zeros(size(x)), inner, [E.name ': simple strain']);
        verify_map(testCase, plot.compute_derived(x, y, u, v, 7, cal), E.q + zeros(size(x)), inner, [E.name ': Q criterion']);
        shear = plot.compute_derived(x, y, u, v, 8, cal);
        if isempty(shear_default)
            shear_default = shear;
        else
            verify_map(testCase, shear, shear_default, inner, [E.name ': shear rate (independent of the axes)']);
        end
    end
end
end

function verify_map(testCase, actual, expected, inner, name)
a = actual(inner);
e = expected(inner);
tol = 1e-9 * max(abs(e(:))) + 1e-12;
testCase.verifyLessThanOrEqual(max(abs(a - e)), tol, name);
end
