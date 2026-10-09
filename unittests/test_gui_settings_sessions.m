function tests = test_gui_settings_sessions
%TEST_GUI_SETTINGS_SESSIONS The PIVlab window with settings files, sessions and preferences,
%driven like a user (menu callbacks, file dialogs replaced by unittests/parity/mocks).
%   Run with: results = runtests('unittests/test_gui_settings_sessions.m')
%   Optional real data (skipped if missing): pco.panda double images in
%   D:\PIV Data\micro_PIV_panda_excelitas\micro_piv_boundary_layer1
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
root = fileparts(fileparts(mfilename('fullpath')));
addpath(root);
addpath(fullfile(root, 'unittests', 'parity', 'mocks'), '-begin');   % uigetfile / uiputfile
testCase.TestData.Root = root;
testCase.TestData.Dir = tempname(tempdir);
mkdir(testCase.TestData.Dir);
setappdata(0, 'PIVlabTestMode', true);
testCase.TestData.Preferences = clear_preferences();
end

function teardownOnce(testCase)
close_pivlab();
restore_preferences(testCase.TestData.Preferences);
rmpath(fullfile(testCase.TestData.Root, 'unittests', 'parity', 'mocks'));
if isappdata(0, 'PIVlabTestMode'), rmappdata(0, 'PIVlabTestMode'); end
if isappdata(0, 'parity_mock_file'), rmappdata(0, 'parity_mock_file'); end
try, rmdir(testCase.TestData.Dir, 's'); catch, end
close all force
end

function setup(~)
close_pivlab();
end

function teardown(~)
close_pivlab();
end

%% ================================================================== 3. settings files
function test_settings_file_in_a_fresh_pivlab(testCase)
% save settings, load them in a fresh PIVlab: analysis, calibration and mask generator settings
% are applied, display / export / acquisition settings stay as they are
root = testCase.TestData.Root;
start_pivlab();
h = gui.gethand;
set(h.clahe_enable,'Value',0); set(h.highpass_enable,'Value',1); set(h.highpass_size,'String','21');
set(h.pass1_size,'String','96'); set(h.pass1_step,'String','48');
set(h.pass3_enable,'Value',1); set(h.pass3_size,'String','24');
set(h.smooth_mode,'Value',2); set(h.smooth_param,'String','0.7');
set(h.stdev_thresh,'String','5.5'); set(h.loc_med_thresh,'String','2.2');
set(h.mask_basic_expert,'Value',2); set(h.binarize_threshold,'String','0.33');
set(h.colormap_choice,'Value',3);                 % display
set(h.ac_interpuls,'String','777');               % acquisition
load_images(jet(root,1));
gui.put('pointscali',[10 10; 210 10]);
set(h.realdist,'String','20'); set(h.time_inp,'String','50');
set(h.x_axis_direction,'Value',2);
calibrate.apply_cali_Callback([],[],[]);
gui.update_dependent_controls;
saved = gui.collect_settings;
saved_cal = cal_values();
f = 'settings_fresh.mat';
mock_file(testCase.TestData.Dir, f);
export.save_settings_Callback([],[],[]);
testCase.assertTrue(isfile(fullfile(testCase.TestData.Dir, f)));
close_pivlab();

start_pivlab();
h = gui.gethand;
set(h.colormap_choice,'Value',5); set(h.ac_interpuls,'String','1234');
set(h.export_mat_derivatives,'Value',1);
before = gui.collect_settings;
mock_file(testCase.TestData.Dir, f);
import.load_settings_Callback([],[],[]); drawnow;
after = gui.collect_settings;
for g = {'analysis','calibration','masks'}
    testCase.verifyEqual(after.(g{1}), saved.(g{1}), ['group ' g{1}]);
end
for g = {'display','export','acquisition'}
    testCase.verifyEqual(after.(g{1}), before.(g{1}), ['group ' g{1} ' must not change']);
end
% the controls show the loaded values, the dependent controls are updated
testCase.verifyEqual(get(h.pass1_size,'String'), '96');
testCase.verifyEqual(get(h.pass3_step,'String'), '12');
testCase.verifyEqual(char(get(h.pass3_size,'Enable')), 'on');
testCase.verifyEqual(char(get(h.uipanel25_2,'Visible')), 'on', 'expert mask panel');
% calibration: values and the green box
c = cal_values();
testCase.verifyEqual(c.calxy, saved_cal.calxy, 'RelTol', 1e-12);
testCase.verifyEqual(c.calu, saved_cal.calu, 'RelTol', 1e-12);
box = get(h.calidisp,'String');
box = strjoin(cellstr(box), ' ');   % char matrix, one row per line
testCase.verifySubstring(box, sprintf('%0.4e', saved_cal.calxy));
testCase.verifySubstring(box, 'm/s');
end

