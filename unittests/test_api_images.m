function tests = test_api_images
%TEST_API_IMAGES Command-line API: pivlab.readImages, pivlab.preprocess and pivlab.getImage with every option.
%   Each option is checked for: it runs, it has the documented effect, wrong values give a clear
%   error. No PIVlab window is opened.
%   Run with: results = runtests('unittests/test_api_images.m')
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
end

%% ================================================================== readImages

function test_readImages_sources(testCase)
root = testCase.TestData.Root;
files = testCase.TestData.Files;
% pattern (char and string)
a = pivlab.readImages(fullfile(root,'Example_data','Jet_0001*.jpg'), "pairwise");
testCase.verifyEqual(a.pairs, 1);
testCase.verifyEqual(pivlab.readImages(fullfile(root,'Example_data','Jet_000?A.jpg'), "pairwise").pairs, 4);   % 9 images
b = pivlab.readImages(string(fullfile(root,'Example_data','Jet_0001*.jpg')), "pairwise");
testCase.verifyEqual(b.filepath, a.filepath);
% a folder: all images in it, sorted by name
d = fullfile(testCase.TestData.Dir, 'folder_source');
mkdir(d);
for k = 4:-1:1
    copyfile(files{k}, d);
end
copyfile(fullfile(root,'README.md'), d);   % no image: ignored
c = pivlab.readImages(d, "pairwise");
testCase.verifyEqual(c.pairs, 2);
[~, n1] = fileparts(c.filepath{1});
testCase.verifyEqual(n1, 'Jet_0001A');
% a list of files: string array and cell array, used in the given order
e = pivlab.readImages(string(files(1:4)), "pairwise");
testCase.verifyEqual(e.filepath, files(1:4));
order = files([3 4 1 2]);
f = pivlab.readImages(order, "pairwise");
testCase.verifyEqual(f.filepath, order);
% several patterns
g = pivlab.readImages({fullfile(root,'Example_data','Jet_0001*.jpg'), fullfile(root,'Example_data','Jet_0003*.jpg')}, "pairwise");
testCase.verifyEqual(g.pairs, 2);
testCase.verifyEqual(g.filepath{3}, files{5});
% imgs contents
testCase.verifyEqual(a.imageSize, size(imread(files{1}), [1 2]));
testCase.verifyEqual(a.sequencing, "pairwise");
testCase.verifyFalse(a.multitiff);
testCase.verifyEmpty(a.preprocess);
% wrong input
testCase.verifyEqual(helper_error_id('pivlab.readImages', fullfile(root,'Example_data','nothing_*.jpg'), "pairwise"), 'pivlab:readImages:noImages');
testCase.verifyEqual(helper_error_id('pivlab.readImages', files(1), "pairwise"), 'pivlab:readImages:tooFewImages');
testCase.verifyNotEmpty(helper_error_id('pivlab.readImages', files, "sideways"));
end

function test_readImages_sequencing(testCase)
files = testCase.TestData.Files;   % 6 images
P = {"pairwise", 3, files([1 2 3 4]); "timeresolved", 5, files([1 2 2 3]); "reference", 5, files([1 2 1 3])};
for k = 1:size(P,1)
    imgs = pivlab.readImages(files, P{k,1});
    testCase.verifyEqual(imgs.sequencing, P{k,1});
    testCase.verifyEqual(imgs.pairs, P{k,2}, char(P{k,1}));
    testCase.verifyEqual(imgs.filepath(1:4), P{k,3}, char(P{k,1}));
    % the B image of pair 2 is the expected file
    B = pivlab.getImage(imgs, 2, Frame="B", Preprocessed=false);
    testCase.verifyEqual(B, imread(P{k,3}{4}), char(P{k,1}));
end
end

function test_readImages_multitiff(testCase)
files = testCase.TestData.Files;
stack1 = fullfile(testCase.TestData.Dir, 'stack1.tif');
stack2 = fullfile(testCase.TestData.Dir, 'stack2.tif');
for k = 1:4
    if k == 1, mode = 'overwrite'; else, mode = 'append'; end
    imwrite(imread(files{k}), stack1, 'WriteMode', mode);
