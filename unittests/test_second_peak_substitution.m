%% Unit tests for second-peak vector substitution in filtervectors_all_parallel
%
% Tests validate.filtervectors_all_parallel directly with synthetic data,
% without needing the GUI. The two new parameters (u2, v2) added to the
% function signature are exercised here.
%
% Run with:
%   runtests('C:\...\unittests\test_second_peak_substitution.m')

function tests = test_second_peak_substitution
tests = functiontests(localfunctions);
end

function setup(testCase)
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(projectRoot);

% 5x5 uniform flow field: u=3, v=2 everywhere
N = 5;
[x, y] = meshgrid(1:N, 1:N);
u = single(3 * ones(N));
v = single(2 * ones(N));
typevector_original = ones(N, 'single');

% Introduce one outlier at (3,3): u=50 (far outside the field)
u(3,3) = 50;

testCase.TestData.x = single(x);
testCase.TestData.y = single(y);
testCase.TestData.u = u;
testCase.TestData.v = v;
testCase.TestData.typevector_original = typevector_original;

% Validation parameters: local median + stdev both active, tight thresholds
testCase.TestData.calu = 1;
testCase.TestData.calv = 1;
testCase.TestData.velrect = [];
testCase.TestData.do_stdev_check = 1;
testCase.TestData.stdthresh = 3;
testCase.TestData.do_local_median = 1;
testCase.TestData.neigh_thresh = 2;
testCase.TestData.interpol_missing = 0;
end

% Helper: call filtervectors_all_parallel with all optional image-based filters off
function [u_out, v_out, tv_out] = run_filter(tc, u2, v2)
td = tc.TestData;
u_out = []; v_out = []; tv_out = [];
try
	[u_out, v_out, tv_out] = validate.filtervectors_all_parallel( ...
		td.x, td.y, td.u, td.v, td.typevector_original, ...
		td.calu, td.calv, td.velrect, ...
		td.do_stdev_check, td.stdthresh, ...
		td.do_local_median, td.neigh_thresh, ...
		0, 0, 0, 0, ...                      % do_contrast, do_bright, thresholds
		td.interpol_missing, [], [], [], [], ... % interpol, images
		0, 0, [], ...                        % corr2 filter
		0, 0, 0, [], ...                     % notch filter, roi_freehand
		u2, v2);
catch ME
	tc.verifyFail(['filtervectors_all_parallel threw: ' ME.message]);
end
end

% -------------------------------------------------------------------------

function test_substitution_replaces_bad_vector(testCase)
% The outlier at (3,3) should be rejected by primary validation.
% Providing a valid second-peak u2/v2=3/2 there should cause substitution
% and typevector==3 at that position.
N = 5;
u2 = nan(N, 'single');
v2 = nan(N, 'single');
u2(3,3) = 3;   % correct velocity at the outlier position
v2(3,3) = 2;

[~, ~, tv] = run_filter(testCase, u2, v2);

testCase.verifyFalse(isempty(tv), 'typevector output is empty');
testCase.verifyEqual(double(tv(3,3)), 3, ...
	'Outlier position should be typevector==3 after second-peak substitution');
end

function test_no_substitution_when_u2_nan(testCase)
% All-NaN u2/v2 (e.g. single-pass with no second peak available).
% Behavior must be identical to the pre-feature baseline: outlier rejected.
N = 5;
u2 = nan(N, 'single');
v2 = nan(N, 'single');

[u_out, v_out, tv] = run_filter(testCase, u2, v2);

testCase.verifyFalse(isempty(tv), 'typevector output is empty');
testCase.verifyEqual(double(tv(3,3)), 2, ...
	'Outlier with no u2/v2 must remain rejected (typevector==2)');
testCase.verifyTrue(isnan(u_out(3,3)) | isnan(v_out(3,3)), ...
	'Outlier without second peak must remain NaN in filtered output');
end

function test_no_substitution_when_u2v2_empty(testCase)
% Empty u2/v2 (old session, pre-feature). Must not error and must produce
% same result as having all-NaN u2/v2.
[u_out, v_out, tv] = run_filter(testCase, [], []);

testCase.verifyFalse(isempty(tv), 'typevector must not be empty with empty u2/v2');
testCase.verifyEqual(double(tv(3,3)), 2, ...
	'Outlier must remain rejected when u2/v2 are empty');
testCase.verifyTrue(isnan(u_out(3,3)) | isnan(v_out(3,3)), ...
	'Outlier must remain NaN when u2/v2 are empty');
end

function test_bad_second_peak_stays_rejected(testCase)
% If u2/v2 at the outlier position are also outliers, the vector must
% remain rejected (typevector==2), not promoted to typevector==3.
N = 5;
u2 = nan(N, 'single');
v2 = nan(N, 'single');
u2(3,3) = 80;  % another outlier value
v2(3,3) = 2;

[~, ~, tv] = run_filter(testCase, u2, v2);

testCase.verifyNotEqual(double(tv(3,3)), 3, ...
	'A bad second-peak candidate must not be promoted to typevector==3');
end

function test_masked_positions_not_substituted(testCase)
% Masked vectors (typevector_original==0) must never receive substitution.
td = testCase.TestData;
typevector_original = td.typevector_original;
typevector_original(3,3) = 0;  % mark the outlier as masked instead

N = 5;
u2 = nan(N, 'single');
v2 = nan(N, 'single');
u2(3,3) = 3;
v2(3,3) = 2;

try
	[~, ~, tv] = validate.filtervectors_all_parallel( ...
		td.x, td.y, td.u, td.v, typevector_original, ...
		td.calu, td.calv, td.velrect, ...
		td.do_stdev_check, td.stdthresh, ...
		td.do_local_median, td.neigh_thresh, ...
		0, 0, 0, 0, ...
		td.interpol_missing, [], [], [], [], ...
		0, 0, [], ...
		0, 0, 0, [], ...
		u2, v2);
catch ME
	testCase.verifyFail(['filtervectors_all_parallel threw: ' ME.message]);
	return
end

testCase.verifyEqual(double(tv(3,3)), 0, ...
	'Masked position must remain typevector==0, not be substituted to type 3');
end

function test_valid_vectors_unchanged(testCase)
% Positions that pass primary validation must be unaffected by the
% second-peak substitution path (typevector remains 1).
N = 5;
u2 = 3 * ones(N, 'single');  % u2 available everywhere
v2 = 2 * ones(N, 'single');

[~, ~, tv] = run_filter(testCase, u2, v2);

% All positions except (3,3) should be valid (type 1)
mask = true(N); mask(3,3) = false;
testCase.verifyTrue(all(tv(mask) == 1 | tv(mask) == 0), ...
	'Good primary vectors must not be overwritten by second-peak substitution');
end