function test_load_settings_keeps_results_and_makes_background(testCase)
root = testCase.TestData.Root;
start_pivlab();
load_images(jet(root,3));
h = gui.gethand;
analyze();
rl = gui.retr('resultslist');
testCase.verifyEmpty(gui.retr('bg_img_A'));
% a settings file with background subtraction "mean"
set(h.bg_subtract,'Value',2); set(h.stdev_thresh,'String','4.5');   % (no callbacks: nothing is computed)
G = gui.collect_settings;
G.calibration_data = calibrate.calibration_data;
set(h.bg_subtract,'Value',1); set(h.stdev_thresh,'String','7');
f = fullfile(testCase.TestData.Dir, 'with_background.mat');
export.write_settings_file(f, G);
mock_file(testCase.TestData.Dir, 'with_background.mat');
import.load_settings_Callback([],[],[]); drawnow;
testCase.verifyEqual(gui.retr('resultslist'), rl, 'results stay');
testCase.verifyEqual(get(h.bg_subtract,'Value'), 2);
testCase.verifyEqual(str2double(get(h.stdev_thresh,'String')), 4.5);
bgA = gui.retr('bg_img_A');
testCase.verifyNotEmpty(bgA, 'background images are made again');
% the same as making them with the button
gui.put('bg_img_A',[]); gui.put('bg_img_B',[]);
preproc.generate_BG_img(); drawnow;
testCase.verifyEqual(gui.retr('bg_img_A'), bgA);
% the analysis uses them
analyze();
rl2 = gui.retr('resultslist');
testCase.verifyNotEqual(rl2{3,1}, rl{3,1});
end

function test_old_files_change_nothing(testCase)
start_pivlab();
load_images(jet(testCase.TestData.Root,1));
h = gui.gethand;
set(h.pass1_size,'String','80');
before = gui.collect_settings;
data_before = session_data();
% PIVlab 3.x settings file
clahe_enable = 1; intarea = '64'; step = '32'; %#ok<NASGU>
save(fullfile(testCase.TestData.Dir,'old_settings.mat'), 'clahe_enable', 'intarea', 'step');
mock_file(testCase.TestData.Dir, 'old_settings.mat');
import.load_settings_Callback([],[],[]); drawnow;
testCase.verifyEqual(gui.collect_settings, before, 'old settings file');
[s, message] = import.read_settings_file(fullfile(testCase.TestData.Dir,'old_settings.mat'));
testCase.verifyEmpty(s);
testCase.verifySubstring(message, 'older PIVlab version');
% PIVlab 3.x session
resultslist = {}; wasdisabled = []; sequencer = 1; filepath = {'a.tif';'b.tif'}; %#ok<NASGU>
old = fullfile(testCase.TestData.Dir,'old_session.mat');
save(old, 'resultslist', 'wasdisabled', 'sequencer', 'filepath');
import.load_session_Callback(1, old); drawnow;
testCase.verifyEqual(gui.collect_settings, before, 'old session: settings');
testCase.verifyEqual(session_data(), data_before, 'old session: data');
[~, message] = import.read_session_file(old);
testCase.verifySubstring(message, 'older PIVlab version');
% a PIVlab 3.x session as settings file
mock_file(testCase.TestData.Dir, 'old_session.mat');
import.load_settings_Callback([],[],[]); drawnow;
testCase.verifyEqual(gui.collect_settings, before, 'old session as settings file');
end

function test_load_settings_from_a_session_file(testCase)
root = testCase.TestData.Root;
% a session with other settings and other images
start_pivlab();
load_images(jet(root,2));
h = gui.gethand;
set(h.pass1_size,'String','48'); set(h.pass1_step,'String','24');
set(h.stdev_thresh,'String','6.5');
set(h.colormap_choice,'Value',4);
analyze();
saved = gui.collect_settings;
export.save_session_function(testCase.TestData.Dir, 'settings_source_session.mat');
close_pivlab();
% another analysis: only the settings are taken over
start_pivlab();
load_images(jet(root,1));
analyze();
h = gui.gethand;
rl = gui.retr('resultslist');
files = gui.retr('filepath');
before = gui.collect_settings;
mock_file(testCase.TestData.Dir, 'settings_source_session.mat');
import.load_settings_Callback([],[],[]); drawnow;
after = gui.collect_settings;
testCase.verifyEqual(after.analysis, saved.analysis);
testCase.verifyEqual(after.display, before.display);
testCase.verifyEqual(gui.retr('resultslist'), rl);
testCase.verifyEqual(gui.retr('filepath'), files);
testCase.verifyEqual(get(h.pass1_size,'String'), '48');
end

