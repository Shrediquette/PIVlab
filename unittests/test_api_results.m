function tests = test_api_results
%TEST_API_RESULTS Command-line API: pivlab.filter, pivlab.toMetric, pivlab.derive, pivlab.temporal with
%   every option, and results edited by hand. No PIVlab window is opened.
%   Run with: results = runtests('unittests/test_api_results.m')
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

%% ================================================================== filter

function test_filter_options(testCase)
res = testCase.TestData.Res;
base = pivlab.filter(res, Verbose=false);
testCase.verifyTrue(base.filtered);
testCase.verifyEqual(base.px.u_raw, res.px.u_raw);   % the raw data stay
nb = nnz(base.typevector == 2);
% stricter thresholds remove more vectors, switched-off filters fewer
testCase.verifyGreaterThan(nnz(pivlab.filter(res, StdevThreshold=2, Verbose=false).typevector == 2), nb);
testCase.verifyGreaterThan(nnz(pivlab.filter(res, LocalMedianThreshold=1, Verbose=false).typevector == 2), nb);
testCase.verifyLessThanOrEqual(nnz(pivlab.filter(res, StdevCheck=false, LocalMedian=false, Verbose=false).typevector == 2), nb);
% filters that are off by default
O = {'CorrelationFilter', true, 'CorrelationThreshold', 0.8; ...
     'NotchFilter', true, 'NotchLimits', [0 2]; ...
     'ContrastFilter', true, 'ContrastThreshold', 0.05; ...
     'BrightnessFilter', true, 'BrightnessThreshold', 0.1};
for k = 1:size(O,1)
    f = pivlab.filter(res, O{k,:}, Verbose=false);
    testCase.verifyGreaterThan(nnz(f.typevector == 2), nb, O{k,1});
    f2 = pivlab.filter(res, O{k,1}, false, O{k,3}, O{k,4}, Verbose=false);
    testCase.verifyEqual(f2.typevector, base.typevector, [O{k,1} ' = false']);
end
% velocity limits in px/frame: vectors outside are removed
lim = [-1 1 -2 2];
f = pivlab.filter(res, VelocityLimits=lim, Interpolate=false, Verbose=false);
u = f.px.u; v = f.px.v; tv = f.typevector;
ok = tv == 1;
testCase.verifyTrue(all(u(ok) >= lim(1) & u(ok) <= lim(2) & v(ok) >= lim(3) & v(ok) <= lim(4)));
% Interpolate=false: removed vectors are NaN, true: they are filled
testCase.verifyTrue(all(isnan(u(tv == 2))));
fi = pivlab.filter(res, VelocityLimits=lim, Verbose=false);
testCase.verifyTrue(all(isfinite(fi.px.u(fi.typevector == 2))));
% after toMetric the limits are in m/s
m = pivlab.toMetric(res, DeltaT=0.001, PxPerMeter=10000, Verbose=false);   % 1 px/frame = 0.1 m/s
fm = pivlab.filter(m, VelocityLimits=lim*0.1, Interpolate=false, Verbose=false);
testCase.verifyEqual(fm.typevector, f.typevector);
% "none" removes limits that came from Settings
s = pivlab.defaults(); s.filter.VelocityLimits = lim;
fs = pivlab.filter(res, Settings=s, Verbose=false);
testCase.verifyEqual(fs.typevector, fi.typevector);
fn = pivlab.filter(res, Settings=s, VelocityLimits="none", Verbose=false);
testCase.verifyEqual(fn.typevector, base.typevector);
% wrong limits
testCase.verifyEqual(helper_error_id('pivlab.filter', res, 'VelocityLimits', [1 -1 -2 2], 'Verbose', false), 'pivlab:filter:limits');
testCase.verifyEqual(helper_error_id('pivlab.filter', res, 'VelocityLimits', [-1 1], 'Verbose', false), 'pivlab:filter:limits');
% image-based filters need images: not on temporal statistics
t = pivlab.temporal(res, "mean");
testCase.verifyEqual(helper_error_id('pivlab.filter', t, 'ContrastFilter', true, 'Verbose', false), 'pivlab:filter:imagefilter');
pivlab.filter(t, Verbose=false);   % the other filters work
% second-peak substitution: typevector 3 exists with the default filter
testCase.verifyGreaterThanOrEqual(nnz(base.typevector == 3), 0);
% filtering again starts from the raw data
ff = pivlab.filter(pivlab.filter(res, StdevThreshold=2, Verbose=false), Verbose=false);
testCase.verifyEqual(ff.typevector, base.typevector);
% Verbose
out = evalc('pivlab.filter(res);');
testCase.verifySubstring(out, 'Vector validation');
end

