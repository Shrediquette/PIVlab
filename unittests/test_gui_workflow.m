function tests = test_gui_workflow
%TEST_GUI_WORKFLOW The PIVlab window used like a user: import, ROI, masks, background, the PIV
%   algorithms, calibration, validation, derived parameters, smoothing, temporal mean, extractions,
%   export, synthetic images, parallel analysis. Checks that every step runs and stores its results;
%   exact numbers are compared by unittests/parity and test_apigui_results.
%   Run with: results = runtests('unittests/test_gui_workflow.m')
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
helper_setup_once(testCase);
end

function teardownOnce(testCase)
helper_teardown_once(testCase);
try
    delete(gcp('nocreate'));
catch
end
end

% The PIVlab window stays open between the tests: helper_start_pivlab resets it ("Reset PIVlab GUI")
% and checks that it is the same as after a new start; helper_teardown_once closes it.

%% ================================================================== import
function test_import_grey_and_colour_images(testCase)
helper_start_pivlab();
h = gui.gethand;
% 3 grey image pairs, pairwise
helper_gui_load_images(helper_files('jet', 3), 1);
verify_imported(testCase, 6, 'grey Jet images');
testCase.verifyEqual(get(h.remove_imgs, 'Enable'), 'on');
% the quick access buttons open their panels
quick = {'quick2', 'multip25'; 'quick3', 'multip03'; 'quick4', 'multip04'; 'quick5', 'multip05'; 'quick6', 'multip07'};
for k = 1:size(quick, 1)
    feval(['gui.' quick{k,1} '_Callback'], [], []);
    drawnow;
    testCase.verifyEqual(char(get(h.(quick{k,2}), 'Visible')), 'on', [quick{k,1} ' did not open ' quick{k,2}]);
end
% 4 colour images, time resolved: 3 pairs
helper_gui_load_images(helper_files('fuerteventura', 4), 0);
verify_imported(testCase, 6, 'colour Fuerteventura images');
testCase.verifyEqual(size(gui.retr('expected_image_size')), [1 2], 'colour import did not record the image size');
end

%% ================================================================== analysis
function test_fft_with_roi_masks_and_background(testCase)
helper_start_pivlab();
helper_gui_load_images(helper_files('jet', 3), 1);
sz = gui.retr('expected_image_size');
% ROI and masks (frame 1 rectangle, frame 2 polygon, frame 3 none)
roi = [20 20 min(sz(2) - 40, 300) min(sz(1) - 40, 220)];
gui.put('roirect', roi);
mask_rect = [30 30 40 35];
masks = {{'ROI_object_rectangle', mask_rect}, {'ROI_object_polygon', [120 90; 155 95; 150 130; 115 125]}, cell(0)};
gui.put('masks_in_frame', masks);
testCase.verifyEqual(gui.retr('roirect'), roi);
% background "mean"
h = gui.gethand;
gui.quick3_Callback([], []);
set(h.bg_subtract, 'Value', 2);
preproc.generate_BG_img();
drawnow;
testCase.verifyNotEmpty(gui.retr('bg_img_A'), 'background image A was not made');
testCase.verifyNotEmpty(gui.retr('bg_img_B'), 'background image B was not made');
testCase.verifyEqual(get(h.bg_subtract, 'Value'), 2, 'background subtraction was switched off');
% four passes
configure_piv(1, 4);
helper_gui_analyze();
rl = verify_results(testCase, 3);
% vectors only inside the ROI, masked vectors in the mask of frame 1 only
x = rl{1,1};
y = rl{2,1};
testCase.verifyTrue(all(x(:) >= roi(1) & x(:) <= roi(1) + roi(3) & y(:) >= roi(2) & y(:) <= roi(2) + roi(4)), ...
    'vectors outside the ROI');
% (vectors more than 2 px inside the mask edge: the exact edge is checked by
% test_core_piv_fftmulti/test_mask_with_roi_at_the_vector_positions)
in_mask = x >= mask_rect(1) + 3 & x <= mask_rect(1) + mask_rect(3) - 3 & y >= mask_rect(2) + 3 & y <= mask_rect(2) + mask_rect(4) - 3;
testCase.assertTrue(any(in_mask(:)), 'test setup: no vector in the mask');
testCase.verifyTrue(all(rl{5,1}(in_mask) == 0), 'vectors in the mask are not masked (frame 1)');
testCase.verifyGreaterThan(nnz(rl{5,2} == 0), 0, 'frame 2: the polygon mask masks no vector');
testCase.verifyTrue(all(rl{5,3}(:) ~= 0), 'frame 3 has no mask, but masked vectors');
end

