% test_capture_driver_folders.m
% Standalone tests (no hardware, no GUI) for the folder layout of
% PIVlab_capture_resources (one subfolder per camera type):
%   1. no two .m files with the same name (shadowing)
%   2. with the path set up like PIVlab_GUI does it, every capture function is
%      found, and every PIVlab_capture_* name used by the GUI code exists
%   3. files that are looked up next to the code via mfilename('fullpath')
%      (.bfml, tycmd.exe, lens config .mat) are really next to that code
%   4. the MATLAB project path contains every capture folder with .m files and
%      no project entry points to a missing file
%   5. toolbox packaging ships all capture files, but no *_tests or scratch files
% Nothing here is a hardcoded list of folders or files: a new camera folder is
% covered automatically.
%
% Run with:
%   cd <PIVlab repo root>
%   run('unittests/test_capture_driver_folders.m')

clc; clear; close all;

project_root = fileparts(fileparts(mfilename('fullpath')));

fprintf('=== test_capture_driver_folders ===\n\n');
[n_passed, n_failed] = run_all_checks(project_root);

% ── Summary ────────────────────────────────────────────────────────────────
fprintf('\n--- Summary: %d passed, %d failed ---\n', n_passed, n_failed);
if n_failed > 0
	error('test_capture_driver_folders: %d test(s) FAILED', n_failed);
end

% ── Checks ─────────────────────────────────────────────────────────────────
function [n_passed, n_failed] = run_all_checks(project_root)
n_passed = 0;
n_failed = 0;
capture_root = fullfile(project_root, 'PIVlab_capture_resources');

% all capture files except the local *_tests folders (same rule as PIVlab_GUI)
all_files = dir(fullfile(capture_root, '**', '*'));
all_files = all_files(~[all_files.isdir] & ~contains({all_files.folder}, '_tests'));
full_names = fullfile({all_files.folder}, {all_files.name});
[~, base_names, exts] = fileparts(full_names);
is_m = strcmp(exts, '.m') & cellfun(@isvarname, base_names); %skips _debug scratch scripts
m_files = full_names(is_m);
m_names = base_names(is_m);

% ── 1. No duplicate function names ────────────────────────────────────────
[unique_names, ~, idx] = unique(lower(m_names));
dup = unique_names(accumarray(idx(:), 1) > 1);
if isempty(dup)
	fprintf('[PASS] no duplicate .m names in PIVlab_capture_resources (%d files)\n', numel(m_names));
	n_passed = n_passed + 1;
else
	fprintf('[FAIL] duplicate .m names: %s\n', strjoin(dup, ', '));
	n_failed = n_failed + 1;
end

% ── 2. Path like PIVlab_GUI: every capture function is found ─────────────
old_path = path;
restore_path = onCleanup(@() path(old_path));
restoredefaultpath;
addpath(project_root);
tempfilepath = project_root;
capture_paths = strsplit(genpath(fullfile(tempfilepath, 'PIVlab_capture_resources')), pathsep);
addpath(capture_paths{~endsWith(capture_paths,'_tests') & ~cellfun(@isempty,capture_paths)});

not_found = {};
for k = 1:numel(m_names)
	if ~strcmpi(which(m_names{k}), m_files{k})
		not_found{end+1} = sprintf('%s (which: ''%s'')', m_names{k}, which(m_names{k})); %#ok<AGROW>
	end
end
if isempty(not_found)
	fprintf('[PASS] all %d capture functions are found on the PIVlab path\n', numel(m_names));
	n_passed = n_passed + 1;
else
	fprintf('[FAIL] capture functions not found or shadowed:\n  %s\n', strjoin(not_found, '\n  '));
	n_failed = n_failed + 1;
end

caller_files = [dir(fullfile(project_root, '+acquisition', '**', '*.m')); ...
	dir(fullfile(project_root, '+gui', '**', '*.m')); dir(fullfile(project_root, 'PIVlab_GUI.m'))];
used_names = {};
for k = 1:numel(caller_files)
	src = fileread(fullfile(caller_files(k).folder, caller_files(k).name));
	used_names = [used_names, regexp(src, 'PIVlab_capture_\w+', 'match')]; %#ok<AGROW>
end
used_names = setdiff(unique(used_names), {'PIVlab_capture_resources', 'PIVlab_capture_lensconfig'});
missing = setdiff(used_names, m_names);
if isempty(missing)
	fprintf('[PASS] all %d PIVlab_capture_* names used in +acquisition, +gui, PIVlab_GUI exist\n', numel(used_names));
	n_passed = n_passed + 1;
else
	fprintf('[FAIL] used by the GUI code, but no such file: %s\n', strjoin(missing, ', '));
	n_failed = n_failed + 1;
