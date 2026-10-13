function tests = test_apigui_results
%TEST_APIGUI_RESULTS The command-line API (+pivlab) and the PIVlab window give the same results, and
%   sessions go from one to the other (bit-identical numbers). The full comparison over many GUI
%   scenarios is unittests/parity (parity_check).
%   Run with: results = runtests('unittests/test_apigui_results.m')
%   test_optical_flow_gui_equals_api needs the wOFV filter matrices (+wOFV/Filter matrices).
%   Optional real data (skipped if missing): pco.panda double images in
%   D:\PIV Data\micro_PIV_panda_excelitas\micro_piv_boundary_layer1
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
helper_setup_once(testCase);
testCase.TestData.Files = helper_files('jet', 3);
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

%% ------------------------------------------------------------------ the same results

function test_api_results_equal_gui_results(testCase)
files = testCase.TestData.Files;
% GUI
helper_start_pivlab();
helper_gui_load_images(files, 1);
h = gui.gethand;
gui.quick4_Callback([],[]);
set(h.pass1_size,'String','64'); piv.intarea_Callback(h.pass1_size,[],[]);
set(h.pass1_step,'String','32'); piv.step_Callback(h.pass1_step,[],[]);
set(h.pass2_enable,'Value',1); set(h.pass2_size,'String','32'); piv.pass2_checkbox_Callback(h.pass2_enable,[],[]);
set(h.pass3_enable,'Value',1); set(h.pass3_size,'String','16'); piv.pass3_checkbox_Callback(h.pass3_enable,[],[]);
set(h.update_display_checkbox,'Value',0);
gui.quick5_Callback([],[]);
piv.AnalyzeAll_Callback([],[],[]);
set(h.stdev_enable,'Value',1); set(h.stdev_thresh,'String','6');
set(h.loc_median_enable,'Value',1); set(h.loc_med_thresh,'String','2.5'); set(h.interpol_missing,'Value',1);
validate.apply_filter_all_Callback([],[],[]);
rl = gui.retr('resultslist');
helper_close_pivlab();
% API
imgs = pivlab.preprocess(pivlab.readImages(files, "pairwise"));
res = pivlab.analyze(imgs, InterrogationArea=64, Step=32, Passes=3, PassSizes=[32 16 16]);
res = pivlab.filter(res, StdevThreshold=6, LocalMedianThreshold=2.5);
for k = 1:3
    testCase.verifyEqual(res.px.u_raw(:,:,k), rl{3,k}, sprintf('raw u, pair %d', k));
    testCase.verifyEqual(res.px.v_raw(:,:,k), rl{4,k}, sprintf('raw v, pair %d', k));
    testCase.verifyEqual(res.px.u(:,:,k), rl{7,k}, sprintf('filtered u, pair %d', k));
    testCase.verifyEqual(res.typevector(:,:,k), rl{9,k}, sprintf('typevector, pair %d', k));
end
end

function test_optical_flow_gui_equals_api(testCase)
testCase.assumeTrue(isfolder(fullfile(testCase.TestData.Root,'+wOFV','Filter matrices')), 'wOFV filter matrices not downloaded');
J = helper_files('jet', 2);
roi = [300 300 256 256];
helper_start_pivlab();
helper_gui_load_images(J);
h = gui.gethand;
gui.put('roirect', roi);
gui.quick4_Callback([],[]);
set(h.algorithm_selection,'Value',4); piv.algorithm_selection_Callback(h.algorithm_selection,[],[]);
testCase.verifyEqual(get(h.autolimit_enable,'Value'), 1);
helper_gui_analyze();
rl = gui.retr('resultslist');
helper_close_pivlab();
imgs = pivlab.preprocess(pivlab.readImages(J, "pairwise"), Roi=roi, Verbose=false);
res = pivlab.analyze(imgs, Algorithm="ofv", Verbose=false);
for k = 1:2
    testCase.verifyEqual(res.px.u_raw(:,:,k), rl{3,k}, sprintf('optical flow u, pair %d: API vs GUI', k));
    testCase.verifyEqual(res.px.v_raw(:,:,k), rl{4,k}, sprintf('optical flow v, pair %d: API vs GUI', k));