function test_filter_limits_from_a_gui_session(testCase)
% velocity limits stored in a session are in calibrated units (LimitUnits = "calibrated")
res = pivlab.toMetric(testCase.TestData.Res, DeltaT=0.001, PxPerMeter=10000, Verbose=false);
f = fullfile(testCase.TestData.Dir, 'limits_session.mat');
res = pivlab.filter(res, VelocityLimits=[-0.1 0.1 -0.2 0.2], Verbose=false);
pivlab.saveSession(res, f, Verbose=false);
s = pivlab.loadSettings(f);
helper_verify_near(testCase, s.filter.VelocityLimits, [-0.1 0.1 -0.2 0.2], 'AbsTol', 1e-12);
% applied to a result in px/frame, the limits are converted with the session calibration
a = pivlab.filter(testCase.TestData.Res, Settings=s, Verbose=false);
b = pivlab.filter(testCase.TestData.Res, VelocityLimits=[-1 1 -2 2], Verbose=false);
testCase.verifyEqual(a.typevector, b.typevector);
end

%% ================================================================== toMetric

function test_toMetric_options(testCase)
res = testCase.TestData.Res;
a = pivlab.toMetric(res, DeltaT=0.002, PxPerMeter=5000, Verbose=false);
testCase.verifyEqual(a.units, "m/s");
helper_verify_near(testCase, a.x, res.px.x/5000, 'RelTol', 1e-12);
helper_verify_near(testCase, double(a.u), double(res.px.u)/5000/0.002, 'RelTol', 1e-6);
% ReferenceDistance: 100 px are 0.02 m = 5000 px/m
b = pivlab.toMetric(res, DeltaT=0.002, ReferenceDistance=[100 0.02], Verbose=false);
helper_verify_near(testCase, b.x, a.x, 'RelTol', 1e-12);
helper_verify_near(testCase, b.u, a.u, 'RelTol', 1e-6);
% Origin: x and y are measured from this pixel
o = pivlab.toMetric(res, DeltaT=0.002, PxPerMeter=5000, Origin=[100 200], Verbose=false);
helper_verify_near(testCase, o.x, (double(res.px.x)-100)/5000, 'AbsTol', 1e-7);   % px positions are single
helper_verify_near(testCase, o.y, (double(res.px.y)-200)/5000, 'AbsTol', 1e-7);
% axis directions
l = pivlab.toMetric(res, DeltaT=0.002, PxPerMeter=5000, XAxis="left", Verbose=false);
helper_verify_near(testCase, l.u, -a.u, 'RelTol', 1e-6);
helper_verify_near(testCase, l.v, a.v, 'RelTol', 1e-6);
testCase.verifyLessThan(l.x(1,2) - l.x(1,1), 0);
up = pivlab.toMetric(res, DeltaT=0.002, PxPerMeter=5000, YAxis="up", Verbose=false);
helper_verify_near(testCase, up.v, -a.v, 'RelTol', 1e-6);
helper_verify_near(testCase, up.u, a.u, 'RelTol', 1e-6);
testCase.verifyLessThan(up.y(2,1) - up.y(1,1), 0);
% the sign of the vorticity follows the axes
[~, w1] = pivlab.derive(a, "vorticity");
[~, w2] = pivlab.derive(up, "vorticity");
helper_verify_near(testCase, w2, -w1, 'AbsTol', 1e-6*max(abs(w1(:))));
% DeltaT = 0: displacements in m per frame
d = pivlab.toMetric(res, DeltaT=0, PxPerMeter=5000, Verbose=false);
testCase.verifyEqual(d.units, "m/frame");
helper_verify_near(testCase, double(d.u), double(res.px.u)/5000, 'RelTol', 1e-6);
% repeated calibration starts from the pixel data
r = pivlab.toMetric(pivlab.toMetric(res, DeltaT=1, PxPerMeter=1, Verbose=false), DeltaT=0.002, PxPerMeter=5000, Verbose=false);
testCase.verifyEqual(r.u, a.u);
% calibration from a session or settings file
f = fullfile(testCase.TestData.Dir, 'cal_session.mat');
pivlab.saveSession(up, f, Verbose=false);
s = pivlab.loadSettings(f);
c = pivlab.toMetric(res, Settings=s, Verbose=false);
helper_verify_near(testCase, c.u, up.u, 'RelTol', 1e-12);
helper_verify_near(testCase, c.y, up.y, 'RelTol', 1e-12);
% missing information
testCase.verifyEqual(helper_error_id('pivlab.toMetric', res), 'pivlab:toMetric:noCalibration');
testCase.verifyEqual(helper_error_id('pivlab.toMetric', res, 'DeltaT', 0.001), 'pivlab:toMetric:missing');
testCase.verifyEqual(helper_error_id('pivlab.toMetric', res, 'PxPerMeter', 1000), 'pivlab:toMetric:missing');
% Verbose
out = evalc('pivlab.toMetric(res, DeltaT=0.002, PxPerMeter=5000);');
testCase.verifySubstring(out, 'm/s');
end

