function tests = test_pivlab_api_options
%TEST_PIVLAB_API_OPTIONS Every function of the command-line API (+pivlab) with every option.
%   Each option is checked for: it runs, it has the documented effect, wrong values give a clear
%   error. Equality with the PIVlab GUI is checked by unittests/parity (api_vs_gui*) and by
%   test_pivlab_api.
%   Run with: results = runtests('unittests/test_pivlab_api_options.m')
%   Optional real data (skipped if missing): pco.panda double images in
%   D:\PIV Data\micro_PIV_panda_excelitas\micro_piv_boundary_layer1
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(projectRoot);
testCase.TestData.ProjectRoot = projectRoot;
testCase.TestData.Dir = tempname(tempdir);
mkdir(testCase.TestData.Dir);
testCase.TestData.Files = jetFiles(projectRoot, 3);
testCase.TestData.Figure = figure('Units','pixels','Position',[20 40 1200 900]);
setappdata(0, 'PIVlabTestMode', true);
setappdata(0, 'pivlab_test_warning_state', warning);   % PIVlab_GUI switches all warnings off
testCase.TestData.Preferences = clear_preferences();
% one analysed result that several tests start from
imgs = pivlab.preprocess(pivlab.readImages(testCase.TestData.Files, "pairwise"), Verbose=false);
testCase.TestData.Imgs = imgs;
testCase.TestData.Res = pivlab.analyze(imgs, Verbose=false);
end

function teardownOnce(testCase)
closePIVlab();
restore_preferences(testCase.TestData.Preferences);
if isappdata(0, 'PIVlabTestMode')
    rmappdata(0, 'PIVlabTestMode');
end
try
    rmdir(testCase.TestData.Dir, 's');
catch
end
close all force
end

%% ================================================================== readImages
function test_readImages_sources(testCase)
root = testCase.TestData.ProjectRoot;
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
testCase.verifyEqual(errorId('pivlab.readImages', fullfile(root,'Example_data','nothing_*.jpg'), "pairwise"), 'pivlab:readImages:noImages');
testCase.verifyEqual(errorId('pivlab.readImages', files(1), "pairwise"), 'pivlab:readImages:tooFewImages');
testCase.verifyNotEmpty(errorId('pivlab.readImages', files, "sideways"));
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
% analysis of a part of the image and a session for the GUI
imgs = pivlab.preprocess(imgs, Roi=[1000 1000 1024 768], Verbose=false);
res = pivlab.filter(pivlab.analyze(imgs, Verbose=false), Verbose=false);
testCase.verifyGreaterThan(nnz(isfinite(res.u)), 0.9*numel(res.u));
f = fullfile(testCase.TestData.Dir, 'pco_session.mat');
pivlab.saveSession(res, f, Verbose=false);
r = pivlab.loadSession(f);
testCase.verifyTrue(r.images.pcopanda_dbl_image);
testCase.verifyEqual(r.px.u, res.px.u);
startPIVlab();
import.load_session_Callback(1, f); drawnow;
testCase.verifyEqual(gui.retr('pcopanda_dbl_image'), 1);
h = gui.gethand;
set(h.update_display_checkbox,'Value',0);
piv.AnalyzeAll_Callback([],[],[]);
rl = gui.retr('resultslist');
testCase.verifyEqual(rl{3,2}, res.px.u_raw(:,:,2));
closePIVlab();
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
out = warnings_of('pivlab:settings:unknownField', 'pivlab.preprocess', raw, 'Settings', bad, 'Verbose', false);
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
verifyNear(testCase, double(mi.background.A), double(min(stack,[],3)), 'AbsTol', 1);
% background subtracted in the image that is analysed, not in the raw image
testCase.verifyNotEqual(pivlab.getImage(mn, 1), pivlab.getImage(none, 1));
testCase.verifyEqual(pivlab.getImage(mn, 1, Preprocessed=false), pivlab.getImage(none, 1, Preprocessed=false));
% time resolved works, reference does not
tr = pivlab.preprocess(pivlab.readImages(files, "timeresolved"), Background="min", Verbose=false);
testCase.verifyEqual(size(tr.background.B), raw.imageSize);
testCase.verifyEqual(errorId('pivlab.preprocess', pivlab.readImages(files, "reference"), 'Background', "mean"), 'pivlab:preprocess:background');
testCase.verifyEqual(errorId('pivlab.preprocess', raw, 'Background', "median"), 'pivlab:preprocess:background');
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
testCase.verifyEqual(errorId('pivlab.preprocess', raw, 'Roi', [0 1 100 100]), 'pivlab:preprocess:roi');
testCase.verifyEqual(errorId('pivlab.preprocess', raw, 'Roi', [1 1 sz(2) 100]), 'pivlab:preprocess:roi');
testCase.verifyEqual(errorId('pivlab.preprocess', raw, 'Roi', [1 1 100]), 'pivlab:preprocess:roi');
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
testCase.verifyEqual(errorId('pivlab.preprocess', raw, 'Mask', true(10)), 'pivlab:preprocess:mask');
testCase.verifyEqual(errorId('pivlab.preprocess', raw, 'Mask', "everything"), 'pivlab:preprocess:mask');
% "none" (and "None") removes ROI and mask
p = pivlab.preprocess(raw, Roi=roi, Mask=m, Verbose=false);
q = pivlab.preprocess(p, Roi="None", Mask="none", Verbose=false);
testCase.verifyEmpty(q.preprocess.Roi);
testCase.verifyEmpty(q.mask);
end

function test_preprocess_camera_options(testCase)
files = distortionFiles(testCase.TestData.ProjectRoot, 2);
raw = pivlab.readImages(files, "pairwise");
sz = raw.imageSize;
cp = cameraModel(sz);
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
col = pivlab.readImages(fuerteventuraFiles(testCase.TestData.ProjectRoot, 4), "timeresolved");
g = pivlab.getImage(col, 1, Preprocessed=false);
testCase.verifyEqual(size(g), col.imageSize);
% wrong input
testCase.verifyEqual(errorId('pivlab.getImage', imgs, 4), 'pivlab:getImage:pair');
testCase.verifyNotEmpty(errorId('pivlab.getImage', imgs, 0));
testCase.verifyNotEmpty(errorId('pivlab.getImage', imgs, 1, 'Frame', "C"));
end

%% ================================================================== analyze
function test_analyze_fft_options(testCase)
imgs = testCase.TestData.Imgs;
ref = pivlab.analyze(imgs, Pairs=1, Verbose=false);
testCase.verifyEqual(ref.units, "px/frame");
testCase.verifyEqual(ref.settings.analysis.Algorithm, "fft");
% default: 64 px / step 32, second pass 32 px -> vector spacing 16 px
testCase.verifyEqual(spacing(ref), 16);
% first pass only: spacing = Step
r = pivlab.analyze(imgs, Passes=1, InterrogationArea=48, Step=24, Pairs=1, Verbose=false);
testCase.verifyEqual(spacing(r), 24);
% 1...4 passes: the spacing of the last pass is half of its window size
P = {1, [32 32 32], 32; 2, [48 48 48], 24; 3, [32 16 16], 8; 4, [48 32 16], 8};
for k = 1:size(P,1)
    r = pivlab.analyze(imgs, Passes=P{k,1}, PassSizes=P{k,2}, Pairs=1, Verbose=false);
    testCase.verifyEqual(spacing(r), P{k,3}, sprintf('%d passes', P{k,1}));
    testCase.verifyEqual(r.settings.analysis.Passes, P{k,1});
end
% a single pass size is used for all following passes
r1 = pivlab.analyze(imgs, Passes=3, PassSizes=32, Pairs=1, Verbose=false);
r2 = pivlab.analyze(imgs, Passes=3, PassSizes=[32 32 32], Pairs=1, Verbose=false);
testCase.verifyEqual(r1.px.u_raw, r2.px.u_raw);
% options that change the result (but not the grid)
O = {'SubpixelFinder', "gauss2d"; 'DisableAutocorrelation', true; 'Robustness', "high"; 'Robustness', "extreme"; ...
     'RepeatLastPass', true};
