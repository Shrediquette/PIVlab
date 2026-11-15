function tests = test_api_coordinate_system
%TEST_API_COORDINATE_SYSTEM PIV analysis of particle images with a known flow (rotation, expansion and
%   strain): the derived quantities and the exported image have the right sign and value for all four
%   axis settings (x, y, z right-handed, z = x cross y), calibrated and in pixels. No PIVlab window.
%   Run with: results = runtests('unittests/test_api_coordinate_system.m')
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
helper_setup_once(testCase);
F = helper_coordinate_flow(testCase.TestData.Dir);
testCase.TestData.F = F;
imgs = pivlab.readImages(F.files, "pairwise");
testCase.TestData.Res = pivlab.analyze(imgs, Verbose=false);
end

function teardownOnce(testCase)
helper_teardown_once(testCase);
end

function test_analysis_in_pixels_default_axes(testCase)
% no calibration: x right, y up, px and px/frame
F = testCase.TestData.F;
res = testCase.TestData.Res;
testCase.verifyEqual(res.units, "px/frame");
testCase.verifyEqual([res.calibration.x_axis_direction res.calibration.y_axis_direction], [1 2]);
% y is counted from the bottom edge, v is positive upward
testCase.verifyLessThan(res.y(2,1) - res.y(1,1), 0, 'y must grow upward');
[u_px, v_px] = helper_coordinate_flow_field(F, double(res.px.x), double(res.px.y));
inner = interior(res.u);
testCase.verifyLessThan(median(abs(res.v(inner) - (-v_px(inner)))), 0.05, 'v positive upward');
testCase.verifyLessThan(median(abs(res.u(inner) - u_px(inner))), 0.05, 'u positive to the right');
check_derived(testCase, res, helper_coordinate_expected(F, 1, 2, 1));
end

function test_analysis_all_axis_settings(testCase)
F = testCase.TestData.F;
res = testCase.TestData.Res;
xnames = ["right", "left"];
ynames = ["down", "up"];
lic_default = [];
for xd = 1:2
    for yd = 1:2
        E = helper_coordinate_expected(F, xd, yd, 0.002);
        m = pivlab.toMetric(res, DeltaT=0.002, PxPerMeter=5000, XAxis=xnames(xd), YAxis=ynames(yd), Verbose=false);
        check_derived(testCase, m, E);
        % LIC is drawn on the image: the same picture for every axis setting (same random texture)
        rng(1);
        [~, lic] = pivlab.derive(m, "lic");
        if isempty(lic_default)
            lic_default = lic;
        else
            testCase.verifyEqual(lic, lic_default, [E.name ': LIC image']);
        end
    end
end
end

function test_image_export(testCase)
% exported image of the vorticity (grey colour map, opaque): bright = positive, dark = negative
F = testCase.TestData.F;
res = testCase.TestData.Res;
xnames = ["right", "left"];
ynames = ["down", "up"];
cases = [1 2; 2 2; 2 1; 1 1];   % x right y up (default), x left y up, x left y down, x right y down
for k = 1:size(cases, 1)
    xd = cases(k, 1);
    yd = cases(k, 2);
    E = helper_coordinate_expected(F, xd, yd, 0.002);
    m = pivlab.toMetric(res, DeltaT=0.002, PxPerMeter=5000, XAxis=xnames(xd), YAxis=ynames(yd), Verbose=false);
    m = pivlab.derive(m, "vorticity");
    fig = figure('Visible', 'off');
    ax = axes(fig);
    pivlab.display(m, Overlay="vorticity", Colormap="gray", ColorLimits=[-2 2] * abs(E.vorticity), ...
        Alpha=1, Background="black", Vectors=false, Colorbar="none", Title="", Parent=ax);
    file = fullfile(testCase.TestData.Dir, sprintf('vorticity_%d.png', k));
    exportgraphics(ax, file, 'Resolution', 72);
    close(fig);
    grey = centre_grey(file);
    % +vorticity at 3/4 of the grey scale, -vorticity at 1/4
    testCase.verifyEqual(grey, 0.5 + 0.25 * sign(E.vorticity), 'AbsTol', 0.08, [E.name ': grey value of the exported image']);
end
end

%% ------------------------------------------------------------------ local functions

function check_derived(testCase, res, E)
[~, vort] = pivlab.derive(res, "vorticity");
[~, div] = pivlab.derive(res, "divergence");
[~, strain] = pivlab.derive(res, "strain");
[~, q] = pivlab.derive(res, "qcriterion");
vort = double(vort); div = double(div); strain = double(strain); q = double(q);
inner = interior(vort);
tol = 0.06 * abs(E.vorticity);   % PIV error of the gradients
testCase.verifyEqual(median(vort(inner)), E.vorticity, 'AbsTol', tol, [E.name ': vorticity']);
testCase.verifyEqual(median(div(inner)), E.divergence, 'AbsTol', tol, [E.name ': divergence']);
testCase.verifyEqual(median(strain(inner)), E.strain, 'AbsTol', tol, [E.name ': simple strain rate']);
testCase.verifyEqual(median(q(inner)), E.q, 'AbsTol', 0.15 * abs(E.q), [E.name ': Q criterion']);
% the exported vorticity is the curl of the exported velocities in the exported coordinates
[~, dudy] = gradient(double(res.u), res.x(1, :), res.y(:, 1));
[dvdx, ~] = gradient(double(res.v), res.x(1, :), res.y(:, 1));
curl_user = dvdx - dudy;
testCase.verifyEqual(median(curl_user(inner)), median(vort(inner)), 'AbsTol', 0.02 * abs(E.vorticity), ...
    [E.name ': vorticity = dv/dx - du/dy of res.x, res.y, res.u, res.v']);
end

function inner = interior(map)
% central half of the vector field (away from the edges)
inner = false(size(map));
r = round(size(map, 1) / 4) : round(3 * size(map, 1) / 4);
c = round(size(map, 2) / 4) : round(3 * size(map, 2) / 4);
inner(r, c) = true;
end

function grey = centre_grey(file)
I = im2double(imread(file));
if size(I, 3) == 3
    I = mean(I, 3);
end
r = round(size(I, 1) * 0.35) : round(size(I, 1) * 0.65);
c = round(size(I, 2) * 0.35) : round(size(I, 2) * 0.65);
grey = median(I(r, c), 'all');
end