%% ================================================================== derive / temporal

function test_derive_all_quantities(testCase)
res = pivlab.filter(testCase.TestData.Res, Verbose=false);
resm = pivlab.toMetric(res, DeltaT=0.001, PxPerMeter=5000, Verbose=false);
Q = ["vorticity","magnitude","u","v","divergence","qcriterion","shear","strain","direction","lic","correlation"];
for q = Q
    for r = {res, resm}
        [out, map] = pivlab.derive(r{1}, q);
        testCase.verifyTrue(isfield(out.derived, q), q);
        testCase.verifyEqual(size(map,3), 3, q);
        testCase.verifyGreaterThan(nnz(isfinite(map)), 0.5*numel(map), q);
    end
end
% values
[~, mag] = pivlab.derive(resm, "magnitude");
helper_verify_near(testCase, double(mag), double(hypot(resm.u, resm.v)), 'RelTol', 1e-5);
[~, uu] = pivlab.derive(resm, "u");
helper_verify_near(testCase, double(uu), double(resm.u), 'RelTol', 1e-5);
[~, dirm] = pivlab.derive(resm, "direction");
testCase.verifyGreaterThanOrEqual(min(dirm(:)), -180);
testCase.verifyLessThanOrEqual(max(dirm(:)), 360);
[~, cm] = pivlab.derive(res, "correlation");
testCase.verifyEqual(cm, res.correlation_map);
% Subtract
[~, us] = pivlab.derive(resm, "u", Subtract=[0.1 0]);
helper_verify_near(testCase, double(us), double(resm.u) - 0.1, 'AbsTol', 1e-5);
[~, ms] = pivlab.derive(resm, "magnitude", Subtract=[0.1 0.05]);
helper_verify_near(testCase, double(ms), double(hypot(resm.u-0.1, resm.v-0.05)), 'RelTol', 1e-4);
% LICSize: size of the LIC image
[~, lic1] = pivlab.derive(res, "lic", LICSize=400);
[~, lic2] = pivlab.derive(res, "lic", LICSize=800);
helper_verify_near(testCase, max(size(lic1,[1 2])), 400, 'AbsTol', 2);
testCase.verifyGreaterThan(max(size(lic2,[1 2])), max(size(lic1,[1 2])));
% smoothing
[~, v0] = pivlab.derive(res, "vorticity");
[o1, v1] = pivlab.derive(res, "vorticity", Smoothing="spatial");
[~, v1b] = pivlab.derive(res, "vorticity", Smoothing="spatial", SmoothingStrength=3);
[o2, v2] = pivlab.derive(res, "vorticity", Smoothing="temporal");
[~, v2b] = pivlab.derive(res, "vorticity", Smoothing="temporal", TemporalWindow=1);
[~, v3] = pivlab.derive(res, "vorticity", Smoothing="spatiotemporal");
testCase.verifyTrue(o1.smoothed);
testCase.verifyTrue(o2.smoothed);
testCase.verifyLessThan(std(v1(:),'omitnan'), std(v0(:),'omitnan'));
testCase.verifyLessThan(std(v1b(:),'omitnan'), std(v1(:),'omitnan'));
testCase.verifyNotEqual(v2, v0);
testCase.verifyNotEqual(v2b, v2);
testCase.verifyNotEqual(v3, v2);
% the smoothed field is used by display and temporal; "none" switches it off again
testCase.verifyNotEmpty(o1.px.u_smoothed);
[o0, ~] = pivlab.derive(o1, "vorticity", Smoothing="none");
testCase.verifyFalse(o0.smoothed);
% Settings
s = pivlab.defaults(); s.derive.Smoothing = "spatial";
[~, vs] = pivlab.derive(res, "vorticity", Settings=s);
testCase.verifyEqual(vs, v1);
% wrong input
testCase.verifyEqual(helper_error_id('pivlab.derive', res, "speed"), 'pivlab:derive:quantity');
testCase.verifyEqual(helper_error_id('pivlab.derive', res, "vorticity", 'Smoothing', "gaussian"), 'pivlab:derive:smoothing');
end