end
imwrite(imread(files{5}), stack2, 'WriteMode', 'overwrite');
imwrite(imread(files{6}), stack2, 'WriteMode', 'append');
% detected automatically, time resolved within one file
imgs = pivlab.readImages(stack1, "timeresolved");
testCase.verifyTrue(imgs.multitiff);
testCase.verifyEqual(imgs.pairs, 3);
testCase.verifyEqual(pivlab.getImage(imgs, 3, Frame="B", Preprocessed=false), imread(files{4}));
% pairwise over two files
imgs = pivlab.readImages({stack1, stack2}, "pairwise");
testCase.verifyEqual(imgs.pairs, 3);
testCase.verifyEqual(pivlab.getImage(imgs, 3, Frame="A", Preprocessed=false), imread(files{5}));
testCase.verifyEqual(pivlab.getImage(imgs, 2, Frame="B", Preprocessed=false), imread(files{4}));
% MultiTiff=false: only the first page of every file
imgs = pivlab.readImages({stack1, stack2}, "pairwise", MultiTiff=false);
testCase.verifyFalse(imgs.multitiff);
testCase.verifyEqual(imgs.pairs, 1);
testCase.verifyEqual(pivlab.getImage(imgs, 1, Frame="B", Preprocessed=false), imread(files{5}));
% and the analysis runs on a multi-page TIFF
res = pivlab.analyze(pivlab.readImages(stack1, "timeresolved"), Pairs=1, Verbose=false);
ref = pivlab.analyze(pivlab.readImages(files(1:2), "pairwise"), Verbose=false);
testCase.verifyEqual(res.px.u_raw, ref.px.u_raw);
end

function test_readImages_pco_double_images(testCase)
d = 'D:\PIV Data\micro_PIV_panda_excelitas\micro_piv_boundary_layer1';
testCase.assumeTrue(isfolder(d), 'pco.panda test images not available');
files = {fullfile(d,'PIVlab_pco_000001.tif'); fullfile(d,'PIVlab_pco_000002.tif')};
imgs = pivlab.readImages(files, "pairwise");
testCase.verifyTrue(imgs.pcopanda_dbl_image);
testCase.verifyEqual(imgs.pairs, 2);
full = imread(files{1});
h = size(full,1)/2;
testCase.verifyEqual(imgs.imageSize, [h size(full,2)]);
A = pivlab.getImage(imgs, 1, Frame="A", Preprocessed=false);
B = pivlab.getImage(imgs, 1, Frame="B", Preprocessed=false);
testCase.verifyEqual(A, full(1:h,:));
testCase.verifyEqual(B, full(h+1:end,:));
% time-resolved sequencing is not possible: warning, pairwise is used
lastwarn('');
w = pivlab.readImages(files, "timeresolved");
[~, id] = lastwarn;
testCase.verifyEqual(id, 'pivlab:readImages:pcoDoubleImage');
testCase.verifyEqual(w.sequencing, "pairwise");
% analysis of a part of the image, session (the same session in the GUI:
% test_apigui_results/test_pco_double_images_gui_and_api)
imgs = pivlab.preprocess(imgs, Roi=[1000 1000 1024 768], Verbose=false);
res = pivlab.filter(pivlab.analyze(imgs, Verbose=false), Verbose=false);
testCase.verifyGreaterThan(nnz(isfinite(res.u)), 0.9*numel(res.u));
f = fullfile(testCase.TestData.Dir, 'pco_session.mat');
pivlab.saveSession(res, f, Verbose=false);
r = pivlab.loadSession(f);
testCase.verifyTrue(r.images.pcopanda_dbl_image);
testCase.verifyEqual(r.px.u, res.px.u);
end

%% ================================================================== preprocess / getImage

function test_preprocess_filter_options(testCase)
raw = pivlab.readImages(testCase.TestData.Files(1:2), "pairwise");
base = pivlab.getImage(pivlab.preprocess(raw, Verbose=false), 1);
testCase.verifyClass(base, 'uint8');
testCase.verifyEqual(size(base), raw.imageSize);
% every option alone changes the pre-processed image
O = {'CLAHE', false; 'CLAHESize', 20; 'Highpass', true; 'IntensityCapping', true; 'Wiener', true; ...
     'AutoLimit', false; 'MinIntensity', 0.1; 'MaxIntensity', 0.5};
