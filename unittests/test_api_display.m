function tests = test_api_display
%TEST_API_DISPLAY Command-line API: pivlab.display with every option (images of all variants are
%   copied to tempdir/pivlab_api_display_images for a look). No PIVlab window is opened.
%   Run with: results = runtests('unittests/test_api_display.m')
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
helper_setup_once(testCase);
testCase.TestData.Files = helper_files('jet', 3);
testCase.TestData.Figure = figure('Units','pixels','Position',[20 40 1200 900]);
testCase.TestData.Imgs = pivlab.preprocess(pivlab.readImages(testCase.TestData.Files, "pairwise"), Verbose=false);
end

function teardownOnce(testCase)
helper_teardown_once(testCase);
end

function test_display_every_option(testCase)
m = false(testCase.TestData.Imgs.imageSize); m(300:500, 400:700) = true;
res = pivlab.preprocess(testCase.TestData.Imgs, Roi=[50 50 1000 800], Mask=m, Verbose=false);
res = pivlab.analyze(res, Pairs=1:2, Verbose=false);
res = pivlab.filter(res, Verbose=false);
res = pivlab.toMetric(res, DeltaT=0.001, PxPerMeter=5000, Verbose=false);
fig = testCase.TestData.Figure;
if ~isgraphics(fig)   % closed by an earlier test
    fig = figure('Units','pixels','Position',[20 40 1200 900]);
end
outdir = fullfile(testCase.TestData.Dir, 'display');
mkdir(outdir);
Q = ["none","vorticity","magnitude","u","v","divergence","qcriterion","shear","strain","direction","lic","correlation"];
V = {};
for q = Q
    V(end+1,:) = {"overlay_" + q, {'Overlay', q}}; %#ok<AGROW>
end
for b = ["image","preprocessed","black","white","raw"]
    V(end+1,:) = {"background_" + b, {'Background', b}}; %#ok<AGROW>
end
cmaps = ["parula","hsv","jet","hsb","hot","cool","spring","summer","autumn","winter","gray","bone","copper","pink","lines","plasma"];
for c = cmaps
    V(end+1,:) = {"colormap_" + c, {'Overlay', "vorticity", 'Colormap', c}}; %#ok<AGROW>
end
for st = [256 128 64 32 16 8 4 2]
    V(end+1,:) = {"steps_" + st, {'Overlay', "vorticity", 'ColormapSteps', st}}; %#ok<AGROW>
end
for cb = ["east","west","north","south","none"]
    V(end+1,:) = {"colorbar_" + cb, {'Overlay', "magnitude", 'Colorbar', cb}}; %#ok<AGROW>
end
for cf = ["compact","scientific","fixed"]
    V(end+1,:) = {"cbformat_" + cf, {'Overlay', "magnitude", 'ColorbarFormat', cf}}; %#ok<AGROW>
end
for mi = ["bilinear","bicubic","nearest"]
    V(end+1,:) = {"interp_" + mi, {'Overlay', "vorticity", 'MapInterpolation', mi}}; %#ok<AGROW>
end
for rv = ["off","top left","top right","bottom left","bottom right"]
    V(end+1,:) = {"refvec_" + strrep(rv," ","_"), {'ReferenceVector', rv, 'ReferenceLength', 0.5}}; %#ok<AGROW>
end
V = [V; {
    "enhance",          {'EnhanceImage', true}
    "alpha_0",          {'Overlay', "vorticity", 'Alpha', 0}
    "alpha_1",          {'Overlay', "vorticity", 'Alpha', 1}
    "colorlimits",      {'Overlay', "vorticity", 'ColorLimits', [-50 50]}
    "extrapolate",      {'Overlay', "vorticity", 'ExtrapolateBorder', true}
    "novectors",        {'Overlay', "vorticity", 'Vectors', false}
    "veccolor_name",    {'VectorColor', "cyan"}
    "veccolor_rgb",     {'VectorColor', [1 0 1]}
    "veccolor_mag",     {'VectorColor', "magnitude"}
    "veccolor_mag_cb",  {'VectorColor', "magnitude", 'Colorbar', "south"}
    "interp_color",     {'InterpolatedColor', "red", 'SecondPeakColor', [1 1 0]}
    "vecscale_auto",    {'VectorScale', "auto"}
    "vecscale_3",       {'VectorScale', 3}
    "vecskip_3",        {'VectorSkip', 3}
    "vecwidth_2",       {'VectorWidth', 2}
    "uniform",          {'UniformLength', true}
    "power",            {'PowerScale', 0.3}
    "subtract",         {'Subtract', [0.05 0]}
    "nomask",           {'ShowMask', false}
    "masktransp_0",     {'MaskTransparency', 0}
    "masktransp_100",   {'MaskTransparency', 100}
    "noroi",            {'ShowROI', false}
    "title",            {'Title', "My title"}
    "notitle",          {'Title', ""}
    "frame2",           {'Frame', 2}
    }];
for k = 1:size(V,1)
    clf(fig);
    ax = axes(fig);
    name = char(V{k,1});
    try
        [f2, a2] = pivlab.display(res, V{k,2}{:}, 'Parent', ax);
        drawnow;
        testCase.verifyEqual(a2, ax, name);
        testCase.verifyEqual(f2, fig, name);
        exportgraphics(ax, fullfile(outdir, [name '.png']));
    catch err
        testCase.verifyFail(sprintf('%s: %s', name, err.message));
    end
