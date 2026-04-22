%% Unit tests for opencv.opencv_undistort — multi-type support
%
% Tests that opencv_undistort correctly handles uint8, uint16, double, and
% single input images, preserving the output class and — critically — NOT
% rescaling pixel values (a narrow uint16 range like [65500,65535] must
% survive the undistortion unchanged).
%
% Run with:
%   runtests('unittests/test_opencv_undistort')

function tests = test_opencv_undistort
tests = functiontests(localfunctions);
end

function setup(testCase)
% Ensure the PIVlab root (which contains +opencv/) is on the path
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(projectRoot);
% Synthetic 100x100 camera with mild barrel distortion.
% K is in OpenCV format: [fx 0 cx; 0 fy cy; 0 0 1]
testCase.TestData.K = [80  0  50;
                        0 80  50;
                        0  0   1];
testCase.TestData.D = [-0.1 0.05 0 0];  % [k1 k2 p1 p2]
testCase.TestData.H = 100;
testCase.TestData.W = 100;
end

% -------------------------------------------------------------------------
% Output class must match input class
% -------------------------------------------------------------------------

function testOutputClassUint8(testCase)
img = uint8(randi(255, testCase.TestData.H, testCase.TestData.W));
out = opencv.opencv_undistort(img, testCase.TestData.K, testCase.TestData.D);
testCase.verifyClass(out, 'uint8', 'uint8 input should produce uint8 output');
end

function testOutputClassUint16(testCase)
img = uint16(randi(65535, testCase.TestData.H, testCase.TestData.W));
out = opencv.opencv_undistort(img, testCase.TestData.K, testCase.TestData.D);
testCase.verifyClass(out, 'uint16', 'uint16 input should produce uint16 output');
end

function testOutputClassDouble(testCase)
img = rand(testCase.TestData.H, testCase.TestData.W);
out = opencv.opencv_undistort(img, testCase.TestData.K, testCase.TestData.D);
testCase.verifyClass(out, 'double', 'double input should produce double output');
end

function testOutputClassSingle(testCase)
img = single(rand(testCase.TestData.H, testCase.TestData.W));
out = opencv.opencv_undistort(img, testCase.TestData.K, testCase.TestData.D);
testCase.verifyClass(out, 'single', 'single input should produce single output');
end

% -------------------------------------------------------------------------
% Output size must match input size (default 'same' view)
% -------------------------------------------------------------------------

function testOutputSizeMatchesInput(testCase)
H = testCase.TestData.H; W = testCase.TestData.W;
img = uint8(randi(255, H, W));
out = opencv.opencv_undistort(img, testCase.TestData.K, testCase.TestData.D);
testCase.verifySize(out, [H W], 'Output size should match input size for view=same');
end

% -------------------------------------------------------------------------
% Narrow pixel-range preservation — the critical PIV use-case.
% A MATLAB im2uint8-based approach would destroy images like these because
% im2uint8 rescales the entire [0,65535] range to [0,255].
% -------------------------------------------------------------------------

function testNarrowRangeUint16IsPreserved(testCase)
% All pixels in [65500, 65535] — extremely narrow range at the top of uint16.
H = testCase.TestData.H; W = testCase.TestData.W;
img = uint16(65500 + uint16(randi(36, H, W) - 1));
out = opencv.opencv_undistort(img, testCase.TestData.K, testCase.TestData.D);
% Check interior crop only — border pixels may be zero-filled by remap.
crop = out(10:end-10, 10:end-10);
testCase.verifyGreaterThan(double(min(crop(:))), 60000, ...
    'uint16 narrow range was not preserved — pixel values appear to have been rescaled');
end

function testNarrowRangeDoubleIsPreserved(testCase)
% All pixels near 0.95 — would map to ~242/255 in uint8, destroying detail.
H = testCase.TestData.H; W = testCase.TestData.W;
img = 0.95 + 0.05 * rand(H, W);
out = opencv.opencv_undistort(img, testCase.TestData.K, testCase.TestData.D);
crop = out(10:end-10, 10:end-10);
testCase.verifyGreaterThan(min(crop(:)), 0.8, ...
    'double narrow range was not preserved — pixel values appear to have been rescaled');
end

% -------------------------------------------------------------------------
% Geometric equivalence with MATLAB undistortImage for uint8 images.
% Both apply the same lens model, so interior pixels should agree within
% a few DN (differences come from interpolation kernel differences).
% -------------------------------------------------------------------------

function testCompareWithMatlabUndistortUint8(testCase)
H = testCase.TestData.H; W = testCase.TestData.W;
K = testCase.TestData.K; D_vec = testCase.TestData.D;

% MATLAB cameraParameters uses a transposed IntrinsicMatrix convention:
%   K_matlab = [fx 0 0; 0 fy 0; cx cy 1]   (columns are rows of OpenCV K)
K_ml = [K(1,1) 0 0; 0 K(2,2) 0; K(1,3) K(2,3) 1];
params = cameraParameters( ...
    'IntrinsicMatrix',      K_ml, ...
    'RadialDistortion',     D_vec(1:2), ...
    'TangentialDistortion', D_vec(3:4), ...
    'ImageSize',            [H W]);

rng(42);
img = uint8(randi(200, H, W) + 28);  % avoid all-zero border ambiguity

out_opencv = opencv.opencv_undistort(img, K, D_vec);
% Use 'cubic' to match OpenCV's INTER_CUBIC; 'linear' would inflate the error.
out_matlab  = undistortImage(img, params, 'cubic', 'OutputView', 'same');

% Compare interior pixels — border treatment differs between implementations.
crop_cv = double(out_opencv(10:end-10, 10:end-10));
crop_ml = double(out_matlab( 10:end-10, 10:end-10));
mae = mean(abs(crop_cv(:) - crop_ml(:)));
testCase.verifyLessThan(mae, 8, ...
    sprintf('opencv and MATLAB undistortion differ by %.2f DN (mean abs error) — expected < 8 DN', mae));
end