for k = 1:size(O,1)
    args = O(k,:);
    if any(strcmp(args{1}, {'MinIntensity','MaxIntensity'}))
        args = [args {'AutoLimit', false}]; %#ok<AGROW>
    end
    p = pivlab.preprocess(raw, args{:}, Verbose=false);
    testCase.verifyEqual(p.preprocess.(O{k,1}), O{k,2}, O{k,1});
    testCase.verifyNotEqual(pivlab.getImage(p, 1), base, O{k,1});
end
% the size options change the result of their filter
S = {'Highpass', 'HighpassSize', 15, 40; 'Wiener', 'WienerSize', 3, 9; 'CLAHE', 'CLAHESize', 64, 16};
for k = 1:size(S,1)
    a = pivlab.getImage(pivlab.preprocess(raw, S{k,1}, true, S{k,2}, S{k,3}, Verbose=false), 1);
    b = pivlab.getImage(pivlab.preprocess(raw, S{k,1}, true, S{k,2}, S{k,4}, Verbose=false), 1);
    testCase.verifyNotEqual(a, b, S{k,2});
end
% Settings: the same as name=value; name=value wins over Settings
s = pivlab.defaults();
s.preprocess.Highpass = true;
s.preprocess.HighpassSize = 25;
a = pivlab.getImage(pivlab.preprocess(raw, Settings=s, Verbose=false), 1);
b = pivlab.getImage(pivlab.preprocess(raw, Highpass=true, HighpassSize=25, Verbose=false), 1);
testCase.verifyEqual(a, b);
c = pivlab.getImage(pivlab.preprocess(raw, Settings=s, Highpass=false, Verbose=false), 1);
testCase.verifyEqual(c, base);
% a settings struct with only some fields is completed with the defaults
part = struct('preprocess', struct('Highpass', true));
d = pivlab.getImage(pivlab.preprocess(raw, Settings=part, Verbose=false), 1);
testCase.verifyEqual(d, pivlab.getImage(pivlab.preprocess(raw, Highpass=true, Verbose=false), 1));
% unknown option names in Settings
bad = struct('preprocess', struct('Hihgpass', true));
out = helper_warning_message('pivlab:settings:unknownField', 'pivlab.preprocess', raw, 'Settings', bad, 'Verbose', false);
testCase.verifySubstring(out, 'Hihgpass', 'misspelled field in Settings');
% the pre-processing is used by the analysis
r1 = pivlab.analyze(pivlab.preprocess(raw, Verbose=false), Verbose=false);
r2 = pivlab.analyze(pivlab.preprocess(raw, Highpass=true, Verbose=false), Verbose=false);
testCase.verifyNotEqual(r1.px.u_raw, r2.px.u_raw);
% without pivlab.preprocess, pivlab.analyze uses the default pre-processing
r3 = pivlab.analyze(raw, Verbose=false);
testCase.verifyEqual(r3.px.u_raw, r1.px.u_raw);
end

function test_preprocess_background(testCase)
files = testCase.TestData.Files;
raw = pivlab.readImages(files, "pairwise");
none = pivlab.preprocess(raw, Background="none", Verbose=false);
testCase.verifyEmpty(none.background);
mn = pivlab.preprocess(raw, Background="mean", Verbose=false);
mi = pivlab.preprocess(raw, Background="min", Verbose=false);
testCase.verifyEqual(mn.background.mode, "mean");
testCase.verifyEqual(size(mn.background.A), raw.imageSize);
% the minimum image is darker than the mean image, and the minimum of the A images is right
testCase.verifyTrue(all(mi.background.A(:) <= mn.background.A(:) + 1));
stack = zeros([raw.imageSize 3], 'uint8');
for k = 1:3
    stack(:,:,k) = imread(files{2*k-1});
end
helper_verify_near(testCase, double(mi.background.A), double(min(stack,[],3)), 'AbsTol', 1);
% background subtracted in the image that is analysed, not in the raw image
testCase.verifyNotEqual(pivlab.getImage(mn, 1), pivlab.getImage(none, 1));
testCase.verifyEqual(pivlab.getImage(mn, 1, Preprocessed=false), pivlab.getImage(none, 1, Preprocessed=false));
% time resolved works, reference does not
tr = pivlab.preprocess(pivlab.readImages(files, "timeresolved"), Background="min", Verbose=false);
testCase.verifyEqual(size(tr.background.B), raw.imageSize);
testCase.verifyEqual(helper_error_id('pivlab.preprocess', pivlab.readImages(files, "reference"), 'Background', "mean"), 'pivlab:preprocess:background');
testCase.verifyEqual(helper_error_id('pivlab.preprocess', raw, 'Background', "median"), 'pivlab:preprocess:background');
% case does not matter
testCase.verifyEqual(pivlab.preprocess(raw, Background="MEAN", Verbose=false).background.A, mn.background.A);
end

