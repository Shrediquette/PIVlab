%% Tests that PIVlab only needs the toolboxes that regular users can be expected to have
%
% A regular user has MATLAB and the Image Processing Toolbox. The toolboxes below are optional:
% the features that need them show a message when the toolbox is missing (misc.require_toolbox),
% or the code falls back (parallel computing). If this test fails, a file needs another toolbox.
% Either avoid the toolbox, or guard the feature with misc.require_toolbox / misc.has_toolbox,
% then add the toolbox to the list "optional" below.
%
% Run with:
%   runtests('unittests/test_core_toolbox_dependencies.m')

function tests = test_core_toolbox_dependencies
tests = functiontests(localfunctions);
end

function setupOnce(~)
addpath(helper_root());
end

function test_no_unexpected_toolbox(testCase)
allowed = {'MATLAB', 'Image Processing Toolbox'};
optional = {'Computer Vision Toolbox', 'Parallel Computing Toolbox', 'Image Acquisition Toolbox', 'MATLAB Compiler'};
% minFunc only uses the Optimization Toolbox line search with LS_type ~= 0 (wOFV uses the Wolfe line search)
ignored_folders = {'OptimizationSolvers', 'unittests', 'dev_notes', '_tests', 'mocks_imaq', 'explore', 'benchmark'};
root = helper_root();
d = dir(fullfile(root, '**', '*.m'));
unexpected = {};
for i = 1:numel(d)
    path = fullfile(d(i).folder, d(i).name);
    skip = false;
    for k = 1:numel(ignored_folders)
        if contains(path, ignored_folders{k})
            skip = true;
        end
    end
    if skip || strcmp(d(i).name, 'clean_and_package_PIVlab.m') % packaging is a developer tool
        continue
    end
    [~, products] = matlab.codetools.requiredFilesAndProducts(path, 'toponly');
    for p = 1:numel(products)
        if ~products(p).Certain % shared functions (e.g. rigidtform3d) are reported as uncertain
            continue
        end
        if ~any(strcmp(products(p).Name, [allowed optional]))
            unexpected{end+1} = [strrep(path, root, '') ' needs ' products(p).Name]; %#ok<AGROW>
        end
    end
end
testCase.verifyEmpty(unexpected, ['Files need toolboxes that regular users may not have:' newline strjoin(unexpected, newline)]);
end

function test_optional_toolboxes_have_a_check(testCase)
% misc.has_toolbox knows every optional toolbox, and it works without a GUI
names = {'Computer Vision Toolbox', 'Parallel Computing Toolbox', 'Image Acquisition Toolbox', 'MATLAB Compiler'};
for i = 1:numel(names)
    testCase.verifyClass(misc.has_toolbox(names{i}), 'logical');
end
err_id = '';
try
    misc.has_toolbox('Some Other Toolbox');
catch err
    err_id = err.identifier;
end
testCase.verifyEqual(err_id, 'PIVlab:unknownToolbox');
end

function test_missing_toolbox_gives_message_not_error(testCase)
% without the GUI, require_toolbox only prints. A known toolbox that is present returns true.
testCase.verifyTrue(islogical(misc.require_toolbox('Computer Vision Toolbox', 'Test feature')));
end
