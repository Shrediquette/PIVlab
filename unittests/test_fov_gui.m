%% Two cameras for a larger field of view in the PIVlab window
%
% "Import multi-camera images" + lens calibration and board image per camera + "Compute 3D alignment" with two
% cameras side by side: PIVlab chooses the larger field of view and makes ONE combined 2D data set (camera
% switch gone, px -> mm filled in, the part no camera sees masked, calibration panel locked). Then: analysis
% against the ground truth, background, image-based validation, sessions, a new import of the same cameras
% (combined again), a 2D import (combined data removed), removing images, Show 3D setup.
% Plan: dev_notes/two_camera_fov_plan.md
%
% Run with (GUI tests: with a time limit, e.g. run_pivlab_tests):
%   runtests('unittests/test_fov_gui.m')

function tests = test_fov_gui
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
helper_setup_once(testCase);
testCase.TestData.c = helper_fov_synthetic_case(fullfile(testCase.TestData.Dir, 'case'), 3);
helper_close_pivlab();
end

function teardownOnce(testCase)
helper_close_pivlab();
helper_teardown_once(testCase);
end

% -------------------------------------------------------------------------

function test_alignment_combines_cameras(testCase)
c = testCase.TestData.c;
combined(c);
h = gui.gethand;
verifyFalse(testCase, isequal(gui.retr('stereomode'), 1), 'still in stereo mode');
verifyTrue(testCase, fov.gui_active);
calib = gui.retr('fov_calib');
verifyEqual(testCase, calib.use, "fov");
F = gui.retr('fov_maps');
verifyEqual(testCase, gui.retr('size_of_the_image'), F.size);
verifyEqual(testCase, numel(gui.retr('filepath')), 6, 'frame list of camera 1');
src2 = gui.retr('fov_src2');
verifyEqual(testCase, numel(src2.filepath), 6, 'frame list of camera 2');
% every frame is the combination of both cameras
img = import.get_img(3);
verifyEqual(testCase, img, fov.compose(imread(c.files{1}(3)), imread(c.files{2}(3)), F));
% the camera switch is gone, the lens calibration and rectification are locked
verifyEqual(testCase, char(get(h.stereo_camera_toggle, 'Visible')), 'off');
verifyEqual(testCase, char(get(h.calib_usecalibration, 'Enable')), 'off');
verifyEqual(testCase, char(get(h.calib_userectification, 'Enable')), 'off');
verifyEqual(testCase, char(get(h.stereo_rect_note, 'Visible')), 'on');
cam = import.cam_settings(FromGUI=true);
verifyEqual(testCase, cam.use_calibration, 0);
verifyNotEmpty(testCase, cam.fov);
% px -> mm from the alignment, region of interest = whole image, the part no camera sees is masked
pc = gui.retr('pointscali');
verifyEqual(testCase, str2double(get(h.realdist, 'String')) / diff(pc(:, 1)), F.mm_per_px, 'RelTol', 1e-3);
verifyEmpty(testCase, gui.retr('roirect'));
masks = gui.retr('masks_in_frame');
verifyEqual(testCase, numel(masks), 3, 'a mask in every frame');
binary = mask.convert_masks_to_binary(F.size, masks{2});
verifyEqual(testCase, binary, F.owner == 0, 'the mask is the part no camera sees');
% the checklist of the panel
verifyTrue(testCase, contains(get(h.stereo_step_4, 'String'), 'larger field of view'));
end

function test_analysis_against_ground_truth(testCase)
c = testCase.TestData.c;
combined(c);
h = gui.gethand;
set(h.pass1_size, 'String', '64'); piv.intarea_Callback(h.pass1_size, [], []);
set(h.pass1_step, 'String', '32'); piv.step_Callback(h.pass1_step, [], []);
set(h.pass2_enable, 'Value', 1); set(h.pass2_size, 'String', '32'); piv.pass2_checkbox_Callback(h.pass2_enable, [], []);
set(h.pass3_enable, 'Value', 1); set(h.pass3_size, 'String', '16'); piv.pass3_checkbox_Callback(h.pass3_enable, [], []);
set(h.update_display_checkbox, 'Value', 0);
piv.AnalyzeAll_Callback;
validate.apply_filter_all_Callback;
rl = gui.retr('resultslist');
verifyEqual(testCase, size(rl, 2), 3);
calib = gui.retr('fov_calib');
F = gui.retr('fov_maps');
U = 0; V = 0;
for i = 1:3
    U = U + rl{3, i} / 3;
    V = V + rl{4, i} / 3;