for k = 1:size(O,1)
    r = pivlab.analyze(imgs, O{k,1}, O{k,2}, Pairs=1, Verbose=false);
    testCase.verifyEqual(size(r.px.u_raw), size(ref.px.u_raw), O{k,1});
    testCase.verifyNotEqual(r.px.u_raw, ref.px.u_raw, sprintf('%s = %s', O{k,1}, string(O{k,2})));
end
% values that equal the default give the default result (also as numbers / other case)
E = {'SubpixelFinder', "Gauss3Point"; 'SubpixelFinder', 1; 'Robustness', "Standard"; 'Robustness', 1; ...
     'DisableAutocorrelation', false; 'RepeatLastPass', false; 'Uncertainty', false};
for k = 1:size(E,1)
    r = pivlab.analyze(imgs, E{k,1}, E{k,2}, Pairs=1, Verbose=false);
    testCase.verifyEqual(r.px.u_raw, ref.px.u_raw, sprintf('%s = %s', E{k,1}, string(E{k,2})));
end
% RepeatLastPassThreshold: a large threshold stops after the first repetition
a = pivlab.analyze(imgs, RepeatLastPass=true, RepeatLastPassThreshold=0.001, Pairs=1, Verbose=false);
b = pivlab.analyze(imgs, RepeatLastPass=true, RepeatLastPassThreshold=10, Pairs=1, Verbose=false);
testCase.verifyNotEqual(a.px.u_raw, b.px.u_raw);
% Uncertainty: map in res, derive can show it
r = pivlab.analyze(imgs, Uncertainty=true, Pairs=1, Verbose=false);
testCase.verifyEqual(size(r.px.uncertainty), size(r.px.u));
testCase.verifyEqual(r.px.u_raw, ref.px.u_raw);
[~, um] = pivlab.derive(r, "uncertainty");
testCase.verifyGreaterThan(nnz(isfinite(um)), 0.5*numel(um));
testCase.verifyEqual(errorId('pivlab.derive', ref, "uncertainty"), 'pivlab:derive:notAvailable');
% second correlation peak stored (for second-peak substitution in pivlab.filter)
testCase.verifyEqual(size(ref.px.u2), size(ref.px.u));
% Settings instead of name=value
s = pivlab.defaults();
s.analysis.Passes = 3; s.analysis.PassSizes = [32 16 16];
a = pivlab.analyze(imgs, Settings=s, Pairs=1, Verbose=false);
b = pivlab.analyze(imgs, Passes=3, PassSizes=[32 16 16], Pairs=1, Verbose=false);
testCase.verifyEqual(a.px.u_raw, b.px.u_raw);
end

function test_analyze_pairs_and_verbose(testCase)
imgs = testCase.TestData.Imgs;
all3 = testCase.TestData.Res;
testCase.verifyEqual(size(all3.u,3), 3);
testCase.verifyEqual(all3.pairs, 1:3);
testCase.verifyEqual(numel(all3.frameLabels), 3);
% a selection of pairs gives the same vectors as the full analysis
r = pivlab.analyze(imgs, Pairs=[3 1], Verbose=false);
testCase.verifyEqual(r.pairs, [3 1]);
testCase.verifyEqual(r.px.u_raw(:,:,1), all3.px.u_raw(:,:,3));
testCase.verifyEqual(r.px.u_raw(:,:,2), all3.px.u_raw(:,:,1));
testCase.verifySubstring(char(r.frameLabels(1)), 'Jet_0003A');
% wrong pairs / algorithm
testCase.verifyEqual(errorId('pivlab.analyze', imgs, 'Pairs', 4, 'Verbose', false), 'pivlab:analyze:pairs');
testCase.verifyEqual(errorId('pivlab.analyze', imgs, 'Pairs', 1.5, 'Verbose', false), 'pivlab:analyze:pairs');
testCase.verifyEqual(errorId('pivlab.analyze', imgs, 'Algorithm', "piv", 'Verbose', false), 'pivlab:analyze:algorithm');
testCase.verifyEqual(errorId('pivlab.analyze', imgs, 'SubpixelFinder', "gauss9", 'Verbose', false), 'pivlab:analyze:subpixel');
testCase.verifyEqual(errorId('pivlab.analyze', imgs, 'Robustness', "low", 'Verbose', false), 'pivlab:analyze:robustness');
testCase.verifyEqual(errorId('pivlab.analyze', imgs, 'Speed', 3, 'Verbose', false), 'MATLAB:TooManyInputs');
% the analysis leaves the warning state of MATLAB as it was (PIVlab switched all warnings off before)
state = warning;
pivlab.analyze(imgs, Pairs=1, Verbose=false);
pivlab.analyze(imgs, Algorithm="ensemble", Pairs=1:2, Verbose=false);
pivlab.analyze(imgs, Algorithm="dcc", Pairs=1, Verbose=false);
testCase.verifyEqual(warning, state, 'warning state changed by pivlab.analyze');
% Verbose
out = evalc('pivlab.analyze(imgs, Pairs=1:2);');
testCase.verifySubstring(out, 'finished');
out = evalc('pivlab.analyze(imgs, Pairs=1:2, Verbose=false);');
testCase.verifyEmpty(strtrim(out));
end

function test_analyze_parallel(testCase)
testCase.assumeTrue(license('test','Distrib_Computing_Toolbox') && ~isempty(ver('parallel')), 'no Parallel Computing Toolbox');
imgs = testCase.TestData.Imgs;
serial = testCase.TestData.Res;
par = pivlab.analyze(imgs, Parallel=true, Verbose=false);
% worker processes calculate with one thread: the same result up to rounding (the window
% deformation lets single rounding differences grow to a few 1/1000 px at the border)
d = abs(double(par.px.u_raw(:)) - double(serial.px.u_raw(:)));
fprintf('parallel vs serial: max difference %.2g px, %.2f %% of the vectors differ by more than 1e-4 px\n', ...
    max(d), 100*mean(d > 1e-4));
testCase.verifyLessThan(max(d), 0.01);
testCase.verifyLessThan(mean(d > 1e-4), 0.01);
testCase.verifyEqual(par.typevector_raw, serial.typevector_raw);
% a second call uses the open pool and gives exactly the same result
par2 = pivlab.analyze(imgs, Parallel=true, Verbose=false);
testCase.verifyEqual(par2.px.u_raw, par.px.u_raw);
% DCC in parallel
d1 = pivlab.analyze(imgs, Algorithm="dcc", Pairs=1:2, Verbose=false);
d2 = pivlab.analyze(imgs, Algorithm="dcc", Pairs=1:2, Parallel=true, Verbose=false);
verifyNear(testCase, d2.px.u_raw, d1.px.u_raw, 'AbsTol', 0.01);
% Parallel with the ensemble: warning, analysed serially
out = warnings_of('pivlab:analyze:noEffect', 'pivlab.analyze', imgs, 'Algorithm', "ensemble", 'Passes', 1, 'Parallel', true, 'Verbose', false);
testCase.verifySubstring(out, 'Parallel has no effect');
delete(gcp('nocreate'));
end

function test_analyze_ensemble(testCase)
imgs = testCase.TestData.Imgs;
r = pivlab.analyze(imgs, Algorithm="ensemble", Verbose=false);
testCase.verifyEqual(size(r.u,3), 1);
testCase.verifyEqual(r.frameLabels, "Ensemble of pairs 1-3");
testCase.verifyEqual(spacing(r), 16);
testCase.verifyGreaterThan(nnz(isfinite(r.u)), 0.9*numel(r.u));
% the ensemble is close to the mean of the single-pair results
m = mean(testCase.TestData.Res.px.u_raw, 3, 'omitnan');
dev = abs(double(r.px.u_raw) - double(m));
testCase.verifyLessThan(median(dev(:), 'omitnan'), 0.2);
% passes, window sizes, subpixel finder, robustness, autocorrelation
P = {'Passes', 1; 'Passes', 3; 'SubpixelFinder', "gauss2d"; 'Robustness', "high"; 'DisableAutocorrelation', true; 'InterrogationArea', 96};
for k = 1:size(P,1)
    e = pivlab.analyze(imgs, 'Algorithm', "ensemble", P{k,1}, P{k,2}, 'Verbose', false);
    testCase.verifyNotEqual(e.px.u_raw, r.px.u_raw, P{k,1});