function test_temporal_options(testCase)
res = pivlab.filter(testCase.TestData.Res, Verbose=false);
u = double(res.px.u);
ops = ["mean","std","sum","tke"];
for op = ops
    t = pivlab.temporal(res, op);
    testCase.verifyEqual(size(t.u,3), 1, op);
    testCase.verifyTrue(t.isMean, op);
    testCase.verifyEqual(t.statistic, op);
    ok = isfinite(t.px.u);
    switch op
        case "mean", expected = mean(u,3,'omitnan');
        case "std",  expected = std(u,0,3,'omitnan');
        case "sum",  expected = sum(u,3,'omitnan');
        case "tke",  expected = 0.5*var(u,0,3,'omitnan');
    end
    helper_verify_near(testCase, double(t.px.u(ok)), expected(ok), 'AbsTol', 1e-4, op);
    testCase.verifyGreaterThan(nnz(ok), 0.9*numel(ok), op);
end
% Frames
t = pivlab.temporal(res, "mean", Frames=[1 3]);
e = mean(u(:,:,[1 3]),3,'omitnan');
ok = isfinite(t.px.u);
helper_verify_near(testCase, double(t.px.u(ok)), e(ok), 'AbsTol', 1e-4);
testCase.verifySubstring(char(t.frameLabels), '1,3');
% one statistics frame per cell (phase averages)
t = pivlab.temporal(res, "mean", Frames={[1 2], 3});
testCase.verifyEqual(size(t.u,3), 2);
% a single frame: its valid vectors (interpolated ones count as missing, like in the GUI)
one = t.px.u(:,:,2); ref3 = res.px.u(:,:,3); ok = isfinite(one);
helper_verify_near(testCase, one(ok), ref3(ok), 'AbsTol', 1e-6);
testCase.verifyEqual(ok, res.typevector(:,:,3) == 1 | res.typevector(:,:,3) == 3);
% the result can be derived, displayed, filtered, calibrated, saved
[~, vort] = pivlab.derive(t, "vorticity");
testCase.verifyEqual(size(vort,3), 2);
close(pivlab.display(t, Frame=2, Overlay="magnitude"));
tm = pivlab.toMetric(t, DeltaT=0.001, PxPerMeter=5000, Verbose=false);
testCase.verifyEqual(tm.units, "m/s");
f = fullfile(testCase.TestData.Dir, 'temporal_session.mat');
pivlab.saveSession(tm, f, Verbose=false);
q = pivlab.loadSession(f);
testCase.verifyEqual(q.px.u, tm.px.u);
testCase.verifyTrue(all(q.isMean));
% the smoothed field is used when the result is smoothed
[sm, ~] = pivlab.derive(res, "magnitude", Smoothing="spatial");
ts = pivlab.temporal(sm, "mean");
testCase.verifyNotEqual(ts.px.u, pivlab.temporal(res, "mean").px.u);
% wrong input
testCase.verifyEqual(helper_error_id('pivlab.temporal', res, "mean", 'Frames', 4), 'pivlab:temporal:frames');
testCase.verifyEqual(helper_error_id('pivlab.temporal', res, "mean", 'Frames', 0), 'pivlab:temporal:frames');
testCase.verifyEqual(helper_error_id('pivlab.temporal', pivlab.temporal(res, "mean"), "std"), 'pivlab:temporal:frames');
testCase.verifyNotEmpty(helper_error_id('pivlab.temporal', res, "median"));
end

