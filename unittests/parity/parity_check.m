function ok = parity_check(ref, outdir, opts)
%PARITY_CHECK Check that the PIVlab GUI of the working copy behaves exactly like a git revision.
%   ok = parity_check()            compares the working copy with HEAD
%   ok = parity_check(ref)         compares with another revision (branch, tag, commit)
%   ok = parity_check(ref, outdir) keeps the results in outdir (default: tempdir)
%
%   Name=value options
%   Scenarios   'all' (default) or a cellstr of scenario names of parity_run
%   API         true (default): also compare the pivlab.* API with the GUI of the reference
%
%   The reference revision is checked out into a temporary git worktree. Both versions are
%   driven through the same GUI scenarios by parity_run, each in its own MATLAB process
%   (matlab -batch), then parity_compare compares all numbers (isequaln) and all window
%   screenshots (pixel by pixel). Takes about 10 minutes per version. See README.md.
arguments
    ref {mustBeTextScalar} = "HEAD"
    outdir {mustBeTextScalar} = fullfile(tempdir, 'pivlab_parity')
    opts.Scenarios = 'all'
    opts.API (1,1) logical = true
end
here = fileparts(mfilename('fullpath'));
root = fileparts(fileparts(here));
outdir = char(outdir);
stamp = char(datetime('now','Format','yyyyMMdd_HHmmss'));
refdir = fullfile(outdir, [stamp '_ref']);
wcdir  = fullfile(outdir, [stamp '_workingcopy']);
worktree = fullfile(tempdir, ['pivlab_ref_' stamp]);

[st, out] = system(sprintf('git -C "%s" worktree add --detach "%s" %s', root, worktree, char(ref)));
if st ~= 0
    error('parity_check:git', 'Could not create a worktree of %s:\n%s', char(ref), out);
end
cleanup = onCleanup(@() system(sprintf('git -C "%s" worktree remove --force "%s"', root, worktree)));
% both GUIs start with the same remembered settings (last folder etc.)
copyfile(fullfile(root,'PIVlab_settings_default.mat'), fullfile(worktree,'PIVlab_settings_default.mat'), 'f');

if iscell(opts.Scenarios)
    scen = ['{' strjoin(cellfun(@(s) ['''' s ''''], opts.Scenarios, 'UniformOutput', false), ',') '}'];
else
    scen = ['''' char(opts.Scenarios) ''''];
end
fprintf('Reference (%s): running the GUI scenarios...\n', char(ref));
run_batch(sprintf('addpath(''%s''); parity_run(''%s'', %s, ''%s'')', here, refdir, scen, worktree));
fprintf('Working copy: running the GUI scenarios...\n');
run_batch(sprintf('addpath(''%s''); parity_run(''%s'', %s, ''%s'')', here, wcdir, scen, root));

fprintf('\nGUI: reference vs. working copy\n');
ok = parity_compare(refdir, wcdir);

if opts.API && ischar(opts.Scenarios) && strcmp(opts.Scenarios,'all')
    fprintf('\npivlab.* API vs. GUI of the reference\n');
    out = run_batch(sprintf(['addpath(''%s''); api_vs_gui(''%s''); api_vs_gui_more(''%s''); ' ...
        'api_display_vs_gui(''%s'',''%s'')'], here, refdir, refdir, refdir, fullfile(outdir,[stamp '_api_display'])));
    ok = ok && ~contains(out, 'DIFFERENCES FOUND') && count(out, 'ALL IDENTICAL') == 3;
end
if ok
    fprintf('\nPARITY CHECK PASSED\n');
else
    fprintf('\nPARITY CHECK FAILED - see the differences above\n');
end
end

function out = run_batch(cmd)
matlab = fullfile(matlabroot, 'bin', 'matlab');
[st, out] = system(sprintf('"%s" -batch "%s"', matlab, cmd));
lines = splitlines(out);
keep = startsWith(strtrim(lines), {'SCENARIO','same','DIFF','API_','PNG','Error','ERROR'});
fprintf('%s\n', strjoin(lines(keep), newline));
if st ~= 0
    warning('parity_check:batch', 'MATLAB process ended with status %d:\n%s', st, out);
end
end