end
e = pivlab.analyze(imgs, Algorithm="ensemble", Passes=3, PassSizes=[32 16 16], Verbose=false);
testCase.verifyEqual(spacing(e), 8);
% Pairs
e = pivlab.analyze(imgs, Algorithm="ensemble", Pairs=2:3, Verbose=false);
testCase.verifyEqual(e.frameLabels, "Ensemble of pairs 2-3");
testCase.verifyNotEqual(e.px.u_raw, r.px.u_raw);
% options of other algorithms: warning
W = {'RepeatLastPass', true; 'Uncertainty', true; 'OFVSmoothness', 20};
for k = 1:size(W,1)
    % (one pass: the smoothing between the passes issues warnings of its own, they would replace
    % this warning in lastwarn)
    out = warnings_of('pivlab:analyze:noEffect', 'pivlab.analyze', imgs, 'Algorithm', "ensemble", 'Passes', 1, W{k,1}, W{k,2}, 'Pairs', 1, 'Verbose', false);
    testCase.verifySubstring(out, [W{k,1} ' has no effect'], W{k,1});
end
% the whole chain works on the ensemble result
r = pivlab.toMetric(pivlab.filter(r, Verbose=false), DeltaT=0.001, PxPerMeter=1000, Verbose=false);
[~, vort] = pivlab.derive(r, "vorticity");
testCase.verifyEqual(size(vort), size(r.u));
f = fullfile(testCase.TestData.Dir, 'ensemble_session.mat');
pivlab.saveSession(r, f, Verbose=false);
q = pivlab.loadSession(f);
testCase.verifyEqual(q.px.u, r.px.u);
close(pivlab.display(r, Overlay="vorticity"));
end

function test_analyze_dcc(testCase)
imgs = testCase.TestData.Imgs;
r = pivlab.analyze(imgs, Algorithm="dcc", Pairs=1, Verbose=false);
testCase.verifyEqual(spacing(r), 32);
fft = testCase.TestData.Res;
testCase.verifyGreaterThan(nnz(isfinite(r.u)), 0.9*numel(r.u));
% DCC agrees with the FFT result
fu = interp2(double(fft.px.x), double(fft.px.y), double(fft.px.u_raw(:,:,1)), double(r.px.x), double(r.px.y));
d = abs(double(r.px.u_raw(:)) - fu(:));
testCase.verifyLessThan(median(d, 'omitnan'), 0.5);
r2 = pivlab.analyze(imgs, Algorithm="dcc", InterrogationArea=48, Step=16, Pairs=1, Verbose=false);
testCase.verifyEqual(spacing(r2), 16);
r3 = pivlab.analyze(imgs, Algorithm="dcc", SubpixelFinder="gauss2d", Pairs=1, Verbose=false);
testCase.verifyNotEqual(r3.px.u_raw, r.px.u_raw);
W = {'Passes', 3; 'PassSizes', [32 16 16]; 'Robustness', "high"; 'DisableAutocorrelation', true; 'RepeatLastPass', true; 'Uncertainty', true};
for k = 1:size(W,1)
    out = warnings_of('pivlab:analyze:noEffect', 'pivlab.analyze', imgs, 'Algorithm', "dcc", W{k,1}, W{k,2}, 'Pairs', 1, 'Verbose', false);
    testCase.verifySubstring(out, [W{k,1} ' has no effect'], W{k,1});
end
end

function test_analyze_optical_flow(testCase)
% (needs the wavelet filter matrices, about 260 MB, downloaded at the first use of the optical flow)
testCase.assumeTrue(isfolder(fullfile(testCase.TestData.ProjectRoot,'+wOFV','Filter matrices')), ...
    'wOFV filter matrices not downloaded yet');
% a small region keeps the optical flow fast (patch size 256 px)
imgs = pivlab.preprocess(pivlab.readImages(testCase.TestData.Files(1:2), "pairwise"), Roi=[300 300 300 300], Verbose=false);
r = pivlab.analyze(imgs, Algorithm="ofv", OFVPyramidLevels=3, Verbose=false);
testCase.verifyEqual(r.settings.analysis.Algorithm, "ofv");
testCase.verifyGreaterThan(nnz(isfinite(r.u)), 0.9*numel(r.u));
% dense result, close to the FFT result
f = pivlab.analyze(imgs, Verbose=false);
testCase.verifyGreaterThan(numel(r.u), numel(f.u));
fu = interp2(double(f.px.x), double(f.px.y), double(f.px.u_raw), double(r.px.x), double(r.px.y));
d = abs(double(r.px.u_raw) - fu);
testCase.verifyLessThan(median(d(:), 'omitnan'), 0.5);
% every optical flow option changes the result
O = {'OFVSmoothness', 20; 'OFVPyramidLevels', 4; 'OFVMedianFilter', "3x3"; 'OFVMedianFilter', "5x5"};
for k = 1:size(O,1)
    args = {O{k,1}, O{k,2}};
    if ~strcmp(O{k,1}, 'OFVPyramidLevels')
        args = [args {'OFVPyramidLevels', 3}]; %#ok<AGROW>
    end
    o = pivlab.analyze(imgs, 'Algorithm', "ofv", args{:}, 'Verbose', false);
    testCase.verifyNotEqual(o.px.u_raw, r.px.u_raw, sprintf('%s = %s', O{k,1}, string(O{k,2})));
end
% options of the correlation algorithms: warning
W = {'InterrogationArea', 32; 'Step', 16; 'Passes', 3; 'SubpixelFinder', "gauss2d"; 'Parallel', true};
for k = 1:size(W,1)
    out = warnings_of('pivlab:analyze:noEffect', 'pivlab.analyze', imgs, 'Algorithm', "ofv", 'OFVPyramidLevels', 3, W{k,1}, W{k,2}, 'Verbose', false);
    testCase.verifySubstring(out, [W{k,1} ' has no effect'], W{k,1});
end
% the chain works on optical flow results (dense grid)
r = pivlab.filter(r, Verbose=false);
[~, v] = pivlab.derive(r, "vorticity");
testCase.verifyEqual(size(v), size(r.u));
end

%% ================================================================== filter
function test_filter_options(testCase)
res = testCase.TestData.Res;
base = pivlab.filter(res, Verbose=false);
testCase.verifyTrue(base.filtered);
testCase.verifyEqual(base.px.u_raw, res.px.u_raw);   % the raw data stay
nb = nnz(base.typevector == 2);
% stricter thresholds remove more vectors, switched-off filters fewer
testCase.verifyGreaterThan(nnz(pivlab.filter(res, StdevThreshold=2, Verbose=false).typevector == 2), nb);
testCase.verifyGreaterThan(nnz(pivlab.filter(res, LocalMedianThreshold=1, Verbose=false).typevector == 2), nb);
testCase.verifyLessThanOrEqual(nnz(pivlab.filter(res, StdevCheck=false, LocalMedian=false, Verbose=false).typevector == 2), nb);
% filters that are off by default
O = {'CorrelationFilter', true, 'CorrelationThreshold', 0.8; ...
     'NotchFilter', true, 'NotchLimits', [0 2]; ...
     'ContrastFilter', true, 'ContrastThreshold', 0.05; ...
     'BrightnessFilter', true, 'BrightnessThreshold', 0.1};
for k = 1:size(O,1)
    f = pivlab.filter(res, O{k,:}, Verbose=false);
    testCase.verifyGreaterThan(nnz(f.typevector == 2), nb, O{k,1});
    f2 = pivlab.filter(res, O{k,1}, false, O{k,3}, O{k,4}, Verbose=false);
    testCase.verifyEqual(f2.typevector, base.typevector, [O{k,1} ' = false']);