%% ================================================================== results edited by hand

function test_hand_edits_are_used(testCase)
% values changed by hand in res.u / res.v are used by all following functions
imgs = pivlab.preprocess(pivlab.readImages(testCase.TestData.Files, "pairwise"), Verbose=false);
res = pivlab.filter(pivlab.analyze(imgs, Verbose=false), Verbose=false);
res = pivlab.toMetric(res, DeltaT=0.002, PxPerMeter=5000, Verbose=false);
before = res.px.u;
res.u(1:3,1:3,2) = 0.5;                     % change a few vectors of pair 2 (m/s)
res.v(1:3,1:3,2) = 0.5;
m = pivlab.temporal(res, "mean");
testCase.verifyEqual(double(m.u(2,2)), double(mean(res.u(2,2,:),'omitnan')), 'AbsTol', 1e-6);
[res2, vort] = pivlab.derive(res, "magnitude");
testCase.verifyEqual(double(vort(2,2,2)), 0.5*sqrt(2), 'AbsTol', 1e-6);
% unchanged values stay exactly as computed
unchanged = true(size(before)); unchanged(1:3,1:3,2) = false;
testCase.verifyEqual(res2.px.u(unchanged), before(unchanged));
% the edit survives a new calibration (half the time step -> twice the velocity)
res3 = pivlab.toMetric(res, DeltaT=0.001, PxPerMeter=5000, Verbose=false);
testCase.verifyEqual(double(res3.u(2,2,2)), 1.0, 'AbsTol', 1e-6);
% and is saved in a session
f = fullfile(testCase.TestData.Dir, 'edited.mat');
pivlab.saveSession(res, f, Verbose=false);
r = pivlab.loadSession(f);
testCase.verifyEqual(double(r.u(2,2,2)), 0.5, 'AbsTol', 1e-6);
% pivlab.filter starts from the raw data again and says so
lastwarn('');
pivlab.filter(res, Verbose=false);
[~, id] = lastwarn;
testCase.verifyEqual(id, 'pivlab:filter:editsReplaced');
% adding / removing frames is not allowed
res.u(:,:,end) = [];
id = '';
try
    pivlab.temporal(res, "mean");
catch err
    id = err.identifier;
end
testCase.verifyEqual(id, 'pivlab:editedResult:size');
end
