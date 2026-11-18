function tests = test_gui_coordinate_system
%TEST_GUI_COORDINATE_SYSTEM PIVlab window: the data exports (ASCII, Tecplot, MAT file, workspace) and
%   the image export contain the right coordinates, velocities and derived quantities for the axis
%   settings of the calibration (x, y, z right-handed, z = x cross y), calibrated and in pixels.
%   Particle images of a flow with known vorticity, divergence and strain (helper_coordinate_flow).
%   File dialogs are replaced by unittests/parity/mocks.
%   Run with: results = runtests('unittests/test_gui_coordinate_system.m')
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
helper_setup_once(testCase);
addpath(fullfile(testCase.TestData.Root, 'unittests', 'parity', 'mocks'), '-begin');   % uiputfile
testCase.TestData.F = helper_coordinate_flow(testCase.TestData.Dir);
helper_close_pivlab();
helper_start_pivlab();
helper_gui_load_images(testCase.TestData.F.files, 1);
helper_gui_analyze();
end

function teardownOnce(testCase)
helper_close_pivlab();
rmpath(fullfile(testCase.TestData.Root, 'unittests', 'parity', 'mocks'));
setappdata(0, 'parity_mock_file', []);
helper_teardown_once(testCase);
end

function test_exports_in_pixels(testCase)
% no calibration: default axes x right, y up; px and px/frame
h = gui.gethand;
calibrate.clear_cali_Callback();
testCase.verifyEqual([get(h.x_axis_direction, 'Value') get(h.y_axis_direction, 'Value')], [1 2]);
testCase.verifyEqual([gui.retr('calu') gui.retr('calv')], [1 -1]);
E = helper_coordinate_expected(testCase.TestData.F, 1, 2, 1);
check_exports(testCase, E, 'px');
end

function test_exports_all_axis_settings_calibrated(testCase)
h = gui.gethand;
dt = 0.002;
for xd = 1:2
    for yd = 1:2
        % 500 px are 100 mm (0.2 mm/px), 2 ms between the images
        gui.put('pointscali', [0 0; 500 0]);
        set(h.realdist, 'String', '100');
        set(h.time_inp, 'String', num2str(dt * 1000));
        set(h.x_axis_direction, 'Value', xd);
        set(h.y_axis_direction, 'Value', yd);
        calibrate.apply_cali_Callback([], [], []);
        E = helper_coordinate_expected(testCase.TestData.F, xd, yd, dt);
        check_exports(testCase, E, sprintf('cal_%d%d', xd, yd));
    end
end
end

function test_image_export(testCase)
% exported PNG of the vorticity (grey colour map, opaque, no vectors): bright = positive
h = gui.gethand;
dt = 0.002;
cases = [1 2; 2 2; 2 1; 1 1];
for k = 1:size(cases, 1)
    xd = cases(k, 1);
    yd = cases(k, 2);
    gui.put('pointscali', [0 0; 500 0]);
    set(h.realdist, 'String', '100');
    set(h.time_inp, 'String', num2str(dt * 1000));
    set(h.x_axis_direction, 'Value', xd);
    set(h.y_axis_direction, 'Value', yd);
    calibrate.apply_cali_Callback([], [], []);
    E = helper_coordinate_expected(testCase.TestData.F, xd, yd, dt);
    set(h.derivchoice, 'Value', 2); plot.derivchoice_Callback(h.derivchoice);   % vorticity
    plot.apply_deriv_all_Callback([], [], []);
    set(h.colormap_choice, 'Value', find(strcmp(get(h.colormap_choice, 'String'), 'Gray')));
    set(h.colormapopacity, 'String', '100');
    set(h.suppress_vec, 'Value', 1);
    set(h.autoscaler, 'Value', 0);
    set(h.mapscale_min, 'String', num2str(-2 * abs(E.vorticity)));
    set(h.mapscale_max, 'String', num2str(2 * abs(E.vorticity)));
    gui.sliderdisp(gui.retr('pivlab_axis'));
    export.pixel_data([], [], []);   % opens the image export panel (fills the list of formats)
    set(h.export_still_or_animation, 'Value', find(strcmp(get(h.export_still_or_animation, 'String'), 'PNG')));
    name = sprintf('vorticity_%d.png', k);
    setappdata(0, 'parity_mock_file', {testCase.TestData.Dir, name});
    src.Source.Tag = 'export_current_frame';
    export.do_export_pixel_data_Callback([], src, []);
    setappdata(0, 'parity_mock_file', []);
    [~, base] = fileparts(name);
    file = fullfile(testCase.TestData.Dir, [base '_001.png']);
    testCase.assertTrue(isfile(file), [E.name ': image was not exported']);
    grey = centre_grey(file);
    testCase.verifyEqual(grey, 0.5 + 0.25 * sign(E.vorticity), 'AbsTol', 0.08, [E.name ': grey value of the exported image']);
