function tests = test_gui_truth
%TEST_GUI_TRUTH PIVlab window: the numbers the user sees and exports, against the analytic truth, for all
%   axis settings and calibrations of helper_truth_cases. An analytic field (no PIV error) replaces the
%   result of a quick analysis of noise images. Checked: calibration factors, all derived parameters,
%   ASCII (values and unit texts), Tecplot, Paraview VTK, MAT file, workspace, poly-line extraction (u,
%   tangent, normal velocity, distance, coordinates), circle (tangent velocity, circulation of a circle
%   series), area extraction (area, mean, integral = circulation).
%   File dialogs are replaced by unittests/parity/mocks; offsets are set without the input dialog.
%   Run with: run_pivlab_tests('test_gui_truth')
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
helper_setup_once(testCase);
addpath(fullfile(testCase.TestData.Root, 'unittests', 'parity', 'mocks'), '-begin');   % uiputfile
sz = [320 320];
files = cell(4, 1);   % two image pairs (frames 1 and 2)
rng(7);
for k = 1:4
    files{k} = fullfile(testCase.TestData.Dir, sprintf('noise_%d.tif', k));
    imwrite(uint8(255 * rand(sz)), files{k});
end
helper_close_pivlab();
helper_start_pivlab();
h = gui.gethand;
set(h.pass1_size, 'String', '32');   % 16 px vector grid, one pass
piv.intarea_Callback(h.pass1_size, [], []);
set(h.pass1_step, 'String', '16');
piv.step_Callback(h.pass1_step, [], []);
set(h.pass2_enable, 'Value', 0);
piv.pass2_checkbox_Callback(h.pass2_enable, [], []);
helper_gui_load_images(files, 1);
helper_gui_analyze();
testCase.TestData.size = sz;
end

function teardownOnce(testCase)
helper_close_pivlab();
rmpath(fullfile(testCase.TestData.Root, 'unittests', 'parity', 'mocks'));
setappdata(0, 'parity_mock_file', []);
helper_teardown_once(testCase);
end

function setup(testCase)
helper_truth_log(testCase, 'start');
end

function teardown(testCase)
helper_truth_log(testCase, 'end');
end

function test_calibration_and_derived_parameters(testCase)
for name = {'linear', 'quadratic'}
    F = helper_truth_flow(name{1}, testCase.TestData.size);
    [x, y, T] = put_field(F);
    inner = false(size(x));
    inner(2:end-1, 2:end-1) = true;
    C = helper_truth_cases();
    for k = 1:numel(C)
        c = C(k);
        label = [F.name ', ' c.name];
        set_calibration(c, F.size);
        helper_verify_near(testCase, gui.retr('calxy'), c.calxy, 'RelTol', 1e-12, [label ': calxy']);
        helper_verify_near(testCase, gui.retr('calu'), c.sx * c.calxy / c.t, 'RelTol', 1e-12, [label ': calu']);
        helper_verify_near(testCase, gui.retr('calv'), -c.sy * c.calxy / c.t, 'RelTol', 1e-12, [label ': calv']);
        E = helper_truth_expected(T, c, x, y, F.size);
        [xc, yc] = calibrate.xy(x, y);
        helper_truth_verify(testCase, xc, E.x, 1e-6, [label ': x']);
        helper_truth_verify(testCase, yc, E.y, 1e-6, [label ': y']);
        g = max([abs(E.vorticity(:)); abs(E.divergence(:)); abs(E.strain(:)); abs(E.shear(:))]);
        list = {2, 'vorticity', 1e-5, g; 3, 'magnitude', 1e-12, []; 4, 'u', 1e-12, []; 5, 'v', 1e-12, []; ...
            6, 'divergence', 1e-5, g; 7, 'qcriterion', 2e-5, g^2; 8, 'shear', 1e-5, g; 9, 'strain', 1e-5, g};
        for q = 1:size(list, 1)
            m = derived_map(list{q, 1});
            helper_truth_verify(testCase, m, E.(list{q, 2}), list{q, 3}, [label ': ' list{q, 2}], inner, list{q, 4});
        end
        d = mod(double(derived_map(11)) - E.direction + 180, 360) - 180;
        testCase.verifyLessThan(max(abs(d(:))), 1e-6, [label ': direction']);
        helper_truth_verify(testCase, derived_map(12), correlation_truth(x), 1e-6, [label ': correlation coefficient']);
        helper_truth_verify(testCase, derived_map(13), uncertainty_truth(x) * E.fv, 1e-6, [label ': uncertainty']);
    end
