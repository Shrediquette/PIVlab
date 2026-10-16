function tests = test_gui_bugfixes
%TEST_GUI_BUGFIXES Old GUI bugs, fixed on 2026-10-09 (list "phase 7" of the command-line API plan).
%   One test per bug. (Optical flow with auto limit, GUI = API: test_apigui_results.)
%   Run with: results = runtests('unittests/test_gui_bugfixes.m')
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
helper_setup_once(testCase);
end

function teardownOnce(testCase)
helper_teardown_once(testCase);
end

% The PIVlab window stays open between the tests: helper_start_pivlab resets it ("Reset PIVlab GUI")
% and checks that it is the same as after a new start; helper_teardown_once closes it.

function test_multitiff_timeresolved_several_files(testCase)
J = helper_files('jet', 3);
s1 = fullfile(testCase.TestData.Dir, 'stack1.tif');
s2 = fullfile(testCase.TestData.Dir, 'stack2.tif');
for k = 1:4
    write_page(s1, imread(J{k}), k);
end
for k = 1:2
    write_page(s2, imread(J{4+k}), k);
end
% API: pairs within each file (3 + 1)
imgs = pivlab.readImages({s1, s2}, "timeresolved");
testCase.verifyEqual(imgs.pairs, 4);
testCase.verifyEqual(pivlab.getImage(imgs, 3, Frame="B", Preprocessed=false), imread(J{4}));
testCase.verifyEqual(pivlab.getImage(imgs, 4, Frame="A", Preprocessed=false), imread(J{5}));
testCase.verifyEqual(pivlab.getImage(imgs, 4, Frame="B", Preprocessed=false), imread(J{6}));
% GUI
helper_start_pivlab();
gui.put('sequencer',0); gui.put('multitiff',1); gui.put('video_selection_done',0);
import.loadimgsbutton_Callback([],[],0,struct('name',{s1; s2},'isdir',{false; false})); drawnow;
testCase.verifyEqual(gui.retr('filepath'), imgs.filepath);
testCase.verifyEqual(gui.retr('framenum'), imgs.framenum);
end

function test_extraction_uses_the_mask_of_its_frame(testCase)
helper_start_pivlab();
helper_gui_load_images(helper_files('jet', 2));
helper_gui_analyze();
gui.put('masks_in_frame', {{'ROI_object_rectangle',[200 200 300 200]}, {}});
h = gui.gethand;
set(h.fileselector,'Value',1); gui.fileselector_Callback(h.fileselector,[],[]);   % frame 1 is displayed
rl = gui.retr('resultslist');
map = ones(size(rl{1,1}));
m1 = plot.rescale_maps_nan(map, 0, 1);
m2 = plot.rescale_maps_nan(map, 0, 2);
testCase.verifyTrue(all(isnan(m1(250:350, 250:450)), 'all'), 'frame 1: its mask');
testCase.verifyFalse(any(isnan(m2(250:350, 250:450)), 'all'), 'frame 2 has no mask');
end

function test_derive_does_not_change_the_vector_data(testCase)
helper_start_pivlab();
helper_gui_load_images(helper_files('jet', 2));
helper_gui_analyze();
h = gui.gethand;
set(h.stdev_enable,'Value',1); set(h.stdev_thresh,'String','2');   % removes vectors
set(h.interpol_missing,'Value',0);                                  % ... and leaves them NaN
validate.apply_filter_all_Callback([],[],[]);
rl = gui.retr('resultslist');
testCase.assertTrue(any(isnan(rl{7,1}), 'all'), 'the test needs missing vectors');
set(h.interpol_missing,'Value',1);   % interpolation for the derived parameters
plot.derivs_Callback([],[],[]);
set(h.derivchoice,'Value',2); plot.derivchoice_Callback(h.derivchoice);
plot.apply_deriv_all_Callback([],[],[]); drawnow;
rl2 = gui.retr('resultslist');
for r = 7:9
    testCase.verifyEqual(rl2(r,:), rl(r,:), sprintf('resultslist row %d changed by deriving', r));
end
derived = gui.retr('derived');
vort = derived{1,1};
testCase.verifyTrue(all(isfinite(vort(isnan(rl{7,1})))), 'the derived map uses interpolated vectors');
% raw data without validation: deriving does not create validated data
helper_close_pivlab();
helper_start_pivlab();
helper_gui_load_images(helper_files('jet', 1));
helper_gui_analyze();
h = gui.gethand;
set(h.interpol_missing,'Value',1);
plot.derivs_Callback([],[],[]);
set(h.derivchoice,'Value',3); plot.derivchoice_Callback(h.derivchoice);
plot.apply_deriv_all_Callback([],[],[]); drawnow;
rl3 = gui.retr('resultslist');
testCase.verifyTrue(size(rl3,1) < 7 || isempty(rl3{7,1}), 'no validated data without validation');
end