end
end

function test_tke_and_stdev_units(testCase)
% (runs last: loads other images) two image pairs with opposite displacements, u and -u: per vector,
% TKE = 0.5*var([u -u]) = u^2 and STDEV = sqrt(2)*|u|, in the user's units, for every axis setting
h = gui.gethand;
F = testCase.TestData.F;
helper_gui_load_images({F.files{1}; F.files{2}; F.files{2}; F.files{1}}, 1);
helper_gui_analyze();
set(h.selectedFramesMean, 'String', '1:2');
plot.temporal_operation_Callback([], [], 3);   % TKE: frame 3
plot.temporal_operation_Callback([], [], 2);   % STDEV: frame 4
filename = gui.retr('filename');
testCase.assertTrue(strncmp(filename{5}, 'TKE of frames', 13) && strncmp(filename{7}, 'STDEV of frames', 15), 'statistics frames missing');
set(h.export_vort, 'Value', 0);
set(h.add_header, 'Value', 0);
set(h.addfileinfo, 'Value', 0);
set(h.delimiter, 'Value', 1);
cases = [1 2; 2 2; 2 1; 1 1];
for k = 1:size(cases, 1)
    gui.put('pointscali', [0 0; 500 0]);
    set(h.realdist, 'String', '100');
    set(h.time_inp, 'String', '2');
    set(h.x_axis_direction, 'Value', cases(k, 1));
    set(h.y_axis_direction, 'Value', cases(k, 2));
    calibrate.apply_cali_Callback([], [], []);
    E = helper_coordinate_expected(F, cases(k, 1), cases(k, 2), 0.002);
    data = cell(1, 4);
    for frame = 1:4
        f = sprintf('stat_%d_%d.txt', k, frame);
        export.file_save(frame, f, testCase.TestData.Dir, 1);
        data{frame} = readmatrix(fullfile(testCase.TestData.Dir, f));
    end
    % reference: statistics of the exported velocities of frames 1 and 2 (in the user's units)
    U12 = [data{1}(:, 3) data{2}(:, 3)];
    V12 = [data{1}(:, 4) data{2}(:, 4)];
    ok = all(isfinite(U12), 2) & isfinite(data{3}(:, 3)) & isfinite(data{4}(:, 3));
    scale = max(abs(U12(:)))^2;
    testCase.verifyEqual(data{3}(ok, 3), 0.5 * var(U12(ok, :), 0, 2), 'AbsTol', 1e-5 * scale, [E.name ': TKE u in (m/s)^2']);
    testCase.verifyEqual(data{3}(ok, 4), 0.5 * var(V12(ok, :), 0, 2), 'AbsTol', 1e-5 * scale, [E.name ': TKE v in (m/s)^2']);
    testCase.verifyEqual(data{4}(ok, 3), std(U12(ok, :), 0, 2), 'AbsTol', 1e-5 * sqrt(scale), [E.name ': STDEV u']);
    testCase.verifyEqual(data{4}(ok, 4), std(V12(ok, :), 0, 2), 'AbsTol', 1e-5 * sqrt(scale), [E.name ': STDEV v']);
    % total TKE (magnitude of the TKE frame): sum of the components
    plot.derivative_calc(3, 3, 1);
    derived = gui.retr('derived');
    tke = derived{2, 3};
    rl = gui.retr('resultslist');
    expected = rl{3, 3} * gui.retr('calu')^2 + rl{4, 3} * gui.retr('calv')^2;
    valid = isfinite(expected);
    testCase.verifyEqual(double(tke(valid)), double(expected(valid)), 'AbsTol', 1e-6 * scale, [E.name ': total TKE']);
    testCase.verifyGreaterThanOrEqual(min(tke(:)), 0, [E.name ': total TKE is never negative']);
end
end

%% ------------------------------------------------------------------ local functions

function check_exports(testCase, E, tag)
h = gui.gethand;
folder = testCase.TestData.Dir;
rl = gui.retr('resultslist');
grid_size = size(rl{1, 1});
% ASCII with all derivatives: x y u v type vorticity magnitude divergence Q shear strain direction ...
set(h.export_vort, 'Value', 1);
set(h.add_header, 'Value', 1);
set(h.addfileinfo, 'Value', 0);
set(h.delimiter, 'Value', 1);
f = ['ascii_' tag '.txt'];
export.file_save(1, f, folder, 1);
A = readmatrix(fullfile(folder, f), 'NumHeaderLines', 1);
check_columns(testCase, E, grid_size, A(:, 1), A(:, 2), A(:, 3), A(:, 4), A(:, 6), A(:, 8), A(:, 11), A(:, 12), ['ASCII ' E.name]);
% Tecplot with all derivatives (rows sorted by y): x y u v isNaN vorticity magnitude divergence Q shear strain direction ...
set(h.export_vort_tec, 'Value', 1);
f = ['tecplot_' tag '.dat'];
export.file_save(1, f, folder, 4);
T = readmatrix(fullfile(folder, f), 'NumHeaderLines', 6, 'FileType', 'text', 'Delimiter', ' ');
T = sortrows(T, [1 2]);
A = sortrows(A, [1 2]);
testCase.verifyEqual(T(:, [1 2 3 4 6 8 11]), A(:, [1 2 3 4 6 8 11]), 'AbsTol', 1e-6 * max(abs(A(:))), ['Tecplot = ASCII, ' E.name]);
% MAT file with derivatives
set(h.export_mat_derivatives, 'Value', 1);
f = ['mat_' tag '.mat'];
export.mat_file_save(1, f, folder, 1);
M = load(fullfile(folder, f));
check_columns(testCase, E, grid_size, M.x(:), M.y(:), M.u_original(:), M.v_original(:), M.vorticity(:), M.divergence(:), ...
    M.strain_rate(:), M.vectorangle(:), ['MAT file ' E.name]);
% workspace (the derived quantities that were computed in the GUI)
plot.derivative_calc(1, 2, 1);
plot.derivative_calc(1, 6, 1);
plot.derivative_calc(1, 9, 1);
plot.derivative_calc(1, 11, 1);
evalc('export.write_workspace_Callback([], [], [])');
x = evalin('base', 'x'); y = evalin('base', 'y');
u = evalin('base', 'u_original'); v = evalin('base', 'v_original');
vort = evalin('base', 'vorticity'); div = evalin('base', 'divergence');
strain = evalin('base', 'strain_rate'); angle = evalin('base', 'vectorangle');
check_columns(testCase, E, grid_size, x{1}(:), y{1}(:), u{1}(:), v{1}(:), vort{1}(:), div{1}(:), strain{1}(:), angle{1}(:), ...
    ['workspace ' E.name]);
end

function check_columns(testCase, E, grid_size, x, y, u, v, vort, div, strain, angle, name)
% the exported values as grids (column order of the vector map), in double precision
X = double(reshape(x, grid_size)); Y = double(reshape(y, grid_size));
U = double(reshape(u, grid_size)); V = double(reshape(v, grid_size));
VORT = double(reshape(vort, grid_size)); DIV = double(reshape(div, grid_size));
STRAIN = double(reshape(strain, grid_size)); ANGLE = double(reshape(angle, grid_size));
inner = false(grid_size);
inner(round(grid_size(1) / 4):round(3 * grid_size(1) / 4), round(grid_size(2) / 4):round(3 * grid_size(2) / 4)) = true;
% axes point where the user wants them
testCase.verifyEqual(sign(X(1, 2) - X(1, 1)), E.sx, [name ': x direction']);
testCase.verifyEqual(sign(Y(1, 1) - Y(2, 1)), E.sy, [name ': y direction (+1 = up)']);
% derived quantities
tol = 0.06 * abs(E.vorticity);
testCase.verifyEqual(median(VORT(inner)), E.vorticity, 'AbsTol', tol, [name ': vorticity']);
testCase.verifyEqual(median(DIV(inner)), E.divergence, 'AbsTol', tol, [name ': divergence']);
testCase.verifyEqual(median(STRAIN(inner)), E.strain, 'AbsTol', tol, [name ': simple strain rate']);
% the exported vorticity is dv/dx - du/dy of the exported x, y, u, v
[~, dudy] = gradient(U, X(1, :), Y(:, 1));
[dvdx, ~] = gradient(V, X(1, :), Y(:, 1));
curl_user = dvdx - dudy;
testCase.verifyEqual(median(VORT(inner)), median(curl_user(inner)), 'AbsTol', 0.02 * abs(E.vorticity), ...
    [name ': vorticity = dv/dx - du/dy of the exported data']);
% vector direction: atan2(v, u) of the exported velocities
d = mod(ANGLE(inner) - atan2d(V(inner), U(inner)) + 180, 360) - 180;
testCase.verifyLessThan(max(abs(d)), 1e-3, [name ': vector direction']);
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
