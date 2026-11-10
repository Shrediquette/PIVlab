%% Tests of PIVlab_capture_particle_diameter: particle image diameter per region, no GUI
%
% Synthetic particle images (Gaussian particles, integrated over the pixels) with a known diameter.
% Checks that the measured diameter matches, that it does not depend on seeding density, brightness,
% background and noise (unlike PIVlab_capture_sharpness_indicator), and that a focus that changes
% from left to right (tilted focal plane, Scheimpflug not adjusted) is seen in the columns.
%
% Run with:
%   runtests('unittests/test_core_particle_diameter.m')

function tests = test_core_particle_diameter
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
addpath(helper_root());
addpath(fullfile(helper_root(), 'PIVlab_capture_resources'));
testCase.TestData.size = [600 900];
end

% -------------------------------------------------------------------------

function test_known_diameter(testCase)
for d = [2 3 5 8 12]
    settings = default_image_settings();
    settings.diameter_left = d;
    settings.diameter_right = d;
    settings.ppp = realistic_ppp(d);
    img = render_particles(testCase.TestData.size, settings);
    result = PIVlab_capture_particle_diameter(img);
    testCase.verifySize(result.diameter, [3 3]);
    testCase.verifyEqual(result.diameter, d * ones(3), 'RelTol', 0.1, sprintf('diameter %g px', d));
end
end

function test_independent_of_image_content(testCase)
% d = 3 px in all images; seeding density, brightness, background and noise change
variants = struct('name', {}, 'field', {}, 'value', {});
variants(end+1) = struct('name', 'low density', 'field', 'ppp', 'value', 0.005);
variants(end+1) = struct('name', 'high density', 'field', 'ppp', 'value', 0.08);
variants(end+1) = struct('name', 'dim particles', 'field', 'peak', 'value', 30);
variants(end+1) = struct('name', 'bright particles', 'field', 'peak', 'value', 2500);
variants(end+1) = struct('name', 'background', 'field', 'background', 'value', 600);
variants(end+1) = struct('name', 'background gradient', 'field', 'gradient', 'value', 800);
variants(end+1) = struct('name', 'noise', 'field', 'noise', 'value', 25);
for i = 1:numel(variants)
    settings = default_image_settings();
    settings.(variants(i).field) = variants(i).value;
    img = render_particles(testCase.TestData.size, settings);
    result = PIVlab_capture_particle_diameter(img);
    testCase.verifyEqual(result.diameter, 3 * ones(3), 'RelTol', 0.1, variants(i).name);
end
end

function test_tilted_focus(testCase)
% diameter grows linearly from 2.5 px (left edge) to 6 px (right edge)
settings = default_image_settings();
settings.diameter_left = 2.5;
settings.diameter_right = 6;
img = render_particles(testCase.TestData.size, settings);
result = PIVlab_capture_particle_diameter(img);
width = testCase.TestData.size(2);
% expected: diameter at the centre of each column (the used part is centred in the region)
centres = (result.col_edges(1:end-1) + result.col_edges(2:end)) / 2;
expected = 2.5 + (6 - 2.5) * centres / width;
testCase.verifyEqual(mean(result.diameter, 1), expected, 'RelTol', 0.1);
testCase.verifyTrue(all(diff(result.diameter, 1, 2) > 0, 'all'), 'diameter does not grow from left to right');
end

function test_saturation(testCase)
settings = default_image_settings();
settings.peak = 6000;   % much more than the 12 bit range
img = uint16(min(render_particles(testCase.TestData.size, settings), 4095));
img(img >= 4095) = intmax('uint16');
result = PIVlab_capture_particle_diameter(img);
testCase.verifyTrue(all(result.saturated > 0, 'all'));
settings.peak = 1000;
result = PIVlab_capture_particle_diameter(uint16(render_particles(testCase.TestData.size, settings)));
testCase.verifyEqual(result.saturated, zeros(3));
end

function test_no_particles(testCase)
result = PIVlab_capture_particle_diameter(uint8(100 * ones(300, 400)));
testCase.verifyTrue(all(isnan(result.diameter), 'all'));
result = PIVlab_capture_particle_diameter(zeros(300, 400));
testCase.verifyTrue(all(isnan(result.diameter), 'all'));
end

function test_region_layout(testCase)
img = render_particles([300 500], default_image_settings());
result = PIVlab_capture_particle_diameter(img, 5, 1);
testCase.verifySize(result.diameter, [1 5]);
testCase.verifyEqual(result.col_edges, [0 100 200 300 400 500]);
testCase.verifyEqual(result.row_edges, [0 300]);
end

