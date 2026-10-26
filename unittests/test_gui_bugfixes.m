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

function test_failed_single_analysis_stops_cleanly(testCase)
% GitHub issue 166: after an error in the analysis, "Analyze current frame" went on with the
% missing result ("Unrecognized function or variable 'x'"). A 6 px ROI makes piv_FFTmulti fail.
helper_start_pivlab();
helper_gui_load_images(helper_files('jet', 1));
gui.put('roirect', [100 100 6 6]);
h = gui.gethand;
evalc('piv.AnalyzeSingle_Callback([], [], [])');   % the error report goes to the Command Window
drawnow;
rl = gui.retr('resultslist');
testCase.verifyTrue(isempty(rl) || isempty(rl{1, 1}), 'a result was stored');
testCase.verifyEqual(get(h.AnalyzeAll, 'Enable'), 'on', 'controls still locked');
testCase.verifyEmpty(findobj(getappdata(0, 'hgui'), 'Tag', 'busyhint'), 'busy strip still shown');
testCase.verifyEqual(get(h.Settings_Apply_current, 'String'), 'Analyze current frame');
end

function test_failed_correlation_matrices_stop_cleanly(testCase)
% like test_failed_single_analysis_stops_cleanly, for "Retrieve correlation matrices" (2026-10-22)
helper_start_pivlab();
helper_gui_load_images(helper_files('jet', 1));
helper_gui_analyze();
gui.put('roirect', [100 100 6 6]);
h = gui.gethand;
evalc('plot.correlation_matrices_calculate([], [], [])');
drawnow;
testCase.verifyEqual(get(h.AnalyzeAll, 'Enable'), 'on', 'controls still locked');
testCase.verifyEmpty(findobj(getappdata(0, 'hgui'), 'Tag', 'busyhint'), 'busy strip still shown');
testCase.verifyEqual(get(h.Settings_Apply_current, 'String'), 'Analyze current frame');
end

function test_circle_series_area_on_frame_without_result(testCase)
% area extraction "circle series" stored, the panel is opened on a frame that is not analysed:
% message instead of "Unrecognized function or variable 'x'" (2026-10-22)
helper_start_pivlab();
helper_gui_load_images(helper_files('jet', 2));
h = gui.gethand;
piv.AnalyzeSingle_Callback([], [], []);   % frame 1 only
gui.put('extract_type', 'extract_circle_series_area');
gui.put('xposition', [700 500]);
gui.put('yposition', 100);
set(h.fileselector, 'Value', 2); gui.fileselector_Callback(h.fileselector, [], []);
extract.area_panel_activation_Callback([], [], []);
testCase.verifyNotEmpty(findobj(gui.retr('pivlab_axis'), 'Tag', 'extract_circle_series_area'), 'circle not drawn');
end

function test_lens_calibration_kept_when_old_images_are_gone(testCase)
% importing new images when the old image files cannot be read any more (moved) switched the lens
% calibration off without notice (2026-10-22)
helper_start_pivlab();
helper_gui_load_images(helper_files('jet', 1));
gui.put('cameraParams', cameraParameters('K', [1500 0 696; 0 1500 520; 0 0 1], 'ImageSize', [1040 1392], 'RadialDistortion', [-0.05 0.01]));
gui.put('cam_use_calibration', 1);
fp = gui.retr('filepath');
fp{1} = fullfile(testCase.TestData.Dir, 'moved_away.jpg');
gui.put('filepath', fp);
evalc('helper_gui_load_images(helper_files(''jet'', 2))');
testCase.verifyEqual(gui.retr('cam_use_calibration'), 1);
end

% ---- found by the random click sequences (unittests/explore/explore_gui.m), 2026-10-22 ----

function test_analyze_current_on_a_mean_frame_unlocks(testCase)
% "Analyze current frame" on a temporal mean frame locked the controls for good
helper_start_pivlab();
helper_gui_load_images(helper_files('jet', 2));
helper_gui_analyze();
plot.temporal_operation_Callback([], [], 1);   % mean of all frames = frame 3
h = gui.gethand;
testCase.assertEqual(gui.retr('ismean'), [0; 0; 1]);
set(h.fileselector, 'Value', 3); gui.fileselector_Callback(h.fileselector, [], []);
piv.AnalyzeSingle_Callback(h.AnalyzeSingle, []);
testCase.verifyEmpty(gui.retr('busy_since'), 'still busy');
testCase.verifyEmpty(findobj(getappdata(0, 'hgui'), 'Tag', 'busyhint'), 'busy strip still shown');
testCase.verifyEqual(get(h.AnalyzeAll, 'Enable'), 'on', 'controls still locked');
end

