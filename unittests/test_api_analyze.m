function tests = test_api_analyze
%TEST_API_ANALYZE Command-line API: pivlab.analyze with every algorithm and every option.
%   Each option is checked for: it runs, it has the documented effect, wrong values give a clear
%   error, options without effect give a warning. No PIVlab window is opened.
%   Run with: results = runtests('unittests/test_api_analyze.m')
%   test_analyze_optical_flow needs the wOFV filter matrices (+wOFV/Filter matrices).
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
helper_setup_once(testCase);
testCase.TestData.Files = helper_files('jet', 3);
% one analysed result that several tests start from
imgs = pivlab.preprocess(pivlab.readImages(testCase.TestData.Files, "pairwise"), Verbose=false);
testCase.TestData.Imgs = imgs;
testCase.TestData.Res = pivlab.analyze(imgs, Verbose=false);
end

function teardownOnce(testCase)
helper_teardown_once(testCase);
end

function test_analyze_fft_options(testCase)
imgs = testCase.TestData.Imgs;
ref = pivlab.analyze(imgs, Pairs=1, Verbose=false);
testCase.verifyEqual(ref.units, "px/frame");
testCase.verifyEqual(ref.settings.analysis.Algorithm, "fft");
% default: 64 px / step 32, second pass 32 px -> vector spacing 16 px
testCase.verifyEqual(spacing(ref), 16);
% first pass only: spacing = Step
r = pivlab.analyze(imgs, Passes=1, InterrogationArea=48, Step=24, Pairs=1, Verbose=false);
testCase.verifyEqual(spacing(r), 24);
% 1...4 passes: the spacing of the last pass is half of its window size
P = {1, [32 32 32], 32; 2, [48 48 48], 24; 3, [32 16 16], 8; 4, [48 32 16], 8};
for k = 1:size(P,1)
    r = pivlab.analyze(imgs, Passes=P{k,1}, PassSizes=P{k,2}, Pairs=1, Verbose=false);
    testCase.verifyEqual(spacing(r), P{k,3}, sprintf('%d passes', P{k,1}));
    testCase.verifyEqual(r.settings.analysis.Passes, P{k,1});
end
% a single pass size is used for all following passes
r1 = pivlab.analyze(imgs, Passes=3, PassSizes=32, Pairs=1, Verbose=false);
r2 = pivlab.analyze(imgs, Passes=3, PassSizes=[32 32 32], Pairs=1, Verbose=false);
testCase.verifyEqual(r1.px.u_raw, r2.px.u_raw);
% options that change the result (but not the grid)
O = {'SubpixelFinder', "gauss2d"; 'DisableAutocorrelation', true; 'Robustness', "high"; 'Robustness', "extreme"; ...
     'RepeatLastPass', true};
for k = 1:size(O,1)
    r = pivlab.analyze(imgs, O{k,1}, O{k,2}, Pairs=1, Verbose=false);
    testCase.verifyEqual(size(r.px.u_raw), size(ref.px.u_raw), O{k,1});
    testCase.verifyNotEqual(r.px.u_raw, ref.px.u_raw, sprintf('%s = %s', O{k,1}, string(O{k,2})));
end
% values that equal the default give the default result (also as numbers / other case)
E = {'SubpixelFinder', "Gauss3Point"; 'SubpixelFinder', 1; 'Robustness', "Standard"; 'Robustness', 1; ...
     'DisableAutocorrelation', false; 'RepeatLastPass', false; 'Uncertainty', false};
for k = 1:size(E,1)
    r = pivlab.analyze(imgs, E{k,1}, E{k,2}, Pairs=1, Verbose=false);
    testCase.verifyEqual(r.px.u_raw, ref.px.u_raw, sprintf('%s = %s', E{k,1}, string(E{k,2})));
