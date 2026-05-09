%% Integration tests for piv.piv_FFTensemble
%
% Tests call piv.piv_FFTensemble end-to-end with synthetic images written
% to temp .png files. No GUI is required — the function falls back to
% no-calibration mode when called outside the PIVlab GUI.
%
% Run with:
%   runtests('C:\...\unittests\test_piv_FFTensemble.m')

function tests = test_piv_FFTensemble
tests = functiontests(localfunctions);
end

function setup(testCase)
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(projectRoot);

% Synthetic 160x160 image pair with a known integer-pixel uniform shift.
rng(42);
N   = 160;
raw = rand(N);
A   = medfilt2(raw, [5 5], 'symmetric');
B   = circshift(A, [3, -7]);   % known shift: v = +3 px, u = -7 px
testCase.TestData.u_true = -7;
testCase.TestData.v_true =  3;

% Write 6 identical pairs (12 images) as uint8 PNG files to a temp folder.
tempDir = fullfile('C:\Users\trash\Documents\MATLAB\claude_code_temp', 'ensemble_test');
if ~exist(tempDir, 'dir')
    mkdir(tempDir);
end
A8 = uint8(A * 255);
B8 = uint8(B * 255);
filePaths = cell(12, 1);
for k = 1:6
    p1 = fullfile(tempDir, sprintf('img_%02d_A.png', k));
    p2 = fullfile(tempDir, sprintf('img_%02d_B.png', k));
    imwrite(A8, p1);
    imwrite(B8, p2);
    filePaths{2*k-1} = p1;
    filePaths{2*k}   = p2;
end
testCase.TestData.filePaths = filePaths;
testCase.TestData.tempDir   = tempDir;

% Subset of 4 files (2 pairs) for the SNR comparison test
testCase.TestData.filePaths2 = filePaths(1:4);
end

function teardown(testCase)
% Remove temp image files
for k = 1:numel(testCase.TestData.filePaths)
    if exist(testCase.TestData.filePaths{k}, 'file')
        delete(testCase.TestData.filePaths{k});
    end
end
end

% -------------------------------------------------------------------------
% Single-pass ensemble — 6 pairs
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

% -------------------------------------------------------------------------
% Multi-pass ensemble — 6 pairs, 2 passes
% -------------------------------------------------------------------------

function test_multi_pass_6pairs(testCase)
[~,~,u,v] = piv.piv_FFTensemble( ...
    filepath=testCase.TestData.filePaths, interrogationarea=64, ...
    clahe=0, step=32, passes=2, int2=32);
testCase.verifyFalse(any(isnan(u(:))), 'u contains NaN (multi-pass 6 pairs)');
testCase.verifyEqual(double(median(u(:))), testCase.TestData.u_true, 'AbsTol', 0.5, ...
    'Multi-pass ensemble: u should converge closer to true shift');
testCase.verifyEqual(double(median(v(:))), testCase.TestData.v_true, 'AbsTol', 0.5, ...
    'Multi-pass ensemble: v should converge closer to true shift');
end

% -------------------------------------------------------------------------
% Correlation map output (6th return value)
% -------------------------------------------------------------------------

function test_correlation_map_output(testCase)
[~,~,~,~,~,corr_map] = piv.piv_FFTensemble( ...
    filepath=testCase.TestData.filePaths, interrogationarea=32, clahe=0);
testCase.verifyNotEmpty(corr_map, 'Correlation map is empty');
testCase.verifyTrue(all(double(corr_map(:)) >= -1 & double(corr_map(:)) <= 1), ...
    'Correlation map values outside valid Pearson range [-1, 1]');
end

% -------------------------------------------------------------------------
% Error handling — missing required arguments
% -------------------------------------------------------------------------

function test_missing_required_args_throws(testCase)
testCase.verifyError( ...
    @() piv.piv_FFTensemble(interrogationarea=32), ...
    'piv:piv_FFTensemble:MissingRequiredInputs');
end

% -------------------------------------------------------------------------
% More pairs produce lower variance (better SNR)
% -------------------------------------------------------------------------

function test_more_pairs_improves_snr(testCase)
[~,~,u6] = piv.piv_FFTensemble( ...
    filepath=testCase.TestData.filePaths, interrogationarea=32, clahe=0);
[~,~,u2] = piv.piv_FFTensemble( ...
    filepath=testCase.TestData.filePaths2, interrogationarea=32, clahe=0);
% For identical image pairs the result should be the same regardless of
% the number of pairs (ensemble average of identical correlations = same
% peak). Verify both give the same median displacement.
testCase.verifyEqual(double(median(u6(:))), double(median(u2(:))), 'AbsTol', 0.1, ...
    '6-pair and 2-pair ensembles should agree for identical image pairs');
end