end
[xw, yw] = intrinsicToWorld(calib.Ravg, rl{1, 1}, rl{2, 1});
Ut = interp2(c.X, c.Y, c.U, xw, yw);
Vt = interp2(c.X, c.Y, c.V, xw, yw);
ok = ~isnan(Ut) & ~isnan(U) & ~isnan(V);
verifyGreaterThan(testCase, nnz(ok), 0.9 * numel(ok), 'vectors missing');
e = [U(ok) - Ut(ok) / F.mm_per_px, V(ok) - Vt(ok) / F.mm_per_px];
verifyLessThan(testCase, sqrt(mean(e .^ 2, 1)), [0.08 0.08], 'rms error [px]');
verifyLessThan(testCase, abs(mean(e, 1)), [0.02 0.02], 'bias [px]');
end

function test_background_and_contrast_filter(testCase)
c = testCase.TestData.c;
combined(c);
h = gui.gethand;
set(h.bg_subtract, 'Value', 3); % minimum intensity
preproc.generate_BG_img_parallel % combined cameras: the serial background of both cameras
F = gui.retr('fov_maps');
verifyEqual(testCase, size(gui.retr('bg_img_A')), F.size);
img = import.get_img(1);
verifyEqual(testCase, size(img), F.size);
% image-based validation of all frames reads the combined images (also in its parallel loop)
set(h.update_display_checkbox, 'Value', 0);
piv.AnalyzeAll_Callback;
set(h.contrast_filter_enable, 'Value', 1);
parallel = gui.retr('parallel');
gui.put('parallel', 1); % the parfor branch (without a pool: a normal loop)
cleanup = onCleanup(@() gui.put('parallel', parallel));
validate.apply_filter_all_Callback;
rl = gui.retr('resultslist');
verifyNotEmpty(testCase, rl{7, 1}, 'validation of all frames did not run');
end

function test_session_round_trip(testCase)
c = testCase.TestData.c;
combined(c);
before = import.get_img(5);
file = fullfile(testCase.TestData.Dir, 'fov_session.mat');
export.save_session_function(testCase.TestData.Dir, 'fov_session.mat');
helper_start_pivlab();
verifyFalse(testCase, fov.gui_active);
import.load_session_Callback(1, file);
verifyTrue(testCase, fov.gui_active, 'combined cameras not back');
verifyNotEmpty(testCase, gui.retr('fov_maps'), 'maps not made again');
verifyEqual(testCase, import.get_img(5), before);
end

function test_new_import_keeps_alignment(testCase)
% "Import multi-camera images" with images of the same cameras: combined again, no new 3D alignment
c = testCase.TestData.c;
combined(c);
calib = gui.retr('fov_calib');
import.stereo_import_Callback([], [], {c.files{1}(1:4), c.files{2}(1:4)});
verifyTrue(testCase, fov.gui_active, 'not combined again');
verifyEqual(testCase, numel(gui.retr('filepath')), 4);
calib2 = gui.retr('fov_calib');
verifyEqual(testCase, calib2.Ravg, calib.Ravg);
verifyEqual(testCase, import.get_img(3), fov.compose(imread(c.files{1}(3)), imread(c.files{2}(3)), gui.retr('fov_maps')));
end

function test_2d_import_removes_combined_cameras(testCase)
c = testCase.TestData.c;
combined(c);
names = cellstr(c.files{1});
import.loadimgsbutton_Callback([], [], 0, struct('name', names(:), 'isdir', num2cell(false(numel(names), 1))));
verifyFalse(testCase, fov.gui_active);
verifyEmpty(testCase, gui.retr('fov_calib'));
img = import.get_img(1);
verifyEqual(testCase, size(img), size(imread(c.files{1}(1))), 'camera 1 alone');
end

