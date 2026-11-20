function tests = test_gui_display_resolution
%TEST_GUI_DISPLAY_RESOLUTION PIVlab window: large frames are drawn at screen resolution
%   (plot.draw_pixel_background_overlay, import.read_frame_display). The image must be at the right
%   place in full resolution pixel coordinates, zoom must show the full resolution pixels, masks,
%   ROI, derived maps and the calibration must work as before, and everything that computes with
%   images (sizes, analysis) must see the full resolution. Small frames and other axes (export) are
%   drawn at full resolution as before.
%   Run with: results = runtests('unittests/test_gui_display_resolution.m')
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
helper_setup_once(testCase);
testCase.TestData.big = write_pair(testCase.TestData.Dir, 'big', [2400 3200]);
testCase.TestData.small = write_pair(testCase.TestData.Dir, 'small', [180 240]); % smaller than the PIVlab axes
helper_close_pivlab();
helper_start_pivlab();
end

function teardownOnce(testCase)
helper_close_pivlab();
helper_teardown_once(testCase);
end

function setup(~)
helper_start_pivlab();
end

%% the frame
function test_large_frame_is_drawn_at_screen_resolution(testCase)
helper_gui_load_images(testCase.TestData.big, 1);
ax = gui.retr('pivlab_axis');
gui.sliderdisp(ax);
h = frame_image(testCase, ax);
sz = [2400 3200];
ax_px = axes_pixels(ax);
% about one display pixel per screen pixel: never coarser, at most twice as fine (whole block sizes)
shown_px = min(ax_px(1), ax_px(2) * sz(2) / sz(1)); % width of the image on the screen (axis image)
verifyGreaterThanOrEqual(testCase, size(h.CData, 2), 0.99 * shown_px, 'not coarser than the screen');
verifyLessThanOrEqual(testCase, size(h.CData, 2), 2 * shown_px + 2, 'not much finer than the screen');
verifyEqual(testCase, [ax.XLim ax.YLim], [0.5 sz(2) + 0.5 0.5 sz(1) + 0.5], 'AbsTol', 1e-9, 'axes limits of the full image');
verifyEqual(testCase, gui.retr('size_of_the_image'), sz, 'full resolution size for the calibration');
% the drawn image is the full resolution frame averaged at the display pixels
full = import.get_img(1);
verifyEqual(testCase, double(h.CData(:, :, 1)), sample_full(full, h), 'AbsTol', 2);
end

function test_small_frame_is_drawn_at_full_resolution(testCase)
helper_gui_load_images(testCase.TestData.small, 1);
ax = gui.retr('pivlab_axis');
gui.sliderdisp(ax);
verifyEmpty(testCase, findobj(ax, 'Type', 'image', 'Tag', 'pivlab_display_frame'));
im = findobj(ax, 'Type', 'image');
full = import.get_img(1);
verifyEqual(testCase, im(end).CData(:, :, 1), full);
verifyEqual(testCase, gui.retr('size_of_the_image'), [180 240]);
end

function test_other_axes_get_the_full_resolution_frame(testCase)
% exports draw into their own axes: always full resolution
helper_gui_load_images(testCase.TestData.big, 1);
f = figure('Visible', 'off', 'Units', 'pixels', 'Position', [10 10 400 300]);
cleanup_fig = f;
ax2 = axes(f);
gui.sliderdisp(ax2);
im = findobj(ax2, 'Type', 'image');
verifyEmpty(testCase, findobj(ax2, 'Tag', 'pivlab_display_frame'));
verifyEqual(testCase, size(im(end).CData, [1 2]), [2400 3200]);
close(cleanup_fig);
end

function test_frame_steps_and_toggle_draw_the_selected_frame(testCase)
helper_gui_load_images(testCase.TestData.big, 1);
h = gui.gethand;
ax = gui.retr('pivlab_axis');
set(h.fileselector, 'Value', 2);
gui.fileselector_Callback();
img = frame_image(testCase, ax);
verifyEqual(testCase, double(img.CData(:, :, 1)), sample_full(import.get_img(3), img), 'AbsTol', 2, 'pair 2, image A');
set(h.togglepair, 'Value', 1);
gui.togglepair_Callback(h.togglepair);
img = frame_image(testCase, ax);
verifyEqual(testCase, double(img.CData(:, :, 1)), sample_full(import.get_img(4), img), 'AbsTol', 2, 'pair 2, image B');
set(h.togglepair, 'Value', 0);
gui.togglepair_Callback(h.togglepair);
end

