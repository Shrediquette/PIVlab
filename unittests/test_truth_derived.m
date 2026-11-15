function tests = test_truth_derived
%TEST_TRUTH_DERIVED Every derived quantity of pivlab.derive ("Plot -> Derive parameters") against the
%   analytic truth, for all axis settings and calibrations of helper_truth_cases and three flows
%   (linear, quadratic, Oseen vortex): u, v, w, magnitude (2D and 3D), direction, vorticity,
%   divergence, Q criterion, shear rate, simple strain rate, correlation coefficient, uncertainty,
%   Subtract, smoothing of a linear field, LIC streak direction. No PIV error, no PIVlab window.
%   Run with: run_pivlab_tests('test_truth_derived')
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
helper_setup_once(testCase);
names = {'linear', 'quadratic', 'oseen'};
for i = 1:numel(names)
    F = helper_truth_flow(names{i});
    folder = fullfile(testCase.TestData.Dir, names{i});
    mkdir(folder);
    testCase.TestData.(names{i}).F = F;
    testCase.TestData.(names{i}).Res = helper_truth_result(F, folder, 1, false);
    testCase.TestData.(names{i}).Res3 = helper_truth_result(F, folder, 1, true);
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

function test_linear_flow(testCase)
% central differences are exact for a linear field (also at the border)
check_flow(testCase, testCase.TestData.linear, 1e-5, false);   % the PIV grid and the derived maps are single precision
end

function test_quadratic_flow(testCase)
% central differences are exact for a quadratic field inside; the border uses one-sided differences
check_flow(testCase, testCase.TestData.quadratic, 1e-5, true);
end

function test_oseen_vortex(testCase)
% curved field: the finite differences on the 16 px grid have a discretization error
check_flow(testCase, testCase.TestData.oseen, 0.05, true);   % about 3 % at the vortex centre (rc = 4 vector spacings)
end

function test_correlation_and_uncertainty(testCase)
D = testCase.TestData.linear;
C = helper_truth_cases();
for k = 1:numel(C)
    r = helper_truth_calibrate(D.Res, C(k));
    [~, m] = pivlab.derive(r, "correlation");
    helper_truth_verify(testCase, m, D.Res.correlation_map, 1e-12, [C(k).name ': correlation coefficient (no units)']);
    [~, m] = pivlab.derive(r, "uncertainty");
    E = helper_truth_expected(helper_truth_field(D.F, 0, 0), C(k), 0, 0, D.F.size);
    helper_truth_verify(testCase, m, D.Res.px.uncertainty * E.fv, 1e-12, [C(k).name ': uncertainty']);
end
end

function test_subtract(testCase)
% Subtract [su sv] (units of the result) is removed from u, v, magnitude and direction
D = testCase.TestData.linear;
C = helper_truth_cases();
x = double(D.Res.px.x);
y = double(D.Res.px.y);
T = helper_truth_field(D.F, x, y);
for k = 1:numel(C)
    r = helper_truth_calibrate(D.Res, C(k));
    E = helper_truth_expected(T, C(k), x, y, D.F.size);
    su = 0.3 * max(abs(E.u(:)));
    sv = -0.2 * max(abs(E.v(:)));
    [~, m] = pivlab.derive(r, "u", Subtract=[su sv]);
    helper_truth_verify(testCase, m, E.u - su, 1e-12, [C(k).name ': u - Subtract']);
    [~, m] = pivlab.derive(r, "v", Subtract=[su sv]);
    helper_truth_verify(testCase, m, E.v - sv, 1e-12, [C(k).name ': v - Subtract']);
    [~, m] = pivlab.derive(r, "magnitude", Subtract=[su sv]);
    helper_truth_verify(testCase, m, sqrt((E.u - su).^2 + (E.v - sv).^2), 1e-12, [C(k).name ': magnitude - Subtract']);
    [~, m] = pivlab.derive(r, "direction", Subtract=[su sv]);
    verify_angle(testCase, m, atan2d(E.v - sv, E.u - su), [C(k).name ': direction - Subtract']);
    % the gradients do not change
    [~, m] = pivlab.derive(r, "vorticity", Subtract=[su sv]);
    helper_truth_verify(testCase, m, E.vorticity, 1e-5, [C(k).name ': vorticity with Subtract']);
end
end

function test_spatial_smoothing_keeps_linear_field(testCase)
% smoothing (smoothn, default strength 0.3) of a linear field: smoothing changes the gradients near
% the border (vorticity about 23 % off in the outermost vectors, 3 % two vectors inside, 0.1 % in the
% middle), so the smoothed results get a larger tolerance; sign and size must still be right everywhere.
D = testCase.TestData.linear;
x = double(D.Res.px.x);
y = double(D.Res.px.y);
T = helper_truth_field(D.F, x, y);
C = helper_truth_cases('short');
for k = 1:numel(C)
    r = helper_truth_calibrate(D.Res, C(k));
    E = helper_truth_expected(T, C(k), x, y, D.F.size);
    [r2, m] = pivlab.derive(r, "vorticity", Smoothing="spatial");
    helper_truth_verify(testCase, m, E.vorticity, 0.3, [C(k).name ': vorticity of the smoothed linear field']);
    helper_truth_verify(testCase, r2.u, E.u, 0.01, [C(k).name ': smoothed u']);
    helper_truth_verify(testCase, r2.v, E.v, 0.01, [C(k).name ': smoothed v']);
    testCase.verifyTrue(r2.smoothed, [C(k).name ': result is marked as smoothed']);
