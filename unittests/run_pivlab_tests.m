function results = run_pivlab_tests(group)
%RUN_PIVLAB_TESTS Runs a group of the PIVlab unit tests and prints a summary.
%   results = run_pivlab_tests(group)
%   group   'fast'    everything without the PIVlab window (core, api, acq, stereo_core), about 5 min
%           'core'    algorithms without GUI (test_core_*)
%           'api'     command-line API without GUI (test_api_*)
%           'gui'     the PIVlab window (test_gui_*)
%           'apigui'  API and GUI give the same results (test_apigui_*)
%           'stereo'  stereo-PIV (test_stereo_*)
%           'acq'     image acquisition without hardware (test_acq_*)
%           'all'     all of them (default), about 25 min
%   or the name of one test file, e.g. 'test_gui_sessions'.
%
%   Do not run the GUI groups while you use PIVlab with a camera in another MATLAB (imaqreset in the
%   test MATLAB can block). Your PIVlab preferences are saved before every test file and restored
%   afterwards (see helper_save_preferences). See README.md for what each file tests.
if nargin < 1
    group = 'all';
end
group = char(group);
here = fileparts(mfilename('fullpath'));
switch group
    case 'fast'
        patterns = {'test_core_*.m', 'test_api_*.m', 'test_acq_*.m', 'test_stereo_core.m'};
    case 'core'
        patterns = {'test_core_*.m'};
    case 'api'
        patterns = {'test_api_*.m'};
    case 'gui'
        patterns = {'test_gui_*.m'};
    case 'apigui'
        patterns = {'test_apigui_*.m'};
    case 'stereo'
        patterns = {'test_stereo_*.m'};
    case 'acq'
        patterns = {'test_acq_*.m'};
    case 'all'
        patterns = {'test_core_*.m', 'test_api_*.m', 'test_acq_*.m', 'test_stereo_*.m', 'test_gui_*.m', 'test_apigui_*.m'};
    otherwise
        patterns = {[group '.m']};
end
files = {};
for k = 1:numel(patterns)
    L = dir(fullfile(here, patterns{k}));
    for j = 1:numel(L)
        files{end+1} = fullfile(L(j).folder, L(j).name); %#ok<AGROW>
    end
end
if isempty(files)
    error('run_pivlab_tests: no test files for "%s"', group);
end
fprintf('Running %d test files (%s)...\n', numel(files), group);
results = runtests(files);
% summary
failed = results([results.Failed]);
skipped = results([results.Incomplete] & ~[results.Failed]);
fprintf('\n%d passed, %d failed, %d skipped, %.1f min\n', nnz([results.Passed]), numel(failed), ...
    numel(skipped), sum([results.Duration])/60);
for k = 1:numel(failed)
    fprintf('  FAILED   %s\n', failed(k).Name);
end
for k = 1:numel(skipped)
    fprintf('  SKIPPED  %s\n', skipped(k).Name);
end
end