%% zoom and pan
function test_zoom_shows_the_full_resolution_pixels(testCase)
helper_gui_load_images(testCase.TestData.big, 1);
ax = gui.retr('pivlab_axis');
gui.put('xzoomlimit', [1000.5 1300.5]);
gui.put('yzoomlimit', [800.5 1000.5]);
gui.sliderdisp(ax);
img = frame_image(testCase, ax);
full = import.get_img(1);
cols = round(linspace(img.XData(1), img.XData(2), size(img.CData, 2)));
rows = round(linspace(img.YData(1), img.YData(2), size(img.CData, 1)));
verifyEqual(testCase, img.CData(:, :, 1), full(rows, cols), 'zoomed: the image pixels');
verifyEqual(testCase, [ax.XLim ax.YLim], [1000.5 1300.5 800.5 1000.5], 'AbsTol', 1e-9);
verifyLessThanOrEqual(testCase, [img.XData(1) img.YData(1)] - 0.5, [1000.5 800.5]);
verifyGreaterThanOrEqual(testCase, [img.XData(2) img.YData(2)] + 0.5, [1300.5 1000.5]);
end

function test_pan_and_zoom_reset_draw_the_view_again(testCase)
helper_gui_load_images(testCase.TestData.big, 1);
ax = gui.retr('pivlab_axis');
gui.put('roirect', [200 300 2000 1500]);
gui.sliderdisp(ax);
n_objects = numel(ax.Children);
% pan / zoom (as the zoom and pan tools do: new limits, then their ActionPostCallback)
set(ax, 'XLim', [2500.5 2700.5], 'YLim', [100.5 250.5]);
gui.after_view_change();
img = frame_image(testCase, ax);
full = import.get_img(1);
cols = round(linspace(img.XData(1), img.XData(2), size(img.CData, 2)));
rows = round(linspace(img.YData(1), img.YData(2), size(img.CData, 1)));
verifyEqual(testCase, img.CData(:, :, 1), full(rows, cols), 'the new view at full resolution');
verifyEqual(testCase, numel(ax.Children), n_objects, 'no objects added or removed (ROI, ...)');
verifyNotEmpty(testCase, findobj(ax, 'Tag', 'roiplot'), 'ROI still drawn');
% scroll wheel zoom / drag pan of the axes: only the limits change (no callback of the zoom tool)
set(ax, 'XLim', [100.5 400.5], 'YLim', [2000.5 2200.5]);
drawnow;
img = frame_image(testCase, ax);
cols = round(linspace(img.XData(1), img.XData(2), size(img.CData, 2)));
rows = round(linspace(img.YData(1), img.YData(2), size(img.CData, 1)));
verifyGreaterThanOrEqual(testCase, [img.XData(2) img.YData(2)] + 0.5, [400.5 2200.5], 'the new view is drawn');
verifyLessThanOrEqual(testCase, [img.XData(1) img.YData(1)] - 0.5, [100.5 2000.5], 'the new view is drawn');
verifyEqual(testCase, img.CData(:, :, 1), full(rows, cols), 'limits set directly: the new view at full resolution');
verifyEqual(testCase, numel(ax.Children), n_objects, 'no objects added or removed');
% zoom reset: the whole image at screen resolution again
gui.zoom_reset_zoom();
img = frame_image(testCase, ax);
verifyEqual(testCase, [ax.XLim ax.YLim], [0.5 3200.5 0.5 2400.5], 'AbsTol', 1e-9);
verifyLessThan(testCase, size(img.CData, 2), 3200);
verifyEqual(testCase, double(img.CData(:, :, 1)), sample_full(full, img), 'AbsTol', 2);
gui.put('roirect', []);
end

