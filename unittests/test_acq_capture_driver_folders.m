%% Tests of the folder layout of PIVlab_capture_resources (no hardware, no GUI)
%
% One subfolder per camera type. Checked:
%   - no two .m files with the same name (shadowing)
%   - with the path set up like PIVlab_GUI does it, every capture function is found, and every
%     PIVlab_capture_* name used by the GUI code exists
%   - files that are looked up next to the code via mfilename('fullpath') (.bfml, tycmd.exe,
%     lens config .mat) are really next to that code
%   - the MATLAB project path contains every capture folder with .m files, and no project entry
%     points to a missing file
%   - the toolbox ships all capture files, but no *_tests or scratch files, and no unit tests
% Nothing here is a hardcoded list of folders or files: a new camera folder is covered automatically.
%
% Run with:
%   runtests('unittests/test_acq_capture_driver_folders.m')

function tests = test_acq_capture_driver_folders
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
root = helper_root();
addpath(root);
capture_root = fullfile(root, 'PIVlab_capture_resources');
% all capture files except the local *_tests folders (same rule as PIVlab_GUI)
all_files = dir(fullfile(capture_root, '**', '*'));
all_files = all_files(~[all_files.isdir] & ~contains({all_files.folder}, '_tests'));
full_names = fullfile({all_files.folder}, {all_files.name});
[~, base_names, exts] = fileparts(full_names);
is_m = false(size(full_names));
for k = 1:numel(full_names)
    is_m(k) = strcmp(exts{k}, '.m') && isvarname(base_names{k});   % skips _debug scratch scripts
end
testCase.TestData.Root = root;
testCase.TestData.CaptureRoot = capture_root;
testCase.TestData.FullNames = full_names;
testCase.TestData.BaseNames = base_names;
testCase.TestData.Exts = exts;
testCase.TestData.IsM = is_m;
testCase.TestData.MFiles = full_names(is_m);
testCase.TestData.MNames = base_names(is_m);
testCase.TestData.MFolders = unique({all_files(is_m).folder});
end

% -------------------------------------------------------------------------

function test_no_duplicate_function_names(testCase)
m_names = testCase.TestData.MNames;
[unique_names, ~, idx] = unique(lower(m_names));
dup = unique_names(accumarray(idx(:), 1) > 1);
testCase.verifyEmpty(dup, ['duplicate .m names: ' strjoin(dup, ', ')]);
end

function test_functions_are_found_on_the_pivlab_path(testCase)
% path like PIVlab_GUI sets it: every capture function is found (and not shadowed)
root = testCase.TestData.Root;
m_files = testCase.TestData.MFiles;
m_names = testCase.TestData.MNames;
old_path = path;
not_found = {};
try
    restoredefaultpath;
    addpath(root);
    capture_paths = strsplit(genpath(fullfile(root, 'PIVlab_capture_resources')), pathsep);
    for k = 1:numel(capture_paths)
        if ~isempty(capture_paths{k}) && ~endsWith(capture_paths{k}, '_tests')
            addpath(capture_paths{k});
        end
    end
    for k = 1:numel(m_names)
        if ~strcmpi(which(m_names{k}), m_files{k})
            not_found{end+1} = sprintf('%s (which: ''%s'')', m_names{k}, which(m_names{k})); %#ok<AGROW>
        end
    end
catch err
    path(old_path);
    rethrow(err);
end
path(old_path);
testCase.verifyEmpty(not_found, sprintf('capture functions not found or shadowed:\n  %s', strjoin(not_found, '\n  ')));
end

function test_names_used_by_the_gui_exist(testCase)
% every PIVlab_capture_* name used in +acquisition, +gui and PIVlab_GUI.m is a file
root = testCase.TestData.Root;
caller_files = [dir(fullfile(root, '+acquisition', '**', '*.m')); ...
    dir(fullfile(root, '+gui', '**', '*.m')); dir(fullfile(root, 'PIVlab_GUI.m'))];
used_names = {};
for k = 1:numel(caller_files)
    src = fileread(fullfile(caller_files(k).folder, caller_files(k).name));
    used_names = [used_names, regexp(src, 'PIVlab_capture_\w+', 'match')]; %#ok<AGROW>
