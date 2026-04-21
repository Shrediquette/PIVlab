%% Integration tests for piv.piv_FFTmulti
%
% All tests call piv.piv_FFTmulti end-to-end with synthetic data so that any
% breakage inside the function (including helper subfunctions) causes failures
% here. No private subfunctions are accessed directly.
%
% Run with:
%   runtests('C:\...\unittests\test_piv_FFTmulti.m')

function tests = test_piv_FFTmulti
tests = functiontests(localfunctions);
end

function setup(testCase)
% Ensure the PIVlab root is on the path (needed when tests run headlessly)
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(projectRoot);

% Synthetic 160x160 image pair with a known integer-pixel uniform shift.
% medfilt2 gives the image enough low-frequency structure for a strong FFT
% correlation peak while keeping the image cheap to generate.
rng(42);
N   = 160;
raw = rand(N);
A   = medfilt2(raw, [5 5], 'symmetric');
B   = circshift(A, [3, -7]);   % known shift: v = +3 px, u = -7 px
testCase.TestData.A      = A;
testCase.TestData.B      = B;
testCase.TestData.u_true = -7;
testCase.TestData.v_true =  3;
end

% -------------------------------------------------------------------------
% Single-pass analysis — different image types
% piv_FFTmulti returns single-precision; cast medians to double before
% comparing with the double-typed expected values.
% -------------------------------------------------------------------------

function test_single_pass_double(testCase)
[~,~,u,v] = piv.piv_FFTmulti( ...
	image1=testCase.TestData.A, image2=testCase.TestData.B, ...
	interrogationarea=32, passes=1);
testCase.verifyFalse(any(isnan(u(:))), 'u contains NaN (double input)');
testCase.verifyFalse(any(isnan(v(:))), 'v contains NaN (double input)');
testCase.verifyEqual(double(median(u(:))), testCase.TestData.u_true, 'AbsTol', 1.5, ...
	'Single-pass double: u does not match expected shift');
testCase.verifyEqual(double(median(v(:))), testCase.TestData.v_true, 'AbsTol', 1.5, ...
	'Single-pass double: v does not match expected shift');
end

function test_single_pass_uint8(testCase)
A8 = uint8(testCase.TestData.A * 255);
B8 = uint8(testCase.TestData.B * 255);
[~,~,u,v] = piv.piv_FFTmulti( ...
	image1=A8, image2=B8, interrogationarea=32, passes=1);
testCase.verifyFalse(any(isnan(u(:))), 'u contains NaN (uint8 input)');
testCase.verifyEqual(double(median(u(:))), testCase.TestData.u_true, 'AbsTol', 1.5, ...
	'Single-pass uint8: shift not correctly detected');
end

function test_single_pass_uint16(testCase)
A16 = uint16(testCase.TestData.A * 65535);
B16 = uint16(testCase.TestData.B * 65535);
[~,~,u,v] = piv.piv_FFTmulti( ...
	image1=A16, image2=B16, interrogationarea=32, passes=1);
testCase.verifyFalse(any(isnan(u(:))), 'u contains NaN (uint16 input)');
testCase.verifyEqual(double(median(u(:))), testCase.TestData.u_true, 'AbsTol', 1.5, ...
	'Single-pass uint16: shift not correctly detected');
end

% -------------------------------------------------------------------------
% Multi-pass analysis — should converge to tighter accuracy.
% 2-pass pyramid: ia=64 -> ia=32, step=16 throughout (>= 50% overlap).
% IA must exceed step on every pass to avoid deformation NaN at borders.
% -------------------------------------------------------------------------

function test_multi_pass_double(testCase)
[~,~,u,v] = piv.piv_FFTmulti( ...
	image1=testCase.TestData.A, image2=testCase.TestData.B, ...
	interrogationarea=64, step=32, passes=2, int2=32, int3=0, int4=0);
testCase.verifyFalse(any(isnan(u(:))), 'u contains NaN (multi-pass)');
testCase.verifyEqual(double(median(u(:))), testCase.TestData.u_true, 'AbsTol', 0.5, ...
	'Multi-pass u should converge closer to the true shift');
testCase.verifyEqual(double(median(v(:))), testCase.TestData.v_true, 'AbsTol', 0.5, ...
	'Multi-pass v should converge closer to the true shift');
end

% -------------------------------------------------------------------------
% Correlation map output (6th return value) — exercises calculate_correlation_map.
% On a 1-pass analysis the interrogation windows are not pre-deformed, so the
% Pearson correlation between windows from a circshift image pair is near zero.
% Verify only that the output exists and contains valid Pearson values in [-1,1].
% -------------------------------------------------------------------------

function test_correlation_map_output(testCase)
[~,~,~,~,~, corr_map] = piv.piv_FFTmulti( ...
	image1=testCase.TestData.A, image2=testCase.TestData.B, ...
	interrogationarea=32, passes=1);
testCase.verifyNotEmpty(corr_map, 'Correlation map is empty');
testCase.verifyTrue(all(double(corr_map(:)) >= -1 & double(corr_map(:)) <= 1), ...
	'Correlation map values outside valid Pearson range [-1, 1]');
end

% -------------------------------------------------------------------------
% Error handling — missing required arguments
% -------------------------------------------------------------------------

function test_missing_required_args_throws(testCase)
testCase.verifyError( ...
	@() piv.piv_FFTmulti(interrogationarea=32), ...
	'piv:piv_FFTmulti:MissingRequiredInputs');
end
