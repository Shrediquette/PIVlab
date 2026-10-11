%% Tests of piv.piv_FFTmulti (FFT window deformation) with synthetic data, no GUI
%
% All tests call piv.piv_FFTmulti end-to-end, so any breakage inside the function (including its
% subfunctions) causes failures here.
%
% Run with:
%   runtests('unittests/test_core_piv_fftmulti.m')

function tests = test_core_piv_fftmulti
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
addpath(helper_root());
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
% Single-pass analysis - different image types
% piv_FFTmulti returns single precision; the medians are cast to double before
% comparing with the double expected values.
% -------------------------------------------------------------------------

function test_single_pass_double(testCase)
[~,~,u,v] = piv.piv_FFTmulti( ...
	image1=testCase.TestData.A, image2=testCase.TestData.B, ...
	interrogationarea=32, passes=1);
verify_shift(testCase, u, v, 1.5, 'single pass, double');
end

function test_single_pass_uint8(testCase)
A8 = uint8(testCase.TestData.A * 255);
B8 = uint8(testCase.TestData.B * 255);
[~,~,u,v] = piv.piv_FFTmulti(image1=A8, image2=B8, interrogationarea=32, passes=1);
verify_shift(testCase, u, v, 1.5, 'single pass, uint8');
end

function test_single_pass_uint16(testCase)
A16 = uint16(testCase.TestData.A * 65535);
B16 = uint16(testCase.TestData.B * 65535);
[~,~,u,v] = piv.piv_FFTmulti(image1=A16, image2=B16, interrogationarea=32, passes=1);
verify_shift(testCase, u, v, 1.5, 'single pass, uint16');
end

% -------------------------------------------------------------------------
% Multi-pass analysis - converges to a tighter accuracy.
% 2-pass pyramid: ia=64 -> ia=32, step=32 -> 16. IA must exceed step on every pass
% to avoid deformation NaN at the borders.
% -------------------------------------------------------------------------

function test_multi_pass_double(testCase)
[~,~,u,v] = piv.piv_FFTmulti( ...
	image1=testCase.TestData.A, image2=testCase.TestData.B, ...
	interrogationarea=64, step=32, passes=2, int2=32, int3=0, int4=0);
verify_shift(testCase, u, v, 0.5, 'multi pass');
end

% -------------------------------------------------------------------------
% Correlation map output (6th return value) - exercises calculate_correlation_map.
% On a 1-pass analysis the interrogation windows are not pre-deformed, so the
% Pearson correlation between windows of a circshift image pair is near zero.
% Only checked: the output exists and contains valid Pearson values in [-1, 1].
% -------------------------------------------------------------------------

function test_correlation_map_output(testCase)
[~,~,u,~,~, corr_map] = piv.piv_FFTmulti( ...
	image1=testCase.TestData.A, image2=testCase.TestData.B, ...
	interrogationarea=32, passes=1);
testCase.verifyEqual(size(corr_map), size(u), 'Correlation map has another size than the vector field');
testCase.verifyTrue(all(double(corr_map(:)) >= -1 & double(corr_map(:)) <= 1), ...
	'Correlation map values outside valid Pearson range [-1, 1]');
end

% -------------------------------------------------------------------------
% Mask: a vector is masked when the mask is true at its position
% -------------------------------------------------------------------------

function test_mask_at_the_vector_positions(testCase)
verify_mask_at_vector_positions(testCase, [], 'without ROI');
end

function test_mask_with_roi_at_the_vector_positions(testCase)
% until 2026-10-11 the vector positions were 1 px too far right / down with a ROI
verify_mask_at_vector_positions(testCase, [20 20 300 220], 'with ROI');
end

% -------------------------------------------------------------------------
% Error handling - missing required arguments
% -------------------------------------------------------------------------

function test_missing_required_args_throws(testCase)
id = helper_error_id('piv.piv_FFTmulti', 'interrogationarea', 32);
testCase.verifyEqual(id, 'piv:piv_FFTmulti:MissingRequiredInputs');
end

% -------------------------------------------------------------------------
% Second-peak outputs (utable2 / vtable2)
% -------------------------------------------------------------------------