function test_manually_deleted_vectors_stay_deleted(testCase)
% the second-peak substitution of the validation must not bring back a vector that was deleted by hand
helper_start_pivlab();
helper_gui_load_images(helper_files('jet', 1));
helper_gui_analyze();
h = gui.gethand;
rl = gui.retr('resultslist');
testCase.assertGreaterThanOrEqual(size(rl, 1), 14, 'the test needs the second correlation peak');
set([h.stdev_enable h.loc_median_enable h.notch_enable h.corr_filter_enable h.contrast_filter_enable h.bright_filter_enable], 'Value', 0);
set(h.interpol_missing, 'Value', 1);
gui.put('velrect', []); gui.put('velrect_freehand', []);
positions = [3 4; 5 6; 7 8];
manualdeletion = cell(1, 1);
manualdeletion{1} = positions;
idx = sub2ind(size(rl{1, 1}), positions(:, 1), positions(:, 2));
testCase.assertTrue(all(isfinite(rl{13, 1}(idx))), 'the test needs a second peak at the deleted positions');
gui.put('manualdeletion', manualdeletion);
validate.apply_filter_current_Callback([], [], []);
rl = gui.retr('resultslist');
testCase.verifyEqual(double(rl{9, 1}(idx)), 2 * ones(size(idx)), 'deleted vectors replaced by the second peak instead of filled');
end

function test_tecplot_units(testCase)
helper_start_pivlab();
helper_gui_load_images(helper_files('jet', 1));
helper_gui_analyze();
h = gui.gethand;
gui.put('pointscali',[10 10; 110 10]);
set(h.realdist,'String','10');
cases = {'100', 'm/s', 'velocity'; '0', 'm/frame', 'displacement'};
for k = 1:size(cases,1)
    set(h.time_inp,'String',cases{k,1});
    calibrate.apply_cali_Callback([],[],[]);
    f = sprintf('tecplot_%s.dat', cases{k,3});
    export.file_save(1, f, testCase.TestData.Dir, 4);
    txt = fileread(fullfile(testCase.TestData.Dir, f));
    testCase.verifySubstring(txt, ['u [' cases{k,2} ']'], cases{k,3});
end
end

function test_uncertainty_label_without_derive_panel(testCase)
helper_start_pivlab();
helper_gui_load_images(helper_files('jet', 1));
h = gui.gethand;
set(h.uncertainty_enable,'Value',1);
helper_gui_analyze();
plot.derivative_calc(1, 13, 0);   % uncertainty (13) computed, the derive panel was not opened
testCase.assertEqual(get(h.derivchoice,'String'), 'N/A');
gui.put('displaywhat', 13);
set(h.colorbarpos,'Value',4);
gui.sliderdisp(gui.retr('pivlab_axis')); drawnow;
cb = findall(getappdata(0,'hgui'), 'Type', 'colorbar');
testCase.assertNotEmpty(cb);
testCase.verifySubstring(char(cb(1).Label.String), 'Uncertainty');
end

function test_invalid_opacity(testCase)
helper_start_pivlab();
helper_gui_load_images(helper_files('jet', 1));
helper_gui_analyze();
plot.derivative_calc(1, 2, 0);   % vorticity
gui.put('displaywhat', 2);
h = gui.gethand;
for value = {'abc', '150'}
    set(h.colormapopacity,'String',value{1});
    gui.sliderdisp(gui.retr('pivlab_axis')); drawnow;
    testCase.verifyEqual(get(h.colormapopacity,'String'), '75', value{1});
    % the colour map image (the one with an AlphaData matrix) has the opacity 0.75 in its pixels
    % (plot.draw_background sets one pixel to 0 and one to 1: workaround for slow R2025 rendering)
    im = findobj(gui.retr('pivlab_axis'), 'Type', 'image');
    map_alpha = [];
    for k = 1:numel(im)
        a = double(im(k).AlphaData);
        if numel(a) > 1
            map_alpha = [map_alpha; median(a(:))]; %#ok<AGROW>
        end
    end
    testCase.verifyEqual(map_alpha, 0.75, 'AbsTol', 1e-9, value{1});
end
end

%% ------------------------------------------------------------------ helpers

function write_page(file, img, k)
if k == 1
    imwrite(img, file, 'WriteMode', 'overwrite');
else
    imwrite(img, file, 'WriteMode', 'append');
end
end