function test_ensemble_and_dcc(testCase)
helper_start_pivlab();
% ensemble over 3 pairs: one result
helper_gui_load_images(helper_files('jet', 3), 1);
configure_piv(2, 1);
helper_gui_analyze();
verify_results(testCase, 1);
% DCC, one pair
helper_gui_load_images(helper_files('jet', 1), 1);
configure_piv(3, 1);
helper_gui_analyze();
verify_results(testCase, 1);
end

function test_parallel_analysis_equals_serial(testCase)
% PIVlab with 2 cores analyses in parallel; worker processes calculate with one thread, so the
% result equals the serial one up to rounding (which can flip single vectors with small windows to
% another correlation peak). Parallel GUI = parallel API exactly: test_apigui_results.
testCase.assumeTrue(license('test', 'Distrib_Computing_Toolbox') == 1 && ~isempty(ver('parallel')), ...
    'no Parallel Computing Toolbox');
helper_start_pivlab();
helper_gui_load_images(helper_files('jet', 3), 1);
configure_piv(1, 3);
helper_gui_analyze();
serial = gui.retr('resultslist');
try
    helper_start_pivlab(2);
catch err
    if contains(err.message, 'parallel pool', 'IgnoreCase', true)
        testCase.assumeFail(['parallel pool could not be started: ' err.message]);
    end
    rethrow(err);
end
testCase.assumeEqual(gui.retr('parallel'), 1, 'PIVlab did not start a parallel pool');
helper_gui_load_images(helper_files('jet', 3), 1);
configure_piv(1, 3);
helper_gui_analyze();
par = verify_results(testCase, 3);
for k = 1:3
    testCase.verifyEqual(par{1,k}, serial{1,k}, sprintf('grid, pair %d', k));
    d = abs(double(par{3,k}(:)) - double(serial{3,k}(:)));
    testCase.verifyLessThan(median(d, 'omitnan'), 1e-4, sprintf('u parallel vs serial, pair %d: median difference', k));
    testCase.verifyLessThan(mean(d > 0.01), 0.001, sprintf('u parallel vs serial, pair %d: more than 0.1 %% of the vectors differ', k));
end
end

%% ================================================================== after the analysis
function test_calibration_validation_and_derived(testCase)
helper_start_pivlab();
helper_gui_load_images(helper_files('jet', 3), 1);
helper_gui_analyze();
h = gui.gethand;
% calibration: 100 px = 10 mm, 100 ms
gui.quick6_Callback([], []);
gui.put('pointscali', [10 10; 110 10]);
set(h.realdist, 'String', '10');
set(h.time_inp, 'String', '100');
set(h.x_axis_direction, 'Value', 1);
set(h.y_axis_direction, 'Value', 1);
calibrate.apply_cali_Callback([], [], []);
drawnow;
testCase.verifyEqual(gui.retr('calxy'), 1e-4, 'AbsTol', 1e-12, 'length scale');
testCase.verifyEqual(gui.retr('calu'), 0.001, 'AbsTol', 1e-12, 'velocity factor u');
testCase.verifyEqual(gui.retr('calv'), 0.001, 'AbsTol', 1e-12, 'velocity factor v');
% validation
set(h.stdev_enable, 'Value', 1);
set(h.stdev_thresh, 'String', '7');
set(h.loc_median_enable, 'Value', 1);
set(h.loc_med_thresh, 'String', '3');
set(h.interpol_missing, 'Value', 1);
validate.apply_filter_all_Callback([], [], []);
drawnow;
rl = gui.retr('resultslist');
testCase.verifyGreaterThanOrEqual(size(rl, 1), 9, 'validation did not add the filtered rows');
for r = 7:9
    testCase.verifyNotEmpty(rl{r, 1}, sprintf('validated data row %d missing', r));