function test_preprocess_roi_and_mask(testCase)
raw = pivlab.readImages(testCase.TestData.Files(1:4), "pairwise");
sz = raw.imageSize;
% region of interest: all vectors inside it
roi = [101 81 600 400];
res = pivlab.analyze(pivlab.preprocess(raw, Roi=roi, Verbose=false), Verbose=false);
testCase.verifyGreaterThanOrEqual(min(res.px.x(:)), roi(1));
testCase.verifyLessThanOrEqual(max(res.px.x(:)), roi(1)+roi(3));
testCase.verifyGreaterThanOrEqual(min(res.px.y(:)), roi(2));
testCase.verifyLessThanOrEqual(max(res.px.y(:)), roi(2)+roi(4));
% a non-integer ROI is rounded, a ROI outside the image is an error
p = pivlab.preprocess(raw, Roi=[100.4 80.6 600 400], Verbose=false);
testCase.verifyEqual(p.preprocess.Roi, [100 81 600 400]);
testCase.verifyEqual(helper_error_id('pivlab.preprocess', raw, 'Roi', [0 1 100 100]), 'pivlab:preprocess:roi');
testCase.verifyEqual(helper_error_id('pivlab.preprocess', raw, 'Roi', [1 1 sz(2) 100]), 'pivlab:preprocess:roi');
testCase.verifyEqual(helper_error_id('pivlab.preprocess', raw, 'Roi', [1 1 100]), 'pivlab:preprocess:roi');
% mask as a logical image: vectors in the mask are masked (typevector 0) in every pair
m = false(sz); m(200:400, 300:600) = true;
res = pivlab.analyze(pivlab.preprocess(raw, Mask=m, Verbose=false), Verbose=false);
inside = m(sub2ind(sz, round(res.px.y), round(res.px.x)));
for k = 1:2
    tv = res.typevector_raw(:,:,k);
    testCase.verifyTrue(all(tv(inside) == 0));
    testCase.verifyTrue(all(tv(~inside) == 1));
end
% a numeric 0/1 image is accepted as well
resn = pivlab.analyze(pivlab.preprocess(raw, Mask=double(m), Verbose=false), Verbose=false);
testCase.verifyEqual(resn.typevector_raw, res.typevector_raw);
% one mask per pair (cell array of logical images)
m2 = false(sz); m2(500:700, 100:300) = true;
resc = pivlab.analyze(pivlab.preprocess(raw, Mask={m, m2}, Verbose=false), Verbose=false);
testCase.verifyEqual(resc.typevector_raw(:,:,1), res.typevector_raw(:,:,1));
testCase.verifyNotEqual(resc.typevector_raw(:,:,2), res.typevector_raw(:,:,1));
% PIVlab mask objects (as in masks_in_frame of the GUI): the same as the equivalent logical image
obj = {{'ROI_object_rectangle', [300 200 300 200]}, {}};
reso = pivlab.analyze(pivlab.preprocess(raw, Mask=obj, Verbose=false), Verbose=false);
mo = mask.convert_masks_to_binary(sz, obj{1});
resl = pivlab.analyze(pivlab.preprocess(raw, Mask={logical(mo), false(sz)}, Verbose=false), Verbose=false);
testCase.verifyEqual(reso.typevector_raw, resl.typevector_raw);
testCase.verifyTrue(all(reso.typevector_raw(:,:,2) == 1, 'all'));
% the ensemble and the optical flow use the mask too
rese = pivlab.analyze(pivlab.preprocess(raw, Mask=m, Verbose=false), Algorithm="ensemble", Verbose=false);
testCase.verifyTrue(all(rese.typevector_raw(m(sub2ind(sz, round(rese.px.y), round(rese.px.x)))) == 0));
% wrong masks
testCase.verifyEqual(helper_error_id('pivlab.preprocess', raw, 'Mask', true(10)), 'pivlab:preprocess:mask');
testCase.verifyEqual(helper_error_id('pivlab.preprocess', raw, 'Mask', "everything"), 'pivlab:preprocess:mask');
% "none" (and "None") removes ROI and mask
p = pivlab.preprocess(raw, Roi=roi, Mask=m, Verbose=false);
q = pivlab.preprocess(p, Roi="None", Mask="none", Verbose=false);
testCase.verifyEmpty(q.preprocess.Roi);
testCase.verifyEmpty(q.mask);
end

