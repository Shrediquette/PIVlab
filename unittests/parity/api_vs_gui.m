function api_vs_gui(basedir)
%API_VS_GUI Run the pair_fft_full GUI scenario through the pivlab.* API and compare.
root = fileparts(fileparts(fileparts(mfilename('fullpath')))); % PIVlab folder of this repository
cd(root); addpath(root);
B = load(fullfile(basedir,'pair_fft_full.mat'));
files = cell(6,1);
for i = 1:3
    files{2*i-1} = fullfile(root,'Example_data',sprintf('Jet_%04dA.jpg',i));
    files{2*i}   = fullfile(root,'Example_data',sprintf('Jet_%04dB.jpg',i));
end
rng(1);
m = cell(1,3);
m{1} = {'ROI_object_rectangle',[25+randi(8) 25+randi(8) 40 35]};
m{2} = {'ROI_object_polygon',[120 90;155 95;150 130;115 125]};
m{3} = cell(0);

ok = true;
imgs = pivlab.readImages(files, "pairwise");
imgs = pivlab.preprocess(imgs, Roi=[20 20 300 220], Mask=m, Background="mean");
ok = check('background A', imgs.background.A, B.bg_A) && ok;
ok = check('background B', imgs.background.B, B.bg_B) && ok;
res = pivlab.analyze(imgs, InterrogationArea=64, Step=32, Passes=4, PassSizes=[32 16 16]);
for k = 1:3
    ok = check(sprintf('x pair %d',k), res.px.x, B.raw{1,k}) && ok;
    ok = check(sprintf('u raw pair %d',k), res.px.u_raw(:,:,k), B.raw{3,k}) && ok;
    ok = check(sprintf('v raw pair %d',k), res.px.v_raw(:,:,k), B.raw{4,k}) && ok;
    ok = check(sprintf('typevector pair %d',k), res.typevector_raw(:,:,k), B.raw{5,k}) && ok;
    ok = check(sprintf('corr map pair %d',k), res.correlation_map(:,:,k), B.raw{12,k}) && ok;
    ok = check(sprintf('u2 pair %d',k), res.px.u2(:,:,k), B.raw{13,k}) && ok;
end
res = pivlab.toMetric(res, ReferenceDistance=[100 0.01], DeltaT=0.1);
ok = check('calxy', res.calibration.calxy, B.cal.calxy) && ok;
ok = check('calu', res.calibration.calu, B.cal.calu) && ok;
res = pivlab.filter(res, StdevThreshold=7, LocalMedianThreshold=3);
for k = 1:3
    ok = check(sprintf('u filtered pair %d',k), res.px.u(:,:,k), B.validated{7,k}) && ok;
    ok = check(sprintf('v filtered pair %d',k), res.px.v(:,:,k), B.validated{8,k}) && ok;
    ok = check(sprintf('typevector filtered pair %d',k), res.typevector(:,:,k), B.validated{9,k}) && ok;
end
names = ["vorticity","magnitude","u","v","divergence","qcriterion","shear","strain","lic","direction","correlation"];
for d = 2:12
    if d == 10, continue; end % LIC depends on the GUI axes size
    [res, map] = pivlab.derive(res, names(d-1));
    for k = 1:3
        ok = check(sprintf('%s pair %d', names(d-1), k), map(:,:,k), B.derived_nosmooth{d-1,k}) && ok;
    end
end
[res, map] = pivlab.derive(res, "vorticity", Smoothing="spatial", SmoothingStrength=0.3);
for k = 1:3
    ok = check(sprintf('vorticity smoothed 2D pair %d',k), map(:,:,k), B.derived_smooth2d{1,k}) && ok;
end
[res, map] = pivlab.derive(res, "magnitude", Smoothing="spatiotemporal", SmoothingStrength=0.3, TemporalWindow=3);
for k = 1:3
    ok = check(sprintf('magnitude smoothed 2D+t pair %d',k), map(:,:,k), B.derived_smooth2dt{2,k}) && ok;
end
% temporal statistics (GUI: mean, sum, stdev, tke of frames 1:3 -> columns 4..7)
ops = ["mean","sum","std","tke"];
for o = 1:4
    t = pivlab.temporal(res, ops(o));
    ok = check(sprintf('temporal %s u', ops(o)), t.px.u, B.temporal_rl{3,3+o}) && ok;
    ok = check(sprintf('temporal %s v', ops(o)), t.px.v, B.temporal_rl{4,3+o}) && ok;
    ok = check(sprintf('temporal %s typevector', ops(o)), t.typevector, B.temporal_rl{5,3+o}) && ok;
end
if ok
    fprintf('API_VS_GUI: ALL IDENTICAL\n');
else
    fprintf('API_VS_GUI: DIFFERENCES FOUND\n');
end
end

function ok = check(name, a, b)
ok = isequaln(a, b);
if ok
    fprintf('  same  %s\n', name);
else
    if isnumeric(a) && isnumeric(b) && isequal(size(a),size(b))
        d = abs(double(a(:))-double(b(:))); d(isnan(d)) = inf;
        fprintf('  DIFF  %s: %d of %d differ, max %g (class %s / %s)\n', name, nnz(d>0), numel(a), max(d), class(a), class(b));
    else
        fprintf('  DIFF  %s: size %s / %s, class %s / %s\n', name, mat2str(size(a)), mat2str(size(b)), class(a), class(b));
    end
end
end