%% ================================================================== 4. sessions
function test_session_with_everything(testCase)
root = testCase.TestData.Root;
files = distortion(root, 3);
start_pivlab();
load_images(files);
h = gui.gethand;
% camera calibration (lens undistortion, view "same") and rectification
set_camera_model(2);
a = 3*pi/180;
gui.put('rectification_tform', affine2d([cos(a) sin(a) 0; -sin(a) cos(a) 0; 0 0 1]));
gui.put('cam_use_rectification', 1);
% ROI, masks, background
sz = gui.retr('expected_image_size');
gui.put('roirect', [40 40 sz(2)-100 sz(1)-90]);
gui.put('masks_in_frame', {{'ROI_object_rectangle',[200 150 80 60]}, {}, {'ROI_object_polygon',[300 300;380 310;370 380;290 370]}});
gui.quick3_Callback([],[]);
set(h.bg_subtract,'Value',2); preproc.generate_BG_img(); drawnow;
set(h.highpass_enable,'Value',1);
% analysis with 3 passes
gui.quick4_Callback([],[]);
set(h.pass3_enable,'Value',1); set(h.pass3_size,'String','24'); piv.pass3_checkbox_Callback(h.pass3_enable,[],[]);
analyze();
% calibration with offsets and flipped axes
gui.put('pointscali',[10 10; 110 10]);
set(h.realdist,'String','10'); set(h.time_inp,'String','100');
set(h.x_axis_direction,'Value',2); set(h.y_axis_direction,'Value',2);
calibrate.apply_cali_Callback([],[],[]);
gui.put('points_offsetx',[100 100 5]); gui.put('points_offsety',[100 200 3]);
calibrate.apply_cali_Callback([],[],[]);
% velocity limits, manual vector deletion, validation
gui.put('velrect', [-0.002 -0.002 0.004 0.004]);
gui.put('manualdeletion', {[3 4; 5 6], [], [2 2]});
set(h.stdev_thresh,'String','6');
validate.apply_filter_all_Callback([],[],[]);
% smoothing, derived parameter, temporal mean appended, stream lines, markers
set(h.smooth_mode,'Value',2); plot.smooth_mode_Callback(h.smooth_mode);
plot.derivs_Callback([],[],[]);
set(h.derivchoice,'Value',2); plot.derivchoice_Callback(h.derivchoice);
plot.apply_deriv_all_Callback([],[],[]);
set(h.selectedFramesMean,'String','1:3'); set(h.append_replace,'Value',1);
plot.temporal_operation_Callback([],[],1); drawnow;
gui.put('streamlinesX', [100 200 300]); gui.put('streamlinesY', [150 150 150]);
gui.put('manmarkersX', [120 220]); gui.put('manmarkersY', [130 230]);
% view: frame 2, B image, zoom, panel, Basic mode
set(h.fileselector,'Value',2); gui.fileselector_Callback(h.fileselector,[],[]);
gui.put('toggler', 1);
gui.put('xzoomlimit', [100 400]); gui.put('yzoomlimit', [80 300]);
gui.apply_ui_mode('basic');
gui.switchui('multip08');
gui.update_dependent_controls;
gui.sliderdisp(gui.retr('pivlab_axis')); drawnow;
saved_settings = gui.collect_settings;
saved_data = session_data();
saved_view = gui.collect_view;
states = enable_visible_states();
shot_before = fullfile(testCase.TestData.Dir, 'everything_before.png');
shot(shot_before);
tic; export.save_session_function(testCase.TestData.Dir, 'everything.mat'); t_save = toc;
close_pivlab();

start_pivlab();
tic; import.load_session_Callback(1, fullfile(testCase.TestData.Dir, 'everything.mat')); drawnow; t_load = toc;
fprintf('session with everything: save %.2f s, load %.2f s\n', t_save, t_load);
testCase.verifyEqual(gui.collect_settings, saved_settings, 'settings');
data = session_data();
keys = fieldnames(saved_data);
for k = 1:numel(keys)
    if strcmp(keys{k}, 'cameraParams')   % object read from a file: compare the lens parameters
        for p = {'K','RadialDistortion','TangentialDistortion','ImageSize'}
            testCase.verifyEqual(data.cameraParams.(p{1}), saved_data.cameraParams.(p{1}), ['cameraParams.' p{1}]);
        end
        continue
    end
    testCase.verifyEqual(data.(keys{k}), saved_data.(keys{k}), ['session data ' keys{k}]);
end
v = gui.collect_view;
testCase.verifyEqual(v, saved_view, 'view');
testCase.verifyEqual(gui.retr('ui_mode'), 'basic');
h = gui.gethand;
testCase.verifyEqual(get(h.fileselector,'Value'), 2);
testCase.verifyEqual(char(get(h.multip08,'Visible')), 'on');
testCase.verifyEqual(get(gui.retr('pivlab_axis'),'XLim'), [100 400]);
verify_same_states(testCase, states, enable_visible_states(), 'after loading the session');
box = get(h.calidisp,'String');
box = strjoin(cellstr(box), ' ');   % char matrix, one row per line
testCase.verifySubstring(box, 'x offset');
% the window looks the same
shot_after = fullfile(testCase.TestData.Dir, 'everything_after.png');
shot(shot_after);
A = imread(shot_before); B = imread(shot_after);
if isequal(size(A), size(B))
    testCase.verifyLessThan(nnz(any(A ~= B, 3)) / numel(A(:,:,1)), 0.01, 'screenshots differ');