function test_preprocess_camera_options(testCase)
files = helper_files('distortion', 2);
raw = pivlab.readImages(files, "pairwise");
sz = raw.imageSize;
cp = helper_camera_model(sz);
% cameraIntrinsics instead of cameraParameters: the same correction
p1 = pivlab.preprocess(raw, Camera=cp, CameraView="same", Verbose=false);
p2 = pivlab.preprocess(raw, Camera=cp.Intrinsics, CameraView="same", Verbose=false);
testCase.verifyEqual(pivlab.getImage(p2, 1), pivlab.getImage(p1, 1));
% the three views
v = pivlab.preprocess(raw, Camera=cp, CameraView="valid", Verbose=false);
f = pivlab.preprocess(raw, Camera=cp, CameraView="full", Verbose=false);
testCase.verifyEqual(p1.imageSize, sz);
testCase.verifyNotEqual(v.imageSize, sz);
testCase.verifyTrue(all(v.imageSize < f.imageSize));   % "valid" cuts the black borders of "full" away
testCase.verifyTrue(all(f.imageSize > sz));
% undistortion changes the image, Preprocessed=false shows the undistorted raw image
rawimg = imread(files{1});
if size(rawimg,3) > 1, rawimg = rgb2gray(rawimg); end
testCase.verifyNotEqual(pivlab.getImage(p1, 1, Preprocessed=false), rawimg);
% rectification with a transformation
a = 5*pi/180;
rect = affine2d([cos(a) sin(a) 0; -sin(a) cos(a) 0; 0 0 1]);
r = pivlab.preprocess(raw, Camera=cp, CameraView="same", Rectification=rect, Verbose=false);
testCase.verifyEqual(r.cam.use_rectification, 1);
testCase.verifyNotEqual(pivlab.getImage(r, 1), pivlab.getImage(p1, 1));
% Rectification=false switches it off again
n = pivlab.preprocess(r, Camera=r.cam.cameraParams, CameraView="same", Rectification=false, Verbose=false);
testCase.verifyEqual(n.cam.use_rectification, 0);
testCase.verifyEqual(pivlab.getImage(n, 1), pivlab.getImage(p1, 1));
% without the Camera option: no camera calibration (default), also for corrected images
d = pivlab.preprocess(r, Verbose=false);
testCase.verifyEqual(d.cam.use_calibration, 0);
testCase.verifyEqual(d.imageSize, sz);
testCase.verifyEqual(pivlab.getImage(d, 1, Preprocessed=false), pivlab.getImage(raw, 1, Preprocessed=false));
% ROI and mask refer to the corrected image, the analysis runs on it
res = pivlab.analyze(pivlab.preprocess(r, Roi=[100 100 500 400], Verbose=false), Verbose=false);
testCase.verifyLessThanOrEqual(max(res.px.x(:)), 600);
testCase.verifyGreaterThan(nnz(isfinite(res.px.u_raw)), 0.9*numel(res.px.u_raw));
% Verbose=true reports the camera correction, Verbose=false is silent
out = evalc('pivlab.preprocess(raw, Camera=cp, Verbose=true);');
testCase.verifySubstring(out, 'lens undistortion');
out = evalc('pivlab.preprocess(raw, Camera=cp, Verbose=false);');
testCase.verifyEmpty(strtrim(out));
end

