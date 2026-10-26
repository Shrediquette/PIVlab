function tests = test_api_workflow
%TEST_API_WORKFLOW Command-line API (+pivlab): the whole chain, Verbose=false, example scripts, help texts.
%   No PIVlab window is opened.
%   Run with: results = runtests('unittests/test_api_workflow.m')
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
helper_setup_once(testCase);
testCase.TestData.Files = helper_files('jet', 3);
end

function teardownOnce(testCase)
helper_teardown_once(testCase);
end

function test_workflow_with_defaults(testCase)
imgs = pivlab.readImages(fullfile(testCase.TestData.Root,'Example_data','Jet_000*.jpg'), "pairwise");
imgs = pivlab.readImages(imgs.files(1:4), "pairwise");
testCase.verifyEqual(imgs.pairs, 2);
imgs = pivlab.preprocess(imgs);
res = pivlab.analyze(imgs);
testCase.verifyEqual(size(res.u,3), 2);
testCase.verifyEqual(size(res.x), size(res.u(:,:,1)));
testCase.verifyTrue(any(isfinite(res.u(:))));
res = pivlab.filter(res);
testCase.verifyTrue(res.filtered);
res = pivlab.toMetric(res, DeltaT=0.001, PxPerMeter=1234);
testCase.verifyEqual(res.units, "m/s");
testCase.verifyEqual(res.x, res.px.x/1234, 'RelTol', 1e-12);
[res, vort] = pivlab.derive(res, "vorticity");
testCase.verifyEqual(size(vort), size(res.u));
m = pivlab.temporal(res, "mean");
testCase.verifyEqual(size(m.u,3), 1);
plain_mean = mean(res.u,3,'omitnan');
ok = isfinite(m.u);   % pivlab.temporal sets vectors with < 25 % valid data to NaN (like the GUI)
testCase.verifyEqual(double(m.u(ok)), double(plain_mean(ok)), 'AbsTol', 1e-5);   % single precision
fig = pivlab.display(m, Overlay="magnitude");
testCase.verifyTrue(isgraphics(fig));
close(fig);
end

function test_verbose_false_is_silent(testCase)
files = testCase.TestData.Files(1:2);
% (no background subtraction here: with only 2 pairs it removes most particles, and piv_FFTmulti
% then prints a data quality warning, which Verbose=false deliberately does not hide)
out = evalc(['imgs = pivlab.preprocess(pivlab.readImages(files, "pairwise"), Verbose=false); ' ...
    'res = pivlab.analyze(imgs, Verbose=false); res = pivlab.filter(res, Verbose=false); ' ...
    'res = pivlab.toMetric(res, DeltaT=0.001, PxPerMeter=1000, Verbose=false); ' ...
    'pivlab.saveSession(res, fullfile(tempdir, "pivlab_silent.mat"), Verbose=false); ' ...
    'res = pivlab.analyze(imgs, Algorithm="ensemble", Verbose=false);']);
testCase.verifyEmpty(strtrim(out));
delete(fullfile(tempdir, 'pivlab_silent.mat'));
end

function test_example_scripts(testCase)
% the example scripts run from start to end (figures are closed afterwards); scripts with placeholder
% file names for your own recording ("%% Your files (placeholders)", e.g. stereo) cannot run here
root = testCase.TestData.Root;
L = dir(fullfile(root, 'Example_scripts', 'PIVlab_api_*.m'));
testCase.verifyNotEmpty(L);
here = pwd;
cd(testCase.TestData.Dir);   % sessions written by the scripts land here
for k = 1:numel(L)
    if contains(fileread(fullfile(L(k).folder, L(k).name)), '(placeholders)')
        testCase.log(1, sprintf('%s not run: it needs your own recording (placeholder file names)', L(k).name));
        continue
    end
    try
        run_script(fullfile(L(k).folder, L(k).name), root);
    catch err
        testCase.verifyFail(sprintf('%s: %s', L(k).name, err.message));
    end
    close all force
end
cd(here);
end

function test_help_texts(testCase)
names = {'readImages','preprocess','getImage','analyze','filter','toMetric','derive','temporal', ...
    'display','defaults','loadSettings','loadSession','saveSession'};
txt = help('pivlab');
for k = 1:numel(names)
    testCase.verifySubstring(txt, names{k}, 'pivlab overview');
    h = help(['pivlab.' names{k}]);
    testCase.verifyGreaterThan(numel(h), 300, names{k});
    if ~strcmp(names{k}, 'defaults')   % its help shows the use without the word "Example"
        testCase.verifySubstring(h, 'Example', names{k});
    end
end
% every name=value option of a function is explained in its help text
fun = {'preprocess','analyze','filter','toMetric','derive','temporal','display','getImage','readImages','saveSession'};
for k = 1:numel(fun)
    code = fileread(fullfile(testCase.TestData.Root, '+pivlab', [fun{k} '.m']));
    opts = regexp(code, '\n\s*opts\.(\w+)', 'tokens');
    h = help(['pivlab.' fun{k}]);
    for j = 1:numel(opts)
        testCase.verifySubstring(h, opts{j}{1}, sprintf('%s: option %s', fun{k}, opts{j}{1}));
    end
end
end

%% ------------------------------------------------------------------ helpers

function run_script(file, root)
% runs an example script in its own workspace, from the PIVlab folder (the scripts start
% with "clear", so nothing needed afterwards is kept in variables here)
setappdata(0, 'pivlab_test_here', pwd);
cd(root);
try
    run(file);
catch err
    cd(getappdata(0, 'pivlab_test_here'));
    rethrow(err);
end
cd(getappdata(0, 'pivlab_test_here'));
end
