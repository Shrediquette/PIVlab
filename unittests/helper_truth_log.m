function helper_truth_log(testCase, what)
%HELPER_TRUTH_LOG Progress file of the truth-based tests, to find the test that was running when
%   MATLAB crashed or hung: helper_truth_log(testCase, 'start') in setup, 'end' in teardown.
%   The file is fullfile(tempdir, 'pivlab_truth_progress.log'); a "start" without "end" is the
%   test that did not finish.
file = fullfile(tempdir, 'pivlab_truth_progress.log');
fid = fopen(file, 'a');
if fid < 0
    return
end
name = '';
try
    name = testCase.Name;
catch
end
fprintf(fid, '%s  %-5s  %s\n', char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss')), what, name);
fclose(fid);
end
