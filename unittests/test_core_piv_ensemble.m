%% Tests of piv.piv_FFTensemble (ensemble correlation) with synthetic images, no GUI
%
% The synthetic images are written to temporary .png files. Without the PIVlab window the function
% works without calibration.
%
% Run with:
%   runtests('unittests/test_core_piv_ensemble.m')

function tests = test_core_piv_ensemble
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
addpath(helper_root());
% Synthetic 160x160 image pair with a known integer-pixel uniform shift.
rng(42);
N   = 160;
raw = rand(N);
A   = medfilt2(raw, [5 5], 'symmetric');
B   = circshift(A, [3, -7]);   % known shift: v = +3 px, u = -7 px
testCase.TestData.u_true = -7;
testCase.TestData.v_true =  3;
% 6 identical pairs (12 images) as uint8 PNG files in a temporary folder
folder = tempname(tempdir);
mkdir(folder);
A8 = uint8(A * 255);
B8 = uint8(B * 255);
filePaths = cell(12, 1);
for k = 1:6
    p1 = fullfile(folder, sprintf('img_%02d_A.png', k));
    p2 = fullfile(folder, sprintf('img_%02d_B.png', k));
    imwrite(A8, p1);
    imwrite(B8, p2);
    filePaths{2*k-1} = p1;
    filePaths{2*k}   = p2;
end
testCase.TestData.filePaths = filePaths;
testCase.TestData.folder = folder;
end

function teardownOnce(testCase)
try
    rmdir(testCase.TestData.folder, 's');
catch
end
end

% -------------------------------------------------------------------------
% Single-pass and multi-pass ensemble of 6 pairs
% -------------------------------------------------------------------------

function test_single_pass_6pairs(testCase)
[~,~,u,v] = piv.piv_FFTensemble( ...
    filepath=testCase.TestData.filePaths, interrogationarea=32, ...
    clahe=0, passes=1);
testCase.verifyFalse(any(isnan(u(:))), 'u contains NaN (single-pass 6 pairs)');
testCase.verifyFalse(any(isnan(v(:))), 'v contains NaN (single-pass 6 pairs)');
testCase.verifyEqual(double(median(u(:))), testCase.TestData.u_true, 'AbsTol', 1.5, ...
    'Single-pass ensemble: u does not match expected shift');
testCase.verifyEqual(double(median(v(:))), testCase.TestData.v_true, 'AbsTol', 1.5, ...
    'Single-pass ensemble: v does not match expected shift');
end

function test_multi_pass_6pairs(testCase)
[~,~,u,v] = piv.piv_FFTensemble( ...
    filepath=testCase.TestData.filePaths, interrogationarea=64, ...
    clahe=0, step=32, passes=2, int2=32);
testCase.verifyFalse(any(isnan(u(:))), 'u contains NaN (multi-pass 6 pairs)');
testCase.verifyFalse(any(isnan(v(:))), 'v contains NaN (multi-pass 6 pairs)');
testCase.verifyEqual(double(median(u(:))), testCase.TestData.u_true, 'AbsTol', 0.5, ...
    'Multi-pass ensemble: u should converge closer to true shift');
testCase.verifyEqual(double(median(v(:))), testCase.TestData.v_true, 'AbsTol', 0.5, ...
    'Multi-pass ensemble: v should converge closer to true shift');
end

% -------------------------------------------------------------------------
% Correlation map output (6th return value)
% -------------------------------------------------------------------------

function test_correlation_map_output(testCase)
[~,~,u,~,~,corr_map] = piv.piv_FFTensemble( ...
    filepath=testCase.TestData.filePaths, interrogationarea=32, clahe=0);
testCase.verifyEqual(size(corr_map), size(u), 'Correlation map has another size than the vector field');
testCase.verifyTrue(all(double(corr_map(:)) >= -1 & double(corr_map(:)) <= 1), ...
    'Correlation map values outside valid Pearson range [-1, 1]');
end

% -------------------------------------------------------------------------
% Error handling - missing required arguments
% -------------------------------------------------------------------------

function test_missing_required_args_throws(testCase)
id = helper_error_id('piv.piv_FFTensemble', 'interrogationarea', 32);
testCase.verifyEqual(id, 'piv:piv_FFTensemble:MissingRequiredInputs');
end

% -------------------------------------------------------------------------
% Number of pairs
% -------------------------------------------------------------------------

function test_identical_pairs_give_the_same_result(testCase)
% For identical image pairs the ensemble average of the correlations is the same correlation, so
% 6 pairs and 2 pairs must give the same displacement.
[~,~,u6] = piv.piv_FFTensemble( ...
    filepath=testCase.TestData.filePaths, interrogationarea=32, clahe=0);
[~,~,u2] = piv.piv_FFTensemble( ...
    filepath=testCase.TestData.filePaths(1:4), interrogationarea=32, clahe=0);
testCase.verifyEqual(double(median(u6(:))), double(median(u2(:))), 'AbsTol', 0.1, ...
    '6-pair and 2-pair ensembles should agree for identical image pairs');
end