end
% velocity limits in px/frame: vectors outside are removed
lim = [-1 1 -2 2];
f = pivlab.filter(res, VelocityLimits=lim, Interpolate=false, Verbose=false);
u = f.px.u; v = f.px.v; tv = f.typevector;
ok = tv == 1;
testCase.verifyTrue(all(u(ok) >= lim(1) & u(ok) <= lim(2) & v(ok) >= lim(3) & v(ok) <= lim(4)));
% Interpolate=false: removed vectors are NaN, true: they are filled
testCase.verifyTrue(all(isnan(u(tv == 2))));
fi = pivlab.filter(res, VelocityLimits=lim, Verbose=false);
testCase.verifyTrue(all(isfinite(fi.px.u(fi.typevector == 2))));
% after toMetric the limits are in m/s
m = pivlab.toMetric(res, DeltaT=0.001, PxPerMeter=10000, Verbose=false);   % 1 px/frame = 0.1 m/s
fm = pivlab.filter(m, VelocityLimits=lim*0.1, Interpolate=false, Verbose=false);
testCase.verifyEqual(fm.typevector, f.typevector);
% "none" removes limits that came from Settings
s = pivlab.defaults(); s.filter.VelocityLimits = lim;
fs = pivlab.filter(res, Settings=s, Verbose=false);
testCase.verifyEqual(fs.typevector, fi.typevector);
fn = pivlab.filter(res, Settings=s, VelocityLimits="none", Verbose=false);
testCase.verifyEqual(fn.typevector, base.typevector);
% wrong limits
testCase.verifyEqual(errorId('pivlab.filter', res, 'VelocityLimits', [1 -1 -2 2], 'Verbose', false), 'pivlab:filter:limits');
testCase.verifyEqual(errorId('pivlab.filter', res, 'VelocityLimits', [-1 1], 'Verbose', false), 'pivlab:filter:limits');
% image-based filters need images: not on temporal statistics
t = pivlab.temporal(res, "mean");
testCase.verifyEqual(errorId('pivlab.filter', t, 'ContrastFilter', true, 'Verbose', false), 'pivlab:filter:imagefilter');
pivlab.filter(t, Verbose=false);   % the other filters work
% second-peak substitution: typevector 3 exists with the default filter
testCase.verifyGreaterThanOrEqual(nnz(base.typevector == 3), 0);
% filtering again starts from the raw data
ff = pivlab.filter(pivlab.filter(res, StdevThreshold=2, Verbose=false), Verbose=false);
testCase.verifyEqual(ff.typevector, base.typevector);
% Verbose
out = evalc('pivlab.filter(res);');
testCase.verifySubstring(out, 'Vector validation');
end

function test_filter_limits_from_a_gui_session(testCase)
% velocity limits stored in a session are in calibrated units (LimitUnits = "calibrated")
res = pivlab.toMetric(testCase.TestData.Res, DeltaT=0.001, PxPerMeter=10000, Verbose=false);
f = fullfile(testCase.TestData.Dir, 'limits_session.mat');
res = pivlab.filter(res, VelocityLimits=[-0.1 0.1 -0.2 0.2], Verbose=false);
pivlab.saveSession(res, f, Verbose=false);
s = pivlab.loadSettings(f);
verifyNear(testCase, s.filter.VelocityLimits, [-0.1 0.1 -0.2 0.2], 'AbsTol', 1e-12);
% applied to a result in px/frame, the limits are converted with the session calibration
a = pivlab.filter(testCase.TestData.Res, Settings=s, Verbose=false);
b = pivlab.filter(testCase.TestData.Res, VelocityLimits=[-1 1 -2 2], Verbose=false);
testCase.verifyEqual(a.typevector, b.typevector);
end

%% ================================================================== toMetric
function test_toMetric_options(testCase)
res = testCase.TestData.Res;
a = pivlab.toMetric(res, DeltaT=0.002, PxPerMeter=5000, Verbose=false);
testCase.verifyEqual(a.units, "m/s");
verifyNear(testCase, a.x, res.px.x/5000, 'RelTol', 1e-12);
verifyNear(testCase, double(a.u), double(res.px.u)/5000/0.002, 'RelTol', 1e-6);
% ReferenceDistance: 100 px are 0.02 m = 5000 px/m
b = pivlab.toMetric(res, DeltaT=0.002, ReferenceDistance=[100 0.02], Verbose=false);
verifyNear(testCase, b.x, a.x, 'RelTol', 1e-12);
verifyNear(testCase, b.u, a.u, 'RelTol', 1e-6);
% Origin: x and y are measured from this pixel
o = pivlab.toMetric(res, DeltaT=0.002, PxPerMeter=5000, Origin=[100 200], Verbose=false);
verifyNear(testCase, o.x, (double(res.px.x)-100)/5000, 'AbsTol', 1e-7);   % px positions are single
verifyNear(testCase, o.y, (double(res.px.y)-200)/5000, 'AbsTol', 1e-7);
% axis directions
l = pivlab.toMetric(res, DeltaT=0.002, PxPerMeter=5000, XAxis="left", Verbose=false);
verifyNear(testCase, l.u, -a.u, 'RelTol', 1e-6);
verifyNear(testCase, l.v, a.v, 'RelTol', 1e-6);
testCase.verifyLessThan(l.x(1,2) - l.x(1,1), 0);
up = pivlab.toMetric(res, DeltaT=0.002, PxPerMeter=5000, YAxis="up", Verbose=false);
verifyNear(testCase, up.v, -a.v, 'RelTol', 1e-6);
verifyNear(testCase, up.u, a.u, 'RelTol', 1e-6);
testCase.verifyLessThan(up.y(2,1) - up.y(1,1), 0);
% the sign of the vorticity follows the axes
[~, w1] = pivlab.derive(a, "vorticity");
[~, w2] = pivlab.derive(up, "vorticity");
verifyNear(testCase, w2, -w1, 'AbsTol', 1e-6*max(abs(w1(:))));
% DeltaT = 0: displacements in m per frame
d = pivlab.toMetric(res, DeltaT=0, PxPerMeter=5000, Verbose=false);
testCase.verifyEqual(d.units, "m/frame");
verifyNear(testCase, double(d.u), double(res.px.u)/5000, 'RelTol', 1e-6);
% repeated calibration starts from the pixel data
r = pivlab.toMetric(pivlab.toMetric(res, DeltaT=1, PxPerMeter=1, Verbose=false), DeltaT=0.002, PxPerMeter=5000, Verbose=false);
testCase.verifyEqual(r.u, a.u);
% calibration from a session or settings file
f = fullfile(testCase.TestData.Dir, 'cal_session.mat');
pivlab.saveSession(up, f, Verbose=false);
s = pivlab.loadSettings(f);
c = pivlab.toMetric(res, Settings=s, Verbose=false);
verifyNear(testCase, c.u, up.u, 'RelTol', 1e-12);
verifyNear(testCase, c.y, up.y, 'RelTol', 1e-12);
% missing information
testCase.verifyEqual(errorId('pivlab.toMetric', res), 'pivlab:toMetric:noCalibration');
testCase.verifyEqual(errorId('pivlab.toMetric', res, 'DeltaT', 0.001), 'pivlab:toMetric:missing');
testCase.verifyEqual(errorId('pivlab.toMetric', res, 'PxPerMeter', 1000), 'pivlab:toMetric:missing');
% Verbose
out = evalc('pivlab.toMetric(res, DeltaT=0.002, PxPerMeter=5000);');
testCase.verifySubstring(out, 'm/s');
end

%% ================================================================== derive / temporal
function test_derive_all_quantities(testCase)
res = pivlab.filter(testCase.TestData.Res, Verbose=false);
resm = pivlab.toMetric(res, DeltaT=0.001, PxPerMeter=5000, Verbose=false);
Q = ["vorticity","magnitude","u","v","divergence","qcriterion","shear","strain","direction","lic","correlation"];
for q = Q
    for r = {res, resm}
        [out, map] = pivlab.derive(r{1}, q);
        testCase.verifyTrue(isfield(out.derived, q), q);
        testCase.verifyEqual(size(map,3), 3, q);
        testCase.verifyGreaterThan(nnz(isfinite(map)), 0.5*numel(map), q);
    end