end
end

function test_tilted_camera_model_in_every_analysis(testCase)
% the tilted camera model (Scheimpflug) is used by every path: GUI parallel analysis, background
% images, ensemble, image size after switching the calibration on. (Serial and parallel results differ
% in the last digits anyway - worker processes calculate with one thread - so parallel is compared
% with parallel.)
files = helper_files('distortion', 2);
raw = pivlab.readImages(files, "pairwise");
cp = helper_camera_model(raw.imageSize);
sz = raw.imageSize;
f = 0.9*sz(2);
cameraParams = cp;
cam_selected_target_images = {'target.jpg'};
cam_use_tilted_model = true;
cam_tilted_D = [-0.25 0.06 0 0 0 0 0 0 0 0 0 0 0.03 0.02];   % k1 k2 ... tauX tauY
cam_K_opencv = [f 0 sz(2)/2; 0 f sz(1)/2; 0 0 1];
file = fullfile(testCase.TestData.Dir, 'tilted_calibration.mat');
save(file, "cameraParams", "cam_selected_target_images", "cam_use_tilted_model", "cam_tilted_D", "cam_K_opencv");
% API
imgs = pivlab.preprocess(raw, Camera=file, Verbose=false);
testCase.verifyTrue(imgs.cam.use_tilted_model);
plain = pivlab.preprocess(raw, Camera=cp, Verbose=false);
testCase.verifyNotEqual(pivlab.getImage(imgs, 1), pivlab.getImage(plain, 1));   % the tilt is applied
res = pivlab.analyze(imgs, Passes=2, PassSizes=[32 32 32], Parallel=true, Verbose=false);
ens = pivlab.analyze(imgs, Algorithm="ensemble", Passes=2, PassSizes=[32 32 32], Verbose=false);
bg = pivlab.preprocess(imgs, Camera=file, Background="mean", Verbose=false);   % (Camera has to be given again)
% GUI with parallel processing
helper_start_pivlab(2);
helper_gui_load_images(files, 1);
h = gui.gethand;
gui.put('cameraParams', cameraParams);
gui.put('cam_selected_target_images', cam_selected_target_images);
gui.put('cam_use_tilted_model', cam_use_tilted_model);
gui.put('cam_tilted_D', cam_tilted_D);
gui.put('cam_K_opencv', cam_K_opencv);
h.calib_viewtype.Value = 1;
h.calib_usecalibration.Value = 1;
preproc.cam_enable_cam_calib_Callback('calib_viewtype', [], []); drawnow;
testCase.verifyEqual(gui.retr('expected_image_size'), imgs.imageSize, 'image size after switching on');
for algorithm = 1:2   % 1 = FFT window deformation (parallel loop), 2 = ensemble
    gui.quick4_Callback([],[]);
    set(h.algorithm_selection,'Value',algorithm); piv.algorithm_selection_Callback(h.algorithm_selection,[],[]);
    set(h.pass1_size,'String','64'); piv.intarea_Callback(h.pass1_size,[],[]);
    set(h.pass1_step,'String','32'); piv.step_Callback(h.pass1_step,[],[]);
    set(h.pass2_enable,'Value',1); set(h.pass2_size,'String','32'); piv.pass2_checkbox_Callback(h.pass2_enable,[],[]);
    set(h.pass3_enable,'Value',0); piv.pass3_checkbox_Callback(h.pass3_enable,[],[]);
    set(h.update_display_checkbox,'Value',0);
    gui.quick5_Callback([],[]);
    piv.AnalyzeAll_Callback([],[],[]); drawnow;
    rl = gui.retr('resultslist');
    if algorithm == 1
        for k = 1:2
            testCase.verifyEqual(rl{3,k}, res.px.u_raw(:,:,k), sprintf('parallel GUI raw u, pair %d', k));
            testCase.verifyEqual(rl{4,k}, res.px.v_raw(:,:,k), sprintf('parallel GUI raw v, pair %d', k));
        end
    else
        testCase.verifyEqual(rl{3,1}, ens.px.u_raw, 'ensemble u');
        testCase.verifyEqual(rl{4,1}, ens.px.v_raw, 'ensemble v');
    end