end
% RepeatLastPassThreshold: a large threshold stops after the first repetition
a = pivlab.analyze(imgs, RepeatLastPass=true, RepeatLastPassThreshold=0.001, Pairs=1, Verbose=false);
b = pivlab.analyze(imgs, RepeatLastPass=true, RepeatLastPassThreshold=10, Pairs=1, Verbose=false);
testCase.verifyNotEqual(a.px.u_raw, b.px.u_raw);
% Uncertainty: map in res, derive can show it
r = pivlab.analyze(imgs, Uncertainty=true, Pairs=1, Verbose=false);
testCase.verifyEqual(size(r.px.uncertainty), size(r.px.u));
testCase.verifyEqual(r.px.u_raw, ref.px.u_raw);
[~, um] = pivlab.derive(r, "uncertainty");
testCase.verifyGreaterThan(nnz(isfinite(um)), 0.5*numel(um));
testCase.verifyEqual(helper_error_id('pivlab.derive', ref, "uncertainty"), 'pivlab:derive:notAvailable');
% second correlation peak stored (for second-peak substitution in pivlab.filter)
testCase.verifyEqual(size(ref.px.u2), size(ref.px.u));
% Settings instead of name=value
s = pivlab.defaults();
s.analysis.Passes = 3; s.analysis.PassSizes = [32 16 16];
a = pivlab.analyze(imgs, Settings=s, Pairs=1, Verbose=false);
b = pivlab.analyze(imgs, Passes=3, PassSizes=[32 16 16], Pairs=1, Verbose=false);
testCase.verifyEqual(a.px.u_raw, b.px.u_raw);
end

function test_analyze_pairs_and_verbose(testCase)
imgs = testCase.TestData.Imgs;
all3 = testCase.TestData.Res;
testCase.verifyEqual(size(all3.u,3), 3);
testCase.verifyEqual(all3.pairs, 1:3);
testCase.verifyEqual(numel(all3.frameLabels), 3);
% a selection of pairs gives the same vectors as the full analysis
r = pivlab.analyze(imgs, Pairs=[3 1], Verbose=false);
testCase.verifyEqual(r.pairs, [3 1]);
testCase.verifyEqual(r.px.u_raw(:,:,1), all3.px.u_raw(:,:,3));
testCase.verifyEqual(r.px.u_raw(:,:,2), all3.px.u_raw(:,:,1));
testCase.verifySubstring(char(r.frameLabels(1)), 'Jet_0003A');
% wrong pairs / algorithm
testCase.verifyEqual(helper_error_id('pivlab.analyze', imgs, 'Pairs', 4, 'Verbose', false), 'pivlab:analyze:pairs');
testCase.verifyEqual(helper_error_id('pivlab.analyze', imgs, 'Pairs', 1.5, 'Verbose', false), 'pivlab:analyze:pairs');
testCase.verifyEqual(helper_error_id('pivlab.analyze', imgs, 'Algorithm', "piv", 'Verbose', false), 'pivlab:analyze:algorithm');
testCase.verifyEqual(helper_error_id('pivlab.analyze', imgs, 'SubpixelFinder', "gauss9", 'Verbose', false), 'pivlab:analyze:subpixel');
testCase.verifyEqual(helper_error_id('pivlab.analyze', imgs, 'Robustness', "low", 'Verbose', false), 'pivlab:analyze:robustness');
testCase.verifyEqual(helper_error_id('pivlab.analyze', imgs, 'Speed', 3, 'Verbose', false), 'MATLAB:TooManyInputs');
% the analysis leaves the warning state of MATLAB as it was (PIVlab switched all warnings off before)
state = warning;
pivlab.analyze(imgs, Pairs=1, Verbose=false);
pivlab.analyze(imgs, Algorithm="ensemble", Pairs=1:2, Verbose=false);
pivlab.analyze(imgs, Algorithm="dcc", Pairs=1, Verbose=false);
testCase.verifyEqual(warning, state, 'warning state changed by pivlab.analyze');
% Verbose
out = evalc('pivlab.analyze(imgs, Pairs=1:2);');
testCase.verifySubstring(out, 'finished');
out = evalc('pivlab.analyze(imgs, Pairs=1:2, Verbose=false);');
testCase.verifyEmpty(strtrim(out));
end

function test_mask_and_roi_at_the_vector_positions(testCase)
% a vector is masked exactly when the mask is true at its position, with and without ROI, for every
% correlation algorithm (until 2026-10-11 the positions were 1 px off with a ROI). The mask edges lie
% exactly on vector positions.
raw = pivlab.readImages(testCase.TestData.Files(1:4), "pairwise");
sz = raw.imageSize;
A = {"fft", {'Passes', 1}; "fft", {'Passes', 3, 'PassSizes', [32 16 16]}; "dcc", {}; "ensemble", {'Passes', 2}};
for roi = {[], [101 81 600 400]}
    for k = 1:size(A,1)
        if isempty(roi{1})
            imgs = pivlab.preprocess(raw, Verbose=false);
        else
            imgs = pivlab.preprocess(raw, Roi=roi{1}, Verbose=false);
        end
        r = pivlab.analyze(imgs, 'Algorithm', A{k,1}, A{k,2}{:}, 'Pairs', 1, 'Verbose', false);
        x = double(r.px.x);
        y = double(r.px.y);
        cols = round(size(x,2) * [0.3 0.6]);
        rows = round(size(x,1) * [0.3 0.6]);
        m = false(sz);
        m(y(rows(1),1):y(rows(2),1), x(1,cols(1)):x(1,cols(2))) = true;
        if isempty(roi{1})
            masked = pivlab.preprocess(raw, Mask=m, Verbose=false);
        else
            masked = pivlab.preprocess(raw, Roi=roi{1}, Mask=m, Verbose=false);
        end
        rm = pivlab.analyze(masked, 'Algorithm', A{k,1}, A{k,2}{:}, 'Pairs', 1, 'Verbose', false);
        inside = m(sub2ind(sz, round(double(rm.px.y)), round(double(rm.px.x))));
        testCase.verifyEqual(rm.typevector_raw(:,:,1) == 0, inside, ...
            sprintf('%s (case %d), ROI %s: masked vectors are not the vectors in the mask', A{k,1}, k, mat2str(roi{1})));
    end