function test_enhanced_contrast_is_the_same_when_zoomed(testCase)
% "enhance" stretches with the limits of the whole frame, also for a zoomed part
helper_gui_load_images(testCase.TestData.big, 1);
h = gui.gethand;
ax = gui.retr('pivlab_axis');
set(h.enhance_images, 'Value', 1);
gui.put('xzoomlimit', []);
gui.put('yzoomlimit', []);
gui.sliderdisp(ax);
[src, cam, bg] = import.frame_inputs(1);
[~, ~, ~, ~, whole] = import.read_frame_display(src, 1, cam, bg, ax, []);
limits = stretchlim(whole);
full = import.get_img(1);
% zoomed by a redraw (frame change with zoom) and by changing the limits (zoom / pan)
gui.put('xzoomlimit', [1000.5 1300.5]);
gui.put('yzoomlimit', [800.5 1000.5]);
gui.sliderdisp(ax);
img = frame_image(testCase, ax);
[rows, cols] = centre_pixels(img, [2400 3200]);
verifyEqual(testCase, img.CData(:, :, 1), imadjust(full(rows, cols), limits), 'zoomed redraw');
set(ax, 'XLim', [2000.5 2300.5], 'YLim', [1500.5 1700.5]);
drawnow;
img = frame_image(testCase, ax);
[rows, cols] = centre_pixels(img, [2400 3200]);
verifyEqual(testCase, img.CData(:, :, 1), imadjust(full(rows, cols), limits), 'zoom / pan');
gui.put('xzoomlimit', []);
gui.put('yzoomlimit', []);
set(h.enhance_images, 'Value', 0);
end

%% masks, ROI, derived map
function test_mask_preview_at_display_pixels(testCase)
helper_gui_load_images(testCase.TestData.big, 1);
h = gui.gethand;
ax = gui.retr('pivlab_axis');
polygon = [400 300; 1500 350; 1300 1600; 500 1200];
gui.put('masks_in_frame', {{'ROI_object_polygon', polygon}});
set(h.mask_edit_mode, 'Value', 2);
gui.sliderdisp(ax);
mk = findobj(ax, 'Type', 'image', 'Tag', 'pivlab_display_mask');
verifyNumElements(testCase, mk, 1);
full_mask = mask.convert_masks_to_binary([2400 3200], {'ROI_object_polygon', polygon});
img = frame_image(testCase, ax);
[rows, cols, sure] = centre_pixels(img, [2400 3200]);
shown = mk.AlphaData > 0;
expected = full_mask(rows, cols);
shown([1 end]) = expected([1 end]); % R2025 workaround pixels in draw_background
verifyEqual(testCase, shown(sure), expected(sure));
verifyEqual(testCase, mk.XData, img.XData);
set(h.mask_edit_mode, 'Value', 1);
gui.put('masks_in_frame', []);
end

function test_derived_map_with_roi(testCase)
helper_gui_load_images(testCase.TestData.big, 1);
h = gui.gethand;
ax = gui.retr('pivlab_axis');
gui.put('roirect', [301 201 2400 1800]);
helper_gui_analyze();
plot.derivative_calc(1, 2, 0); % vorticity of pair 1
gui.put('displaywhat', 2);
set(h.fileselector, 'Value', 1);
set(h.autoscaler, 'Value', 1);
gui.sliderdisp(ax);
mp = findobj(ax, 'Type', 'image', 'Tag', 'pivlab_display_map');
verifyNumElements(testCase, mp, 1);
derived = gui.retr('derived');
full_map = plot.rescale_maps(derived{1, 1}, false, [2400 3200]);
% colour limits from the full resolution map (as before)
mn = str2double(get(h.mapscale_min, 'String'));
mx = str2double(get(h.mapscale_max, 'String'));
verifyLessThanOrEqual(testCase, mn, min(full_map(:)));
verifyGreaterThanOrEqual(testCase, mx, max(full_map(:)));
img = frame_image(testCase, ax);
[rows, cols, sure] = centre_pixels(img, [2400 3200]);
steps_list = get(h.colormap_steps, 'String');
steps = str2double(steps_list{get(h.colormap_steps, 'Value')});
expected = full_map(rows, cols);
expected = min(max(expected, mn), mx);
expected = uint8(floor((expected - mn) / (mx - mn) * steps));
verifyEqual(testCase, mp.CData(sure), expected(sure), 'the full resolution map at the display pixels');
inside = (rows' >= 201 & rows' <= 2001) & (cols >= 301 & cols <= 2701);
shown = mp.AlphaData > 0;
shown([1 end]) = inside([1 end]);
verifyEqual(testCase, shown(sure), inside(sure), 'map only inside the ROI');
verifyEqual(testCase, gui.retr('size_of_the_image'), [2400 3200]);
gui.put('displaywhat', 1);
gui.put('roirect', []);
end