function test_overlay_median_of_last_updates(testCase)
% the Sharpness overlay shows the median of the last 5 updates per column; a new image size starts again
fig = figure('Visible', 'off');
ax = axes(fig);
old_hgui = [];
if isappdata(0, 'hgui')
    old_hgui = getappdata(0, 'hgui');
end
setappdata(0, 'hgui', fig);
setappdata(fig, 'pivlab_axis', ax);
testCase.addTeardown(@restore_hgui, fig, old_hgui);
settings = default_image_settings();
sharp = uint16(render_particles([300 450], settings));
settings.diameter_left = 9;
settings.diameter_right = 9;
settings.ppp = realistic_ppp(9);
blurred = uint16(render_particles([300 450], settings));
PIVlab_capture_sharpness_indicator(sharp, 1);
testCase.verifyEqual(shown_diameters(ax), [3 3 3], 'AbsTol', 0.35, 'first update');
PIVlab_capture_sharpness_indicator(blurred, 1);   % one outlier
PIVlab_capture_sharpness_indicator(sharp, 1);
testCase.verifyEqual(shown_diameters(ax), [3 3 3], 'AbsTol', 0.35, 'one outlier is ignored');
for i = 1:4
    PIVlab_capture_sharpness_indicator(blurred, 1);
end
testCase.verifyEqual(shown_diameters(ax), [9 9 9], 'RelTol', 0.1, 'after 5 blurred updates only blurred values are left');
PIVlab_capture_sharpness_indicator(sharp(1:200, :), 1);
testCase.verifyEqual(shown_diameters(ax), [3 3 3], 'AbsTol', 0.35, 'new image size: history starts again');
% stereo: one history per camera
delete(findobj(ax, 'tag', 'sharpness_display_text'));
PIVlab_capture_sharpness_indicator(sharp, 1, 0);
PIVlab_capture_sharpness_indicator(blurred, 1, 500);
values = shown_diameters(ax);
testCase.verifyEqual(sort(values), [3 3 3 9 9 9], 'RelTol', 0.12, 'two cameras');
end

function test_overlay_bars(testCase)
% one sharpness bar per third: full = smallest diameter seen, height = that / diameter of the third; a mark keeps
% the best value of each third (Scheimpflug adjustment: equal bars at their marks)
fig = figure('Visible', 'off');
ax = axes(fig);
old_hgui = [];
if isappdata(0, 'hgui')
    old_hgui = getappdata(0, 'hgui');
end
setappdata(0, 'hgui', fig);
setappdata(fig, 'pivlab_axis', ax);
testCase.addTeardown(@restore_hgui, fig, old_hgui);
image_size = [300 450];
full = 0.4 * image_size(1);
settings = default_image_settings();
for i = 1:3
    PIVlab_capture_sharpness_indicator(uint16(render_particles(image_size, settings)), 1);
end
[bars, marks] = bar_heights(ax);
testCase.verifyEqual(bars, full * [1 1 1], 'RelTol', 0.12, 'equal diameters: equal, (nearly) full bars');
testCase.verifyEqual(marks, full * [1 1 1], 'RelTol', 0.12, 'equal diameters: marks at the top');
testCase.verifyEqual(numel(findobj(ax, 'Type', 'patch', 'tag', 'sharpness_display_text')), 6, 'three frames + three bars');
settings.diameter_right = 6; % 3 px left, 6 px right
settings.ppp = realistic_ppp(6);
tilted_size = image_size + [0 1]; % new image size: history and best values start again
for i = 1:5
    PIVlab_capture_sharpness_indicator(uint16(render_particles(tilted_size, settings)), 1);
end
[bars, marks] = bar_heights(ax);
testCase.verifyTrue(bars(1) > bars(2) && bars(2) > bars(3), 'larger diameter on the right: the right bar is lower');
testCase.verifyEqual(bars(1), full, 'RelTol', 0.05, 'the sharpest third has a full bar');
% the diameter grows linearly from 3 to 6 px over the width: thirds at about 3.5 and 5.5 px
testCase.verifyEqual(bars(3) / bars(1), 3.5 / 5.5, 'RelTol', 0.1, 'bar ratio = inverse diameter ratio');
testCase.verifyEqual(marks, bars, 'RelTol', 0.05, 'no change: the bars are at their marks');
% defocus everything: the bars drop, the marks stay at the best values
settings.diameter_left = 6;
for i = 1:5
    PIVlab_capture_sharpness_indicator(uint16(render_particles(tilted_size, settings)), 1);
end
[bars_blurred, marks_blurred] = bar_heights(ax);
testCase.verifyEqual(marks_blurred, marks, 'RelTol', 0.05, 'the marks keep the best values');
testCase.verifyLessThan(bars_blurred(1), 0.7 * marks_blurred(1), 'left defocused: the bar is below its mark');
end

