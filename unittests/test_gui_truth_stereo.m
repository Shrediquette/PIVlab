function tests = test_gui_truth_stereo
%TEST_GUI_TRUTH_STEREO Stereo-PIV in the PIVlab window: the exports with w (ASCII, Tecplot, Paraview VTK,
%   MAT file, workspace) against the ground truth of helper_stereo_synthetic_case, for all four axis
%   settings, in px/frame and in m/s: coordinates, u, v, w (positive along z = x cross y), column
%   headers with the unit of w. File dialogs are not used (export functions are called directly).
%   Run with: run_pivlab_tests('test_gui_truth_stereo')
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
helper_setup_once(testCase);
c = helper_stereo_synthetic_case(fullfile(testCase.TestData.Dir, 'case'), 3, 0, 'side');
helper_close_pivlab();
helper_start_pivlab();
h = gui.gethand;
helper_stereo_gui_calibrate(c);
set(h.pass1_size, 'String', '64'); piv.intarea_Callback(h.pass1_size, [], []);
set(h.pass1_step, 'String', '32'); piv.step_Callback(h.pass1_step, [], []);
set(h.pass2_enable, 'Value', 1); set(h.pass2_size, 'String', '32'); piv.pass2_checkbox_Callback(h.pass2_enable, [], []);
set(h.update_display_checkbox, 'Value', 0);
piv.AnalyzeAll_Callback;
validate.apply_filter_all_Callback;
calib = gui.retr('stereo_calib');
rl = gui.retr('resultslist');
testCase.TestData.c = c;
testCase.TestData.calib = calib;
testCase.TestData.x = double(rl{1, 1});
testCase.TestData.y = double(rl{2, 1});
testCase.TestData.T = helper_truth_stereo_field(rl{1, 1}, rl{2, 1}, calib, c);
testCase.TestData.cal_data = struct('pointscali', gui.retr('pointscali'), 'points_offsetx', [], ...
    'points_offsety', [], 'size_of_the_image', calib.Ravg.ImageSize);
testCase.TestData.realdist = get(h.realdist, 'String');
end

function teardownOnce(testCase)
helper_close_pivlab();
helper_teardown_once(testCase);
end

function setup(testCase)
helper_truth_log(testCase, 'start');
end

function teardown(testCase)
helper_truth_log(testCase, 'end');
end

function test_exports_with_w(testCase)
D = testCase.TestData;
h = gui.gethand;
folder = D.Dir;
n = 3;                                   % frames (image pairs)
mm = D.calib.Ravg.PixelExtentInWorldX;
sz = D.calib.Ravg.ImageSize;
gs = size(D.x);
C = cases(mm);
for k = 1:numel(C)
    c = C(k);
    label = c.name;
    set_calibration(c, D);
    helper_verify_near(testCase, gui.retr('calxy'), c.calxy, 'RelTol', 1e-5, [label ': scale of the stereo calibration']);
    c.calxy = gui.retr('calxy');         % the rounded reference length of the GUI (5e-7 relative)
    E = helper_truth_expected(D.T, c, D.x, D.y, sz);
    ok = ~isnan(D.T.U) & ~isnan(D.T.w);
    vmax = max(abs([E.u(ok); E.v(ok); E.w(ok)]));
    % ASCII without derivatives: x y u v w type
    set(h.delimiter, 'Value', 1); set(h.add_header, 'Value', 1); set(h.addfileinfo, 'Value', 0);
    set(h.export_vort, 'Value', 0);
    A = zeros(numel(D.x), 6, n);
    for f = 1:n
        file = sprintf('stereo_%d_%d.txt', k, f);
        export.file_save(f, file, folder, 1);
        A(:, :, f) = readmatrix(fullfile(folder, file), 'NumHeaderLines', 1);
    end
    lines = readlines(fullfile(folder, file));
    testCase.verifyTrue(startsWith(lines(1), "x [" + c.length + "],y [" + c.length + "],u [" + c.units + "],v [" + ...
        c.units + "],w [" + c.units + "],Vector type"), sprintf('%s: ASCII header "%s"', label, lines(1)));
    helper_truth_verify(testCase, reshape(A(:, 1, 1), gs), E.x, 1e-5, [label ': ASCII x']);
    helper_truth_verify(testCase, reshape(A(:, 2, 1), gs), E.y, 1e-5, [label ': ASCII y']);
    Am = mean(A, 3, 'omitnan');
    verify_rms(testCase, reshape(Am(:, 3), gs), E.u, ok, 0.03 * vmax, [label ': ASCII u (mean of the frames)']);
    verify_rms(testCase, reshape(Am(:, 4), gs), E.v, ok, 0.03 * vmax, [label ': ASCII v']);
    verify_rms(testCase, reshape(Am(:, 5), gs), E.w, ok, 0.03 * vmax, [label ': ASCII w']);
    verify_sign(testCase, reshape(Am(:, 5), gs), E.w, ok, [label ': ASCII w along z']);
    % Tecplot: x y u v w isNaN, rows sorted by y (NaN written as 0)
    set(h.export_vort_tec, 'Value', 0);
    file = sprintf('stereo_%d.dat', k);
    export.file_save(1, file, folder, 4);
    lines = readlines(fullfile(folder, file));
    testCase.verifyTrue(any(startsWith(lines, 'VARIABLES = "x", "y", "u", "v", "w", "isNaN"')), [label ': Tecplot variables']);
    testCase.verifyTrue(contains(lines(3), "w [" + c.units + "]"), sprintf('%s: Tecplot header "%s"', label, lines(3)));
    Tp = readmatrix(fullfile(folder, file), 'NumHeaderLines', 6, 'FileType', 'text', 'Delimiter', ' ');
    Tp = sortrows(Tp, [1 2]);
    ref = sortrows([A(:, 1:5, 1) isnan(A(:, 3, 1))], [1 2]);
    ref(isnan(ref)) = 0;
    helper_truth_verify(testCase, Tp(:, 1:5), ref(:, 1:5), 1e-6, [label ': Tecplot x y u v w = ASCII']);
    % Paraview VTK: velocity vectors (u, v, w), points (x, y, 0)
    file = sprintf('stereo_%d.vtk', k);
    V = zeros(3, numel(D.x), n);
    for f = 1:n
        export.file_save(f, file, folder, 3);
        [P, V(:, :, f)] = read_vtk(fullfile(folder, file), numel(D.x));
    end
    helper_truth_verify(testCase, reshape(P(1, :), gs), E.x, 1e-5, [label ': VTK x']);
    Vm = mean(V, 3, 'omitnan');
    verify_rms(testCase, reshape(Vm(1, :), gs), E.u, ok, 0.03 * vmax, [label ': VTK u']);
    verify_rms(testCase, reshape(Vm(2, :), gs), E.v, ok, 0.03 * vmax, [label ': VTK v']);
    verify_rms(testCase, reshape(Vm(3, :), gs), E.w, ok, 0.03 * vmax, [label ': VTK w']);
    verify_sign(testCase, reshape(Vm(3, :), gs), E.w, ok, [label ': VTK w along z']);
    % MAT file of all frames
    set(h.export_mat_derivatives, 'Value', 0);
    file = sprintf('stereo_%d.mat', k);
    export.mat_file_save(1, file, folder, 2);
    M = load(fullfile(folder, file));
    helper_truth_verify(testCase, M.x{1}, E.x, 1e-5, [label ': MAT x']);
    wm = mean(cat(3, M.w_filtered{1:n}), 3, 'omitnan');
    um = mean(cat(3, M.u_filtered{1:n}), 3, 'omitnan');
    verify_rms(testCase, um, E.u, ok, 0.03 * vmax, [label ': MAT u_filtered']);
    verify_rms(testCase, wm, E.w, ok, 0.03 * vmax, [label ': MAT w_filtered']);
    verify_sign(testCase, wm, E.w, ok, [label ': MAT w along z']);
    % workspace
    evalc('export.write_workspace_Callback([], [], [])');
    ws = evalin('base', 'w_filtered');
    wm = mean(cat(3, ws{1:n}), 3, 'omitnan');
    verify_rms(testCase, wm, E.w, ok, 0.03 * vmax, [label ': workspace w_filtered']);
    verify_sign(testCase, wm, E.w, ok, [label ': workspace w along z']);