end
% values
[~, mag] = pivlab.derive(resm, "magnitude");
verifyNear(testCase, double(mag), double(hypot(resm.u, resm.v)), 'RelTol', 1e-5);
[~, uu] = pivlab.derive(resm, "u");
verifyNear(testCase, double(uu), double(resm.u), 'RelTol', 1e-5);
[~, dirm] = pivlab.derive(resm, "direction");
testCase.verifyGreaterThanOrEqual(min(dirm(:)), -180);
testCase.verifyLessThanOrEqual(max(dirm(:)), 360);
[~, cm] = pivlab.derive(res, "correlation");
testCase.verifyEqual(cm, res.correlation_map);
% Subtract
[~, us] = pivlab.derive(resm, "u", Subtract=[0.1 0]);
verifyNear(testCase, double(us), double(resm.u) - 0.1, 'AbsTol', 1e-5);
[~, ms] = pivlab.derive(resm, "magnitude", Subtract=[0.1 0.05]);
verifyNear(testCase, double(ms), double(hypot(resm.u-0.1, resm.v-0.05)), 'RelTol', 1e-4);
% LICSize: size of the LIC image
[~, lic1] = pivlab.derive(res, "lic", LICSize=400);
[~, lic2] = pivlab.derive(res, "lic", LICSize=800);
verifyNear(testCase, max(size(lic1,[1 2])), 400, 'AbsTol', 2);
testCase.verifyGreaterThan(max(size(lic2,[1 2])), max(size(lic1,[1 2])));
% smoothing
[~, v0] = pivlab.derive(res, "vorticity");
[o1, v1] = pivlab.derive(res, "vorticity", Smoothing="spatial");
[~, v1b] = pivlab.derive(res, "vorticity", Smoothing="spatial", SmoothingStrength=3);
[o2, v2] = pivlab.derive(res, "vorticity", Smoothing="temporal");
[~, v2b] = pivlab.derive(res, "vorticity", Smoothing="temporal", TemporalWindow=1);
[~, v3] = pivlab.derive(res, "vorticity", Smoothing="spatiotemporal");
testCase.verifyTrue(o1.smoothed);
testCase.verifyTrue(o2.smoothed);
testCase.verifyLessThan(std(v1(:),'omitnan'), std(v0(:),'omitnan'));
testCase.verifyLessThan(std(v1b(:),'omitnan'), std(v1(:),'omitnan'));
testCase.verifyNotEqual(v2, v0);
testCase.verifyNotEqual(v2b, v2);
testCase.verifyNotEqual(v3, v2);
% the smoothed field is used by display and temporal; "none" switches it off again
testCase.verifyNotEmpty(o1.px.u_smoothed);
[o0, ~] = pivlab.derive(o1, "vorticity", Smoothing="none");
testCase.verifyFalse(o0.smoothed);
% Settings
s = pivlab.defaults(); s.derive.Smoothing = "spatial";
[~, vs] = pivlab.derive(res, "vorticity", Settings=s);
testCase.verifyEqual(vs, v1);
% wrong input
testCase.verifyEqual(errorId('pivlab.derive', res, "speed"), 'pivlab:derive:quantity');
testCase.verifyEqual(errorId('pivlab.derive', res, "vorticity", 'Smoothing', "gaussian"), 'pivlab:derive:smoothing');
end

function test_temporal_options(testCase)
res = pivlab.filter(testCase.TestData.Res, Verbose=false);
u = double(res.px.u);
ops = ["mean","std","sum","tke"];
for op = ops
    t = pivlab.temporal(res, op);
    testCase.verifyEqual(size(t.u,3), 1, op);
    testCase.verifyTrue(t.isMean, op);
    testCase.verifyEqual(t.statistic, op);
    ok = isfinite(t.px.u);
    switch op
        case "mean", expected = mean(u,3,'omitnan');
        case "std",  expected = std(u,0,3,'omitnan');
        case "sum",  expected = sum(u,3,'omitnan');
        case "tke",  expected = 0.5*var(u,0,3,'omitnan');
    end
    verifyNear(testCase, double(t.px.u(ok)), expected(ok), 'AbsTol', 1e-4, op);
    testCase.verifyGreaterThan(nnz(ok), 0.9*numel(ok), op);
end
% Frames
t = pivlab.temporal(res, "mean", Frames=[1 3]);
e = mean(u(:,:,[1 3]),3,'omitnan');
ok = isfinite(t.px.u);
verifyNear(testCase, double(t.px.u(ok)), e(ok), 'AbsTol', 1e-4);
testCase.verifySubstring(char(t.frameLabels), '1,3');
% one statistics frame per cell (phase averages)
t = pivlab.temporal(res, "mean", Frames={[1 2], 3});
testCase.verifyEqual(size(t.u,3), 2);
% a single frame: its valid vectors (interpolated ones count as missing, like in the GUI)
one = t.px.u(:,:,2); ref3 = res.px.u(:,:,3); ok = isfinite(one);
verifyNear(testCase, one(ok), ref3(ok), 'AbsTol', 1e-6);
testCase.verifyEqual(ok, res.typevector(:,:,3) == 1 | res.typevector(:,:,3) == 3);
% the result can be derived, displayed, filtered, calibrated, saved
[~, vort] = pivlab.derive(t, "vorticity");
testCase.verifyEqual(size(vort,3), 2);
close(pivlab.display(t, Frame=2, Overlay="magnitude"));
tm = pivlab.toMetric(t, DeltaT=0.001, PxPerMeter=5000, Verbose=false);
testCase.verifyEqual(tm.units, "m/s");
f = fullfile(testCase.TestData.Dir, 'temporal_session.mat');
pivlab.saveSession(tm, f, Verbose=false);
q = pivlab.loadSession(f);
testCase.verifyEqual(q.px.u, tm.px.u);
testCase.verifyTrue(all(q.isMean));
% the smoothed field is used when the result is smoothed
[sm, ~] = pivlab.derive(res, "magnitude", Smoothing="spatial");
ts = pivlab.temporal(sm, "mean");
testCase.verifyNotEqual(ts.px.u, pivlab.temporal(res, "mean").px.u);
% wrong input
testCase.verifyEqual(errorId('pivlab.temporal', res, "mean", 'Frames', 4), 'pivlab:temporal:frames');
testCase.verifyEqual(errorId('pivlab.temporal', res, "mean", 'Frames', 0), 'pivlab:temporal:frames');
testCase.verifyEqual(errorId('pivlab.temporal', pivlab.temporal(res, "mean"), "std"), 'pivlab:temporal:frames');
testCase.verifyNotEmpty(errorId('pivlab.temporal', res, "median"));
end

%% ================================================================== display
function test_display_every_option(testCase)
m = false(testCase.TestData.Imgs.imageSize); m(300:500, 400:700) = true;
res = pivlab.preprocess(testCase.TestData.Imgs, Roi=[50 50 1000 800], Mask=m, Verbose=false);
res = pivlab.analyze(res, Pairs=1:2, Verbose=false);
res = pivlab.filter(res, Verbose=false);
res = pivlab.toMetric(res, DeltaT=0.001, PxPerMeter=5000, Verbose=false);
fig = testCase.TestData.Figure;
if ~isgraphics(fig)   % closed by an earlier test
    fig = figure('Units','pixels','Position',[20 40 1200 900]);
end
outdir = fullfile(testCase.TestData.Dir, 'display');
mkdir(outdir);
Q = ["none","vorticity","magnitude","u","v","divergence","qcriterion","shear","strain","direction","lic","correlation"];
V = {};
for q = Q
    V(end+1,:) = {"overlay_" + q, {'Overlay', q}}; %#ok<AGROW>
end
for b = ["image","preprocessed","black","white","raw"]
    V(end+1,:) = {"background_" + b, {'Background', b}}; %#ok<AGROW>
end
cmaps = ["parula","hsv","jet","hsb","hot","cool","spring","summer","autumn","winter","gray","bone","copper","pink","lines","plasma"];
for c = cmaps
    V(end+1,:) = {"colormap_" + c, {'Overlay', "vorticity", 'Colormap', c}}; %#ok<AGROW>