end
end

function test_no_warnings_for_harmless_options(testCase)
% options of other algorithms with values that change nothing give no warning (options with an
% effect: test_analyze_dcc / test_analyze_ensemble / test_analyze_optical_flow); a filter that
% removes most vectors does warn
imgs = pivlab.preprocess(pivlab.readImages(testCase.TestData.Files(1:2), "pairwise"), Verbose=false);
lastwarn('');
pivlab.analyze(imgs, Algorithm="dcc", Passes=1, Parallel=false, Verbose=false);
[~, id] = lastwarn;
testCase.verifyEmpty(id);
% most vectors removed (limits in px/frame, far too small) -> warning
res = pivlab.analyze(imgs, Verbose=false);
lastwarn('');
pivlab.filter(res, VelocityLimits=[-0.01 0.01 -0.01 0.01], Verbose=false);
[~, id] = lastwarn;
testCase.verifyEqual(id, 'pivlab:filter:manyRemoved');
end

function test_analyze_parallel(testCase)
testCase.assumeTrue(license('test','Distrib_Computing_Toolbox') && ~isempty(ver('parallel')), 'no Parallel Computing Toolbox');
imgs = testCase.TestData.Imgs;
serial = testCase.TestData.Res;
par = pivlab.analyze(imgs, Parallel=true, Verbose=false);
% worker processes calculate with one thread: the same result up to rounding (the window
% deformation lets single rounding differences grow to a few 1/1000 px at the border)
d = abs(double(par.px.u_raw(:)) - double(serial.px.u_raw(:)));
fprintf('parallel vs serial: max difference %.2g px, %.2f %% of the vectors differ by more than 1e-4 px\n', ...
    max(d), 100*mean(d > 1e-4));
testCase.verifyLessThan(max(d), 0.01);
testCase.verifyLessThan(mean(d > 1e-4), 0.01);
testCase.verifyEqual(par.typevector_raw, serial.typevector_raw);
% a second call uses the open pool and gives exactly the same result
par2 = pivlab.analyze(imgs, Parallel=true, Verbose=false);
testCase.verifyEqual(par2.px.u_raw, par.px.u_raw);
% DCC in parallel
d1 = pivlab.analyze(imgs, Algorithm="dcc", Pairs=1:2, Verbose=false);
d2 = pivlab.analyze(imgs, Algorithm="dcc", Pairs=1:2, Parallel=true, Verbose=false);
helper_verify_near(testCase, d2.px.u_raw, d1.px.u_raw, 'AbsTol', 0.01);
% Parallel with the ensemble: warning, analysed serially
out = helper_warning_message('pivlab:analyze:noEffect', 'pivlab.analyze', imgs, 'Algorithm', "ensemble", 'Passes', 1, 'Parallel', true, 'Verbose', false);
testCase.verifySubstring(out, 'Parallel has no effect');
delete(gcp('nocreate'));
end

function test_analyze_ensemble(testCase)
imgs = testCase.TestData.Imgs;
r = pivlab.analyze(imgs, Algorithm="ensemble", Verbose=false);
testCase.verifyEqual(size(r.u,3), 1);
testCase.verifyEqual(r.frameLabels, "Ensemble of pairs 1-3");
testCase.verifyEqual(spacing(r), 16);
testCase.verifyGreaterThan(nnz(isfinite(r.u)), 0.9*numel(r.u));
% the ensemble is close to the mean of the single-pair results
m = mean(testCase.TestData.Res.px.u_raw, 3, 'omitnan');
dev = abs(double(r.px.u_raw) - double(m));
testCase.verifyLessThan(median(dev(:), 'omitnan'), 0.2);
% passes, window sizes, subpixel finder, robustness, autocorrelation
P = {'Passes', 1; 'Passes', 3; 'SubpixelFinder', "gauss2d"; 'Robustness', "high"; 'DisableAutocorrelation', true; 'InterrogationArea', 96};
for k = 1:size(P,1)
    e = pivlab.analyze(imgs, 'Algorithm', "ensemble", P{k,1}, P{k,2}, 'Verbose', false);
    testCase.verifyNotEqual(e.px.u_raw, r.px.u_raw, P{k,1});
