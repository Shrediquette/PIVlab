function tests = test_truth_piv_e2e
%TEST_TRUTH_PIV_E2E The whole chain with PIV error: synthetic particle images (300 x 300 px) of a known
%   linear flow -> pivlab.analyze (fft multipass, ensemble, dcc, wavelet optical flow) -> pivlab.filter
%   -> pivlab.toMetric -> pivlab.derive, for all axis settings and calibrations: velocities,
%   coordinates and gradients match the truth within the PIV error. The optical flow test needs the
%   wOFV filter matrices (+wOFV/Filter matrices, downloaded at the first use of the optical flow in
%   PIVlab) and is skipped without them. No PIVlab window.
%   Run with: run_pivlab_tests('test_truth_piv_e2e')
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
helper_setup_once(testCase);
F = helper_truth_flow('linear', [300 300]);
[xg, yg] = meshgrid(1:4:304, 1:4:304);
T = helper_truth_field(F, xg, yg);
n = 4;
files = strings(1, 2 * n);
for k = 1:n
    [A, B] = simulate.gui_images(xg, yg, T.u, T.v, ImageSize=F.size, Particles=25000, Diameter=3, ...
        DiameterVariation=0.5, Seed=10 + k);
    files(2 * k - 1) = fullfile(testCase.TestData.Dir, sprintf('e2e_%02dA.png', k));
    files(2 * k) = fullfile(testCase.TestData.Dir, sprintf('e2e_%02dB.png', k));
    imwrite(A, files(2 * k - 1));
    imwrite(B, files(2 * k));
end
imgs = pivlab.readImages(files, "pairwise");
testCase.TestData.F = F;
testCase.TestData.Res.fft = pivlab.analyze(imgs, Algorithm="fft", InterrogationArea=48, Step=16, ...
    Passes=2, PassSizes=24, Verbose=false);
testCase.TestData.Res.ensemble = pivlab.analyze(imgs, Algorithm="ensemble", InterrogationArea=48, Step=16, ...
    Passes=2, PassSizes=24, Verbose=false);
testCase.TestData.Res.dcc = pivlab.analyze(imgs, Algorithm="dcc", InterrogationArea=32, Step=16, Verbose=false);
testCase.TestData.Imgs = imgs;
end

function teardownOnce(testCase)
helper_teardown_once(testCase);
end

function setup(testCase)
helper_truth_log(testCase, 'start');
end

function teardown(testCase)
helper_truth_log(testCase, 'end');
end

function test_fft_multipass(testCase)
check_algorithm(testCase, "fft", 4);
end

function test_ensemble(testCase)
check_algorithm(testCase, "ensemble", 1);
end

function test_dcc(testCase)
check_algorithm(testCase, "dcc", 4);
end

function test_optical_flow(testCase)
% dense result (one vector per pixel, patch size 256 px). Measured: rms error about 0.01 px/frame,
% max 0.05 inside, up to 0.2 in the outermost 8 px, which are left out.
testCase.assumeTrue(isfolder(fullfile(testCase.TestData.Root, '+wOFV', 'Filter matrices')), ...
    'wOFV filter matrices not downloaded yet');
testCase.TestData.Res.ofv = pivlab.analyze(testCase.TestData.Imgs, Algorithm="ofv", Verbose=false);
check_algorithm(testCase, "ofv", 4, 8);
end

%% ------------------------------------------------------------------ local functions

function check_algorithm(testCase, alg, n_frames, border)
% measured on these images (px/frame): rms error about 0.02, max about 0.08, vorticity median
% within 1 %. Tolerances: rms 0.05, max 0.2, median of the gradients 3 %, 95th percentile 50 %.
% border: vectors closer than this to the image border (px) are not checked (default: only the
% outermost row and column of vectors)
if nargin < 4
    border = [];