end
for st = [256 128 64 32 16 8 4 2]
    V(end+1,:) = {"steps_" + st, {'Overlay', "vorticity", 'ColormapSteps', st}}; %#ok<AGROW>
end
for cb = ["east","west","north","south","none"]
    V(end+1,:) = {"colorbar_" + cb, {'Overlay', "magnitude", 'Colorbar', cb}}; %#ok<AGROW>
end
for cf = ["compact","scientific","fixed"]
    V(end+1,:) = {"cbformat_" + cf, {'Overlay', "magnitude", 'ColorbarFormat', cf}}; %#ok<AGROW>
end
for mi = ["bilinear","bicubic","nearest"]
    V(end+1,:) = {"interp_" + mi, {'Overlay', "vorticity", 'MapInterpolation', mi}}; %#ok<AGROW>
end
for rv = ["off","top left","top right","bottom left","bottom right"]
    V(end+1,:) = {"refvec_" + strrep(rv," ","_"), {'ReferenceVector', rv, 'ReferenceLength', 0.5}}; %#ok<AGROW>
end
V = [V; {
    "enhance",          {'EnhanceImage', true}
    "alpha_0",          {'Overlay', "vorticity", 'Alpha', 0}
    "alpha_1",          {'Overlay', "vorticity", 'Alpha', 1}
    "colorlimits",      {'Overlay', "vorticity", 'ColorLimits', [-50 50]}
    "extrapolate",      {'Overlay', "vorticity", 'ExtrapolateBorder', true}
    "novectors",        {'Overlay', "vorticity", 'Vectors', false}
    "veccolor_name",    {'VectorColor', "cyan"}
    "veccolor_rgb",     {'VectorColor', [1 0 1]}
    "veccolor_mag",     {'VectorColor', "magnitude"}
    "veccolor_mag_cb",  {'VectorColor', "magnitude", 'Colorbar', "south"}
    "interp_color",     {'InterpolatedColor', "red", 'SecondPeakColor', [1 1 0]}
    "vecscale_auto",    {'VectorScale', "auto"}
    "vecscale_3",       {'VectorScale', 3}
    "vecskip_3",        {'VectorSkip', 3}
    "vecwidth_2",       {'VectorWidth', 2}
    "uniform",          {'UniformLength', true}
    "power",            {'PowerScale', 0.3}
    "subtract",         {'Subtract', [0.05 0]}
    "nomask",           {'ShowMask', false}
    "masktransp_0",     {'MaskTransparency', 0}
    "masktransp_100",   {'MaskTransparency', 100}
    "noroi",            {'ShowROI', false}
    "title",            {'Title', "My title"}
    "notitle",          {'Title', ""}
    "frame2",           {'Frame', 2}
    }];
for k = 1:size(V,1)
    clf(fig);
    ax = axes(fig);
    name = char(V{k,1});
    try
        [f2, a2] = pivlab.display(res, V{k,2}{:}, 'Parent', ax);
        drawnow;
        testCase.verifyEqual(a2, ax, name);
        testCase.verifyEqual(f2, fig, name);
        exportgraphics(ax, fullfile(outdir, [name '.png']));
    catch err
        testCase.verifyFail(sprintf('%s: %s', name, err.message));
    end
end
% effects that can be checked on the graphics objects
clf(fig); ax = axes(fig);
pivlab.display(res, Overlay="vorticity", Colormap="gray", ColormapSteps=16, Parent=ax);
testCase.verifySize(colormap(ax), [16 3]);
verifyNear(testCase, colormap(ax), gray(16), 'AbsTol', 1e-12);
cb = findall(fig, 'Type', 'colorbar');
testCase.verifyNumElements(cb, 1);
testCase.verifyEqual(cb.Location, 'eastoutside');
clf(fig); ax = axes(fig);
pivlab.display(res, Overlay="vorticity", ColorLimits=[-50 50], Parent=ax);
cb = findall(fig, 'Type', 'colorbar');
labels = cellstr(cb.TickLabels);
testCase.verifyEqual(strtrim(labels{1}), '-50');
testCase.verifyEqual(strtrim(labels{end}), '50');
clf(fig); ax = axes(fig);
pivlab.display(res, Overlay="vorticity", Colorbar="none", Parent=ax);
testCase.verifyEmpty(findall(fig, 'Type', 'colorbar'));
clf(fig); ax = axes(fig);
pivlab.display(res, Overlay="vorticity", Vectors=false, Parent=ax);
testCase.verifyEmpty(findobj(ax, 'Type', 'quiver'));
clf(fig); ax = axes(fig);
pivlab.display(res, Title="My title", Parent=ax);
testCase.verifyEqual(ax.Title.String, 'My title');
clf(fig); ax = axes(fig);
pivlab.display(res, Frame=2, Parent=ax);
testCase.verifySubstring(ax.Title.String, 'Jet_0002A');
clf(fig); ax = axes(fig);
pivlab.display(res, ShowROI=true, Parent=ax);
testCase.verifyNotEmpty(findobj(ax, 'Tag', 'roiplot'));
clf(fig); ax = axes(fig);
pivlab.display(res, ShowROI=false, Parent=ax);
testCase.verifyEmpty(findobj(ax, 'Tag', 'roiplot'));
n1 = numel(vector_x(ax, res));
clf(fig); ax = axes(fig);
pivlab.display(res, VectorSkip=3, ShowROI=false, Parent=ax);
testCase.verifyLessThan(numel(vector_x(ax, res)), n1/4);
clf(fig); ax = axes(fig);
pivlab.display(res, Background="black", Vectors=false, ShowMask=false, ShowROI=false, Parent=ax);
im = findobj(ax, 'Type', 'image');
testCase.verifyEqual(max(double(im(end).CData(:))), 0);
% without Parent: a new figure
before = numel(findall(groot, 'Type', 'figure'));
[f3, a3] = pivlab.display(res);
testCase.verifyEqual(numel(findall(groot, 'Type', 'figure')), before + 1);
testCase.verifyEqual(a3.Parent, f3);
close(f3);
% Settings: display group
s = res.settings; s.display.Colormap = "jet"; s.display.ColormapSteps = 8;
clf(fig); ax = axes(fig);
pivlab.display(res, Overlay="vorticity", Colormap="jet", ColormapSteps=8, Parent=ax);
expected = colormap(ax);
clf(fig); ax = axes(fig);
pivlab.display(res, Overlay="vorticity", Settings=s, Parent=ax);
testCase.verifyEqual(colormap(ax), expected);
testCase.verifySize(expected, [8 3]);
% wrong values give clear errors
W = {'Frame', 3, 'pivlab:display:frame'; 'Colormap', "rainbow", 'pivlab:display:colormap'; ...
     'Colorbar', "inside", 'pivlab:display:colorbar'; 'ReferenceVector', "middle", 'pivlab:display:reference'; ...
     'VectorColor', "sky", 'pivlab:display:color'; 'Overlay', "speed", 'pivlab:derive:quantity'};
for k = 1:size(W,1)
    clf(fig); ax = axes(fig);
    testCase.verifyEqual(errorId('pivlab.display', res, W{k,1}, W{k,2}, 'Parent', ax), W{k,3}, W{k,1});
end
testCase.verifyNotEmpty(errorId('pivlab.display', res, 'Background', "grey"));
testCase.verifyNotEmpty(errorId('pivlab.display', res, 'ColorbarFormat', "long"));
% missing images: black background with a warning
moved = res;
moved.images.filepath{1} = fullfile(testCase.TestData.Dir, 'missing.jpg');
clf(fig); ax = axes(fig);
lastwarn('');
pivlab.display(moved, Parent=ax);
[~, id] = lastwarn;
testCase.verifyEqual(id, 'pivlab:display:image');
copyfile(outdir, fullfile(tempdir, 'pivlab_api_display_images'), 'f');
end

%% ================================================================== settings and sessions
function test_defaults_and_loadSettings(testCase)
s = pivlab.defaults();
groups = {'preprocess','analysis','filter','calibration','derive','display'};
for k = 1:numel(groups)
    testCase.verifyTrue(isfield(s, groups{k}), groups{k});