end
gui.quick3_Callback([],[]);
set(h.bg_subtract,'Value',2);
preproc.generate_BG_img(); drawnow;
testCase.verifyEqual(gui.retr('bg_img_A'), bg.background.A, 'background A');
testCase.verifyEqual(gui.retr('bg_img_B'), bg.background.B, 'background B');
helper_close_pivlab();
end

%% ------------------------------------------------------------------ sessions from one to the other

function test_camera_session_roundtrip_and_gui(testCase)
% undistortion + rectification: saved in a session, loaded by the API and by the GUI
files = helper_files('distortion', 2);
raw = pivlab.readImages(files, "pairwise");
a = 3*pi/180;
rect = affine2d([cos(a) sin(a) 0; -sin(a) cos(a) 0; 0 0 1]);
imgs = pivlab.preprocess(raw, Camera=helper_camera_model(raw.imageSize), CameraView="same", Rectification=rect, Verbose=false);
res = pivlab.analyze(imgs, Verbose=false);
f = fullfile(testCase.TestData.Dir, 'camera_session.mat');
pivlab.saveSession(res, f, Verbose=false);
% API: loadSession and the session as Camera source give the same camera calibration
r = pivlab.loadSession(f);
helper_verify_same_camera(testCase, r.images.cam, imgs.cam);
p = pivlab.preprocess(raw, Camera=f, Verbose=false);
helper_verify_same_camera(testCase, p.cam, imgs.cam);
testCase.verifyEqual(p.imageSize, imgs.imageSize);
p = pivlab.preprocess(raw, Camera=f, Rectification=false, Verbose=false);
testCase.verifyEqual(p.cam.use_rectification, 0);
testCase.verifyEqual(p.cam.view, 'same');
% GUI: undistortion and rectification are switched on, and the analysis gives the same result
helper_start_pivlab();
import.load_session_Callback(1, f); drawnow;
h = gui.gethand;
testCase.verifyEqual(gui.retr('cam_use_calibration'), 1);
testCase.verifyEqual(gui.retr('cam_use_rectification'), 1);
testCase.verifyEqual(h.calib_viewtype.Value, 2);
helper_verify_same_camera(testCase, import.cam_settings(FromGUI=true), imgs.cam);
set(h.update_display_checkbox,'Value',0);
piv.AnalyzeAll_Callback([],[],[]);
rl = gui.retr('resultslist');
for k = 1:2
    testCase.verifyEqual(rl{3,k}, res.px.u_raw(:,:,k), sprintf('raw u, pair %d', k));
    testCase.verifyEqual(rl{4,k}, res.px.v_raw(:,:,k), sprintf('raw v, pair %d', k));
end
helper_close_pivlab();
end

