function helper_truth_verify(testCase, actual, expected, reltol, label, inner, scale)
%HELPER_TRUTH_VERIFY Compare a map with its analytic truth.
%   helper_truth_verify(testCase, actual, expected, reltol, label)
%   helper_truth_verify(testCase, actual, expected, reltol, label, inner)
%   helper_truth_verify(testCase, actual, expected, reltol, label, inner, scale)
%   The largest deviation must be below reltol * scale (+ 1e-12); scale is max(|expected|) unless
%   given (e.g. the size of the velocity gradients for a divergence that is 0). inner: logical mask
%   of the vectors to compare (e.g. without the border row, where gradients are one-sided), [] = all.
%   The message names the case and the largest deviation, e.g. "ms, x left, y up: vorticity".
actual = double(actual);
expected = double(expected);
if nargin >= 6 && ~isempty(inner)
    actual = actual(inner);
    expected = expected(inner);
end
testCase.verifyEqual(size(actual), size(expected), [label ': size']);
if ~isequal(size(actual), size(expected))
    return
end
if nargin < 7 || isempty(scale)
    scale = max(abs(expected(:)));
end
tol = reltol * scale + 1e-12;
both_nan = isnan(actual) & isnan(expected);
d = abs(actual - expected);
d(both_nan) = 0;
d(isnan(d)) = Inf;          % NaN in only one of them
worst = max(d(:));
testCase.verifyLessThanOrEqual(worst, tol, sprintf('%s: max deviation %.3g (tolerance %.3g, max |truth| %.3g)', ...
    label, worst, tol, scale));
end