end
D = testCase.TestData;
F = D.F;
res = D.Res.(alg);
testCase.verifyEqual(size(res.px.u, 3), n_frames, alg + ": number of frames");
res = pivlab.filter(res, Verbose=false);
x = double(res.px.x);
y = double(res.px.y);
T = helper_truth_field(F, x, y);
if isempty(border)
    inner = false(size(x));
    inner(2:end-1, 2:end-1) = true;
else
    inner = x > border & x <= F.size(2) - border & y > border & y <= F.size(1) - border;
end
C = helper_truth_cases();
for k = 1:numel(C)
    c = C(k);
    r = helper_truth_calibrate(res, c);
    E = helper_truth_expected(T, c, x, y, F.size);
    name = alg + ", " + c.name;
    testCase.verifyEqual(r.units, c.units, name + ": units");
    helper_truth_verify(testCase, r.x, E.x, 1e-6, char(name + ": x"));
    helper_truth_verify(testCase, r.y, E.y, 1e-6, char(name + ": y"));
    for f = 1:n_frames
        eu = double(r.u(:, :, f)) - E.u;
        ev = double(r.v(:, :, f)) - E.v;
        verify_error(testCase, eu(inner), 0.05 * E.fv, 0.2 * E.fv, name + ": u, frame " + f);
        verify_error(testCase, ev(inner), 0.05 * E.fv, 0.2 * E.fv, name + ": v, frame " + f);
    end
    % gradients: median close to the truth, right sign. g = size of the gradients (the divergence
    % 2a is small compared with the noise of the single-frame gradients)
    g = max(abs([E.vorticity(1) E.strain(1) E.divergence(1)]));
    pairs = {"vorticity", E.vorticity; "divergence", E.divergence; "strain", E.strain; "qcriterion", E.qcriterion};
    for q = 1:size(pairs, 1)
        [~, m] = pivlab.derive(r, pairs{q, 1});
        m = double(m(:, :, 1));
        truth = pairs{q, 2}(1);       % constant for the linear flow
        med = median(m(inner), 'omitnan');
        if alg == "ofv"
            % optical flow: the gradients are taken on the 1 px grid. Their medians are within 1 %,
            % but single values are noisy: 95th percentile of the error about 0.67 g (tolerance g).
            % Q is a product of gradients: the noise (interquartile range about 6 times Q) biases its
            % median to about 15 % of the truth, also after spatial smoothing: only the sign is checked.
            if pairs{q, 1} == "qcriterion"
                testCase.verifyEqual(sign(med), sign(truth), ...
                    sprintf('%s: sign of the median qcriterion %.4g, truth %.4g', name, med, truth));
                continue
            end
            tol = 0.03 * g;
            testCase.verifyLessThanOrEqual(prctile(abs(m(inner) - truth), 95), g, ...
                sprintf('%s: 95th percentile of the %s error', name, pairs{q, 1}));
        elseif pairs{q, 1} == "qcriterion"
            % Q = omega^2 - a^2 - s^2 is a small difference of products of noisy gradients: the noise
            % biases it (about -15 % with fft, -30 % with dcc here): only size and sign are checked
            tol = 0.4 * abs(truth);
        else
            tol = 0.03 * g;
            testCase.verifyLessThanOrEqual(prctile(abs(m(inner) - truth), 95), 0.5 * g, ...
                sprintf('%s: 95th percentile of the %s error', name, pairs{q, 1}));
        end
        testCase.verifyLessThanOrEqual(abs(med - truth), tol, ...
            sprintf('%s: median %s %.4g, truth %.4g', name, pairs{q, 1}, med, truth));
    end
end
end

function verify_error(testCase, e, rms_tol, max_tol, name)
e = e(~isnan(e));
testCase.verifyNotEmpty(e, name + ": no valid vectors");
testCase.verifyLessThanOrEqual(sqrt(mean(e.^2)), rms_tol, sprintf('%s: rms error %.3g (tolerance %.3g)', name, sqrt(mean(e.^2)), rms_tol));
testCase.verifyLessThanOrEqual(max(abs(e)), max_tol, sprintf('%s: max error %.3g (tolerance %.3g)', name, max(abs(e)), max_tol));
end