end

% ── 3. Files looked up next to the code (mfilename('fullpath')) ───────────
missing = {};
n_checked = 0;
for k = 1:numel(m_files)
	src_lines = splitlines(fileread(m_files{k}));
	if ~any(contains(src_lines, 'mfilename(''fullpath'')'))
		continue
	end
	for j = 1:numel(src_lines)
		if contains(src_lines{j}, 'does not exist yet')
			continue
		end
		needed = regexp(src_lines{j}, '''([\w.-]+\.(bfml|exe|mat))''', 'tokens');
		for t = 1:numel(needed)
			n_checked = n_checked + 1;
			if ~isfile(fullfile(fileparts(m_files{k}), needed{t}{1}))
				missing{end+1} = sprintf('%s needs %s', m_names{k}, needed{t}{1}); %#ok<AGROW>
			end
		end
	end
end
if isempty(missing) && n_checked > 0
	fprintf('[PASS] %d file references (.bfml/.exe/.mat) are next to the code that loads them\n', n_checked);
	n_passed = n_passed + 1;
else
	fprintf('[FAIL] files not next to their code (%d checked):\n  %s\n', n_checked, strjoin(missing, '\n  '));
	n_failed = n_failed + 1;
end

path(old_path);
clear restore_path

% ── 4. MATLAB project ─────────────────────────────────────────────────────
proj = matlab.project.rootProject;
opened_here = isempty(proj) || ~strcmpi(proj.RootFolder, project_root);
if opened_here
	proj = openProject(project_root);
end
project_path = string({proj.ProjectPath.File});
m_folders = unique({all_files(is_m).folder});
not_on_path = setdiff(m_folders, project_path);
if isempty(not_on_path)
	fprintf('[PASS] all %d capture folders with .m files are on the project path\n', numel(m_folders));
	n_passed = n_passed + 1;
else
	fprintf('[FAIL] capture folders missing on the project path (add with addPath(currentProject, folder)):\n  %s\n', strjoin(not_on_path, '\n  '));
	n_failed = n_failed + 1;
end
project_files = string({proj.Files.Path});
project_files = project_files(startsWith(project_files, capture_root, 'IgnoreCase', true));
stale = project_files(~isfile(project_files) & ~isfolder(project_files));
if isempty(stale)
	fprintf('[PASS] no project entry in PIVlab_capture_resources points to a missing file\n');
	n_passed = n_passed + 1;
else
	fprintf('[FAIL] project entries without file:\n  %s\n', strjoin(stale, '\n  '));
	n_failed = n_failed + 1;
end
if opened_here
	close(proj);
end

% ── 5. Toolbox packaging ─────────────────────────────────────────────────
opts = matlab.addons.toolbox.ToolboxOptions(fullfile(project_root, 'PIVlab_source.prj'));
toolbox_files = string(opts.ToolboxFiles);
is_scratch = startsWith(base_names, {'_', 'william_'});
should_ship = full_names((is_m | ismember(exts, {'.bfml', '.exe', '.mat'})) & ~is_scratch);
not_shipped = setdiff(should_ship, toolbox_files);
if isempty(not_shipped)
	fprintf('[PASS] toolbox contains all %d capture .m/.bfml/.exe/.mat files\n', numel(should_ship));
	n_passed = n_passed + 1;
else
	fprintf('[FAIL] missing in toolbox:\n  %s\n', strjoin(not_shipped, '\n  '));
	n_failed = n_failed + 1;
end
[~, shipped_names] = fileparts(toolbox_files);
unwanted = toolbox_files(startsWith(toolbox_files, capture_root, 'IgnoreCase', true) & ...
	(contains(toolbox_files, '_tests') | startsWith(shipped_names, {'_', 'william_'})));
if isempty(unwanted)
	fprintf('[PASS] toolbox contains no *_tests or scratch files from PIVlab_capture_resources\n');
	n_passed = n_passed + 1;
else
	fprintf('[FAIL] toolbox ships local test/scratch files (see package.ignore):\n  %s\n', strjoin(unwanted, '\n  '));
	n_failed = n_failed + 1;
end
toolbox_path = string(opts.ToolboxMatlabPath);
not_in_toolbox_path = setdiff(m_folders, toolbox_path);
if isempty(not_in_toolbox_path)
	fprintf('[PASS] all capture folders with .m files are on the toolbox MATLAB path\n');
	n_passed = n_passed + 1;
else
	fprintf('[FAIL] capture folders missing on the toolbox MATLAB path:\n  %s\n', strjoin(not_in_toolbox_path, '\n  '));
	n_failed = n_failed + 1;
end
end