end
end

function test_ascii_tecplot_vtk_mat_workspace(testCase)
h = gui.gethand;
folder = testCase.TestData.Dir;
F = helper_truth_flow('quadratic', testCase.TestData.size);
[x, y, T] = put_field(F);
gs = size(x);
inner = false(gs);
inner(2:end-1, 2:end-1) = true;
C = helper_truth_cases();
for k = 1:numel(C)
    c = C(k);
    label = c.name;
    set_calibration(c, F.size);
    E = helper_truth_expected(T, c, x, y, F.size);
    g = max([abs(E.vorticity(:)); abs(E.divergence(:)); abs(E.strain(:)); abs(E.shear(:))]);
    % ASCII with all derivatives: x y u v type vorticity magnitude divergence Q shear strain direction corr unc
    set(h.export_vort, 'Value', 1);
    set(h.add_header, 'Value', 1);
    set(h.addfileinfo, 'Value', 0);
    set(h.delimiter, 'Value', 1);
    f = sprintf('ascii_%d.txt', k);
    export.file_save(1, f, folder, 1);
    A = readmatrix(fullfile(folder, f), 'NumHeaderLines', 1);
    lines = readlines(fullfile(folder, f));
    check_header_units(testCase, lines(1), c, true, ['ASCII with derivatives, ' label]);
    check_table(testCase, A, [1 2 3 4 6 7 8 9 10 11 12 13 14], E, x, inner, g, ['ASCII, ' label]);
    testCase.verifyEqual(A(:, 5), ones(numel(x), 1), ['ASCII, ' label ': vector type']);
    % ASCII without derivatives: header units
    set(h.export_vort, 'Value', 0);
    f = sprintf('ascii_plain_%d.txt', k);
    export.file_save(1, f, folder, 1);
    lines = readlines(fullfile(folder, f));
    check_header_units(testCase, lines(1), c, false, ['ASCII without derivatives, ' label]);
    A = readmatrix(fullfile(folder, f), 'NumHeaderLines', 1);
    helper_truth_verify(testCase, A(:, 3), E.u(:), 1e-6, ['ASCII without derivatives, ' label ': u']);
    % file information line: unit of the conversion factor of the velocities
    set(h.addfileinfo, 'Value', 1);
    f = sprintf('ascii_info_%d.txt', k);
    export.file_save(1, f, folder, 1);
    lines = readlines(fullfile(folder, f));
    testCase.verifyTrue(contains(lines(2), "(px/frame -> " + c.units + ")"), ...
        sprintf('ASCII file info, %s: conversion factor uv names the unit %s: "%s"', label, c.units, lines(2)));
    set(h.addfileinfo, 'Value', 0);
    % Tecplot with all derivatives (rows sorted by y): x y u v isNaN vorticity ...
    set(h.export_vort_tec, 'Value', 1);
    f = sprintf('tecplot_%d.dat', k);
    export.file_save(1, f, folder, 4);
    Tp = readmatrix(fullfile(folder, f), 'NumHeaderLines', 6, 'FileType', 'text', 'Delimiter', ' ');
    expected = [E.x(:) E.y(:) E.u(:) E.v(:) E.vorticity(:)];
    Tp = sortrows(Tp, [1 2]);
    [expected, order] = sortrows(expected, [1 2]);
    in = inner(:);
    in = in(order);
    helper_truth_verify(testCase, Tp(:, 1:4), expected(:, 1:4), 1e-6, ['Tecplot, ' label ': x y u v']);
    helper_truth_verify(testCase, Tp(in, 6), expected(in, 5), 1e-5, ['Tecplot, ' label ': vorticity'], [], g);
    % Paraview VTK: points (x, y, 0) and velocity vectors (u, v, 0)
    f = sprintf('paraview_%d.vtk', k);
    export.file_save(1, f, folder, 3);
    [P, V] = read_vtk(fullfile(folder, f), numel(x));
    helper_truth_verify(testCase, P(1, :)', E.x(:), 1e-6, ['VTK, ' label ': x']);
    helper_truth_verify(testCase, P(2, :)', E.y(:), 1e-6, ['VTK, ' label ': y']);
    helper_truth_verify(testCase, V(1, :)', E.u(:), 1e-6, ['VTK, ' label ': u']);
    helper_truth_verify(testCase, V(2, :)', E.v(:), 1e-6, ['VTK, ' label ': v']);
    testCase.verifyEqual(max(abs(V(3, :))), 0, ['VTK, ' label ': w of 2D data']);
    % MAT file with derivatives
    set(h.export_mat_derivatives, 'Value', 1);
    f = sprintf('mat_%d.mat', k);
    export.mat_file_save(1, f, folder, 1);
    M = load(fullfile(folder, f));
    helper_truth_verify(testCase, M.x, E.x, 1e-6, ['MAT, ' label ': x']);
    helper_truth_verify(testCase, M.y, E.y, 1e-6, ['MAT, ' label ': y']);
    helper_truth_verify(testCase, M.u_original, E.u, 1e-6, ['MAT, ' label ': u']);
    helper_truth_verify(testCase, M.v_original, E.v, 1e-6, ['MAT, ' label ': v']);
    helper_truth_verify(testCase, M.vorticity, E.vorticity, 1e-5, ['MAT, ' label ': vorticity'], inner, g);
    helper_truth_verify(testCase, M.divergence, E.divergence, 1e-5, ['MAT, ' label ': divergence'], inner, g);
    helper_truth_verify(testCase, M.strain_rate, E.strain, 1e-5, ['MAT, ' label ': strain rate'], inner, g);
    % workspace
    plot.derivative_calc(1, 2, 1);
    evalc('export.write_workspace_Callback([], [], [])');
    wx = evalin('base', 'x');
    wu = evalin('base', 'u_original');
    wv = evalin('base', 'v_original');
    wvort = evalin('base', 'vorticity');
    helper_truth_verify(testCase, wx{1}, E.x, 1e-6, ['workspace, ' label ': x']);
    helper_truth_verify(testCase, wu{1}, E.u, 1e-6, ['workspace, ' label ': u']);
    helper_truth_verify(testCase, wv{1}, E.v, 1e-6, ['workspace, ' label ': v']);
    helper_truth_verify(testCase, wvort{1}, E.vorticity, 1e-5, ['workspace, ' label ': vorticity'], inner, g);
end
end

function test_polyline_extraction(testCase)
h = gui.gethand;
F = helper_truth_flow('uniform', testCase.TestData.size);
[x, y, T] = put_field(F);
C = helper_truth_cases();
p1 = [60 250];
p2 = [250 70];      % diagonal line: up and to the right on the screen
for k = 1:numel(C)
    c = C(k);
    label = c.name;
    set_calibration(c, F.size);
    E = helper_truth_expected(T, c, x, y, F.size);
    gui.put('extract_type', 'extract_poly');
    gui.put('xposition', [p1(1); p2(1)]);
    gui.put('yposition', [p1(2); p2(2)]);
    set(h.draw_what, 'Value', 1);
    % u along the line (uniform flow: constant)
    [cvals, distance, cx, cy] = extract_line(3);
    helper_truth_verify(testCase, cvals, E.u(1) + zeros(size(cvals)), 1e-6, [label ': u along the line']);
    len = hypot(p2(1) - p1(1), p2(2) - p1(2));
    helper_verify_near(testCase, distance(end), len * c.calxy, 'RelTol', 1e-9, [label ': length of the line']);
    Ee = helper_truth_expected(T, c, [p1(1) p2(1)], [p1(2) p2(2)], F.size);
    helper_verify_near(testCase, [cx(1) cx(end)], Ee.x, 'AbsTol', 1e-6 * max(abs(Ee.x)) + 1e-12, [label ': x of the end points']);
    helper_verify_near(testCase, [cy(1) cy(end)], Ee.y, 'AbsTol', 1e-6 * max(abs(Ee.y)) + 1e-12, [label ': y of the end points']);
    % tangent and normal velocity: unit vector of the line in the user's axes, normal = tangent turned
    % by +90 degrees (counter-clockwise from x to y)
    t = [c.sx * (p2(1) - p1(1)), c.sy * (-(p2(2) - p1(2)))] / len;
    n = [-t(2) t(1)];
    cvals = extract_line(12);
    expected = E.u(1) * t(1) + E.v(1) * t(2);
    helper_truth_verify(testCase, cvals, expected + zeros(size(cvals)), 1e-6, [label ': tangent velocity'], [], E.magnitude(1));
    [cvals, distance] = extract_line(13);
    expected = E.u(1) * n(1) + E.v(1) * n(2);
    helper_truth_verify(testCase, cvals, expected + zeros(size(cvals)), 1e-6, [label ': normal velocity'], [], E.magnitude(1));
    % the integral of the normal velocity along the line (flow rate per depth) = un * length
    helper_verify_near(testCase, trapz(distance, cvals), expected * len * c.calxy, 'RelTol', 1e-6, [label ': flow rate through the line']);
end
end

function test_circle_and_circle_series(testCase)
h = gui.gethand;
F = helper_truth_flow('oseen', testCase.TestData.size);
x = put_field(F);
C = helper_truth_cases();
R = 80;
centre = [F.xc F.yc];
vtheta = F.gamma / (2 * pi * R) * (1 - exp(-R^2 / F.rc^2));     % px per frame, counter-clockwise
for k = 1:numel(C)
    c = C(k);
    label = c.name;
    set_calibration(c, F.size);
    fv = c.calxy / c.t;
    % tangent velocity on a circle: the dot product of velocity and direction of the circle does not
    % depend on the axis settings; the circle of PIVlab runs counter-clockwise on the screen
    gui.put('extract_type', 'extract_circle');
    gui.put('xposition', centre);
    gui.put('yposition', R);
    set(h.draw_what, 'Value', 2);
    cvals = extract_line(12);
    testCase.verifyLessThan(max(abs(cvals - vtheta * fv)), 0.03 * vtheta * fv, ...
        sprintf('%s: tangent velocity on the circle (mean %.4g, truth %.4g)', label, mean(cvals), vtheta * fv));
    % circle series: circulation of every circle = gamma(r) in the user's units (m^2/s)
    gui.put('extract_type', 'extract_circle_series');
    set(h.draw_what, 'Value', 3);
    extract_line(12);
    integral = gui.retr('integral');
    step = double(x(1, 2) - x(1, 1));
    radii = [linspace(step, R - step, round((R - step) / step)) R];
    truth = F.gamma * (1 - exp(-radii.^2 / F.rc^2)) * c.calxy^2 / c.t;
    testCase.verifyEqual(numel(integral), numel(radii), [label ': number of circles']);
    if numel(integral) == numel(radii)
        testCase.verifyLessThan(max(abs(integral(2:end) - truth(2:end))), 0.08 * truth(end), ...
            sprintf('%s: circulation of the circle series (largest %.4g, truth %.4g)', label, integral(end), truth(end)));
    end
    delete(findobj('tag', 'extract_circle_series_max_circulation'));
end
end

function test_area_extraction(testCase)
h = gui.gethand;
% rectangle in a uniform flow: area and mean velocity
F = helper_truth_flow('uniform', testCase.TestData.size);
[x, y, T] = put_field(F);
C = helper_truth_cases();
for k = 1:numel(C)
    c = C(k);
    label = c.name;
    set_calibration(c, F.size);
    E = helper_truth_expected(T, c, x, y, F.size);
    gui.put('extract_type', 'extract_rectangle_area');
    gui.put('xposition', [50 120]);   % x, width (px)
    gui.put('yposition', [60 80]);    % y, height (px)
    set(h.extraction_choice_area, 'Value', 3);   % u
    data = extract.plot_data_area(1, 0);
    helper_verify_near(testCase, data{1}, 120 * 80 * c.calxy^2, 'RelTol', 0.02, [label ': rectangle area']);
    helper_verify_near(testCase, data{2}, E.u(1), 'RelTol', 1e-6, [label ': mean u in the rectangle']);
    helper_verify_near(testCase, data{3}, E.u(1) * data{1}, 'RelTol', 1e-6, [label ': integral of u']);
end
% circle around the Oseen vortex: the area integral of the vorticity is the circulation (sign along z)
F = helper_truth_flow('oseen', testCase.TestData.size);
put_field(F);
R = 80;
for k = 1:numel(C)
    c = C(k);
    label = c.name;
    set_calibration(c, F.size);
    gui.put('extract_type', 'extract_circle_area');
    gui.put('xposition', [F.xc F.yc]);
    gui.put('yposition', R);
    set(h.extraction_choice_area, 'Value', 1);   % vorticity
    data = extract.plot_data_area(1, 0);
    truth = c.sx * c.sy * F.gamma * (1 - exp(-R^2 / F.rc^2)) * c.calxy^2 / c.t;
    helper_verify_near(testCase, data{1}, pi * R^2 * c.calxy^2, 'RelTol', 0.03, [label ': circle area']);
    testCase.verifyLessThan(abs(data{3} - truth), 0.06 * abs(truth), ...
        sprintf('%s: area integral of the vorticity %.4g, circulation %.4g', label, data{3}, truth));
end
end

function test_vector_click_readout(testCase)
% click on a vector: the readout shows x, y, u, v and the displayed derived parameter of that vector
h = gui.gethand;
F = helper_truth_flow('linear', testCase.TestData.size);
[x, y, T] = put_field(F);
ax = gui.retr('pivlab_axis');
C = helper_truth_cases();
picks = [5 7; 12 4; 9 15];   % vectors (row, column), not at the border
for k = 1:numel(C)
    c = C(k);
    set_calibration(c, F.size);
    E = helper_truth_expected(T, c, x, y, F.size);
    set(h.fileselector, 'Value', 1);
    gui.put('displaywhat', 2);   % vorticity
    plot.derivative_calc(1, 2, 1);
    gui.sliderdisp(ax);
    for p = 1:size(picks, 1)
        i = picks(p, 1);
        j = picks(p, 2);
        click_vector(x(i, j), y(i, j));
        label = sprintf('%s, vector (%d,%d)', c.name, i, j);
        fixed_xy = c.kind ~= "px" && all(abs([E.x(i, j) E.y(i, j)]) >= 0.01 & abs([E.x(i, j) E.y(i, j)]) <= 100);
        fixed_uv = c.kind ~= "px" && E.magnitude(i, j) >= 0.01 && E.magnitude(i, j) <= 100;
        fixed_scalar = abs(E.vorticity(i, j)) >= 0.001 && abs(E.vorticity(i, j)) <= 100;
        verify_readout(testCase, readout_number(h.x_cp), E.x(i, j), [label ': x readout'], fixed_xy);
        verify_readout(testCase, readout_number(h.y_cp), E.y(i, j), [label ': y readout'], fixed_xy);
        verify_readout(testCase, readout_number(h.u_cp), E.u(i, j), [label ': u readout'], fixed_uv);
        verify_readout(testCase, readout_number(h.v_cp), E.v(i, j), [label ': v readout'], fixed_uv);
        txt = get(h.scalar_cp, 'String');
        value = str2double(strtrim(txt(find(txt == ':', 1, 'last') + 1:end)));
        verify_readout(testCase, value, E.vorticity(i, j), [label ': vorticity readout'], fixed_scalar);
        % plain decimal format for normal values, also negative ones (exponential only for very
        % small or large values)
        if fixed_xy
            testCase.verifyFalse(contains(get(h.x_cp, 'String'), 'e'), [label ': x readout in decimal format: ' get(h.x_cp, 'String')]);
            testCase.verifyFalse(contains(get(h.y_cp, 'String'), 'e'), [label ': y readout in decimal format: ' get(h.y_cp, 'String')]);
        end
        if fixed_scalar && c.kind ~= "px"
            testCase.verifyFalse(contains(txt(find(txt == ':', 1, 'last') + 1:end), 'e'), [label ': vorticity readout in decimal format: ' txt]);
        end
        if c.kind == "px"
            testCase.verifyTrue(endsWith(strtrim(get(h.u_cp, 'String')), 'px/fr'), [label ': unit of u']);
        elseif c.kind == "disp"
            testCase.verifyTrue(endsWith(strtrim(get(h.u_cp, 'String')), 'm/frame'), [label ': unit of u']);
        else
            testCase.verifyTrue(endsWith(strtrim(get(h.u_cp, 'String')), 'm/s'), [label ': unit of u']);
        end
    end
    delete(findobj(ax, 'tag', 'infopoint'));
end
end

function test_statistics_readout(testCase)
% statistics panel: mean, min, max and std of u and v of the displayed frame; TKE frames in velocity^2
h = gui.gethand;
F = helper_truth_flow('linear', testCase.TestData.size);
du = 0.4;
dv = -0.3;
[x, y, T] = put_field(F, [0 0; du dv]);
C = helper_truth_cases();
for k = 1:numel(C)
    c = C(k);
    put_field(F, [0 0; du dv]);
    set_calibration(c, F.size);
    E = helper_truth_expected(T, c, x, y, F.size);
    set(h.fileselector, 'Value', 1);
    show_statistics(1);
    label = c.name;
    verify_readout(testCase, readout_number(h.meanu), mean(E.u(:)), [label ': mean u'], false);
    verify_readout(testCase, readout_number(h.minu), min(E.u(:)), [label ': min u'], false);
    verify_readout(testCase, readout_number(h.maxu), max(E.u(:)), [label ': max u'], false);
    verify_readout(testCase, readout_number(h.stdu), std(E.u(:)), [label ': std u'], false);
    verify_readout(testCase, readout_number(h.meanv), mean(E.v(:)), [label ': mean v'], false);
    verify_readout(testCase, readout_number(h.stdv), std(E.v(:)), [label ': std v'], false);
    testCase.verifyTrue(endsWith(strtrim(get(h.meanu, 'String')), c.units), [label ': unit of the statistics']);
    % TKE of frames 1 and 2: 0.5*var([u, u+du]) = du^2/4 per vector, in (velocity unit)^2
    set(h.selectedFramesMean, 'String', '1:2');
    set(h.append_replace, 'Value', 2);
    plot.temporal_operation_Callback([], [], 3);
    set(h.fileselector, 'Value', 3);
    show_statistics(3);
    fv = c.calxy / c.t;
    verify_readout(testCase, readout_number(h.meanu), du^2 / 4 * fv^2, [label ': TKE frame, mean u'], false);
    verify_readout(testCase, readout_number(h.meanv), dv^2 / 4 * fv^2, [label ': TKE frame, mean v'], false);
    testCase.verifyTrue(endsWith(strtrim(get(h.meanu, 'String')), "(" + c.units + ")^2"), ...
        sprintf('%s: unit of the TKE frame: "%s"', label, get(h.meanu, 'String')));
    % ASCII export of the TKE frame: values and column unit in (velocity unit)^2
    set(h.export_vort, 'Value', 0); set(h.add_header, 'Value', 1); set(h.addfileinfo, 'Value', 0);
    set(h.delimiter, 'Value', 1);
    file = sprintf('tke_%d.txt', k);
    export.file_save(3, file, testCase.TestData.Dir, 1);
    lines = readlines(fullfile(testCase.TestData.Dir, file));
    testCase.verifyTrue(contains(lines(1), "u [(" + c.units + ")^2]"), sprintf('%s: ASCII header of the TKE frame "%s"', label, lines(1)));
    A = readmatrix(fullfile(testCase.TestData.Dir, file), 'NumHeaderLines', 1);
    helper_truth_verify(testCase, A(:, 3), du^2 / 4 * fv^2 + zeros(size(A, 1), 1), 1e-5, [label ': ASCII TKE u']);
end
end

%% ------------------------------------------------------------------ local functions

function verify_readout(testCase, shown, truth, label, fixed)
% readouts are rounded for display: fixed = true: %0.4f (absolute 5e-5); else %0.4e or num2str
% (about 5 significant digits: relative 1e-4; uncalibrated readouts are rounded to 1e-5 first)
tol = 1e-4 * abs(truth) + 5e-6 + 1e-12;
if fixed
    tol = tol + 5e-5;
end
testCase.verifyLessThanOrEqual(abs(shown - truth), tol, ...
    sprintf('%s: shown %.6g, truth %.6g', label, shown, truth));
end

function [x, y, T] = put_field(F, offsets)
% replace the PIV results of frames 1 and 2 by the analytic field (px per frame, v downward).
% offsets [du1 dv1; du2 dv2] (px per frame, v downward) are added to frame 1 and 2 (default 0).
% Statistics frames (temporal operations) after frame 2 are removed.
if nargin < 2
    offsets = zeros(2, 2);
end
rl = gui.retr('resultslist');
rl = rl(:, 1:2);
x = double(rl{1, 1});
y = double(rl{2, 1});
T = helper_truth_field(F, x, y);
for f = 1:2
    rl{1, f} = rl{1, 1};
    rl{2, f} = rl{2, 1};
    rl{3, f} = T.u + offsets(f, 1);
    rl{4, f} = T.v + offsets(f, 2);
    rl{5, f} = ones(size(x));
    for r = [6 7 8 9 10 11 13 14]
        rl{r, f} = [];
    end
    rl{12, f} = correlation_truth(x);
    rl{15, f} = uncertainty_truth(x);
end
gui.put('resultslist', rl);
remove_statistics_frames();
gui.put('derived', []);
gui.put('subtr_u', 0);
gui.put('subtr_v', 0);
end

function show_statistics(frame)
% the statistics panel of a frame, as gui.sliderdisp fills it when the panel is visible
rl = gui.retr('resultslist');
[x, y, u, v, ~, w] = plot.get_desired_u_and_v(rl, 2 * frame - 1);
plot.update_Stats(x, y, u, v, w);
end

function remove_statistics_frames()
% keep only the two analyzed image pairs (removes frames of earlier temporal statistics)
for name = {'filepath', 'filename', 'framenum', 'framepart'}
    value = gui.retr(name{1});
    if size(value, 1) > 4
        gui.put(name{1}, value(1:4, :));
    end
end
gui.put('ismean', []);
gui.sliderrange(1);
end

function value = readout_number(control)
% the number in a readout text like "u:-0.1234 m/s" or "-1.2e-05 (m/s)^2"
txt = get(control, 'String');
if iscell(txt)
    txt = txt{1};
end
token = regexp(txt, '[-+]?(\d+\.?\d*|\.\d+)([eE][-+]?\d+)?', 'match', 'once');
value = str2double(token);
end

function m = correlation_truth(x)
m = 0.5 + 0.4 * x / max(x(:));
end

function m = uncertainty_truth(x)
[rows, ~] = ndgrid(1:size(x, 1), 1:size(x, 2));
m = 0.01 + 0.001 * rows;
end

function set_calibration(c, sz)
% the calibration controls of the PIVlab window, applied without dialogs
h = gui.gethand;
set(h.x_axis_direction, 'Value', c.xdir);
set(h.y_axis_direction, 'Value', c.ydir);
data = struct('pointscali', [], 'points_offsetx', [], 'points_offsety', [], 'size_of_the_image', sz);
switch c.kind
    case 'px'
        set(h.realdist, 'String', '1');
        set(h.time_inp, 'String', '1');
    case 'ref'
        data.pointscali = [0 0; c.ref(1) 0];
        set(h.realdist, 'String', num2str(c.ref(2) * 1000, 12));
        set(h.time_inp, 'String', num2str(c.dt * 1000, 12));
    otherwise
        data.pointscali = [0 0; c.px_per_m * 0.1 0];   % 100 mm
        set(h.realdist, 'String', '100');
        set(h.time_inp, 'String', num2str(c.dt * 1000, 12));
end
if ~isempty(c.origin)
    data.points_offsetx = [c.origin 0];   % this pixel has x = 0 mm
    data.points_offsety = [c.origin 0];   % and y = 0 mm
end
calibrate.apply_calibration_data(data);
extract.update_choice_lists(h);   % extraction lists with the units (filled when the panel opens)
gui.put('derived', []);
end

function m = derived_map(d)
plot.derivative_calc(1, d, 1);
derived = gui.retr('derived');
m = double(derived{d - 1, 1});
end

function [c, distance, cx, cy] = extract_line(choice)
% poly-line / circle extraction of frame 1 without the plot window (A.Tag = frame number)
h = gui.gethand;
set(h.extraction_choice, 'Value', choice);
A.Tag = 1;
extract.plot_data_Callback(A, [], []);
c = double(gui.retr('c'));
c = c(:);
distance = double(gui.retr('distance'));
distance = distance(:);
cx = double(gui.retr('cx'));
cy = double(gui.retr('cy'));
if ~isvector(cx)
    cx = cx(end, :);
    cy = cy(end, :);
end
end

function check_header_units(testCase, line, c, with_derivatives, label)
switch c.units
    case "px/frame"
        unit = "px/frame";
        xunit = "px";
    case "m/frame"
        unit = "m/frame";
        xunit = "m";
    otherwise
        unit = "m/s";
        xunit = "m";
end
testCase.verifyTrue(contains(line, "x [" + xunit + "]"), sprintf('%s: x unit in "%s"', label, line));
testCase.verifyTrue(contains(line, "u [" + unit + "]") && contains(line, "v [" + unit + "]"), ...
    sprintf('%s: velocity unit %s in "%s"', label, unit, line));
if with_derivatives
    testCase.verifyTrue(contains(line, "magnitude [" + unit + "]"), sprintf('%s: magnitude unit', label));
end
end

function check_table(testCase, A, cols, E, x, inner, g, label)
% ASCII columns: x y u v type vorticity magnitude divergence Q shear strain direction corr unc
gs = size(x);
names = {'x', 'y', 'u', 'v', 'vorticity', 'magnitude', 'divergence', 'qcriterion', 'shear', 'strain'};
tols = [1e-6 1e-6 1e-6 1e-6 1e-5 1e-6 1e-5 2e-5 1e-5 1e-5];   % exported values are single precision
scales = {[], [], [], [], g, [], g, g^2, g, g};
for i = 1:numel(names)
    a = reshape(A(:, cols(i)), gs);
    mask = [];
    if ~isempty(scales{i})
        mask = inner;
    end
    helper_truth_verify(testCase, a, E.(names{i}), tols(i), [label ': ' names{i}], mask, scales{i});
end
d = mod(reshape(A(:, cols(11)), gs) - E.direction + 180, 360) - 180;
testCase.verifyLessThan(max(abs(d(:))), 1e-5, [label ': direction']);
helper_truth_verify(testCase, reshape(A(:, cols(12)), gs), correlation_truth(x), 1e-6, [label ': correlation']);
helper_truth_verify(testCase, reshape(A(:, cols(13)), gs), uncertainty_truth(x) * E.fv, 1e-6, [label ': uncertainty']);
end

function [P, V] = read_vtk(file, n)
% points and velocity vectors of a binary structured-grid VTK file of PIVlab (3 x n each)
fid = fopen(file, 'r', 'ieee-be');
bytes = fread(fid, Inf, 'uint8=>uint8')';
txt = char(bytes);
key = sprintf('POINTS %d float\n', n);
k = strfind(txt, key);
fseek(fid, k(1) - 1 + numel(key), 'bof');
P = fread(fid, [3 n], 'single');      % big-endian floats (file opened as ieee-be)
key = sprintf('VECTORS velocity_vectors float\n');
k = strfind(txt, key);
fseek(fid, k(1) - 1 + numel(key), 'bof');
V = fread(fid, [3 n], 'single');
fclose(fid);
P = double(P);
V = double(V);
end

function click_vector(x, y)
% clicks on the vector at (x, y) of the PIVlab axes (gui.veclick), as in test_stereo_gui. The axes
% CurrentPoint is read-only, it follows the figure CurrentPoint: the figure point is found from two
% probe points (linear in x and y).
target_axis = gui.retr('pivlab_axis');
fig = ancestor(target_axis, 'figure');
probe = [100 100; 300 300];
axes_point = zeros(2, 2);
for k = 1:2
    set(fig, 'CurrentPoint', probe(k, :));
    p = get(target_axis, 'CurrentPoint');
    axes_point(k, :) = p(1, 1:2);
end
scale = (probe(2, :) - probe(1, :)) ./ (axes_point(2, :) - axes_point(1, :));
set(fig, 'CurrentPoint', probe(1, :) + ([x y] - axes_point(1, :)) .* scale);
click.Button = 1;
gui.veclick([], click);
end
