function tests = test_core_display_resolution
%TEST_CORE_DISPLAY_RESOLUTION Large frames drawn at screen resolution (import.read_frame_display,
%plot.display_grid, plot.draw_background with a grid), without the PIVlab window.
%   The screen resolution frame must be the full resolution frame of import.read_frame (lens
%   undistortion, rectification, stereo transform, background) averaged over each display pixel,
%   at the right place in full resolution pixel coordinates.
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
testCase.TestData.folder = tempname;
mkdir(testCase.TestData.folder);
testCase.TestData.fig = figure('Visible', 'off', 'Units', 'pixels', 'Position', [10 10 600 500]);
testCase.TestData.ax = axes(testCase.TestData.fig, 'Units', 'pixels', 'Position', [10 10 500 400]);
end

function teardownOnce(testCase)
close(testCase.TestData.fig);
rmdir(testCase.TestData.folder, 's');
end

%% grid
function test_small_image_is_drawn_at_full_resolution(testCase)
verifyEmpty(testCase, plot.display_grid(testCase.TestData.ax, [600 900], []), '< 2 image pixels per screen pixel');
verifyNotEmpty(testCase, plot.display_grid(testCase.TestData.ax, [1503 2001], []));
end

function test_grid_tiles_the_whole_image_exactly(testCase)
sizes = {[1503 2001], [2048 2048], [1000 3001], [4099 1201]};
for k = 1:numel(sizes)
	sz = sizes{k};
	g = plot.display_grid(testCase.TestData.ax, sz, []);
	sx = (g.xdata(2) - g.xdata(1)) / (numel(g.xc) - 1);
	sy = (g.ydata(2) - g.ydata(1)) / (numel(g.yc) - 1);
	verifyEqual(testCase, [g.xdata(1) - sx / 2, g.xdata(2) + sx / 2], [0.5, sz(2) + 0.5], 'AbsTol', 1e-9);
	verifyEqual(testCase, [g.ydata(1) - sy / 2, g.ydata(2) + sy / 2], [0.5, sz(1) + 0.5], 'AbsTol', 1e-9);
	verifyEqual(testCase, g.region, [0.5, sz(2) + 0.5, 0.5, sz(1) + 0.5]);
	verifyGreaterThanOrEqual(testCase, g.n, 2);
	% about one display pixel per screen pixel (axes 500 x 400 px), never coarser
	per_screen_pixel = max(sz(2) / 500, sz(1) / 400);
	verifyLessThanOrEqual(testCase, max(sx, sy), per_screen_pixel + 1e-9);
	verifyGreaterThan(testCase, min(sx, sy), per_screen_pixel / 2);
	% the full resolution pixel that contains each centre
	verifyEqual(testCase, g.ci, min(max(round(g.xc), 1), sz(2)));
	verifyEqual(testCase, g.ri, min(max(round(g.yc), 1), sz(1)));
end
end

function test_zoomed_grid_is_sharp_and_covers_the_view(testCase)
sz = [3000 4000];
limits = [1000.5 1300.5 700.5 940.5]; % 300 x 240 image pixels on a 500 x 400 axes
g = plot.display_grid(testCase.TestData.ax, sz, limits);
verifyEqual(testCase, g.n, 1);
verifyLessThanOrEqual(testCase, g.region([1 3]), limits([1 3]));
verifyGreaterThanOrEqual(testCase, g.region([2 4]), limits([2 4]));
verifyEqual(testCase, mod(g.region, 1), 0.5 * ones(1, 4), 'whole pixels');
% at n = 1 the display pixel centres are the image pixel centres
verifyEqual(testCase, g.xc, round(g.xc), 'AbsTol', 1e-9);
verifyEqual(testCase, g.yc, round(g.yc), 'AbsTol', 1e-9);
end