end
% spatial smoothing and a derived parameter
gui.switchui('multip08');
set(h.smooth_mode, 'Value', 2);      % 2D
set(h.smooth_param, 'String', '0.3');
plot.smooth_mode_Callback(h.smooth_mode);
plot.derivative_calc(1, 3, 0);
derived = gui.retr('derived');
rl = gui.retr('resultslist');
testCase.verifyNotEmpty(derived{2, 1}, 'velocity magnitude was not calculated');
testCase.verifyNotEmpty(rl{10, 1}, 'smoothed u missing');
testCase.verifyNotEmpty(rl{11, 1}, 'smoothed v missing');
testCase.verifyNotEqual(rl{10, 1}, rl{7, 1}, 'smoothing changed nothing');
% temporal (2D + time) moving-average smoothing
set(h.smooth_mode, 'Value', 4);      % 2D + time
set(h.temporal_window, 'String', '3');
plot.smooth_mode_Callback(h.smooth_mode);
plot.derivative_calc(2, 3, 0);
rl = gui.retr('resultslist');
testCase.verifyNotEmpty(rl{10, 2}, 'temporally smoothed u missing');
testCase.verifyNotEmpty(rl{11, 2}, 'temporally smoothed v missing');
% the derived parameter is displayed
gui.put('displaywhat', 2);
gui.sliderdisp(gui.retr('pivlab_axis'));
drawnow;
testCase.verifyNotEmpty(findobj(gui.retr('pivlab_axis'), 'Type', 'image'), 'nothing displayed');
end

function test_temporal_mean_and_phase_averages(testCase)
helper_start_pivlab();
helper_gui_load_images(helper_files('jet', 3), 1);
helper_gui_analyze();
validate.apply_filter_all_Callback([], [], []);
h = gui.gethand;
% mean of frames 1:3, appended
set(h.selectedFramesMean, 'String', '1:3');
set(h.append_replace, 'Value', 1);
plot.temporal_operation_Callback([], [], 1);
drawnow;
rl = gui.retr('resultslist');
testCase.verifyEqual(size(rl, 2), 4, 'temporal mean was not appended');
testCase.verifyNotEmpty(rl{3, 4}, 'mean u is empty');
% one average per ';'-separated row (phase averages), rows of different length, "replace" removes
% the earlier mean first
set(h.selectedFramesMean, 'String', '[1;2:3]');
set(h.append_replace, 'Value', 2);
plot.temporal_operation_Callback([], [], 1);
drawnow;
rl = gui.retr('resultslist');
ismean = gui.retr('ismean');
filename = gui.retr('filename');
testCase.verifyEqual(nnz(ismean == 1), 2, 'two rows must give two mean frames');
testCase.verifyEqual(size(rl, 2), 3 + 2, 'one appended frame per row');
testCase.verifyNotEmpty(rl{3, 4}, 'first phase average is empty');
testCase.verifyNotEmpty(rl{3, 5}, 'second phase average is empty');
testCase.verifyFalse(isequal(rl{3, 4}, rl{3, 5}), 'averages over different frames are identical');
testCase.verifyTrue(contains(filename{end, 1}, '#2'), 'the mean frames of several rows need a label per row');
% statistics panel
plot.statistics_Callback([], [], []);
testCase.verifyEqual(char(get(h.multip14, 'Visible')), 'on', 'statistics panel did not open');
end

function test_extraction_polyline_and_area(testCase)
helper_start_pivlab();
helper_gui_load_images(helper_files('jet', 1), 1);
helper_gui_analyze();
h = gui.gethand;
rl = gui.retr('resultslist');
x = double(rl{1, 1});
y = double(rl{2, 1});
% polyline (loaded from a coordinate file)
polyline_file = fullfile(testCase.TestData.Dir, 'polyline.mat');
save_coordinates(polyline_file, [x(2, 2); x(2, end-1); x(end-1, end-1)], [y(2, 2); y(2, end-1); y(end-1, end-1)], 'extract_poly');
extract.poly_extract_Callback([], [], []);
extract.load_polyline_Callback(h.load_polyline, [], polyline_file);
set(h.extraction_choice, 'Value', 1);
extract.plot_data_Callback(h.plot_data, [], []);
testCase.verifyNotEmpty(gui.retr('distance'), 'polyline: distance not stored');
testCase.verifyNotEmpty(gui.retr('cx'), 'polyline: x coordinates not stored');
testCase.verifyNotEmpty(gui.retr('cy'), 'polyline: y coordinates not stored');
c = gui.retr('c');
testCase.verifyTrue(any(isfinite(c(:))), 'polyline: no finite values');
% area
area_file = fullfile(testCase.TestData.Dir, 'area.mat');
save_coordinates(area_file, [x(2, 2); x(2, end-2); x(end-2, end-2); x(end-2, 2)], ...
    [y(2, 2); y(2, end-2); y(end-2, end-2); y(end-2, 2)], 'extract_poly_area');
extract.area_panel_activation_Callback([], [], []);
extract.load_polyline_Callback(h.load_area_coordinates, [], area_file);
set(h.extraction_choice_area, 'Value', 2);
[data, header] = extract.plot_data_area(1, 1);
testCase.verifyNotEmpty(header, 'area: header is empty');
testCase.verifyNotEmpty(data, 'area: data is empty');
found = false;
for k = 1:numel(data)
    if isnumeric(data{k}) && isscalar(data{k}) && isfinite(data{k})
        found = true;
    end