end
% every analysis option of pivlab.analyze is in the defaults (and the other way round)
names = fieldnames(s.analysis);
testCase.verifyTrue(all(ismember({'Algorithm','InterrogationArea','Step','Passes','PassSizes','SubpixelFinder', ...
    'DisableAutocorrelation','Robustness','RepeatLastPass','RepeatLastPassThreshold','Uncertainty', ...
    'OFVSmoothness','OFVPyramidLevels','OFVMedianFilter','Parallel'}, names)));
% the defaults run as they are
pivlab.analyze(testCase.TestData.Imgs, Settings=s, Pairs=1, Verbose=false);
% optical flow defaults = the GUI defaults (3 pyramid levels, smoothness 40, no median filter)
testCase.verifyEqual(s.analysis.OFVPyramidLevels, 3);
testCase.verifyEqual(s.analysis.OFVSmoothness, 40);
testCase.verifyEqual(s.analysis.OFVMedianFilter, "off");
% settings file written by the GUI code
G = gui.default_settings;
G.analysis.pass1_size = 80;
G.analysis.pass1_step = 40;
G.analysis.algorithm_selection = 2;
G.analysis.highpass_enable = 1;
G.analysis.ofv_pyramid_levels = 1;   % popup '5' '4' '3' '2' '1': 5 levels
G.analysis.ofv_median = 3;           % '5x5'
G.analysis.ofv_eta = 55;
f = fullfile(testCase.TestData.Dir, 'gui_settings.mat');
export.write_settings_file(f, G);
[s, t] = pivlab.loadSettings(f);
testCase.verifyEqual(t, 'settings');
testCase.verifyEqual(s.analysis.InterrogationArea, 80);
testCase.verifyEqual(s.analysis.Step, 40);
testCase.verifyEqual(s.analysis.Algorithm, "ensemble");
testCase.verifyTrue(logical(s.preprocess.Highpass));
testCase.verifyEqual(s.analysis.OFVPyramidLevels, 5);
testCase.verifyEqual(s.analysis.OFVMedianFilter, "5x5");
testCase.verifyEqual(s.analysis.OFVSmoothness, 55);
testCase.verifyEqual(s.source, string(f));
% and back: an API session carries the optical flow settings into the GUI settings
s.analysis.Algorithm = "fft";
r = pivlab.analyze(testCase.TestData.Imgs, Settings=s, Pairs=1, Verbose=false);
sf = fullfile(testCase.TestData.Dir, 'ofv_settings_session.mat');
pivlab.saveSession(r, sf, Verbose=false);
session = import.read_session_file(sf);
A = session.settings.analysis;
testCase.verifyEqual([A.ofv_pyramid_levels A.ofv_median A.ofv_eta], [1 3 55]);
% loadSettings accepts string and char
testCase.verifyEqual(pivlab.loadSettings(string(f)).analysis.Step, 40);
% files that are not settings
testCase.verifyEqual(errorId('pivlab.loadSettings', fullfile(testCase.TestData.Dir, 'nope.mat')), 'pivlab:loadSettings:notFound');
x = 1; %#ok<NASGU>
other = fullfile(testCase.TestData.Dir, 'other.mat');
save(other, 'x');
testCase.verifyEqual(errorId('pivlab.loadSettings', other), 'pivlab:loadSettings:unknownFile');
u_original = {1}; u_filtered = {1}; typevector_original = {1}; %#ok<NASGU>
exported = fullfile(testCase.TestData.Dir, 'exported.mat');
save(exported, 'u_original', 'u_filtered', 'typevector_original');
testCase.verifyEqual(errorId('pivlab.loadSettings', exported), 'pivlab:loadSettings:noSettings');
% PIVlab 3.x settings file (variables of the GUI controls)
clahe_enable = 1; clahe_size = 64; intarea = 64; stepsize = 32; %#ok<NASGU>
old = fullfile(testCase.TestData.Dir, 'old_settings.mat');
save(old, 'clahe_enable', 'clahe_size', 'intarea', 'stepsize');
[id, msg] = errorId('pivlab.loadSettings', old);
testCase.verifyNotEmpty(id);
testCase.verifySubstring(lower(msg), 'pivlab');
end

function test_session_with_everything(testCase)
% ROI, masks per pair, background, camera undistortion, calibration with origin and flipped axes,
% velocity limits, smoothing -> saveSession -> loadSession and GUI
files = distortionFiles(testCase.TestData.ProjectRoot, 3);
raw = pivlab.readImages(files, "pairwise");
cp = cameraModel(raw.imageSize);
imgs = pivlab.preprocess(raw, Camera=cp, CameraView="same", Verbose=false);
sz = imgs.imageSize;
m1 = false(sz); m1(300:400, 300:450) = true;
roi = [60 50 sz(2)-150 sz(1)-120];
imgs = pivlab.preprocess(imgs, Camera=cp, CameraView="same", Roi=roi, Mask={m1, {}, {'ROI_object_rectangle', [200 200 100 80]}}, ...
    Background="mean", Highpass=true, Verbose=false);
res = pivlab.analyze(imgs, Passes=3, PassSizes=[32 24 24], Verbose=false);
res = pivlab.toMetric(res, DeltaT=0.0005, PxPerMeter=8000, Origin=[100 120], XAxis="left", YAxis="up", Verbose=false);
lim = [-0.6 0.6 -0.6 0.6];
res = pivlab.filter(res, VelocityLimits=lim, StdevThreshold=6, Verbose=false);
[res, ~] = pivlab.derive(res, "vorticity", Smoothing="spatial", SmoothingStrength=1);
f = fullfile(testCase.TestData.Dir, 'everything.mat');
pivlab.saveSession(res, f, Verbose=false);
% API
[r, s] = pivlab.loadSession(f);
testCase.verifyEqual(r.px.u_raw, res.px.u_raw);
testCase.verifyEqual(r.px.u, res.px.u);
testCase.verifyEqual(r.px.u_smoothed, res.px.u_smoothed);
testCase.verifyTrue(r.smoothed);
testCase.verifyEqual(r.typevector, res.typevector);
verifyNear(testCase, r.u, res.u, 'RelTol', 1e-12);
verifyNear(testCase, r.x, res.x, 'RelTol', 1e-12);
testCase.verifyEqual(r.units, "m/s");
testCase.verifyEqual(r.images.preprocess.Roi, roi);
testCase.verifyEqual(r.images.background.A, imgs.background.A);
verifySameCamera(testCase, r.images.cam, imgs.cam);
testCase.verifyEqual(s.preprocess.Roi, roi);
testCase.verifyEqual(s.preprocess.Background, "mean");
testCase.verifyTrue(logical(s.preprocess.Highpass));
testCase.verifyEqual(s.analysis.Passes, 3);
verifyNear(testCase, s.filter.VelocityLimits, lim, 'AbsTol', 1e-12);
testCase.verifyEqual(s.derive.Smoothing, "spatial");
% the mask of every pair is back (masked vectors stay masked)
testCase.verifyEqual(r.typevector_raw == 0, res.typevector_raw == 0);
% the loaded result is analysed again with its own settings: same raw result
again = pivlab.analyze(pivlab.preprocess(r.images, Camera=f, Settings=s, Mask=r.images.mask, Verbose=false), Settings=s, Verbose=false);
testCase.verifyEqual(again.px.u_raw, res.px.u_raw);
% GUI: everything shown and used
startPIVlab();
import.load_session_Callback(1, f); drawnow;
testCase.verifyEqual(gui.retr('roirect'), roi);
testCase.verifyEqual(gui.retr('calu'), res.calibration.calu);
hc = gui.gethand;
testCase.verifyEqual(hc.x_axis_direction.Value, 2);
testCase.verifyEqual(hc.y_axis_direction.Value, 2);
testCase.verifyEqual(gui.retr('cam_use_calibration'), 1);
testCase.verifyNotEmpty(gui.retr('bg_img_A'));
masks = gui.retr('masks_in_frame');
testCase.verifyNotEmpty(masks{1});
testCase.verifyNotEmpty(masks{3});
rl = gui.retr('resultslist');
testCase.verifyEqual(rl{7,2}, res.px.u(:,:,2));
testCase.verifyEqual(rl{10,2}, res.px.u_smoothed(:,:,2));
h = gui.gethand;
testCase.verifyEqual(get(h.highpass_enable,'Value'), 1);
% display, re-analysis and validation in the GUI
set(h.fileselector,'Value',2); gui.fileselector_Callback(h.fileselector,[],[]);
gui.sliderdisp(gui.retr('pivlab_axis')); drawnow;
set(h.update_display_checkbox,'Value',0);
piv.AnalyzeAll_Callback([],[],[]);
rl = gui.retr('resultslist');
for k = 1:3
    testCase.verifyEqual(rl{3,k}, res.px.u_raw(:,:,k), sprintf('GUI re-analysis pair %d', k));
