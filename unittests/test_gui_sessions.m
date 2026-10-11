function tests = test_gui_sessions
%TEST_GUI_SESSIONS Sessions of the PIVlab window: save and load bring PIVlab back to exactly where it was
%   (settings, data, view, Enable / Visible of the controls, the look of the window), also with
%   multi-page TIFF files, after a recording of the capture panel, and for very large sessions.
%   Run with: results = runtests('unittests/test_gui_sessions.m')
%   Optional real data (skipped if missing): pco.panda double images in
%   D:\PIV Data\micro_PIV_panda_excelitas\micro_piv_boundary_layer1
%   test_large_session needs more than 12 GB free memory (skipped otherwise).
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
helper_setup_once(testCase);
end

function teardownOnce(testCase)
helper_teardown_once(testCase);
end

function setup(~)
helper_close_pivlab();
end

function teardown(~)
helper_close_pivlab();
end

function test_session_with_everything(testCase)
root = testCase.TestData.Root;
files = helper_files('distortion', 3);
helper_start_pivlab();
helper_gui_load_images(files);
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
helper_gui_analyze();
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
states = helper_states();
shot_before = fullfile(testCase.TestData.Dir, 'everything_before.png');
shot(shot_before);
tic; export.save_session_function(testCase.TestData.Dir, 'everything.mat'); t_save = toc;
helper_close_pivlab();

helper_start_pivlab();
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
helper_verify_same_states(testCase, states, helper_states(), 'after loading the session');
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
helper_gui_analyze();
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
J = helper_files('jet', 2);
stack = fullfile(testCase.TestData.Dir, 'session_stack.tif');
for k = 1:4
    if k == 1, mode = 'overwrite'; else, mode = 'append'; end
    imwrite(imread(J{k}), stack, 'WriteMode', mode);
end
helper_start_pivlab();
gui.put('sequencer',0); gui.put('multitiff',1); gui.put('video_selection_done',0);
import.loadimgsbutton_Callback([],[],0,struct('name',{stack},'isdir',false)); drawnow;
testCase.verifyEqual(size(gui.retr('filepath'),1), 6);
helper_gui_analyze();
rl = gui.retr('resultslist');
export.save_session_function(testCase.TestData.Dir, 'multitiff_session.mat');
helper_close_pivlab();
helper_start_pivlab();
import.load_session_Callback(1, fullfile(testCase.TestData.Dir, 'multitiff_session.mat')); drawnow;
testCase.verifyEqual(gui.retr('multitiff'), 1);
testCase.verifyEqual(gui.retr('framenum'), [1;2;2;3;3;4]);
helper_gui_analyze();
rl2 = gui.retr('resultslist');
testCase.verifyEqual(rl2{3,3}, rl{3,3});
end

function test_capture_session(testCase)
% what the capture panel does after a recording: images -> GUI, PIVlab_Capture_Session.mat
root = testCase.TestData.Root;
proj = fullfile(testCase.TestData.Dir, 'capture_project');
mkdir(proj);
J = helper_files('jet', 2);
for i = 1:2
    imwrite(imread(J{2*i-1}), fullfile(proj, sprintf('PIVlab_%04d_A.tif', i-1)));
    imwrite(imread(J{2*i}),   fullfile(proj, sprintf('PIVlab_%04d_B.tif', i-1)));
end
helper_start_pivlab();
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
helper_close_pivlab();
helper_start_pivlab();
import.load_session_Callback(1, fullfile(proj, 'PIVlab_Capture_Session.mat')); drawnow;
h = gui.gethand;
testCase.verifyEqual(gui.retr('filepath'), files);
testCase.verifyEqual(get(h.time_inp,'String'), '1.5');
testCase.verifyEqual(get(h.ac_interpuls,'String'), '1500');
helper_gui_analyze();
testCase.verifyEqual(size(gui.retr('resultslist'),2), 2);
% pco.panda double images recorded by PIVlab
d = 'D:\PIV Data\micro_PIV_panda_excelitas\micro_piv_boundary_layer1';
if isfolder(d)
    set(h.ac_project,'String',d);
    found = acquisition.push_recorded_to_GUI('pco_panda', 2);
    testCase.verifyEqual(found, 1);
    testCase.verifyEqual(gui.retr('pcopanda_dbl_image'), 1);
    export.save_session_function(testCase.TestData.Dir, 'PIVlab_Capture_Session_pco.mat');
    helper_close_pivlab();
    helper_start_pivlab();
    import.load_session_Callback(1, fullfile(testCase.TestData.Dir, 'PIVlab_Capture_Session_pco.mat')); drawnow;
    testCase.verifyEqual(gui.retr('pcopanda_dbl_image'), 1);
    gui.sliderdisp(gui.retr('pivlab_axis')); drawnow;
end
end

function test_large_session(testCase)
% about 1 GB of results: time to save / load and file size (format 7 without compression);
% more than 2 GB: format 7.3
helper_start_pivlab();
helper_gui_load_images(helper_files('jet', 1));
helper_gui_analyze();
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
    helper_close_pivlab();
    helper_start_pivlab();
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
    helper_close_pivlab();
    helper_start_pivlab();
    helper_gui_load_images(helper_files('jet', 1));
    gui.put('resultslist', rl);
end
end

%% ------------------------------------------------------------------ helpers

function D = session_data()
keys = gui.session_data_keys;
D = struct();
for k = 1:numel(keys)
    D.(keys{k}) = gui.retr(keys{k});
end
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

function shot(file)
hgui = getappdata(0,'hgui');
drawnow;
F = getframe(hgui);
imwrite(F.cdata, file);
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