function [bars, marks] = bar_heights(ax)
% filled bar heights and mark heights above the bar base, sorted from left to right
patches = findobj(ax, 'Type', 'patch', 'tag', 'sharpness_display_text');
bars = [];
x = [];
base = [];
for i = 1:numel(patches)
    if isnumeric(patches(i).FaceColor) % the frames have FaceColor 'none'
        bars(end+1) = max(patches(i).YData) - min(patches(i).YData); %#ok<AGROW>
        x(end+1) = mean(patches(i).XData); %#ok<AGROW>
        base(end+1) = max(patches(i).YData); %#ok<AGROW>
    end
end
[~, order] = sort(x);
bars = bars(order);
base = base(order);
lines = findobj(ax, 'Type', 'line', 'tag', 'sharpness_display_text');
marks = [];
x = [];
for i = 1:numel(lines)
    marks(end+1) = lines(i).YData(1); %#ok<AGROW>
    x(end+1) = mean(lines(i).XData); %#ok<AGROW>
end
[~, order] = sort(x);
marks = base - marks(order);
end

function test_content_detection(testCase)
% particle images are recognised; a board, a photo and noise are not taken for particles (their
% "diameter" is only the size of the structures) and only the board counts as a board
settings = default_image_settings();
for d = [2 5 12]
    settings.diameter_left = d;
    settings.diameter_right = d;
    settings.ppp = realistic_ppp(d);
    img = render_particles(testCase.TestData.size, settings);
    testCase.verifyTrue(all(PIVlab_capture_particle_diameter(img).is_particles, 'all'), sprintf('particles %g px', d));
    testCase.verifyFalse(any(PIVlab_capture_edge_width(img).is_board, 'all'), sprintf('particles %g px: no board', d));
end
others = {board_image(1), imresize(imread('cameraman.tif'), 4), uint8(20 + 3 * randn(900))};
names = {'board', 'photo', 'noise'};
for i = 1:numel(others)
    % thirds, as in the Sharpness overlay
    testCase.verifyFalse(any(PIVlab_capture_particle_diameter(others{i}, 3, 1).is_particles), [names{i} ': not particles']);
end
testCase.verifyTrue(all(PIVlab_capture_edge_width(others{1}).is_board, 'all'), 'board');
testCase.verifyFalse(any(PIVlab_capture_edge_width(others{2}).is_board, 'all'), 'photo: no board');
testCase.verifyFalse(any(PIVlab_capture_edge_width(others{3}).is_board, 'all'), 'noise: no board');
end

function test_edge_width(testCase)
% 10-90 % width of a Gaussian blurred step = 2.56 sigma; grows with the blur up to sigma 6 (beyond about
% sigma 2 it reads too small: the white margins next to the markers are narrower than the blur)
widths = zeros(1, 6);
blurs = [0.7 1 2 3 4 6];
for i = 1:numel(blurs)
    r = PIVlab_capture_edge_width(board_image(blurs(i)));
    testCase.verifyTrue(all(r.is_board, 'all'), sprintf('blur %g: board', blurs(i)));
    widths(i) = median(r.width(:));
    % the same blur everywhere: the same value in all regions
    testCase.verifyEqual(r.width, widths(i) * ones(3), 'RelTol', 0.05, sprintf('blur %g: equal regions', blurs(i)));
end
testCase.verifyEqual(widths(2:3), 2.563 * sqrt(blurs(2:3).^2 + 1/12), 'RelTol', 0.15);
testCase.verifyTrue(all(diff(widths) > 0), 'width grows with the blur');
end

function test_overlay_content(testCase)
% the overlay names what it measures; other content: '-' and a hint
fig = figure('Visible', 'off');
ax = axes(fig);
old_hgui = [];
if isappdata(0, 'hgui')
    old_hgui = getappdata(0, 'hgui');
end
setappdata(0, 'hgui', fig);
setappdata(fig, 'pivlab_axis', ax);
testCase.addTeardown(@restore_hgui, fig, old_hgui);
images = {uint16(render_particles([300 450], default_image_settings())), board_image(1), imresize(imread('cameraman.tif'), 4)};
expected_text = {'Particle diameter', 'edge width', 'No particles / board'};
for i = 1:numel(images)
    PIVlab_capture_sharpness_indicator(images{i}, 1);
    texts = findobj(ax, 'Type', 'text', 'tag', 'sharpness_display_text');
    summary = '';
    for k = 1:numel(texts)
        if iscell(texts(k).String)
            summary = strjoin(texts(k).String, ' ');
        end
    end
    testCase.verifySubstring(summary, expected_text{i});
    values = shown_diameters(ax);
    if i < 3
        testCase.verifyTrue(all(isfinite(values)), [expected_text{i} ': three values']);
    else
        testCase.verifyTrue(all(isnan(values)), 'photo: no values');
    end