end
e = pivlab.analyze(imgs, Algorithm="ensemble", Passes=3, PassSizes=[32 16 16], Verbose=false);
testCase.verifyEqual(spacing(e), 8);
% Pairs
e = pivlab.analyze(imgs, Algorithm="ensemble", Pairs=2:3, Verbose=false);
testCase.verifyEqual(e.frameLabels, "Ensemble of pairs 2-3");
testCase.verifyNotEqual(e.px.u_raw, r.px.u_raw);
% options of other algorithms: warning
W = {'RepeatLastPass', true; 'Uncertainty', true; 'OFVSmoothness', 20};
for k = 1:size(W,1)
    % (one pass: the smoothing between the passes issues warnings of its own, they would replace
    % this warning in lastwarn)
    out = helper_warning_message('pivlab:analyze:noEffect', 'pivlab.analyze', imgs, 'Algorithm', "ensemble", 'Passes', 1, W{k,1}, W{k,2}, 'Pairs', 1, 'Verbose', false);
    testCase.verifySubstring(out, [W{k,1} ' has no effect'], W{k,1});
end
% the whole chain works on the ensemble result
r = pivlab.toMetric(pivlab.filter(r, Verbose=false), DeltaT=0.001, PxPerMeter=1000, Verbose=false);
[~, vort] = pivlab.derive(r, "vorticity");
testCase.verifyEqual(size(vort), size(r.u));
f = fullfile(testCase.TestData.Dir, 'ensemble_session.mat');
pivlab.saveSession(r, f, Verbose=false);
q = pivlab.loadSession(f);
testCase.verifyEqual(q.px.u, r.px.u);
close(pivlab.display(r, Overlay="vorticity"));
end

function test_analyze_dcc(testCase)
imgs = testCase.TestData.Imgs;
r = pivlab.analyze(imgs, Algorithm="dcc", Pairs=1, Verbose=false);
testCase.verifyEqual(spacing(r), 32);
fft = testCase.TestData.Res;
testCase.verifyGreaterThan(nnz(isfinite(r.u)), 0.9*numel(r.u));
% DCC agrees with the FFT result
fu = interp2(double(fft.px.x), double(fft.px.y), double(fft.px.u_raw(:,:,1)), double(r.px.x), double(r.px.y));
d = abs(double(r.px.u_raw(:)) - fu(:));
testCase.verifyLessThan(median(d, 'omitnan'), 0.5);
r2 = pivlab.analyze(imgs, Algorithm="dcc", InterrogationArea=48, Step=16, Pairs=1, Verbose=false);
testCase.verifyEqual(spacing(r2), 16);
r3 = pivlab.analyze(imgs, Algorithm="dcc", SubpixelFinder="gauss2d", Pairs=1, Verbose=false);
testCase.verifyNotEqual(r3.px.u_raw, r.px.u_raw);
W = {'Passes', 3; 'PassSizes', [32 16 16]; 'Robustness', "high"; 'DisableAutocorrelation', true; 'RepeatLastPass', true; 'Uncertainty', true};
for k = 1:size(W,1)
    out = helper_warning_message('pivlab:analyze:noEffect', 'pivlab.analyze', imgs, 'Algorithm', "dcc", W{k,1}, W{k,2}, 'Pairs', 1, 'Verbose', false);
    testCase.verifySubstring(out, [W{k,1} ' has no effect'], W{k,1});
end
end

function test_analyze_optical_flow(testCase)
% (needs the wavelet filter matrices, about 260 MB, downloaded at the first use of the optical flow)
testCase.assumeTrue(isfolder(fullfile(testCase.TestData.Root,'+wOFV','Filter matrices')), ...
    'wOFV filter matrices not downloaded yet');