else
    testCase.verifyFail('screenshots have different sizes');
end
copyfile(shot_before, fullfile(tempdir, 'pivlab_session_everything_before.png'));
copyfile(shot_after, fullfile(tempdir, 'pivlab_session_everything_after.png'));
% keep working: analyse again -> the same raw results; validate; derive; export
rl = saved_data.resultslist;
gui.apply_ui_mode('advanced');
analyze();
rl2 = gui.retr('resultslist');
for k = 1:3
    testCase.verifyEqual(rl2{3,k}, rl{3,k}, sprintf('analysis again, pair %d', k));
end
validate.apply_filter_all_Callback([],[],[]);
rl3 = gui.retr('resultslist');
testCase.verifyEqual(rl3{9,1}, rl{9,1}, 'validation again (manual deletion, velocity limits)');
testCase.verifyTrue(all(rl3{9,1}(3,4) == 2), 'manually deleted vector');
set(h.derivchoice,'Value',3); plot.derivchoice_Callback(h.derivchoice);
plot.apply_deriv_all_Callback([],[],[]);
testCase.verifyNotEmpty(gui.retr('derived'));
expdir = fullfile(testCase.TestData.Dir, 'export_after_session');
mkdir(expdir);
export.mat_file_save(1,'export.mat',expdir,2);
E = load(fullfile(expdir,'export.mat'));
testCase.verifyTrue(isfield(E, 'u_filtered'));
export.file_save(1,'export.txt',expdir,1);
testCase.verifyTrue(isfile(fullfile(expdir,'export.txt')));
end

function test_session_with_multitiff(testCase)
root = testCase.TestData.Root;
J = jet(root, 2);
stack = fullfile(testCase.TestData.Dir, 'session_stack.tif');
for k = 1:4
    if k == 1, mode = 'overwrite'; else, mode = 'append'; end
    imwrite(imread(J{k}), stack, 'WriteMode', mode);
end
start_pivlab();
gui.put('sequencer',0); gui.put('multitiff',1); gui.put('video_selection_done',0);
import.loadimgsbutton_Callback([],[],0,struct('name',{stack},'isdir',false)); drawnow;
testCase.verifyEqual(size(gui.retr('filepath'),1), 6);
analyze();
rl = gui.retr('resultslist');
export.save_session_function(testCase.TestData.Dir, 'multitiff_session.mat');
close_pivlab();
start_pivlab();
import.load_session_Callback(1, fullfile(testCase.TestData.Dir, 'multitiff_session.mat')); drawnow;
testCase.verifyEqual(gui.retr('multitiff'), 1);
testCase.verifyEqual(gui.retr('framenum'), [1;2;2;3;3;4]);
analyze();
rl2 = gui.retr('resultslist');
testCase.verifyEqual(rl2{3,3}, rl{3,3});
end

function test_session_with_pco_double_images(testCase)
d = 'D:\PIV Data\micro_PIV_panda_excelitas\micro_piv_boundary_layer1';
testCase.assumeTrue(isfolder(d), 'pco.panda test images not available');
files = {fullfile(d,'PIVlab_pco_000001.tif'); fullfile(d,'PIVlab_pco_000002.tif')};
start_pivlab();
load_images(files);
testCase.verifyEqual(gui.retr('pcopanda_dbl_image'), 1);
sz = gui.retr('expected_image_size');
gui.put('roirect', [1000 1000 1024 768]);
analyze();
rl = gui.retr('resultslist');
testCase.verifyEqual(size(rl,2), 2);
export.save_session_function(testCase.TestData.Dir, 'pco_session.mat');
close_pivlab();
start_pivlab();
import.load_session_Callback(1, fullfile(testCase.TestData.Dir, 'pco_session.mat')); drawnow;
testCase.verifyEqual(gui.retr('pcopanda_dbl_image'), 1);
testCase.verifyEqual(gui.retr('expected_image_size'), sz);
analyze();
rl2 = gui.retr('resultslist');
testCase.verifyEqual(rl2{3,2}, rl{3,2});
% the API reads the session as well
r = pivlab.loadSession(fullfile(testCase.TestData.Dir, 'pco_session.mat'));
testCase.verifyTrue(r.images.pcopanda_dbl_image);
testCase.verifyEqual(r.px.u_raw(:,:,2), rl{3,2});
img = pivlab.getImage(r.images, 1, Frame="B", Preprocessed=false);
testCase.verifyEqual(size(img), sz);
end

