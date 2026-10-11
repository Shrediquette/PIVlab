function helper_verify_near(testCase, a, b, varargin)
%HELPER_VERIFY_NEAR verifyEqual with a tolerance, also for single values (both are compared as
%   double: verifyEqual does not accept a double tolerance for single values).
testCase.verifyEqual(double(a), double(b), varargin{:});
end