function test_second_peak_nonnull_multipass(testCase)
% On a multi-pass run the second peak must be computed and returned
[~,~,u,~,~,~,~,~,u2,v2] = piv.piv_FFTmulti( ...
	image1=testCase.TestData.A, image2=testCase.TestData.B, ...
	interrogationarea=64, step=32, passes=2, int2=32, int3=0, int4=0);
testCase.verifyEqual(size(u2), size(u), 'utable2 must be the same size as utable');
testCase.verifyEqual(size(v2), size(u), 'vtable2 must be the same size as utable');
testCase.verifyTrue(any(~isnan(u2(:))), 'utable2 is entirely NaN (multi-pass)');
testCase.verifyTrue(any(~isnan(v2(:))), 'vtable2 is entirely NaN (multi-pass)');
end

function test_second_peak_nonnull_singlepass(testCase)
% Single pass is the final (and only) pass, so second peaks must also be returned
[~,~,u,~,~,~,~,~,u2,v2] = piv.piv_FFTmulti( ...
	image1=testCase.TestData.A, image2=testCase.TestData.B, ...
	interrogationarea=32, passes=1);
testCase.verifyEqual(size(u2), size(u), 'utable2 must be the same size as utable');
testCase.verifyEqual(size(v2), size(u), 'vtable2 must be the same size as utable');
testCase.verifyTrue(any(~isnan(u2(:))), 'utable2 is entirely NaN (single-pass)');
end

function test_second_peak_differs_from_first(testCase)
% The second-peak displacement must differ from the first peak at most positions.
% If they are identical everywhere the suppression of the first peak is broken.
[~,~,u,v,~,~,~,~,u2,v2] = piv.piv_FFTmulti( ...
	image1=testCase.TestData.A, image2=testCase.TestData.B, ...
	interrogationarea=64, step=32, passes=2, int2=32, int3=0, int4=0);
valid = ~isnan(u2) & ~isnan(v2);
fraction_different_u = sum(u(valid) ~= u2(valid), 'all') / sum(valid(:));
fraction_different_v = sum(v(valid) ~= v2(valid), 'all') / sum(valid(:));
testCase.verifyGreaterThan(fraction_different_u, 0.5, ...
	'utable2 should differ from utable at the majority of positions');
testCase.verifyGreaterThan(fraction_different_v, 0.5, ...
	'vtable2 should differ from vtable at the majority of positions');
end

% -------------------------------------------------------------------------
% Helpers
% -------------------------------------------------------------------------

function verify_shift(testCase, u, v, tol, what)
testCase.verifyFalse(any(isnan(u(:))), ['u contains NaN: ' what]);
testCase.verifyFalse(any(isnan(v(:))), ['v contains NaN: ' what]);
testCase.verifyEqual(double(median(u(:))), testCase.TestData.u_true, 'AbsTol', tol, ['u shift: ' what]);
testCase.verifyEqual(double(median(v(:))), testCase.TestData.v_true, 'AbsTol', tol, ['v shift: ' what]);
end

function verify_mask_at_vector_positions(testCase, roi, what)
% mask edges exactly on vector positions (vectors every 8 px at 31, 39, ... with this ROI), both passes
rng(1);
A = imgaussfilt(rand(400), 1);
B = circshift(A, [1 2]);
m = false(400);
m(31:63, 31:71) = true;
for passes = [1 4]
    [x, y, ~, ~, tv] = piv.piv_FFTmulti(image1=A, image2=B, interrogationarea=16*(1 + 3*(passes > 1)), ...
        step=8*(1 + 3*(passes > 1)), passes=passes, int2=32, int3=16, int4=16, mask_inpt=m, roi_inpt=roi);
    inside = m(sub2ind(size(m), round(y), round(x)));
    testCase.assertTrue(any(inside(:)) && any(~inside(:)), 'test setup: the mask must cover a part of the vectors');
    testCase.verifyEqual(tv == 0, inside, sprintf('%s, %d passes: masked vectors (typevector 0) are not the vectors in the mask', what, passes));
end
end