%% frame without geometry change
function test_identity_equals_block_average_of_full_frame(testCase)
for cls = {'uint8', 'uint16', 'double'}
	[src, raw] = write_frame(testCase, [1503 2001], cls{1}, 'plain');
	cam = import.cam_settings();
	full = import.read_frame(src, 1, cam, []);
	[img, g, out_size] = import.read_frame_display(src, 1, cam, [], testCase.TestData.ax, []);
	verifyEqual(testCase, out_size, size(full));
	verifyClass(testCase, img, class(full));
	verifyEqual(testCase, size(img), [numel(g.yc) numel(g.xc)]);
	ref = ideal_display(full, g);
	verifyEqual(testCase, double(img), double(ref), 'AbsTol', 1e-4 * double(max(raw(:))) + (isinteger(raw)), cls{1});
end
end

function test_identity_with_background(testCase)
% background images have the class of the frames (an integer frame minus a double image is an
% error in import.read_frame too)
for cls = {'uint16', 'double'}
	[src, raw] = write_frame(testCase, [1503 2001], cls{1}, 'plain');
	b = cast(double(raw) * 0.4 + 0.005 * double(max(raw(:))) * rand(size(raw)), cls{1});
	bg = struct('A', b, 'B', b);
	cam = import.cam_settings();
	full = import.read_frame(src, 1, cam, bg);
	full(full < 0) = 0;
	[img, g] = import.read_frame_display(src, 1, cam, bg, testCase.TestData.ax, []);
	verifyClass(testCase, img, class(full));
	ref = ideal_display(full, g);
	verifyEqual(testCase, double(img), double(ref), 'AbsTol', 1.01 * isinteger(raw) + 1e-5, cls{1});
end
end

function test_color_frame_is_gray_as_full_frame(testCase)
[src, raw] = write_frame(testCase, [1503 2001], 'uint8', 'color');
cam = import.cam_settings();
full = import.read_frame(src, 1, cam, []);
[img, g] = import.read_frame_display(src, 1, cam, [], testCase.TestData.ax, []);
verifyEqual(testCase, size(raw, 3), 3);
verifyEqual(testCase, size(img, 3), 1);
verifyEqual(testCase, double(img), double(ideal_display(full, g)), 'AbsTol', 1);
end

function test_zoomed_identity_shows_the_image_pixels(testCase)
[src, ~] = write_frame(testCase, [1503 2001], 'uint16', 'plain');
cam = import.cam_settings();
full = import.read_frame(src, 1, cam, []);
limits = [800.5 1100.5 500.5 740.5];
[img, g] = import.read_frame_display(src, 1, cam, [], testCase.TestData.ax, limits);
verifyEqual(testCase, g.n, 1);
verifyEqual(testCase, img, full(round(g.yc), round(g.xc)));
end

%% frames with geometry change: lens undistortion, rectification, stereo transform
function test_standard_lens_model_all_views(testCase)
sz = [1503 2001];
[src, ~] = write_frame(testCase, sz, 'uint8', 'texture');
for view = {'same', 'valid', 'full'}
	cam = import.cam_settings(view=view{1}, use_calibration=1, cameraParams=helper_camera_model(sz));
	check_against_full_frame(testCase, src, cam, [], ['standard ' view{1}]);
end
end

function test_tilted_lens_model_all_views(testCase)
sz = [1503 2001];
[src, ~] = write_frame(testCase, sz, 'uint16', 'texture');
K = [2400 0 1010; 0 2410 740; 0 0 1];
D = zeros(1, 14);
D(1:4) = [-0.2 0.1 1e-3 -5e-4];
D(13:14) = deg2rad([0.8 5]);
cp = cameraParameters('K', K, 'ImageSize', sz);
for view = {'same', 'valid', 'full'}
	cam = import.cam_settings(view=view{1}, use_calibration=1, cameraParams=cp, use_tilted_model=true, tilted_D=D, K_opencv=K);
	check_against_full_frame(testCase, src, cam, [], ['tilted ' view{1}]);
end
end