end
end

function ppp = realistic_ppp(d)
% particles per pixel: 0.02, but at most half of the area covered (defocused particles do not overlap into a
% speckle pattern; that case gives no value, see the dev notes)
ppp = min(0.02, 0.5 / (pi * (d / 2)^2));
end

function test_obstacles(testCase)
% particles with a dark shadow, a bright wall and a large object in the image: the value of each third
% stays the particle diameter
settings = default_image_settings();
settings.diameter_left = 3;
settings.diameter_right = 6;
img = render_particles([900 1350], settings);
img(1:300, :) = 30;                          % shadow over the top third of the image
img(:, 420:480) = 3000;                      % bright wall in the left third
[xx, yy] = meshgrid(1:1350, 1:900);
img((xx - 700).^2 + (yy - 650).^2 < 120^2) = 1500; % object in the centre third
r = PIVlab_capture_particle_diameter(img, 3, 1);
testCase.verifyTrue(all(r.is_particles), 'all thirds still have particle tiles');
centres = (r.col_edges(1:end-1) + r.col_edges(2:end)) / 2;
expected = 3 + 3 * centres / 1350;
testCase.verifyEqual(r.diameter, expected, 'RelTol', 0.15);
end

function img = board_image(blur)
% ChArUco board with 64 px checkers over the whole image
cam = simulate.camera(ImageSize=[600 900], Scale=6.4, Origin=[-5 -5]);
img = simulate.charuco_image(cam, PatternDims=[12 16], CheckerSize=10, MarkerSize=7, Blur=blur, Noise=1e-5);
end

function values = shown_diameters(ax)
% the column labels, sorted from left to right
labels = findobj(ax, 'Type', 'text', 'tag', 'sharpness_display_text');
values = [];
x = [];
for i = 1:numel(labels)
    if ischar(labels(i).String)
        values(end+1) = str2double(labels(i).String); %#ok<AGROW>
        x(end+1) = labels(i).Position(1); %#ok<AGROW>
    end
end
[~, order] = sort(x);
values = values(order);
end

function restore_hgui(fig, old_hgui)
close(fig);
if isempty(old_hgui)
    if isappdata(0, 'hgui')
        rmappdata(0, 'hgui');
    end
else
    setappdata(0, 'hgui', old_hgui);
end
end

% ------------------------------------------------------------------------- helpers

function settings = default_image_settings()
settings.ppp = 0.02;            % particles per pixel
settings.diameter_left = 3;     % e^-2 diameter at the left / right image edge [px]
settings.diameter_right = 3;
settings.peak = 800;            % mean peak intensity (single particle, centred on a pixel)
settings.background = 50;
settings.gradient = 0;          % background increase from left to right
settings.noise = 3;             % std of the Gaussian camera noise
settings.seed = 1;
end

function img = render_particles(img_size, settings)
% Gaussian particles integrated over the pixel area (erf), random peak intensity 0.3 ... 1.7 x peak
rng(settings.seed);
height = img_size(1);
width = img_size(2);
img = zeros(height, width);
n = round(settings.ppp * height * width);
x0 = rand(n, 1) * width + 0.5;
y0 = rand(n, 1) * height + 0.5;
peak = settings.peak * (0.3 + 1.4 * rand(n, 1));
for i = 1:n
    d = settings.diameter_left + (settings.diameter_right - settings.diameter_left) * (x0(i) - 0.5) / width;
    s = d / 4;
    radius = ceil(3 * s) + 1;
    cols = max(1, floor(x0(i)) - radius):min(width, floor(x0(i)) + radius);
    rows = max(1, floor(y0(i)) - radius):min(height, floor(y0(i)) + radius);
    ex = 0.5 * (erf((cols + 0.5 - x0(i)) / (sqrt(2) * s)) - erf((cols - 0.5 - x0(i)) / (sqrt(2) * s)));
    ey = 0.5 * (erf((rows + 0.5 - y0(i)) / (sqrt(2) * s)) - erf((rows - 0.5 - y0(i)) / (sqrt(2) * s)));
    centre = erf(0.5 / (sqrt(2) * s))^2;   % value of a pixel centred on the particle
    img(rows, cols) = img(rows, cols) + peak(i) / centre * (ey' * ex);
end
[~, xx] = meshgrid(1:height, 1:width);
img = img + settings.background + settings.gradient * xx' / width;
img = img + settings.noise * randn(height, width);
img = max(img, 0);
end