end
% effects that can be checked on the graphics objects
clf(fig); ax = axes(fig);
pivlab.display(res, Overlay="vorticity", Colormap="gray", ColormapSteps=16, Parent=ax);
testCase.verifySize(colormap(ax), [16 3]);
helper_verify_near(testCase, colormap(ax), gray(16), 'AbsTol', 1e-12);
cb = findall(fig, 'Type', 'colorbar');
testCase.verifyNumElements(cb, 1);
testCase.verifyEqual(cb.Location, 'eastoutside');
clf(fig); ax = axes(fig);
pivlab.display(res, Overlay="vorticity", ColorLimits=[-50 50], Parent=ax);
cb = findall(fig, 'Type', 'colorbar');
labels = cellstr(cb.TickLabels);
testCase.verifyEqual(strtrim(labels{1}), '-50');
testCase.verifyEqual(strtrim(labels{end}), '50');
clf(fig); ax = axes(fig);
pivlab.display(res, Overlay="vorticity", Colorbar="none", Parent=ax);
testCase.verifyEmpty(findall(fig, 'Type', 'colorbar'));
clf(fig); ax = axes(fig);
pivlab.display(res, Overlay="vorticity", Vectors=false, Parent=ax);
testCase.verifyEmpty(findobj(ax, 'Type', 'quiver'));
clf(fig); ax = axes(fig);
pivlab.display(res, Title="My title", Parent=ax);
testCase.verifyEqual(ax.Title.String, 'My title');
clf(fig); ax = axes(fig);
pivlab.display(res, Frame=2, Parent=ax);
testCase.verifySubstring(ax.Title.String, 'Jet_0002A');
clf(fig); ax = axes(fig);
pivlab.display(res, ShowROI=true, Parent=ax);
testCase.verifyNotEmpty(findobj(ax, 'Tag', 'roiplot'));
clf(fig); ax = axes(fig);
pivlab.display(res, ShowROI=false, Parent=ax);
testCase.verifyEmpty(findobj(ax, 'Tag', 'roiplot'));
n1 = numel(vector_x(ax, res));
clf(fig); ax = axes(fig);
pivlab.display(res, VectorSkip=3, ShowROI=false, Parent=ax);
testCase.verifyLessThan(numel(vector_x(ax, res)), n1/4);
clf(fig); ax = axes(fig);
pivlab.display(res, Background="black", Vectors=false, ShowMask=false, ShowROI=false, Parent=ax);
im = findobj(ax, 'Type', 'image');
testCase.verifyEqual(max(double(im(end).CData(:))), 0);
% without Parent: a new figure
before = numel(findall(groot, 'Type', 'figure'));
[f3, a3] = pivlab.display(res);
testCase.verifyEqual(numel(findall(groot, 'Type', 'figure')), before + 1);
testCase.verifyEqual(a3.Parent, f3);
close(f3);
% Settings: display group
s = res.settings; s.display.Colormap = "jet"; s.display.ColormapSteps = 8;
clf(fig); ax = axes(fig);
pivlab.display(res, Overlay="vorticity", Colormap="jet", ColormapSteps=8, Parent=ax);
expected = colormap(ax);
clf(fig); ax = axes(fig);
pivlab.display(res, Overlay="vorticity", Settings=s, Parent=ax);
testCase.verifyEqual(colormap(ax), expected);
testCase.verifySize(expected, [8 3]);
% wrong values give clear errors
W = {'Frame', 3, 'pivlab:display:frame'; 'Colormap', "rainbow", 'pivlab:display:colormap'; ...
     'Colorbar', "inside", 'pivlab:display:colorbar'; 'ReferenceVector', "middle", 'pivlab:display:reference'; ...
     'VectorColor', "sky", 'pivlab:display:color'; 'Overlay', "speed", 'pivlab:derive:quantity'};
for k = 1:size(W,1)
    clf(fig); ax = axes(fig);
    testCase.verifyEqual(helper_error_id('pivlab.display', res, W{k,1}, W{k,2}, 'Parent', ax), W{k,3}, W{k,1});
end
testCase.verifyNotEmpty(helper_error_id('pivlab.display', res, 'Background', "grey"));
testCase.verifyNotEmpty(helper_error_id('pivlab.display', res, 'ColorbarFormat', "long"));
% missing images: black background with a warning
moved = res;
moved.images.filepath{1} = fullfile(testCase.TestData.Dir, 'missing.jpg');
clf(fig); ax = axes(fig);
lastwarn('');
pivlab.display(moved, Parent=ax);
[~, id] = lastwarn;
testCase.verifyEqual(id, 'pivlab:display:image');
copyfile(outdir, fullfile(tempdir, 'pivlab_api_display_images'), 'f');
end

%% ------------------------------------------------------------------ helpers

function x = vector_x(ax, res) %#ok<INUSD>
% x positions of the drawn (valid) vectors
x = [];
q = findobj(ax, 'Type', 'quiver');
for k = 1:numel(q)
    x = [x; q(k).XData(:)]; %#ok<AGROW>
end
end