function test_capture_session(testCase)
% what the capture panel does after a recording: images -> GUI, PIVlab_Capture_Session.mat
root = testCase.TestData.Root;
proj = fullfile(testCase.TestData.Dir, 'capture_project');
mkdir(proj);
J = jet(root, 2);
for i = 1:2
    imwrite(imread(J{2*i-1}), fullfile(proj, sprintf('PIVlab_%04d_A.tif', i-1)));
    imwrite(imread(J{2*i}),   fullfile(proj, sprintf('PIVlab_%04d_B.tif', i-1)));
end
start_pivlab();
h = gui.gethand;
set(h.ac_project,'String',proj);
set(h.ac_interpuls,'String','1500');
gui.put('camera_type','OPTRONIS');
found = acquisition.push_recorded_to_GUI('OPTRONIS', 2);
testCase.verifyEqual(found, 1);
gui.put('sessionpath', proj);
set(h.time_inp,'String',num2str(str2num(get(h.ac_interpuls,'String'))/1000)); %#ok<ST2NM>
export.save_session_function(proj, 'PIVlab_Capture_Session.mat');
files = gui.retr('filepath');
close_pivlab();
start_pivlab();
import.load_session_Callback(1, fullfile(proj, 'PIVlab_Capture_Session.mat')); drawnow;
h = gui.gethand;
testCase.verifyEqual(gui.retr('filepath'), files);
testCase.verifyEqual(get(h.time_inp,'String'), '1.5');
testCase.verifyEqual(get(h.ac_interpuls,'String'), '1500');
analyze();
testCase.verifyEqual(size(gui.retr('resultslist'),2), 2);
% pco.panda double images recorded by PIVlab
d = 'D:\PIV Data\micro_PIV_panda_excelitas\micro_piv_boundary_layer1';
if isfolder(d)
    set(h.ac_project,'String',d);
    found = acquisition.push_recorded_to_GUI('pco_panda', 2);
    testCase.verifyEqual(found, 1);
    testCase.verifyEqual(gui.retr('pcopanda_dbl_image'), 1);
    export.save_session_function(testCase.TestData.Dir, 'PIVlab_Capture_Session_pco.mat');
    close_pivlab();
    start_pivlab();
    import.load_session_Callback(1, fullfile(testCase.TestData.Dir, 'PIVlab_Capture_Session_pco.mat')); drawnow;
    testCase.verifyEqual(gui.retr('pcopanda_dbl_image'), 1);
    gui.sliderdisp(gui.retr('pivlab_axis')); drawnow;
end
end

function test_large_session(testCase)
% about 1 GB of results: time to save / load and file size (format 7 without compression);
% more than 2 GB: format 7.3
start_pivlab();
load_images(jet(testCase.TestData.Root,1));
analyze();
rl = gui.retr('resultslist');
[~, sys] = memory;
free_gb = sys.PhysicalMemory.Available / 2^30;
testCase.assumeGreaterThan(free_gb, 12, 'not enough free memory for the large session test');
for target_gb = [1 2.2]
    one = whos('rl');
    n = ceil(target_gb * 2^30 / one.bytes);
    big = repmat(rl(:,1), 1, n);
    for k = 1:n   % different numbers in every frame (no shared copies)
        big{3,k} = rl{3,1} + single(k);
        big{4,k} = rl{4,1} + single(k);
        big{7,k} = rl{3,1} - single(k);
        big{8,k} = rl{4,1} - single(k);
    end
    gui.put('resultslist', big);
    gui.put('filepath', repmat(gui.retr('filepath'), n, 1));
    gui.put('filename', repmat(gui.retr('filename'), n, 1));
    f = sprintf('large_%g.mat', target_gb);
    tic; export.save_session_function(testCase.TestData.Dir, f); t_save = toc;
    info = dir(fullfile(testCase.TestData.Dir, f));
    w = whos('big');
    vars = who('-file', fullfile(testCase.TestData.Dir, f));
    testCase.verifyTrue(ismember('pivlab_data', vars));
    is73 = h5_like(fullfile(testCase.TestData.Dir, f));
    close_pivlab();
    start_pivlab();
    tic; import.load_session_Callback(1, fullfile(testCase.TestData.Dir, f)); drawnow; t_load = toc;
    back = gui.retr('resultslist');
    testCase.verifyEqual(size(back,2), n);
    testCase.verifyEqual(back{3,n}, big{3,n});
    fprintf('LARGE SESSION %.2f GB data: %d frames, file %.2f GB, format %s, save %.1f s, load %.1f s\n', ...
        w.bytes/2^30, n, info.bytes/2^30, ifelse(is73, '7.3', '7'), t_save, t_load);
    testCase.verifyEqual(is73, w.bytes > 2^31 - 2^24, sprintf('format for %.2f GB', w.bytes/2^30));
    delete(fullfile(testCase.TestData.Dir, f));
    clear big back
    gui.put('resultslist', rl);
    close_pivlab();
    start_pivlab();
    load_images(jet(testCase.TestData.Root,1));
    gui.put('resultslist', rl);