% a small region keeps the optical flow fast (patch size 256 px)
imgs = pivlab.preprocess(pivlab.readImages(testCase.TestData.Files(1:2), "pairwise"), Roi=[300 300 300 300], Verbose=false);
r = pivlab.analyze(imgs, Algorithm="ofv", OFVPyramidLevels=3, Verbose=false);
testCase.verifyEqual(r.settings.analysis.Algorithm, "ofv");
testCase.verifyGreaterThan(nnz(isfinite(r.u)), 0.9*numel(r.u));
% dense result, close to the FFT result
f = pivlab.analyze(imgs, Verbose=false);
testCase.verifyGreaterThan(numel(r.u), numel(f.u));
fu = interp2(double(f.px.x), double(f.px.y), double(f.px.u_raw), double(r.px.x), double(r.px.y));
d = abs(double(r.px.u_raw) - fu);
testCase.verifyLessThan(median(d(:), 'omitnan'), 0.5);
% every optical flow option changes the result
O = {'OFVSmoothness', 20; 'OFVPyramidLevels', 4; 'OFVMedianFilter', "3x3"; 'OFVMedianFilter', "5x5"};
for k = 1:size(O,1)
    args = {O{k,1}, O{k,2}};
    if ~strcmp(O{k,1}, 'OFVPyramidLevels')
        args = [args {'OFVPyramidLevels', 3}]; %#ok<AGROW>
    end
    o = pivlab.analyze(imgs, 'Algorithm', "ofv", args{:}, 'Verbose', false);
    testCase.verifyNotEqual(o.px.u_raw, r.px.u_raw, sprintf('%s = %s', O{k,1}, string(O{k,2})));
end
% options of the correlation algorithms: warning
W = {'InterrogationArea', 32; 'Step', 16; 'Passes', 3; 'SubpixelFinder', "gauss2d"; 'Parallel', true};
for k = 1:size(W,1)
    out = helper_warning_message('pivlab:analyze:noEffect', 'pivlab.analyze', imgs, 'Algorithm', "ofv", 'OFVPyramidLevels', 3, W{k,1}, W{k,2}, 'Verbose', false);
    testCase.verifySubstring(out, [W{k,1} ' has no effect'], W{k,1});
end
% the chain works on optical flow results (dense grid)
r = pivlab.filter(r, Verbose=false);
[~, v] = pivlab.derive(r, "vorticity");
testCase.verifyEqual(size(v), size(r.u));
end

function test_image_smaller_than_interrogation_area(testCase)
% a clear message instead of an index error (fft, ensemble) or an empty result (dcc) (2026-10-22)
files = write_images(testCase.TestData.Dir, 'strip', rand(24, 300), 2);
imgs = pivlab.readImages(files, "pairwise");
testCase.verifyError(@() pivlab.analyze(imgs, Verbose=false), 'PIVlab:areaTooSmall');
testCase.verifyError(@() pivlab.analyze(imgs, Algorithm="dcc", Verbose=false), 'PIVlab:areaTooSmall');
testCase.verifyError(@() pivlab.analyze(imgs, Algorithm="ensemble", Verbose=false), 'PIVlab:areaTooSmall');
% one pass with a window that fits works, the spatial derivatives of a single row of vectors are NaN
files = write_images(testCase.TestData.Dir, 'strip16', rand(16, 300), 2);
res = pivlab.analyze(pivlab.readImages(files, "pairwise"), InterrogationArea=16, Step=8, Passes=1, Verbose=false);
testCase.assertEqual(size(res.u, 1), 1, 'the test needs a single row of vectors');
[~, vort] = pivlab.derive(res, "vorticity");
testCase.verifyEqual(size(vort), size(res.u));
testCase.verifyTrue(all(isnan(vort(:))));
end

function test_ensemble_on_images_without_particles(testCase)
% no correlation peak anywhere: all vectors NaN instead of an index error in peakfinding (2026-10-22)
files = write_images(testCase.TestData.Dir, 'uniform', 0.5 * ones(256, 256), 2);
imgs = pivlab.readImages(files, "pairwise");
res = evalc_analyze(imgs);
testCase.verifyTrue(all(isnan(res.u(:))));
end

%% ------------------------------------------------------------------ helpers

function res = evalc_analyze(imgs)
% ensemble analysis without the quality warnings in the test output
[~, res] = evalc('pivlab.analyze(imgs, Algorithm="ensemble", Verbose=false)');
end

function files = write_images(folder, name, I, pairs)
% the same image as A and B of every pair
files = strings(1, 2 * pairs);
for k = 1:2 * pairs
    files(k) = fullfile(folder, sprintf('%s_%02d.tif', name, k));
    imwrite(I, files(k));
end
end

function d = spacing(res)
d = double(res.px.x(1,2) - res.px.x(1,1));
end