function test_circle_series_after_changing_the_type(testCase)
% circle series drawn, type list changed to poly-line (no new drawing), other quantity, "Extract data"
helper_start_pivlab();
helper_gui_load_images(helper_files('jet', 1));
helper_gui_analyze();
h = gui.gethand;
extract.poly_extract_Callback([], []);
set(h.draw_what, 'Value', 3); extract.draw_what_Callback(h.draw_what, []);
gui.put('extract_type', 'extract_circle_series'); gui.put('xposition', [700 500]); gui.put('yposition', 150);
set(h.draw_what, 'Value', 1); extract.draw_what_Callback(h.draw_what, []);
set(h.extraction_choice, 'Value', 2); extract.extraction_choice_Callback(h.extraction_choice, []);
extract.plot_data_Callback(h.plot_data, []);   % was: Unrecognized ... 'extraction_coordinates_x'
testCase.verifyEqual(get(h.extraction_choice, 'Value'), 12, 'a circle series gives the tangential velocity');
close_other_figures();
end

function test_strain_rate_along_a_polyline(testCase)
% the unit was cut from "Strain rate in 1/frame" with all positions of 'in ' ("strain" contains it)
helper_start_pivlab();
helper_gui_load_images(helper_files('jet', 1));
helper_gui_analyze();
h = gui.gethand;
extract.poly_extract_Callback([], []);
gui.put('extract_type', 'extract_poly'); gui.put('xposition', [100; 900]); gui.put('yposition', [100; 700]);
names = cellstr(get(h.extraction_choice, 'String'));
q = find(contains(names, 'train'), 1);
testCase.assertNotEmpty(q);
set(h.extraction_choice, 'Value', q);
extract.plot_data_Callback(h.plot_data, []);   % was: Colon operands must be real scalars
close_other_figures();
end