function test_api_session_with_everything_in_gui(testCase)
% the API session with ROI, masks per pair, background, camera undistortion, calibration with origin
% and flipped axes, velocity limits and smoothing opens in the GUI: everything shown and used
% (the session itself: test_api_settings_sessions/test_session_with_everything)
[res, ~, f, roi] = helper_api_session_everything(testCase.TestData.Dir);
helper_start_pivlab();
import.load_session_Callback(1, f); drawnow;
testCase.verifyEqual(gui.retr('roirect'), roi);
testCase.verifyEqual(gui.retr('calu'), res.calibration.calu);
h = gui.gethand;
testCase.verifyEqual(h.x_axis_direction.Value, 2);
testCase.verifyEqual(h.y_axis_direction.Value, 2);
testCase.verifyEqual(gui.retr('cam_use_calibration'), 1);
testCase.verifyNotEmpty(gui.retr('bg_img_A'));
masks = gui.retr('masks_in_frame');
testCase.verifyNotEmpty(masks{1});
testCase.verifyNotEmpty(masks{3});
rl = gui.retr('resultslist');
testCase.verifyEqual(size(rl,2), 3);
testCase.verifyEqual(rl{7,2}, res.px.u(:,:,2));
testCase.verifyEqual(rl{10,2}, res.px.u_smoothed(:,:,2));
testCase.verifyEqual(get(h.highpass_enable,'Value'), 1);
% display, re-analysis and validation in the GUI
set(h.fileselector,'Value',2); gui.fileselector_Callback(h.fileselector,[],[]);
gui.sliderdisp(gui.retr('pivlab_axis')); drawnow;
helper_gui_analyze();
rl = gui.retr('resultslist');
for k = 1:3
    testCase.verifyEqual(rl{3,k}, res.px.u_raw(:,:,k), sprintf('GUI re-analysis pair %d', k));
end
validate.apply_filter_all_Callback([],[],[]);
rl = gui.retr('resultslist');
testCase.verifyEqual(rl{9,1}, res.typevector(:,:,1));
end

function test_pco_double_images_gui_and_api(testCase)
% pco.panda double images (A and B in one file): a GUI session in the API, an API session in the GUI
d = 'D:\PIV Data\micro_PIV_panda_excelitas\micro_piv_boundary_layer1';
testCase.assumeTrue(isfolder(d), 'pco.panda test images not available');
files = {fullfile(d,'PIVlab_pco_000001.tif'); fullfile(d,'PIVlab_pco_000002.tif')};
roi = [1000 1000 1024 768];
% GUI -> session -> GUI and API
helper_start_pivlab();
helper_gui_load_images(files);
testCase.verifyEqual(gui.retr('pcopanda_dbl_image'), 1);
sz = gui.retr('expected_image_size');
gui.put('roirect', roi);
helper_gui_analyze();
rl = gui.retr('resultslist');
testCase.verifyEqual(size(rl,2), 2);
export.save_session_function(testCase.TestData.Dir, 'pco_gui_session.mat');
helper_start_pivlab();
import.load_session_Callback(1, fullfile(testCase.TestData.Dir, 'pco_gui_session.mat')); drawnow;
testCase.verifyEqual(gui.retr('pcopanda_dbl_image'), 1);
testCase.verifyEqual(gui.retr('expected_image_size'), sz);
helper_gui_analyze();
rl2 = gui.retr('resultslist');
testCase.verifyEqual(rl2{3,2}, rl{3,2});
helper_close_pivlab();
r = pivlab.loadSession(fullfile(testCase.TestData.Dir, 'pco_gui_session.mat'));
testCase.verifyTrue(r.images.pcopanda_dbl_image);
testCase.verifyEqual(r.px.u_raw(:,:,2), rl{3,2});
img = pivlab.getImage(r.images, 1, Frame="B", Preprocessed=false);
testCase.verifyEqual(size(img), sz);
% API -> session -> GUI
imgs = pivlab.preprocess(pivlab.readImages(files, "pairwise"), Roi=roi, Verbose=false);
res = pivlab.filter(pivlab.analyze(imgs, Verbose=false), Verbose=false);
testCase.verifyEqual(res.px.u_raw(:,:,2), rl{3,2}, 'API and GUI analysis');
f = fullfile(testCase.TestData.Dir, 'pco_api_session.mat');
pivlab.saveSession(res, f, Verbose=false);
helper_start_pivlab();
import.load_session_Callback(1, f); drawnow;
testCase.verifyEqual(gui.retr('pcopanda_dbl_image'), 1);
helper_gui_analyze();
rl3 = gui.retr('resultslist');
testCase.verifyEqual(rl3{3,2}, res.px.u_raw(:,:,2));
end