end
end

%% ================================================================== 5. preferences
function test_first_start_without_preferences(testCase)
if ispref('PIVlab'), rmpref('PIVlab'); end
start_pivlab();
testCase.verifyEqual(gui.retr('pathname'), fullfile(testCase.TestData.Root, 'Example_data'));
testCase.verifyEqual(gui.retr('ui_mode'), 'advanced');
testCase.verifyEqual(gui.retr('panelwidth'), default_panelwidth());
% dark / light follows MATLAB (an old PIVlab_ad preference is not used)
hgui = getappdata(0,'hgui');
testCase.verifyEqual(isequal(gui.retr('darkmode'), 1), strcmpi(hgui.Theme.BaseColorStyle,'dark'));
close_pivlab();
testCase.verifyFalse(ispref('PIVlab','ui_mode'), 'nothing stored without a change');
end

function test_preferences_are_remembered(testCase)
root = testCase.TestData.Root;
if ispref('PIVlab'), rmpref('PIVlab'); end
start_pivlab();
h = gui.gethand;
% last folder (stored when PIVlab is closed) and sequencing style of the file dialog
load_images(distortion(root,1), 1);
folder = gui.retr('pathname');
close_with_menu();
start_pivlab();
testCase.verifyEqual(gui.retr('pathname'), folder, 'last folder');
h = gui.gethand;
% Basic mode, panel width, theme
gui.request_mode_switch('basic');
set(h.panelslider,'Value',55); gui.pref_apply_Callback;
h = gui.gethand;
dark_now = double(isequal(gui.retr('darkmode'), 1));   % empty = light (MATLAB theme)
set(h.matlab_theme,'Value', 1 + double(dark_now == 1));   % 1 = dark, 2 = light: the other one
gui.change_theme();
close_with_menu();
start_pivlab();
testCase.verifyEqual(gui.retr('ui_mode'), 'basic');
testCase.verifyEqual(gui.retr('panelwidth'), 55);
testCase.verifyEqual(double(isequal(gui.retr('darkmode'), 1)), 1 - dark_now, 'theme');
hgui = getappdata(0,'hgui');
testCase.verifyEqual(strcmpi(hgui.Theme.BaseColorStyle,'dark'), dark_now == 0);
end

function test_preferences_apply_and_theme_keep_the_settings(testCase)
% Preferences -> Apply (panel width) and the theme change rebuild all controls: settings, images,
% results, calibration, ROI, frame and the remembered folder stay
start_pivlab();
load_images(jet(testCase.TestData.Root,3));
h = gui.gethand;
set(h.colormap_choice,'Value',3); set(h.stdev_thresh,'String','4');
set(h.ac_interpuls,'String','999');
gui.update_dependent_controls;
gui.put('roirect',[50 50 800 600]);
analyze();
gui.put('pointscali',[10 10; 110 10]);
set(h.realdist,'String','10'); set(h.time_inp,'String','100');
calibrate.apply_cali_Callback([],[],[]);
set(h.fileselector,'Value',2); gui.fileselector_Callback(h.fileselector,[],[]);
gui.sliderdisp(gui.retr('pivlab_axis')); drawnow;
before = gui.collect_settings;
data = session_data();
folder = gui.retr('pathname');
states = enable_visible_states();
box = strjoin(cellstr(get(h.calidisp,'String')), ' ');
gui.preferences_Callback;
h = gui.gethand;
set(h.panelslider,'Value',55); gui.pref_apply_Callback;
testCase.verifyEqual(without_derive_list(gui.collect_settings), without_derive_list(before), 'after Apply (panel width)');
testCase.verifyEqual(session_data(), data, 'data after Apply');
testCase.verifyEqual(gui.retr('pathname'), folder, 'last folder after Apply');
h = gui.gethand;
testCase.verifyEqual(get(h.fileselector,'Value'), 2, 'frame after Apply');
testCase.verifyEqual(strjoin(cellstr(get(h.calidisp,'String')), ' '), box, 'calibration box after Apply');
testCase.verifyEqual(get(h.filenamebox,'String'), gui.retr('filename'));
set(h.matlab_theme,'Value', 1 + double(isequal(gui.retr('darkmode'), 1)));   % the other theme (1 dark, 2 light)
gui.change_theme();
testCase.verifyEqual(without_derive_list(gui.collect_settings), without_derive_list(before), 'after the theme change');
testCase.verifyEqual(session_data(), data, 'data after the theme change');
testCase.verifyEqual(gui.retr('pathname'), folder, 'last folder after the theme change');
h = gui.gethand;
testCase.verifyEqual(get(h.fileselector,'Value'), 2, 'frame after the theme change');
testCase.verifyNotEmpty(findobj(gui.retr('pivlab_axis'),'Type','quiver'), 'vectors shown after the theme change');
shot(fullfile(tempdir, 'pivlab_after_theme_change.png'));
% the PIVlab window can still be used: analysis again
analyze();
rl = gui.retr('resultslist');
testCase.verifyEqual(rl{3,2}, data.resultslist{3,2});
s = enable_visible_states();
f = fieldnames(states);
diff = {};
for k = 1:numel(f)
    % (the status boxes of the acquisition panel are 'inactive' after rebuilding, 'on' after the
    % start: both look and behave the same; the frame slider without images: enabled after the
    % start, disabled after rebuilding)
    if isfield(s, f{k}) && ~strcmp(s.(f{k}), states.(f{k})) && ~startsWith(f{k}, 'multip') ...
            && ~any(strcmp(f{k}, {'ac_msgbox','ac_laserstatus','ac_serialstatus','fileselector'}))
        diff{end+1} = sprintf('%s: %s -> %s', f{k}, states.(f{k}), s.(f{k})); %#ok<AGROW>
    end
