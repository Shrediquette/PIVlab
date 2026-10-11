function helper_setup_once(testCase)
%HELPER_SETUP_ONCE Common start of a test file (call it in setupOnce).
%   - PIVlab folder on the path, testCase.TestData.Root
%   - an empty temporary folder testCase.TestData.Dir (removed by helper_teardown_once)
%   - PIVlabTestMode: message boxes of PIVlab return their default answer
%   - the warning state of MATLAB is kept (PIVlab_GUI switches all warnings off;
%     helper_close_pivlab switches them back)
%   - the user's PIVlab preferences are saved and removed, so the tests start like a first start
%     of PIVlab (helper_teardown_once brings them back)
root = helper_root();
addpath(root);
testCase.TestData.Root = root;
testCase.TestData.Dir = tempname(tempdir);
mkdir(testCase.TestData.Dir);
setappdata(0, 'PIVlabTestMode', true);
setappdata(0, 'pivlab_test_warning_state', warning);
testCase.TestData.Preferences = helper_save_preferences();
end