function test_rectification(testCase)
sz = [1503 2001];
[src, ~] = write_frame(testCase, sz, 'uint8', 'texture');
T = projtform2d([1.05 0.04 0; -0.03 0.97 0; 2e-5 -1e-5 1]');
cam = import.cam_settings(view='same', use_calibration=1, use_rectification=1, cameraParams=helper_camera_model(sz), rectification_tform=T);
check_against_full_frame(testCase, src, cam, [], 'rectification');
end

function test_stereo_map_with_raw_background(testCase)
sz = [1503 2001];
[src, raw] = write_frame(testCase, sz, 'uint8', 'texture');
[xx, yy] = meshgrid(1:sz(2), 1:sz(1));
cam = import.cam_settings();
cam.stereo_map.x = single(0.97 * xx + 0.00002 * yy .^ 2 + 20);
cam.stereo_map.y = single(1.02 * yy - 0.01 * xx + 5);
bg = uint8(0.3 * double(raw));
check_against_full_frame(testCase, src, cam, struct('A', bg, 'B', bg), 'stereo');
end

function test_lens_model_with_background_in_corrected_coordinates(testCase)
sz = [1503 2001];
[src, ~] = write_frame(testCase, sz, 'uint8', 'texture');
cam = import.cam_settings(view='full', use_calibration=1, cameraParams=helper_camera_model(sz));
full = import.read_frame(src, 1, cam, []);
bg = uint8(0.25 * double(full)); % background images are made from corrected frames
check_against_full_frame(testCase, src, cam, struct('A', bg, 'B', bg), 'standard full + background');
end

function test_zoomed_lens_model_shows_the_corrected_pixels(testCase)
sz = [1503 2001];
[src, ~] = write_frame(testCase, sz, 'uint8', 'texture');
cam = import.cam_settings(view='same', use_calibration=1, cameraParams=helper_camera_model(sz));
full = import.read_frame(src, 1, cam, []);
limits = [600.5 900.5 400.5 640.5];
[img, g] = import.read_frame_display(src, 1, cam, [], testCase.TestData.ax, limits);
verifyEqual(testCase, g.n, 1);
ref = full(round(g.yc), round(g.xc));
d = abs(double(img) - double(ref));
verifyLessThan(testCase, mean(d(:)), 1.5, 'interpolation of the display vs the analysis');
verifyLessThan(testCase, measured_shift(img, ref), 0.05, 'position in image pixels');
end

%% drawing
function test_draw_background_takes_map_mask_and_roi_at_display_centres(testCase)
ax = testCase.TestData.ax;
sz = [1503 2001];
g = plot.display_grid(ax, sz, []);
img = uint8(255 * rand(numel(g.yc), numel(g.xc)));
[X, Y] = meshgrid(1:sz(2), 1:sz(1));
map = X + 1000 * Y; % every full resolution pixel has its own value
o = default_options();
o.autoscale = false;
o.map_min = 0;
o.map_max = max(map(:));
o.colormap_steps = 255;
o.mask_preview = true;
o.render_mask = true;
o.mask = X > 700 & Y < 300;
o.roirect = [101 201 1500 1000];
plot.draw_background(ax, img, map, o, g);
h_frame = findobj(ax, 'Type', 'image', 'Tag', 'pivlab_display_frame');
h_map = findobj(ax, 'Type', 'image', 'Tag', 'pivlab_display_map');
h_mask = findobj(ax, 'Type', 'image', 'Tag', 'pivlab_display_mask');
verifyNumElements(testCase, h_frame, 1);
verifyNumElements(testCase, h_map, 1);
verifyNumElements(testCase, h_mask, 1);
for h = [h_frame h_map h_mask]
	verifyEqual(testCase, h.XData, g.xdata);
	verifyEqual(testCase, h.YData, g.ydata);
end
expected = uint8(floor(map(g.ri, g.ci) / o.map_max * 255));
verifyEqual(testCase, h_map.CData, expected);
shown = h_map.AlphaData > 0;
inside = (g.ri >= 201 & g.ri <= 1201) & (g.ci >= 101 & g.ci <= 1601) & ~o.mask(g.ri, g.ci);
shown([1 end]) = inside([1 end]); % first / last pixel: R2025 workaround in draw_background
verifyEqual(testCase, shown, inside);
verifyEqual(testCase, h_mask.AlphaData(2:end-1, 2:end-1) > 0, o.mask(g.ri(2:end-1), g.ci(2:end-1)));
verifyEqual(testCase, axis_extent(ax), [0.5 sz(2) + 0.5 0.5 sz(1) + 0.5], 'AbsTol', 1e-9);
end

function test_draw_background_update_keeps_other_objects(testCase)
ax = testCase.TestData.ax;
sz = [1503 2001];
g = plot.display_grid(ax, sz, []);
o = default_options();
plot.draw_background(ax, uint8(rand(numel(g.yc), numel(g.xc)) * 255), [], o, g);
hold(ax, 'on');
marker = plot(ax, [10 1900], [10 1400], 'r-', 'Tag', 'some_overlay');
hold(ax, 'off');
g2 = plot.display_grid(ax, sz, [500.5 800.5 400.5 640.5]);
img2 = uint8(rand(numel(g2.yc), numel(g2.xc)) * 255);
plot.draw_background(ax, img2, [], o, g2, true);
h_frame = findobj(ax, 'Type', 'image', 'Tag', 'pivlab_display_frame');
verifyTrue(testCase, isvalid(marker));
verifyNumElements(testCase, h_frame, 1);
verifyEqual(testCase, h_frame.CData(:, :, 1), img2);
verifyEqual(testCase, h_frame.XData, g2.xdata);
end

%% derived maps at the display pixels
function test_derived_map_at_display_pixels_equals_full_map(testCase)
% plot.rescale_map_display: inside the vector grid and the fill outside exactly the values of
% plot.rescale_map_core at the display pixels; the colour limits of the full map exactly
ax = testCase.TestData.ax;
sz = [2400 3200];
[x, y] = meshgrid(25:16:3170, 33:16:2380);
rng(4);
base = peaks(max(size(x)));
base = base(1:size(x, 1), 1:size(x, 2)) + 0.2 * randn(size(x));
with_nan = base;
with_nan(10:14, 20:30) = NaN;
angles = mod(atan2(sin(x / 300), cos(y / 200)) * 180 / pi + 20 * randn(size(x)), 360) - 180;
limits_list = {[], [1000.5 1300.5 800.5 1000.5]};
for L = 1:numel(limits_list)
	g = plot.display_grid(ax, sz, limits_list{L});
	for method = {'bilinear', 'bicubic', 'nearest'}
		for m = 1:3
			switch m
				case 1, in = base; isangle = false; label = 'map';
				case 2, in = with_nan; isangle = false; label = 'map with NaN';
				case 3, in = angles; isangle = true; label = 'angles';
			end
			for roi = {[], [301 201 2400 1800]}
				full = plot.rescale_map_core(in, x, y, sz, isangle, method{1}, false, roi{1});
				[d, mn, mx] = plot.rescale_map_display(in, x, y, sz, isangle, method{1}, false, roi{1}, g);
				txt = sprintf('%s %s, zoom %d, roi %d', label, method{1}, L, ~isempty(roi{1}));
				verifyEqual(testCase, d, full(g.ri, g.ci), txt);
				verifyEqual(testCase, [mn mx], [min(full(:)) max(full(:))], txt);
			end
		end
	end
end
% map already at image resolution (e.g. LIC)
g = plot.display_grid(ax, sz, []);
lic = rand(sz);
[d, mn, mx] = plot.rescale_map_display(lic, x, y, sz, false, 'bilinear', false, [], g);
verifyEqual(testCase, d, lic(g.ri, g.ci));
verifyEqual(testCase, [mn mx], [min(lic(:)) max(lic(:))]);
end

function test_derived_map_extrapolated_border_at_display_resolution(testCase)
% extrapolate border: the inside is exact, the border is inpainted at display resolution (close to
% the full resolution inpainting), the colour limits are those of the full map
ax = testCase.TestData.ax;
sz = [2400 3200];
[x, y] = meshgrid(49:32:3150, 49:32:2350); % wide border (64 px windows)
in = peaks(max(size(x)));
in = in(1:size(x, 1), 1:size(x, 2));
in(20:22, 30:35) = NaN;
for roi = {[], [10 10 3000 2300]} % ROI with parts of the border
	g = plot.display_grid(ax, sz, []);
	full = plot.rescale_map_core(in, x, y, sz, false, 'bilinear', true, roi{1});
	[d, mn, mx] = plot.rescale_map_display(in, x, y, sz, false, 'bilinear', true, roi{1}, g);
	ref = full(g.ri, g.ci);
	% region of the vector grid in image pixels (as plot.rescale_map_core)
	r1 = floor(min(y(:)) - 16); r2 = floor(max(y(:)) + 16 - 1);
	c1 = floor(min(x(:)) - 16); c2 = floor(max(x(:)) + 16 - 1);
	inside = g.ri >= r1 & g.ri <= r2 & g.ci >= c1 & g.ci <= c2;
	inside = inside & ~isnan(ref) & ~isnan(d);
	verifyEqual(testCase, d(inside), ref(inside), 'inside the vector grid: exact');
	verifyEqual(testCase, isnan(d), isnan(ref), 'NaN (outside the ROI, missing vectors) at the same pixels');
	border = ~(g.ri >= r1 & g.ri <= r2 & g.ci >= c1 & g.ci <= c2) & ~isnan(ref);
	verifyGreaterThan(testCase, nnz(border), 1000, 'the test needs border pixels');
	range = max(full(:)) - min(full(:));
	verifyLessThan(testCase, mean(abs(d(border) - ref(border))) / range, 0.02, 'border close to the full resolution inpainting');
	verifyEqual(testCase, [mn mx], [min(full(:)) max(full(:))], 'colour limits of the full map');
end
end

%% helpers
function [src, raw] = write_frame(testCase, sz, cls, kind)
rng(7);
H = sz(1);
W = sz(2);
[X, Y] = meshgrid(1:W, 1:H);
switch kind
	case 'plain' % particle-like image
		I = zeros(H, W);
		n = round(H * W / 60);
		px = randi(W, n, 1);
		py = randi(H, n, 1);
		I(sub2ind([H W], py, px)) = 1;
		I = imgaussfilt(I, 1.2) * 12 + 0.05 + 0.1 * (X / W);
	otherwise % smooth texture (features of several pixels) for the geometry checks
		I = imgaussfilt(rand(H, W), 4);
		I = (I - min(I(:))) / (max(I(:)) - min(I(:)));
		I = 0.6 * I + 0.4 * (0.5 + 0.5 * sin(X / 37) .* cos(Y / 23));
end
I = min(max(I, 0), 1);
switch cls
	case 'uint8', raw = im2uint8(I);
	case 'uint16', raw = im2uint16(I);
	otherwise, raw = I;
end
if strcmp(kind, 'color')
	raw = cat(3, raw, raw * 0.8, raw * 0.5);
end
file = fullfile(testCase.TestData.folder, sprintf('frame_%s_%s.tif', cls, kind));
if isa(raw, 'double')
	t = Tiff(file, 'w');
	tags.ImageLength = H; tags.ImageWidth = W; tags.Photometric = Tiff.Photometric.MinIsBlack;
	tags.BitsPerSample = 64; tags.SampleFormat = Tiff.SampleFormat.IEEEFP; tags.SamplesPerPixel = 1;
	tags.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky; tags.Compression = Tiff.Compression.None;
	t.setTag(tags); t.write(raw); t.close();
else
	imwrite(raw, file);
end
src.filepath = {file; file};
src.framenum = [1; 1];
src.framepart = [1 H; 1 H];
src.video_reader_object = [];
end

function ref = ideal_display(full, g)
% the full resolution frame averaged over n x n blocks and taken at the display centres (cubic),
% within the grey value range of its class
cls = class(full);
full = double(full);
n = g.n;
[h, w] = size(full);
hb = ceil(h / n);
wb = ceil(w / n);
full = [full; repmat(full(end, :), hb * n - h, 1)];
full = [full, repmat(full(:, end), 1, wb * n - w)];
P = reshape(sum(sum(reshape(full, n, hb, n, wb), 1), 3), hb, wb) / n ^ 2;
gy = (1:hb) * n + 1 - n + (n - 1) / 2;
gx = (1:wb) * n + 1 - n + (n - 1) / 2;
F = griddedInterpolant({gy, gx}, P, 'cubic', 'nearest');
ref = F({g.yc(:), g.xc(:)});
ref(ref < 0) = 0;
if isinteger(zeros(1, cls))
	ref = min(ref, double(intmax(cls)));
end
end

function check_against_full_frame(testCase, src, cam, bg, label)
full = import.read_frame(src, 1, cam, bg);
full(full < 0) = 0;
[img, g, out_size] = import.read_frame_display(src, 1, cam, bg, testCase.TestData.ax, []);
verifyEqual(testCase, out_size, [size(full, 1) size(full, 2)], [label ': size']);
verifyClass(testCase, img, class(full), [label ': class']);
ref = ideal_display(full, g);
d = abs(double(img) - ref);
range = double(max(full(:)));
valid = ref > 0.05 * range & double(img) > 0.05 * range; % inside the corrected image (edges fade)
verifyGreaterThan(testCase, mean(valid(:)), 0.5, [label ': mostly valid']);
verifyLessThan(testCase, mean(d(valid)) / range, 0.02, [label ': grey values']);
c = corrcoef(double(img(valid)), ref(valid));
verifyGreaterThan(testCase, c(1, 2), 0.97, [label ': correlation']);
verifyLessThan(testCase, measured_shift(img, ref) * g.n, 0.5, [label ': position in image pixels']);
% where the corrected frame has no source (edge of the 'full' view), the display is dark too
outside = ref == 0;
if any(outside(:))
	verifyLessThan(testCase, mean(double(img(outside))) / range, 0.05, [label ': outside']);
end
end

function s = measured_shift(a, b)
% shift between two images in display pixels (phase correlation, parabolic sub-pixel peak)
a = double(a) - mean(double(a(:)));
b = double(b) - mean(double(b(:)));
R = fft2(a) .* conj(fft2(b));
c = real(ifft2(R ./ max(abs(R), eps)));
c = fftshift(c);
[~, k] = max(c(:));
[r, q] = ind2sub(size(c), k);
dr = 0.5 * (c(r - 1, q) - c(r + 1, q)) / (c(r - 1, q) - 2 * c(r, q) + c(r + 1, q));
dq = 0.5 * (c(r, q - 1) - c(r, q + 1)) / (c(r, q - 1) - 2 * c(r, q) + c(r, q + 1));
centre = floor(size(c) / 2) + 1;
s = hypot(r + dr - centre(1), q + dq - centre(2));
end

function o = default_options()
o.alpha = 0.75;
o.displ_image = 1;
o.enhance = false;
o.colormap_name = 'Parula';
o.colormap_steps = 64;
o.is_lic = false;
o.autoscale = true;
o.map_min = 0;
o.map_max = 1;
o.mask = [];
o.mask_preview = false;
o.render_mask = false;
o.masktransp = 50;
o.roirect = [];
o.colorbar_position = 'None';
o.colorbar_label = '';
o.colorbar_format = 1;
end

function e = axis_extent(ax)
axis(ax, 'image');
e = [ax.XLim ax.YLim];
end