end
testCase.verifyEmpty(diff, strjoin(diff, newline));
end

function test_warnings_stay_switched_on(testCase)
% PIVlab must not switch the MATLAB warnings off (start, analysis, display, mask tools)
state = warning;
start_pivlab();
load_images(jet(testCase.TestData.Root,2));
analyze();
validate.apply_filter_all_Callback([],[],[]);
gui.sliderdisp(gui.retr('pivlab_axis')); drawnow;
close_pivlab();
testCase.verifyEqual(warning, state, 'the PIVlab GUI changed the warning state of MATLAB');
end

function test_pivlab_folder_stays_unchanged(testCase)
% a complete GUI workflow (start, analyse, LIC, session, settings, close) writes nothing into
% the PIVlab folder (apart from the LIC MEX file compiled at the first LIC, if it was missing)
root = testCase.TestData.Root;
before = folder_listing(root);
start_pivlab();
load_images(jet(root,2));
analyze();
validate.apply_filter_all_Callback([],[],[]);
h = gui.gethand;
plot.derivs_Callback([],[],[]);
set(h.derivchoice,'Value',2); plot.derivchoice_Callback(h.derivchoice);
plot.apply_deriv_all_Callback([],[],[]);
export.save_session_function(testCase.TestData.Dir, 'folder_test.mat');
mock_file(testCase.TestData.Dir, 'folder_settings.mat');
export.save_settings_Callback([],[],[]);
close_with_menu();
after = folder_listing(root);
new = setdiff(after, before);
new = new(~contains(new, 'fastLICFunction.'));
testCase.verifyEmpty(new, ['new files: ' strjoin(new, ', ')]);
end

%% ------------------------------------------------------------------ helpers
function S = without_derive_list(S)
% the list of derived parameters is filled when the data is shown again after rebuilding the
% controls (like after loading a session); before, it was still empty if the derive panel had
% not been opened. Only the stored text of the selected item differs, not a setting.
if isfield(S, 'popup_texts') && isfield(S.popup_texts, 'derivchoice')
    S.popup_texts = rmfield(S.popup_texts, 'derivchoice');
end
end

function close_with_menu()
% closing like the user (File -> Exit / window close): stores the last folder etc.
hgui = getappdata(0,'hgui');
gui.put('batchModeActive',1);
gui.MainWindow_CloseRequestFcn(hgui, []);
drawnow;
setappdata(0,'hgui',[]);
end

function L = folder_listing(root)
F = dir(fullfile(root, '**', '*'));
F = F(~[F.isdir]);
L = {};
for k = 1:numel(F)
    p = fullfile(F(k).folder, F(k).name);
    if contains(p, [filesep '.git' filesep]) || contains(p, [filesep 'unittests' filesep])
        continue
    end
    L{end+1} = p; %#ok<AGROW>
end
end

function w = default_panelwidth()
w = [];
txt = fileread(which('PIVlab_GUI.m'));
t = regexp(txt, 'panelwidth\s*=\s*(\d+)\s*;', 'tokens', 'once');
if ~isempty(t), w = str2double(t{1}); end
end

function tf = h5_like(file)
fid = fopen(file, 'r');
head = fread(fid, 128, '*char')';
fclose(fid);
tf = contains(head, 'MATLAB 7.3');
end

function out = ifelse(c, a, b)
if c, out = a; else, out = b; end
end

function D = session_data()
keys = gui.session_data_keys;
D = struct();
for k = 1:numel(keys)
    D.(keys{k}) = gui.retr(keys{k});
end
end

function c = cal_values()
c = struct();
for n = {'calu','calv','calxy','offset_x_true','offset_y_true'}
    c.(n{1}) = gui.retr(n{1});
