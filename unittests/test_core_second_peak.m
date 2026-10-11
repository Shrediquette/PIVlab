%% Tests of the second-peak vector substitution in validate.filtervectors_all_parallel, no GUI
%
% A vector rejected by the validation is replaced by the displacement of the second correlation
% peak (u2, v2) if that one passes the validation (typevector 3).
%
% Run with:
%   runtests('unittests/test_core_second_peak.m')

function tests = test_core_second_peak
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
addpath(helper_root());
% 5x5 uniform flow field u = 3, v = 2, with one outlier u = 50 at (3,3)
N = 5;
[x, y] = meshgrid(1:N, 1:N);
u = single(3 * ones(N));
v = single(2 * ones(N));
u(3,3) = 50;
testCase.TestData.N = N;
testCase.TestData.x = single(x);
testCase.TestData.y = single(y);
testCase.TestData.u = u;
testCase.TestData.v = v;
testCase.TestData.typevector_original = ones(N, 'single');
end

% -------------------------------------------------------------------------

function test_substitution_replaces_bad_vector(testCase)
% the outlier is rejected; the correct second peak there is used (typevector 3)
[u2, v2] = no_second_peaks(testCase);
u2(3,3) = 3;
v2(3,3) = 2;
[u_out, v_out, tv] = run_filter(testCase, testCase.TestData.typevector_original, u2, v2);
testCase.verifyEqual(double(tv(3,3)), 3, ...
	'Outlier position should be typevector 3 after second-peak substitution');
testCase.verifyEqual(double([u_out(3,3) v_out(3,3)]), [3 2], 'AbsTol', 1e-6, ...
	'The second-peak displacement must be used at the outlier position');
end

function test_no_substitution_when_u2_nan(testCase)
% all-NaN u2/v2 (no second peak available): the outlier stays rejected
[u2, v2] = no_second_peaks(testCase);
[u_out, v_out, tv] = run_filter(testCase, testCase.TestData.typevector_original, u2, v2);
testCase.verifyEqual(double(tv(3,3)), 2, 'Outlier with no u2/v2 must remain rejected (typevector 2)');
testCase.verifyTrue(isnan(u_out(3,3)) | isnan(v_out(3,3)), 'Outlier without second peak must remain NaN');
end

function test_no_substitution_when_u2v2_empty(testCase)
% empty u2/v2 (result without second peaks): no error, same as all-NaN
[u_out, v_out, tv] = run_filter(testCase, testCase.TestData.typevector_original, [], []);
testCase.verifyEqual(double(tv(3,3)), 2, 'Outlier must remain rejected when u2/v2 are empty');
testCase.verifyTrue(isnan(u_out(3,3)) | isnan(v_out(3,3)), 'Outlier must remain NaN when u2/v2 are empty');
end

function test_bad_second_peak_stays_rejected(testCase)
% a second peak that is an outlier as well is not used
[u2, v2] = no_second_peaks(testCase);
u2(3,3) = 80;
v2(3,3) = 2;
[~, ~, tv] = run_filter(testCase, testCase.TestData.typevector_original, u2, v2);
testCase.verifyEqual(double(tv(3,3)), 2, 'A bad second-peak candidate must stay rejected (typevector 2)');
end

function test_masked_positions_not_substituted(testCase)
% masked vectors (typevector_original 0) never receive a substitution
typevector_original = testCase.TestData.typevector_original;
typevector_original(3,3) = 0;
[u2, v2] = no_second_peaks(testCase);
u2(3,3) = 3;
v2(3,3) = 2;
[~, ~, tv] = run_filter(testCase, typevector_original, u2, v2);
testCase.verifyEqual(double(tv(3,3)), 0, 'Masked position must remain typevector 0');
end

function test_valid_vectors_unchanged(testCase)
% vectors that pass the validation are not touched by the substitution
N = testCase.TestData.N;
u2 = 3 * ones(N, 'single');
v2 = 2 * ones(N, 'single');
u2(1,1) = 7;   % a different second peak at a good vector
[u_out, v_out, tv] = run_filter(testCase, testCase.TestData.typevector_original, u2, v2);
good = true(N);
good(3,3) = false;
testCase.verifyTrue(all(tv(good) == 1), 'Good primary vectors must keep typevector 1');
testCase.verifyEqual(double(u_out(good)), double(testCase.TestData.u(good)), 'Good u values must not change');
testCase.verifyEqual(double(v_out(good)), double(testCase.TestData.v(good)), 'Good v values must not change');
end

% -------------------------------------------------------------------------
% Helpers
% -------------------------------------------------------------------------

function [u2, v2] = no_second_peaks(testCase)
N = testCase.TestData.N;
u2 = nan(N, 'single');
v2 = nan(N, 'single');
end

function [u_out, v_out, tv_out] = run_filter(testCase, typevector_original, u2, v2)
% validate.filtervectors_all_parallel with standard deviation and local median filter (tight
% thresholds), all image-based filters off, no interpolation
td = testCase.TestData;
[u_out, v_out, tv_out] = validate.filtervectors_all_parallel( ...
	td.x, td.y, td.u, td.v, typevector_original, ...
	1, 1, [], ...                        % calu, calv, velrect
	1, 3, ...                            % stdev check, threshold
	1, 2, ...                            % local median, threshold
	0, 0, 0, 0, ...                      % contrast and brightness filters
	0, [], [], [], [], ...               % interpolation, images
	0, 0, [], ...                        % correlation filter
	0, 0, 0, [], ...                     % notch filter, roi_freehand
	u2, v2);
end