end
testCase.verifyTrue(found, 'area: no finite numeric value');
end

function test_mat_export(testCase)
helper_start_pivlab();
helper_gui_load_images(helper_files('jet', 2), 1);
helper_gui_analyze();
validate.apply_filter_all_Callback([], [], []);
export.mat_file_save(1, 'export.mat', testCase.TestData.Dir, 2);
file = fullfile(testCase.TestData.Dir, 'export.mat');
testCase.assertTrue(isfile(file), 'MAT file was not written');
E = load(file);
rl = gui.retr('resultslist');
for name = {'x', 'y', 'u_original', 'v_original', 'u_filtered', 'v_filtered', 'typevector_original'}
    testCase.verifyTrue(isfield(E, name{1}), ['MAT export without ' name{1}]);
end
testCase.verifyEqual(numel(E.u_original), 2, 'one entry per frame');
testCase.verifyEqual(E.u_original{2}, rl{3, 2}, 'exported u of frame 2');
end

%% ================================================================== synthetic images
function test_synthetic_image_generator(testCase)
helper_start_pivlab();
h = gui.gethand;
gui.switchui('multip15');
set(h.flow_sim, 'Value', 3);
set(h.img_sizex, 'String', '96');
set(h.img_sizey, 'String', '96');
set(h.part_am, 'String', '250');
set(h.part_noise, 'String', '0.001');
set(h.shiftdisplacement, 'String', '2');
simulate.generate_it_Callback([], [], []);
drawnow;
A = gui.retr('gen_image_1');
B = gui.retr('gen_image_2');
testCase.verifyEqual(size(A), [96 96], 'first synthetic image');
testCase.verifyEqual(size(B), [96 96], 'second synthetic image');
testCase.verifyNotEqual(A, B, 'the two synthetic images are the same');
end

%% ------------------------------------------------------------------ helpers
function configure_piv(algorithm, passes)
% algorithm: 1 FFT window deformation, 2 ensemble, 3 DCC; passes 1...4 (64 / 32 / 16 / 16 px)
h = gui.gethand;
gui.quick4_Callback([], []);
set(h.algorithm_selection, 'Value', algorithm);
piv.algorithm_selection_Callback(h.algorithm_selection, [], []);
set(h.pass1_size, 'String', '64');
piv.intarea_Callback(h.pass1_size, [], []);
set(h.pass1_step, 'String', '32');
piv.step_Callback(h.pass1_step, [], []);
set(h.subpixel_estimator, 'Value', 1);
sizes = {'32', '16', '16'};
names = {'pass2', 'pass3', 'pass4'};
for k = 1:3
    on = double(passes >= k + 1);
    set(h.([names{k} '_enable']), 'Value', on);
    if on
        set(h.([names{k} '_size']), 'String', sizes{k});
    end
    feval(['piv.' names{k} '_checkbox_Callback'], h.([names{k} '_enable']), [], []);
end
gui.quick5_Callback([], []);
drawnow;
end

function rl = verify_results(testCase, frames)
% the results list has frames analysed frames with x, y, u, v and type vector
rl = gui.retr('resultslist');
testCase.assertNotEmpty(rl, 'the analysis made no results');
testCase.verifyGreaterThanOrEqual(size(rl, 1), 5, 'results list has too few rows');
testCase.verifyEqual(size(rl, 2), frames, 'number of analysed frames');
for f = 1:min(frames, size(rl, 2))
    for r = 1:5
        testCase.verifyNotEmpty(rl{r, f}, sprintf('row %d of frame %d is empty', r, f));
    end
    testCase.verifyTrue(any(isfinite(rl{3, f}(:))), sprintf('u of frame %d has no finite values', f));
    testCase.verifyTrue(any(isfinite(rl{4, f}(:))), sprintf('v of frame %d has no finite values', f));
end
end

function verify_imported(testCase, n, what)
filepath = gui.retr('filepath');
testCase.verifyNumElements(filepath, n, ['number of ' what]);
testCase.verifyNotEmpty(gui.retr('filename'), ['no file names for ' what]);
for k = 1:numel(filepath)
    testCase.verifyTrue(isfile(filepath{k}), ['imported file does not exist: ' filepath{k}]);
end
end

function save_coordinates(file, xposition, yposition, extract_type) %#ok<INUSD>
save(file, 'xposition', 'yposition', 'extract_type');
end