function test_area_extraction_on_a_frame_without_result(testCase)
helper_start_pivlab();
helper_gui_load_images(helper_files('jet', 2));
h = gui.gethand;
piv.AnalyzeSingle_Callback(h.AnalyzeSingle, []);   % frame 1 only
extract.area_panel_activation_Callback([], []);
gui.put('extract_type', 'extract_rectangle_area'); gui.put('xposition', [200 400]); gui.put('yposition', [200 300]);
set(h.fileselector, 'Value', 2); gui.fileselector_Callback(h.fileselector, [], []);
extract.plot_data_area_Callback([], []);   % was: Brace indexing is not supported for variables of type double
set(h.fileselector, 'Value', 1); gui.fileselector_Callback(h.fileselector, [], []);
extract.plot_data_area_Callback([], []);
testCase.verifySubstring(strjoin(cellstr(get(h.area_results, 'String'))', ' '), 'Area');
gui.put('extract_type', 'extract_poly');   % no area drawn
extract.plot_data_area_Callback([], []);   % was: Output argument "returned_data" not assigned
end

function test_redraw_with_fewer_derived_parameters(testCase)
% display parameter "magnitude" selected, results analysed again, a poly-line extraction computes
% only the vorticity: the display redraw indexed a derived row that does not exist
helper_start_pivlab();
helper_gui_load_images(helper_files('jet', 1));
helper_gui_analyze();
h = gui.gethand;
gui.put('displaywhat', 3);
helper_gui_analyze();
extract.poly_extract_Callback([], []);
gui.put('extract_type', 'extract_poly'); gui.put('xposition', [100; 900]); gui.put('yposition', [100; 700]);
set(h.extraction_choice, 'Value', 1);
extract.plot_data_Callback(h.plot_data, []);
close_other_figures();
testCase.assertEqual(size(gui.retr('derived'), 1), 1);
gui.sliderdisp(gui.retr('pivlab_axis'));
end

function test_remove_image_with_masks_on_the_first_frame_only(testCase)
helper_start_pivlab();
helper_gui_load_images(helper_files('jet', 3));
h = gui.gethand;
roiobj = images.roi.Rectangle(gui.retr('pivlab_axis'), 'Position', [100 100 200 150]);
roiobj.UserData = 'ROI_object_rectangle'; roiobj.Tag = 'test';
gui.put('masks_in_frame', mask.update_mask_memory(roiobj, 1, gui.retr('masks_in_frame')));
delete(roiobj);
set(h.filenamebox, 'Value', 6);
import.remove_images_from_list([], []);   % was: Matrix index is out of range for deletion
testCase.verifyEqual(size(gui.retr('filepath'), 1), 5);
masks = gui.retr('masks_in_frame');
testCase.verifyNotEmpty(masks{1}, 'the mask of frame 1 is kept');
end

function test_remove_temporal_frame_on_a_frame_without_result(testCase)
% only frame 1 analysed, frame 3 shown: ismean was indexed beyond its end
helper_start_pivlab();
helper_gui_load_images(helper_files('jet', 3));
h = gui.gethand;
piv.AnalyzeSingle_Callback(h.AnalyzeSingle, []);
set(h.fileselector, 'Value', 3); gui.fileselector_Callback(h.fileselector, [], []);
plot.remove_temporal_frame_Callback([], []);   % was: Index in position 1 exceeds array bounds
testCase.verifyEqual(size(gui.retr('filepath'), 1), 6, 'no frame removed');
end

function test_apply_derived_to_all_frames_without_images(testCase)
% progress 0/0 = NaN: "Value must be numeric and finite" in gui.update_progress
helper_start_pivlab();
plot.derivs_Callback([], [], []);
plot.apply_deriv_all_Callback([], [], []);
testCase.verifyEmpty(gui.retr('busy_since'), 'still busy');
end

function test_particle_generator_invalid_inputs(testCase)
% empty / negative fields crashed deep inside the generator (interp2 with NaN image size):
% a message instead, nothing generated; with valid values the simple setup loads the images
helper_start_pivlab();
h = gui.gethand;
simulate.part_img_3d_Callback([], []);
folder = tempname;
set(h.sim3d_sizey, 'String', '');
simulate.generate_3d_Callback([], [], folder);   % message instead of an error
testCase.verifyFalse(isfolder(fullfile(folder, 'particle_images')), 'generated with an empty image height');
set(h.sim3d_sizey, 'String', '300'); set(h.sim3d_sizex, 'String', '400'); set(h.sim3d_sheet_thick, 'String', '-1');
simulate.generate_3d_Callback([], [], folder);
testCase.verifyFalse(isfolder(fullfile(folder, 'particle_images')), 'generated with a negative sheet thickness');
set(h.sim3d_sheet_thick, 'String', '1.5'); set(h.sim3d_pairs, 'String', '1');
simulate.generate_3d_Callback([], [], folder);
I = imread(fullfile(folder, 'particle_images', 'img_0001_A.tif'));
testCase.verifyEqual(size(I), [300 400]);
testCase.verifyNumElements(gui.retr('filepath'), 2, 'the image pair is not loaded into PIVlab');
rmdir(folder, 's');
close_other_figures();
end

function test_roi_fields_with_nan(testCase)
% "NaN" typed into a ROI field: drawrectangle error "Expected Position to be finite"
helper_start_pivlab();
helper_gui_load_images(helper_files('jet', 1));
h = gui.gethand;
roi.img_ROI_Callback([], []);
set(h.ROI_Man_x, 'String', '10'); set(h.ROI_Man_y, 'String', '20');
set(h.ROI_Man_w, 'String', '500'); set(h.ROI_Man_h, 'String', 'NaN');
roi.Man_ROI_Callback(h.ROI_Man_h, []);
testCase.verifyEmpty(gui.retr('roirect'), 'no ROI from invalid fields');
set(h.ROI_Man_h, 'String', '400');
roi.Man_ROI_Callback(h.ROI_Man_h, []);
testCase.verifyEqual(gui.retr('roirect'), [10 20 500 400]);
end

function test_settings_check_window_larger_than_image(testCase)
helper_start_pivlab();
helper_gui_load_images(helper_files('jet', 1));
h = gui.gethand;
set(h.pass1_size, 'String', '2000');
testCase.verifyEqual(gui.checksettings, 0);
set(h.pass1_size, 'String', '64');
testCase.verifyEqual(gui.checksettings, 1);
gui.put('roirect', [100 100 79 300]);   % 80 px wide: one pass ok, two passes need 64 + 32
set(h.pass2_enable, 'Value', 1);
testCase.verifyEqual(gui.checksettings, 0);
set(h.pass2_enable, 'Value', 0);
testCase.verifyEqual(gui.checksettings, 1);
end

%% ------------------------------------------------------------------ helpers

function close_other_figures()
f = findall(groot, 'Type', 'figure');
for i = 1:numel(f)
    if ~isequal(f(i), getappdata(0, 'hgui'))
        delete(f(i));
    end
end
end

function write_page(file, img, k)
if k == 1
    imwrite(img, file, 'WriteMode', 'overwrite');
else
    imwrite(img, file, 'WriteMode', 'append');
end
end