end
used_names = setdiff(unique(used_names), {'PIVlab_capture_resources', 'PIVlab_capture_lensconfig'});
testCase.verifyNotEmpty(used_names, 'test setup: no PIVlab_capture_* names found in the GUI code');
missing = setdiff(used_names, testCase.TestData.MNames);
testCase.verifyEmpty(missing, ['used by the GUI code, but no such file: ' strjoin(missing, ', ')]);
end

function test_files_are_next_to_the_code_that_loads_them(testCase)
% .bfml / .exe / .mat files loaded with mfilename('fullpath') are in the folder of that code
m_files = testCase.TestData.MFiles;
m_names = testCase.TestData.MNames;
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
testCase.verifyGreaterThan(n_checked, 0, 'test setup: no file references found');
testCase.verifyEmpty(missing, sprintf('files not next to their code:\n  %s', strjoin(missing, '\n  ')));
end

function test_matlab_project(testCase)
% every capture folder with .m files is on the project path; no project entry points to a missing file
root = testCase.TestData.Root;
proj = matlab.project.rootProject;
opened_here = isempty(proj) || ~strcmpi(proj.RootFolder, root);
if opened_here
    proj = openProject(root);
end
project_path = string({proj.ProjectPath.File});
not_on_path = setdiff(testCase.TestData.MFolders, project_path);
project_files = string({proj.Files.Path});
project_files = project_files(startsWith(project_files, testCase.TestData.CaptureRoot, 'IgnoreCase', true));
stale = project_files(~isfile(project_files) & ~isfolder(project_files));
if opened_here
    close(proj);
end
testCase.verifyEmpty(not_on_path, sprintf(['capture folders missing on the project path ' ...
    '(add with addPath(currentProject, folder)):\n  %s'], strjoin(not_on_path, '\n  ')));
testCase.verifyEmpty(stale, sprintf('project entries without file:\n  %s', strjoin(stale, '\n  ')));
end

function test_toolbox_packaging(testCase)
% the toolbox ships all capture files, no local test / scratch files and no unit tests
root = testCase.TestData.Root;
capture_root = testCase.TestData.CaptureRoot;
full_names = testCase.TestData.FullNames;
base_names = testCase.TestData.BaseNames;
exts = testCase.TestData.Exts;
opts = matlab.addons.toolbox.ToolboxOptions(fullfile(root, 'PIVlab_source.prj'));
toolbox_files = string(opts.ToolboxFiles);
is_scratch = startsWith(base_names, {'_', 'william_'});
is_shipped_type = testCase.TestData.IsM | ismember(exts, {'.bfml', '.exe', '.mat'});
should_ship = full_names(is_shipped_type & ~is_scratch);
not_shipped = setdiff(should_ship, toolbox_files);
testCase.verifyEmpty(not_shipped, sprintf('missing in the toolbox:\n  %s', strjoin(not_shipped, '\n  ')));
[~, shipped_names] = fileparts(toolbox_files);
unwanted = toolbox_files(startsWith(toolbox_files, capture_root, 'IgnoreCase', true) & ...
    (contains(toolbox_files, '_tests') | startsWith(shipped_names, {'_', 'william_'})));
testCase.verifyEmpty(unwanted, sprintf('the toolbox ships local test / scratch files (see package.ignore):\n  %s', ...
    strjoin(unwanted, '\n  ')));
toolbox_path = string(opts.ToolboxMatlabPath);
not_in_toolbox_path = setdiff(testCase.TestData.MFolders, toolbox_path);
testCase.verifyEmpty(not_in_toolbox_path, sprintf('capture folders missing on the toolbox MATLAB path:\n  %s', ...
    strjoin(not_in_toolbox_path, '\n  ')));
unittests = toolbox_files(startsWith(toolbox_files, fullfile(root, 'unittests'), 'IgnoreCase', true));
testCase.verifyEmpty(unittests, sprintf('the toolbox ships unit tests (see package.ignore):\n  %s', ...
    strjoin(unittests, '\n  ')));
end