function test_preprocess_camera_sources(testCase)
% cameraParameters object, calibration file of the GUI, session; switching it off; wrong use
imgs = pivlab.readImages(helper_files('distortion', 2), "pairwise");
raw_size = imgs.imageSize;
cp = helper_camera_model(raw_size);
% cameraParameters object, view "valid" (default): black borders cut away, so smaller than "full"
p = pivlab.preprocess(imgs, Camera=cp, Verbose=false);
testCase.verifyEqual(p.cam.view, 'valid');
testCase.verifyEqual(p.cam.use_calibration, 1);
testCase.verifyNotEqual(p.imageSize, raw_size);
testCase.verifyEqual(size(pivlab.getImage(p, 1)), p.imageSize);
% (the other views: test_preprocess_camera_options)
p = pivlab.preprocess(imgs, Camera=cp, CameraView="same", Verbose=false);
testCase.verifyEqual(p.imageSize, raw_size);
% camera calibration file saved in the GUI ("Save camera parameters")
cameraParams = cp;
cam_selected_target_images = {};
cam_use_tilted_model = false;
cam_tilted_D = [];
cam_K_opencv = [];
f = fullfile(testCase.TestData.Dir, 'camera_calibration.mat');
save(f, "cameraParams", "cam_selected_target_images", "cam_use_tilted_model", "cam_tilted_D", "cam_K_opencv");
q = pivlab.preprocess(imgs, Camera=f, CameraView="same", Verbose=false);
helper_verify_same_camera(testCase, q.cam, p.cam);
testCase.verifyEqual(pivlab.getImage(q, 1), pivlab.getImage(p, 1));
% "none" switches the undistortion off again
n = pivlab.preprocess(q, Camera="none", Verbose=false);
testCase.verifyEqual(n.cam.use_calibration, 0);
testCase.verifyEqual(n.imageSize, raw_size);
% wrong use
testCase.verifyEqual(helper_error_id('pivlab.preprocess', imgs, 'CameraView', "same", 'Verbose', false), 'pivlab:preprocess:camera');
testCase.verifyEqual(helper_error_id('pivlab.preprocess', imgs, 'Camera', cp, 'CameraView', "big", 'Verbose', false), 'pivlab:preprocess:cameraView');
testCase.verifyEqual(helper_error_id('pivlab.preprocess', imgs, 'Camera', cp, 'Rectification', true, 'Verbose', false), 'pivlab:preprocess:rectification');
testCase.verifyEqual(helper_error_id('pivlab.preprocess', imgs, 'Camera', testCase.TestData.Files{1}, 'Verbose', false), 'pivlab:preprocess:cameraFile');
% a session without camera calibration
jet = pivlab.preprocess(pivlab.readImages(testCase.TestData.Files(1:2), "pairwise"), Verbose=false);
s = fullfile(testCase.TestData.Dir, 'no_camera.mat');
pivlab.saveSession(pivlab.analyze(jet, Verbose=false), s, Verbose=false);
testCase.verifyEqual(helper_error_id('pivlab.preprocess', imgs, 'Camera', s, 'Verbose', false), 'pivlab:preprocess:noCameraCalibration');
r = pivlab.loadSession(s);
testCase.verifyEqual(r.images.cam.use_calibration, 0);
end

function test_getImage(testCase)
files = testCase.TestData.Files;
imgs = pivlab.preprocess(pivlab.readImages(files, "pairwise"), Verbose=false);
A = pivlab.getImage(imgs, 2);
B = pivlab.getImage(imgs, 2, Frame="B");
testCase.verifyNotEqual(A, B);
testCase.verifyEqual(pivlab.getImage(imgs, 2, Frame="A"), A);
testCase.verifyEqual(pivlab.getImage(imgs, 2, Frame="B", Preprocessed=false), imread(files{4}));
% without pivlab.preprocess: background / filters are not applied
raw = pivlab.readImages(files, "pairwise");
testCase.verifyEqual(pivlab.getImage(raw, 1), imread(files{1}));
% colour images are converted to grey values
col = pivlab.readImages(helper_files('fuerteventura', 4), "timeresolved");
g = pivlab.getImage(col, 1, Preprocessed=false);
testCase.verifyEqual(size(g), col.imageSize);
% wrong input
testCase.verifyEqual(helper_error_id('pivlab.getImage', imgs, 4), 'pivlab:getImage:pair');
testCase.verifyNotEmpty(helper_error_id('pivlab.getImage', imgs, 0));
testCase.verifyNotEmpty(helper_error_id('pivlab.getImage', imgs, 1, 'Frame', "C"));
end