function test_analysis_unchanged_by_display(testCase)
% the analysis reads full resolution frames: same result with a small and a large PIVlab axes
helper_gui_load_images(testCase.TestData.big, 1);
helper_gui_analyze();
r1 = gui.retr('resultslist');
hgui = getappdata(0, 'hgui');
pos = get(hgui, 'Position');
set(hgui, 'Position', [pos(1:2) 900 600]);
try
	gui.MainWindow_ResizeFcn(hgui);
catch
end
drawnow;
gui.sliderdisp(gui.retr('pivlab_axis'));
helper_gui_analyze();
r2 = gui.retr('resultslist');
set(hgui, 'Position', pos);
verifyEqual(testCase, r2(1:4, :), r1(1:4, :));
end

%% calibration
function test_tilted_camera_calibration(testCase)
helper_gui_load_images(testCase.TestData.big, 1);
h = gui.gethand;
ax = gui.retr('pivlab_axis');
sz = [2400 3200];
K = [3600 0 1610; 0 3610 1190; 0 0 1];
D = zeros(1, 14);
D(1:4) = [-0.15 0.08 1e-3 -5e-4];
D(13:14) = deg2rad([0.5 4]);
gui.put('cameraParams', cameraParameters('K', K, 'ImageSize', sz));
gui.put('cam_use_tilted_model', true);
gui.put('cam_tilted_D', D);
gui.put('cam_K_opencv', K);
gui.put('cam_selected_target_images', testCase.TestData.big(1));
views = {'valid', 'same', 'full'};
for v = 1:3
	h.calib_viewtype.Value = v;
	h.calib_usecalibration.Value = 1;
	preproc.cam_enable_cam_calib_Callback(h.calib_usecalibration, [], []);
	gui.sliderdisp(ax);
	full = import.get_img(1);
	img = frame_image(testCase, ax);
	verifyEqual(testCase, gui.retr('size_of_the_image'), size(full), views{v});
	verifyEqual(testCase, [ax.XLim ax.YLim], [0.5 size(full, 2) + 0.5 0.5 size(full, 1) + 0.5], 'AbsTol', 1e-9, views{v});
	% whole image (strongly reduced): the averaging blocks lie differently before and after the lens
	% correction, so compare the images smoothed over a few display pixels, and their position
	n = (img.XData(2) - img.XData(1)) / (size(img.CData, 2) - 1);
	ref = imgaussfilt(sample_full(full, img), 2);
	shown = imgaussfilt(double(img.CData(:, :, 1)), 2);
	c = corrcoef(shown(:), ref(:));
	verifyGreaterThan(testCase, c(1, 2), 0.95, [views{v} ': correlation']);
	verifyLessThan(testCase, measured_shift(shown, ref) * n, 1, [views{v} ': position in image pixels (whole image)']);
	% zoomed in: the corrected full resolution pixels
	gui.put('xzoomlimit', [1400.5 1700.5]);
	gui.put('yzoomlimit', [1000.5 1200.5]);
	gui.sliderdisp(ax);
	img = frame_image(testCase, ax);
	cols = round(linspace(img.XData(1), img.XData(2), size(img.CData, 2)));
	rows = round(linspace(img.YData(1), img.YData(2), size(img.CData, 1)));
	ref = double(full(rows, cols));
	shown = double(img.CData(:, :, 1));
	verifyLessThan(testCase, mean(abs(shown(:) - ref(:))) / double(max(full(:))), 0.03, [views{v} ': zoomed grey values']);
	verifyLessThan(testCase, measured_shift(shown, ref), 0.1, [views{v} ': zoomed position in image pixels']);
	gui.put('xzoomlimit', []);
	gui.put('yzoomlimit', []);
