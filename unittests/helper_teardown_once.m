function helper_teardown_once(testCase)
%HELPER_TEARDOWN_ONCE Common end of a test file (call it in teardownOnce), see helper_setup_once.
helper_close_pivlab();
helper_restore_preferences(testCase.TestData.Preferences);
if isappdata(0, 'PIVlabTestMode')
    rmappdata(0, 'PIVlabTestMode');
end
if isappdata(0, 'parity_mock_file')
    rmappdata(0, 'parity_mock_file');
end
if isappdata(0, 'pivlab_test_warning_state')
    warning(getappdata(0, 'pivlab_test_warning_state'));
    rmappdata(0, 'pivlab_test_warning_state');
end
try
    rmdir(testCase.TestData.Dir, 's');
catch
end
close all force
end