end
end

%% ------------------------------------------------------------------ local functions

function C = cases(mm_per_px)
% 4 axis settings, uncalibrated (px/frame) and with the stereo scale + 2 ms (m/s)
base = helper_truth_cases('short');   % px (1-4) and orig (5-8)
C = base(1:4);
for k = 1:4
    C(k).length = "px";
end
for k = 5:8
    c = base(k);
    c.kind = 'stereo';
    c.dt = 0.002;
    c.origin = [];
    c.calxy = mm_per_px / 1000;
    c.t = 0.002;
    c.units = "m/s";
    c.length = "m";
    c.name = strrep(c.name, 'orig', 'stereo m/s');
    C(k) = c;
end
end

function set_calibration(c, D)
% the calibration controls of the PIVlab window, applied without dialogs
h = gui.gethand;
set(h.x_axis_direction, 'Value', c.xdir);
set(h.y_axis_direction, 'Value', c.ydir);
data = D.cal_data;
if strcmp(c.kind, 'px')
    data.pointscali = [];
    set(h.time_inp, 'String', '1');
else
    set(h.realdist, 'String', D.realdist);
    set(h.time_inp, 'String', num2str(c.dt * 1000));
end
calibrate.apply_calibration_data(data);
gui.put('derived', []);
end

function verify_rms(testCase, actual, expected, ok, tol, name)
% measured in test_truth_stereo: rms error of the mean of 3 pairs about 1 % of the largest displacement
a = double(actual(ok));
e = double(expected(ok));
valid = ~isnan(a);
testCase.verifyGreaterThan(nnz(valid), 0.8 * numel(a), [name ': at least 80 % valid vectors']);
err = sqrt(mean((a(valid) - e(valid)).^2));
testCase.verifyLessThanOrEqual(err, tol, sprintf('%s: rms error %.3g (tolerance %.3g)', name, err, tol));
end

function verify_sign(testCase, actual, expected, ok, name)
valid = ok & ~isnan(actual);
r = corrcoef(double(actual(valid)), double(expected(valid)));
testCase.verifyGreaterThan(r(1, 2), 0.95, sprintf('%s: correlation with the truth %.3f', name, r(1, 2)));
end

function [P, V] = read_vtk(file, n)
% points and velocity vectors of a binary structured-grid VTK file of PIVlab (3 x n each)
fid = fopen(file, 'r', 'ieee-be');
bytes = fread(fid, Inf, 'uint8=>uint8')';
txt = char(bytes);
key = sprintf('POINTS %d float\n', n);
k = strfind(txt, key);
fseek(fid, k(1) - 1 + numel(key), 'bof');
P = double(fread(fid, [3 n], 'single'));
key = sprintf('VECTORS velocity_vectors float\n');
k = strfind(txt, key);
fseek(fid, k(1) - 1 + numel(key), 'bof');
V = double(fread(fid, [3 n], 'single'));
fclose(fid);
end