end
h.calib_usecalibration.Value = 0;
preproc.cam_enable_cam_calib_Callback(h.calib_usecalibration, [], []);
end

%% helpers
function files = write_pair(folder, name, sz)
% particle image pair, image B shifted by (3, 2) pixels
rng(3);
H = sz(1);
W = sz(2);
n = round(H * W / 40);
px = rand(n, 1) * (W + 20) - 10;
py = rand(n, 1) * (H + 20) - 10;
files = cell(2, 1);
for k = 1:2
	I = zeros(H, W);
	x = px + 3 * (k - 1);
	y = py + 2 * (k - 1);
	inside = x >= 1 & x <= W & y >= 1 & y <= H;
	I(sub2ind([H W], round(y(inside)), round(x(inside)))) = 1;
	I = imgaussfilt(I, 1) * 10;
	files{k} = fullfile(folder, sprintf('%s_%d.tif', name, k));
	imwrite(im2uint16(min(I, 1)), files{k});
end
files = files(:);
files = [files; files]; % two pairs
end

function h = frame_image(testCase, ax)
h = findobj(ax, 'Type', 'image', 'Tag', 'pivlab_display_frame');
testCase.assertNumElements(h, 1, 'one frame image at screen resolution');
end

function ref = sample_full(full, h)
% the full resolution frame averaged over the display pixels (n x n blocks, cubic at the centres)
full = double(full);
nx = size(h.CData, 2);
ny = size(h.CData, 1);
xc = linspace(h.XData(1), h.XData(2), nx);
yc = linspace(h.YData(1), h.YData(2), ny);
n = max(1, floor(min((h.XData(2) - h.XData(1)) / (nx - 1), (h.YData(2) - h.YData(1)) / (ny - 1)) + 1e-9));
[hh, ww] = size(full);
hb = ceil(hh / n);
wb = ceil(ww / n);
full = [full; repmat(full(end, :), hb * n - hh, 1)];
full = [full, repmat(full(:, end), 1, wb * n - ww)];
P = reshape(sum(sum(reshape(full, n, hb, n, wb), 1), 3), hb, wb) / n ^ 2;
F = griddedInterpolant({(1:hb) * n + 1 - n + (n - 1) / 2, (1:wb) * n + 1 - n + (n - 1) / 2}, P, 'cubic', 'nearest');
ref = F({yc(:), xc(:)});
ref = min(max(ref, 0), 65535);
end

function [rows, cols, sure] = centre_pixels(h, sz)
% full resolution pixel that contains each display pixel centre of image h; sure = false where a
% centre lies on the border between two pixels (both are right)
xc = linspace(h.XData(1), h.XData(2), size(h.CData, 2));
yc = linspace(h.YData(1), h.YData(2), size(h.CData, 1))';
cols = min(max(round(xc), 1), sz(2));
rows = min(max(round(yc), 1), sz(1));
sure = (abs(yc - floor(yc) - 0.5) > 1e-6) & (abs(xc - floor(xc) - 0.5) > 1e-6);
rows = rows';
end

function s = measured_shift(a, b)
% shift between two images in pixels (phase correlation, parabolic sub-pixel peak)
a = double(a) - mean(double(a(:)));
b = double(b) - mean(double(b(:)));
R = fft2(a) .* conj(fft2(b));
c = fftshift(real(ifft2(R ./ max(abs(R), eps))));
[~, k] = max(c(:));
[r, q] = ind2sub(size(c), k);
dr = 0.5 * (c(r - 1, q) - c(r + 1, q)) / (c(r - 1, q) - 2 * c(r, q) + c(r + 1, q));
dq = 0.5 * (c(r, q - 1) - c(r, q + 1)) / (c(r, q - 1) - 2 * c(r, q) + c(r, q + 1));
centre = floor(size(c) / 2) + 1;
s = hypot(r + dr - centre(1), q + dq - centre(2));
end

function px = axes_pixels(ax)
old = ax.Units;
ax.Units = 'pixels';
px = ax.Position(3:4);
ax.Units = old;
end