end
end

function test_lic_streaks_follow_the_flow(testCase)
% LIC: the texture is smeared along the flow. For a flow along x (y) the image changes much less
% along x (y) than across. The LIC is drawn on the image, so this holds for all axis settings.
D = testCase.TestData.linear;
x = double(D.Res.px.x);
C = helper_truth_cases('short');
dirs = {'x', 'y'};
for k = 1:numel(C)
    for d = 1:2
        if d == 1
            u = 2 + zeros(size(x));
            v = zeros(size(x));
        else
            u = zeros(size(x));
            v = 2 + zeros(size(x));
        end
        r = helper_truth_set(D.Res, u, v, []);
        r = helper_truth_calibrate(r, C(k));
        rng(3);
        [~, lic] = pivlab.derive(r, "lic", LICSize=300);
        lic = double(lic);
        b = round(0.1 * size(lic, 1));
        lic = lic(b:end-b, b:end-b);
        along_x = mean(abs(diff(lic, 1, 2)), 'all');
        along_y = mean(abs(diff(lic, 1, 1)), 'all');
        name = sprintf('%s: LIC of a flow along image %s', C(k).name, dirs{d});
        if d == 1
            testCase.verifyLessThan(along_x, 0.5 * along_y, name);
        else
            testCase.verifyLessThan(along_y, 0.5 * along_x, name);
        end
    end
end
end

%% ------------------------------------------------------------------ local functions

function check_flow(testCase, D, reltol, skip_border)
x = double(D.Res.px.x);
y = double(D.Res.px.y);
T = helper_truth_field(D.F, x, y);
inner = true(size(x));
if skip_border
    inner(:) = false;
    inner(2:end-1, 2:end-1) = true;
end
C = helper_truth_cases();
for k = 1:numel(C)
    c = C(k);
    E = helper_truth_expected(T, c, x, y, D.F.size);
    r = helper_truth_calibrate(D.Res, c);
    name = [D.F.name ', ' c.name];
    % velocity components and magnitude: no finite differences, exact everywhere
    [~, m] = pivlab.derive(r, "u");
    helper_truth_verify(testCase, m, E.u, 1e-12, [name ': u']);
    [~, m] = pivlab.derive(r, "v");
    helper_truth_verify(testCase, m, E.v, 1e-12, [name ': v']);
    [~, m] = pivlab.derive(r, "magnitude");
    helper_truth_verify(testCase, m, E.magnitude, 1e-12, [name ': magnitude']);
    [~, m] = pivlab.derive(r, "direction");
    verify_angle(testCase, m, E.direction, [name ': direction']);
    % gradients, compared with the size of the velocity gradients (the divergence can be 0)
    g = max([abs(E.vorticity(inner)); abs(E.divergence(inner)); abs(E.strain(inner)); abs(E.shear(inner))]);
    [~, m] = pivlab.derive(r, "vorticity");
    helper_truth_verify(testCase, m, E.vorticity, reltol, [name ': vorticity'], inner, g);
    [~, m] = pivlab.derive(r, "divergence");
    helper_truth_verify(testCase, m, E.divergence, reltol, [name ': divergence'], inner, g);
    [~, m] = pivlab.derive(r, "strain");
    helper_truth_verify(testCase, m, E.strain, reltol, [name ': simple strain rate'], inner, g);
    [~, m] = pivlab.derive(r, "shear");
    helper_truth_verify(testCase, m, E.shear, reltol, [name ': shear rate'], inner, g);
    [~, m] = pivlab.derive(r, "qcriterion");
    helper_truth_verify(testCase, m, E.qcriterion, 2 * reltol, [name ': Q criterion'], inner, g^2);
    % stereo: w and the 3D magnitude
    r3 = helper_truth_calibrate(D.Res3, c);
    [~, m] = pivlab.derive(r3, "w");
    helper_truth_verify(testCase, m, E.w, 1e-12, [name ': w']);
    [~, m] = pivlab.derive(r3, "magnitude");
    helper_truth_verify(testCase, m, E.magnitude3, 1e-12, [name ': 3D magnitude']);
    [~, m] = pivlab.derive(r3, "vorticity");
    helper_truth_verify(testCase, m, E.vorticity, reltol, [name ': vorticity of a stereo result'], inner, g);
end
end

function verify_angle(testCase, actual, expected, name)
d = mod(double(actual) - double(expected) + 180, 360) - 180;
testCase.verifyLessThanOrEqual(max(abs(d(:))), 1e-9, sprintf('%s: max deviation %.3g deg', name, max(abs(d(:)))));
end