function test_remove_images_keeps_cameras_together(testCase)
c = testCase.TestData.c;
combined(c);
h = gui.gethand;
set(h.filenamebox, 'Value', [3 4]); % the second image pair
import.remove_images_from_list;
verifyEqual(testCase, numel(gui.retr('filepath')), 4);
src2 = gui.retr('fov_src2');
verifyEqual(testCase, numel(src2.filepath), 4);
verifyEqual(testCase, import.get_img(3), fov.compose(imread(c.files{1}(5)), imread(c.files{2}(5)), gui.retr('fov_maps')));
end

function test_show_3d_setup(testCase)
c = testCase.TestData.c;
combined(c);
before = findall(0, 'Type', 'figure');
stereo.show_3d_Callback;
fig = setdiff(findall(0, 'Type', 'figure'), before);
verifyNumElements(testCase, fig, 1);
cleanup = onCleanup(@() delete(fig));
report = findall(fig, 'Tag', 'stereo_calib_report');
verifyTrue(testCase, any(contains(report.String, 'larger field of view')));
end

function test_measure_disparity_moves_cameras_onto_sheet(testCase)
% light sheet 0.6 mm behind the board, tilted 1 deg: "Measure disparity" finds it in the overlap, maps both cameras
% onto it, resets the results and keeps the masks drawn by the user
c = helper_fov_synthetic_case(fullfile(testCase.TestData.Dir, 'tilted'), 3, SheetOffset=0.6, SheetTilt=1);
combined(c);
h = gui.gethand;
verifyEqual(testCase, char(get(h.stereo_measure_disparity, 'Enable')), 'on');
verifyEqual(testCase, char(get(h.stereo_disp_panel, 'Visible')), 'on');
verifyTrue(testCase, contains(get(h.stereo_step_5, 'String'), 'Light sheet position'));
masks = gui.retr('masks_in_frame');
user = {'ROI_object_rectangle', [100 100 50 40], [1 0 0], '', 'user_mask'};
masks{1} = [masks{1}; user];
gui.put('masks_in_frame', masks);
gui.put('resultslist', cell(15, 3));
stereo.measure_disparity_Callback;
calib = gui.retr('fov_calib');
verifyTrue(testCase, isfield(calib, 'sheet'), 'sheet not measured');
A = c.sheet_pose.A;
[~, cy] = centroid(calib.grid_info.overlap);
verifyEqual(testCase, calib.sheet.offset, A(3, 4) + A(3, 2) / A(2, 2) * cy, 'AbsTol', 0.05, 'offset [mm]');
verifyLessThan(testCase, calib.sheet.history(end, 1), 0.2, 'mismatch on the sheet [px]');
verifyTrue(testCase, any(contains(cellstr(get(h.stereo_disp_report, 'String')), 'Light sheet at the seam')));
verifyTrue(testCase, startsWith(get(h.stereo_step_5, 'String'), char(10003)), 'checklist: sheet measured');
verifyEmpty(testCase, gui.retr('resultslist'), 'results not reset');
F = gui.retr('fov_maps');
verifyEqual(testCase, import.get_img(3), fov.compose(imread(c.files{1}(3)), imread(c.files{2}(3)), F));
masks = gui.retr('masks_in_frame');
verifyTrue(testCase, any(strcmp(masks{1}(:, 5), 'user_mask')), 'user mask lost');
verifyEqual(testCase, mask.convert_masks_to_binary(F.size, masks{2}), F.owner == 0, 'mask of the part no camera sees');
verifyEqual(testCase, size(masks{1}, 1), size(masks{2}, 1) + 1);
% a session keeps the sheet
before = import.get_img(5);
file = fullfile(testCase.TestData.Dir, 'fov_sheet_session.mat');
export.save_session_function(testCase.TestData.Dir, 'fov_sheet_session.mat');
helper_start_pivlab();
import.load_session_Callback(1, file);
verifyEqual(testCase, import.get_img(5), before);
end

% -------------------------------------------------------------------------

function combined(c)
helper_start_pivlab();
helper_stereo_gui_calibrate(c);
end