end
end

function analyze()
h = gui.gethand;
set(h.update_display_checkbox,'Value',0);
piv.AnalyzeAll_Callback([],[],[]); drawnow;
end

function load_images(paths, sequencer)
if nargin < 2, sequencer = 1; end
gui.put('sequencer',sequencer); gui.put('multitiff',0); gui.put('video_selection_done',0);
ps = struct('name',paths(:),'isdir',num2cell(false(numel(paths),1)));
import.loadimgsbutton_Callback([],[],0,ps); drawnow;
end

function set_camera_model(viewtype)
sz = gui.retr('expected_image_size');
f = 0.9*sz(2);
K = [f 0 sz(2)/2; 0 f sz(1)/2; 0 0 1];
cp = cameraParameters('K', K, 'RadialDistortion', [-0.25 0.06], 'ImageSize', sz);
h = gui.gethand;
h.calib_viewtype.Value = viewtype;
gui.put('cameraParams', cp);
gui.put('cam_use_calibration', 1);
gui.put('cam_use_rectification', 0);
gui.put('cam_use_tilted_model', false);
end

function mock_file(p, f)
setappdata(0,'parity_mock_file',{p,f});
end

function p = jet(root, n)
p = cell(2*n,1);
for i = 1:n
    p{2*i-1} = fullfile(root,'Example_data',sprintf('Jet_%04dA.jpg',i));
    p{2*i}   = fullfile(root,'Example_data',sprintf('Jet_%04dB.jpg',i));
end
end

function p = distortion(root, n)
p = cell(2*n,1);
for i = 1:n
    p{2*i-1} = fullfile(root,'Example_data','worst_case_distortion',sprintf('PIVlab_%04d_A.jpg',i-1));
    p{2*i}   = fullfile(root,'Example_data','worst_case_distortion',sprintf('PIVlab_%04d_B.jpg',i-1));
end
end

function shot(file)
hgui = getappdata(0,'hgui');
drawnow;
F = getframe(hgui);
imwrite(F.cdata, file);
end

function S = enable_visible_states()
hgui = getappdata(0,'hgui');
h = [findall(hgui, 'Type', 'uicontrol'); findall(hgui, 'Type', 'uipanel')];
S = struct();
for k = 1:numel(h)
    t = h(k).Tag;
    if isempty(t) || ~isvarname(t), continue; end
    e = '';
    if isprop(h(k), 'Enable'), e = char(h(k).Enable); end
    S.(t) = [e '/' char(h(k).Visible)];
end
end

function verify_same_states(testCase, A, B, what)
f = fieldnames(A);
different = {};
for k = 1:numel(f)
    if ~isfield(B, f{k}) || ~strcmp(A.(f{k}), B.(f{k}))
        b = '(missing)';
        if isfield(B, f{k}), b = B.(f{k}); end
        different{end+1} = sprintf('%s: %s -> %s', f{k}, A.(f{k}), b); %#ok<AGROW>
    end
end
testCase.verifyEmpty(different, sprintf('Enable/Visible differ %s:\n%s', what, strjoin(different, newline)));
end

function start_pivlab()
close_pivlab();
PIVlab_GUI(1); drawnow;
gui.put('batchModeActive',1);
hgui = getappdata(0,'hgui');
set(hgui,'Units','pixels','Position',[20 40 1600 1000]); drawnow;
try, gui.MainWindow_ResizeFcn(hgui); catch, end
drawnow;
end

function close_pivlab()
hgui = getappdata(0,'hgui');
if ~isempty(hgui) && ishghandle(hgui)
    try, gui.put('batchModeActive',1); catch, end
    try, delete(hgui); catch, close(hgui,'force'); end
end
setappdata(0,'hgui',[]);
try, close(findall(0,'Type','figure'),'force'); catch, end
end

function prefs = clear_preferences()
% the user's PIVlab preferences (gui.set_preference): saved, then removed, so the tests start
% like a first start of PIVlab. Also saved in a file: if a test run is stopped before its end,
% load(fullfile(tempdir,'PIVlab_preferences_backup.mat')) and restore_preferences(prefs) bring
% them back.
prefs = struct();
if ispref('PIVlab')
    prefs = getpref('PIVlab');
    rmpref('PIVlab');
end
backup = fullfile(tempdir, 'PIVlab_preferences_backup.mat');
if ~isfile(backup)   % a backup of a stopped run is not overwritten with the cleared preferences
    save(backup, 'prefs');
end
end

function restore_preferences(prefs)
if ispref('PIVlab')
    rmpref('PIVlab');
end
names = fieldnames(prefs);
for k = 1:numel(names)
    setpref('PIVlab', names{k}, prefs.(names{k}));
end
backup = fullfile(tempdir, 'PIVlab_preferences_backup.mat');
if isfile(backup)
    delete(backup);
end
end