end
validate.apply_filter_all_Callback([],[],[]);
rl = gui.retr('resultslist');
testCase.verifyEqual(rl{9,1}, res.typevector(:,:,1));
closePIVlab();
end

function test_saveSession_options(testCase)
res = testCase.TestData.Res;
f = fullfile(testCase.TestData.Dir, 'verbose.mat');
out = evalc('pivlab.saveSession(res, f);');
testCase.verifySubstring(out, 'verbose.mat');
out = evalc('pivlab.saveSession(res, f, Verbose=false);');
testCase.verifyEmpty(strtrim(out));
% string file name, result without filter / calibration
pivlab.saveSession(res, string(f), Verbose=false);
r = pivlab.loadSession(string(f));
testCase.verifyEqual(r.px.u_raw, res.px.u_raw);
testCase.verifyEqual(r.units, "px/frame");
[id, msg] = errorId('pivlab.loadSession', fullfile(testCase.TestData.Dir, 'nope.mat'));
testCase.verifyNotEmpty(id);
testCase.verifySubstring(msg, 'nope.mat');
% a settings file is not a session
G = gui.default_settings;
sf = fullfile(testCase.TestData.Dir, 'only_settings.mat');
export.write_settings_file(sf, G);
testCase.verifyEqual(errorId('pivlab.loadSession', sf), 'pivlab:loadSession:notSession');
end

function test_example_scripts(testCase)
% the example scripts run from start to end (figures are closed afterwards)
root = testCase.TestData.ProjectRoot;
L = dir(fullfile(root, 'Example_scripts', 'PIVlab_api_*.m'));
testCase.verifyNotEmpty(L);
here = pwd;
cd(testCase.TestData.Dir);   % sessions written by the scripts land here
for k = 1:numel(L)
    try
        run_script(fullfile(L(k).folder, L(k).name), root);
    catch err
        testCase.verifyFail(sprintf('%s: %s', L(k).name, err.message));
    end
    close all force
end
cd(here);
end

function test_help_texts(testCase)
names = {'readImages','preprocess','getImage','analyze','filter','toMetric','derive','temporal', ...
    'display','defaults','loadSettings','loadSession','saveSession'};
txt = help('pivlab');
for k = 1:numel(names)
    testCase.verifySubstring(txt, names{k}, 'pivlab overview');
    h = help(['pivlab.' names{k}]);
    testCase.verifyGreaterThan(numel(h), 300, names{k});
    if ~strcmp(names{k}, 'defaults')   % its help shows the use without the word "Example"
        testCase.verifySubstring(h, 'Example', names{k});
    end
end
% every name=value option of a function is explained in its help text
fun = {'preprocess','analyze','filter','toMetric','derive','temporal','display','getImage','readImages','saveSession'};
for k = 1:numel(fun)
    code = fileread(fullfile(testCase.TestData.ProjectRoot, '+pivlab', [fun{k} '.m']));
    opts = regexp(code, '\n\s*opts\.(\w+)', 'tokens');
    h = help(['pivlab.' fun{k}]);
    for j = 1:numel(opts)
        testCase.verifySubstring(h, opts{j}{1}, sprintf('%s: option %s', fun{k}, opts{j}{1}));
    end
end
end

%% ------------------------------------------------------------------ helpers
function run_script(file, root)
% runs an example script in its own workspace, from the PIVlab folder (the scripts start
% with "clear", so nothing needed afterwards is kept in variables here)
setappdata(0, 'pivlab_test_here', pwd);
cd(root);
try
    run(file);
catch err
    cd(getappdata(0, 'pivlab_test_here'));
    rethrow(err);
end
cd(getappdata(0, 'pivlab_test_here'));
end

function d = spacing(res)
d = double(res.px.x(1,2) - res.px.x(1,1));
end

function x = vector_x(ax, res) %#ok<INUSD>
% x positions of the drawn (valid) vectors
x = [];
q = findobj(ax, 'Type', 'quiver');
for k = 1:numel(q)
    x = [x; q(k).XData(:)]; %#ok<AGROW>
end
end

function msg = warnings_of(id, fun, varargin)
% message of the warning id issued by fun(varargin{:}), '' if there is none
% (evalc does not see warnings in matlab -batch: they go to stderr. lastwarn also records
% warnings that are switched off, so fun must not issue other warnings after this one)
state = warning;
warning('off', 'all');
warning('on', id);
lastwarn('');
try
    feval(fun, varargin{:});
catch err
    warning(state);
    rethrow(err);
end
[msg, last] = lastwarn;
warning(state);
if ~strcmp(last, id)
    msg = '';
end
end

function [id, msg] = errorId(fun, varargin)
% identifier (and message) of the error of fun(varargin{:}), '' if there is none
id = ''; msg = '';
try
    feval(fun, varargin{:});
catch err
    id = err.identifier;
    msg = err.message;
end
end

function f = jetFiles(root, n)
f = cell(2*n,1);
for i = 1:n
    f{2*i-1} = fullfile(root,'Example_data',sprintf('Jet_%04dA.jpg',i));
    f{2*i}   = fullfile(root,'Example_data',sprintf('Jet_%04dB.jpg',i));
end
end

function f = fuerteventuraFiles(root, n)
f = cell(n,1);
for i = 1:n
    f{i} = fullfile(root,'Example_data',sprintf('Fuerteventura_%06d.jpeg',i-1));
end
end

function f = distortionFiles(root, n)
f = cell(2*n,1);
for i = 1:n
    f{2*i-1} = fullfile(root,'Example_data','worst_case_distortion',sprintf('PIVlab_%04d_A.jpg',i-1));
    f{2*i}   = fullfile(root,'Example_data','worst_case_distortion',sprintf('PIVlab_%04d_B.jpg',i-1));
end
end

function cp = cameraModel(sz)
f = 0.9*sz(2);
K = [f 0 sz(2)/2; 0 f sz(1)/2; 0 0 1];
cp = cameraParameters('K', K, 'RadialDistortion', [-0.25 0.06], 'ImageSize', sz);
end

function verifySameCamera(testCase, a, b)
testCase.verifyEqual(rmfield(a, 'cameraParams'), rmfield(b, 'cameraParams'));
names = {'K', 'RadialDistortion', 'TangentialDistortion', 'ImageSize'};
for k = 1:numel(names)
    testCase.verifyEqual(a.cameraParams.(names{k}), b.cameraParams.(names{k}), names{k});
end
end

function startPIVlab()
closePIVlab();
PIVlab_GUI(1); drawnow;
gui.put('batchModeActive',1);
end

function closePIVlab()
hgui = getappdata(0,'hgui');
if ~isempty(hgui) && ishghandle(hgui)
    try, gui.put('batchModeActive',1); catch, end
    try, delete(hgui); catch, close(hgui,'force'); end
end
setappdata(0,'hgui',[]);
if isappdata(0, 'pivlab_test_warning_state')
    warning(getappdata(0, 'pivlab_test_warning_state'));   % PIVlab_GUI switched all warnings off
end
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

function verifyNear(testCase, a, b, varargin)
% verifyEqual with a tolerance, also for single values (verifyEqual ignores tolerances for single)
testCase.verifyEqual(double(a), double(b), varargin{:});
end
