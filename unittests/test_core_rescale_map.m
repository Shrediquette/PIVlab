%% Tests of plot.rescale_map_core: derived map from the vector grid to the image size, no GUI
%
% Used by the GUI (plot.rescale_maps) and by pivlab.display. Checks the interpolation inside the
% vector grid, the border (mean value or extrapolated), masked vectors (NaN) and angle data.
%
% Run with:
%   runtests('unittests/test_core_rescale_map.m')

function tests = test_core_rescale_map
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
addpath(helper_root());
% synthetic PIV grid: vectors every 10 px on a 60 x 80 px image, a smooth field (all values > 0)
img_size = [60 80];
step = 10;
[x, y] = meshgrid(step:step:img_size(2)-step, step:step:img_size(1)-step);
testCase.TestData.img_size = img_size;
testCase.TestData.x = x;
testCase.TestData.y = y;
testCase.TestData.in = sin(x/10) + cos(y/10) + 3;
% the part of the image covered by the vector grid (rows / columns), as in rescale_map_core
miny = max(1, floor(min(y(:)) - step/2));
minx = max(1, floor(min(x(:)) - step/2));
maxy = min(img_size(1), floor(max(y(:)) + step/2 - 1));
maxx = min(img_size(2), floor(max(x(:)) + step/2 - 1));
inner = false(img_size);
inner(miny:maxy, minx:maxx) = true;
testCase.TestData.inner = inner;
testCase.TestData.rows = miny:maxy;
testCase.TestData.cols = minx:maxx;
end

% -------------------------------------------------------------------------

function test_inside_the_grid_values_at_the_true_pixel_positions(testCase)
% pixel (r, c) has its centre at x = c, y = r. A linear map is reproduced exactly (bilinear: in the
% whole region, the half cell outside the outermost vectors continues their values; bicubic: one
% cell inside the outermost vectors); nearest: the value of the nearest vector (ties to the next).
% Until 2026-11 the map was shifted by 0.5 px (1 px for grids on half pixels).
td = testCase.TestData;
lin = 0.3 * td.x - 0.2 * td.y + 5;
[C, R] = meshgrid(td.cols, td.rows);
xg = td.x(1, :);
yg = td.y(:, 1);
Cc = min(max(C, xg(1)), xg(end));       % the outermost values continue
Rc = min(max(R, yg(1)), yg(end));
for method = {'bilinear', 'bicubic', 'nearest'}
    out = plot.rescale_map_core(lin, td.x, td.y, td.img_size, false, method{1}, false, []);
    testCase.verifyEqual(size(out), td.img_size, method{1});
    inside = out(td.rows, td.cols);
    switch method{1}
        case 'bilinear'
            testCase.verifyEqual(inside, 0.3 * Cc - 0.2 * Rc + 5, 'AbsTol', 1e-12, method{1});
        case 'bicubic'
            ok = C >= xg(2) & C <= xg(end-1) & R >= yg(2) & R <= yg(end-1);
            testCase.verifyEqual(inside(ok), 0.3 * C(ok) - 0.2 * R(ok) + 5, 'AbsTol', 1e-12, method{1});
        case 'nearest'
            step = xg(2) - xg(1);
            j = min(max(floor((C - xg(1)) / step + 0.5) + 1, 1), numel(xg));
            i = min(max(floor((R - yg(1)) / step + 0.5) + 1, 1), numel(yg));
            testCase.verifyEqual(inside, lin(sub2ind(size(lin), i, j)), 'AbsTol', 1e-12, method{1});
    end
end
end

function test_same_kernels_as_imresize(testCase)
% on a grid where imresize to the size of the region is at the right positions (vectors on half
% pixels: x1 - step/2 + 0.5 is a whole pixel), the map is that of imresize: only the positions
% were changed, not the interpolation
[x, y] = meshgrid(5.5:10:75.5, 5.5:10:55.5);
rng(2);
in = rand(size(x));
for method = {'bilinear', 'bicubic', 'nearest'}
    out = plot.rescale_map_core(in, x, y, [70 90], false, method{1}, false, []);
    expected = imresize(in, size(x) * 10, method{1});   % pixel centres 1 ... 10 n
    % the region of the map is rows 1 ... 59, columns 1 ... 79 (as before the change)
    testCase.verifyEqual(out(1:59, 1:79), expected(1:59, 1:79), 'AbsTol', 1e-12, method{1});
end
end

function test_border_is_the_mean_without_extrapolation(testCase)
td = testCase.TestData;
out = plot.rescale_map_core(td.in, td.x, td.y, td.img_size, false, 'bilinear', false, []);
testCase.verifyEqual(out(~td.inner), repmat(mean(td.in(:)), nnz(~td.inner), 1), 'AbsTol', 1e-12);
end

function test_extrapolated_border(testCase)
td = testCase.TestData;
out_mean = plot.rescale_map_core(td.in, td.x, td.y, td.img_size, false, 'bilinear', false, []);
out_ex = plot.rescale_map_core(td.in, td.x, td.y, td.img_size, false, 'bilinear', true, []);
% the inside is the same with and without extrapolation
testCase.verifyEqual(out_ex(td.inner), out_mean(td.inner), 'AbsTol', 1e-12, 'inside changed by the extrapolation');
% the border is filled (no NaN), not flat, and continues the map (no jump at the edge of the grid)
border = out_ex(~td.inner);
testCase.verifyFalse(any(isnan(border)), 'NaN left in the extrapolated border');
testCase.verifyGreaterThan(std(border), 1e-6, 'extrapolated border is flat');
r = td.rows;
c = td.cols;
jump_ex = max(abs(out_ex(r, c(1)-1) - out_ex(r, c(1))));
jump_mean = max(abs(out_mean(r, c(1)-1) - out_mean(r, c(1))));
testCase.verifyLessThan(jump_ex, 0.25*jump_mean, 'jump at the left edge of the grid (compared with the mean border)');
testCase.verifyLessThan(jump_ex, 0.05*(max(td.in(:)) - min(td.in(:))), 'jump at the left edge of the grid');
testCase.verifyGreaterThanOrEqual(min(border), min(td.in(:)) - 1, 'extrapolation far below the map');
testCase.verifyLessThanOrEqual(max(border), max(td.in(:)) + 1, 'extrapolation far above the map');
end

function test_masked_vectors_stay_nan(testCase)
% NaN inside the grid (masked / removed vectors) stays NaN, the border is still filled
td = testCase.TestData;
in = td.in;
in(2,3) = NaN;
in(3,2) = NaN;
out = plot.rescale_map_core(in, td.x, td.y, td.img_size, false, 'bilinear', true, []);
% bilinear: a pixel is NaN if a NaN vector is less than one step away in x and in y (the outermost
% values continue in the half cell outside the grid)
xg = td.x(1, :);
yg = td.y(:, 1);
step = xg(2) - xg(1);
[C, R] = meshgrid(td.cols, td.rows);
Cc = min(max(C, xg(1)), xg(end));
Rc = min(max(R, yg(1)), yg(end));
[ni, nj] = find(isnan(in));
near_nan = false(size(C));
for k = 1:numel(ni)
    near_nan = near_nan | (abs(Cc - xg(nj(k))) < step & abs(Rc - yg(ni(k))) < step);
end
expected_nan = false(td.img_size);
expected_nan(td.rows, td.cols) = near_nan;
testCase.assertTrue(any(expected_nan(:)), 'test setup: no NaN inside the grid');
testCase.verifyEqual(isnan(out), expected_nan, 'NaN of masked vectors changed');
end

function test_extrapolation_limited_to_the_roi(testCase)
% with a region of interest, only the border inside the ROI is extrapolated (pixels outside the
% ROI are masked in the display and stay NaN). As in PIVlab, the vector grid lies inside the ROI.
td = testCase.TestData;
roi = [2 2 76 56];   % [x y w h]: rows 2...58, columns 2...78 (grid: rows 5...54, columns 5...74)
out = plot.rescale_map_core(td.in, td.x, td.y, td.img_size, false, 'bilinear', true, roi);
in_roi = false(td.img_size);
in_roi(roi(2):roi(2)+roi(4), roi(1):roi(1)+roi(3)) = true;
testCase.verifyFalse(any(isnan(out(in_roi))), 'NaN left inside the ROI');
testCase.verifyTrue(all(isnan(out(~in_roi))), 'pixels outside the ROI were filled');
end

function test_extrapolation_with_grid_beyond_the_roi(testCase)
% a ROI drawn after the analysis: the vector grid reaches beyond the ROI on one side (this was an
% index error in inpaint_border_strips). No border strip on that side, the others are extrapolated.
td = testCase.TestData;
roi = [2 2 60 40];   % rows 2...42, columns 2...62; grid rows 5...54, columns 5...74
out = plot.rescale_map_core(td.in, td.x, td.y, td.img_size, false, 'bilinear', true, roi);
in_roi = false(td.img_size);
in_roi(roi(2):roi(2)+roi(4), roi(1):roi(1)+roi(3)) = true;
testCase.verifyFalse(any(isnan(out(in_roi))), 'NaN left inside the ROI');
testCase.verifyTrue(all(isnan(out(~in_roi & ~td.inner))), 'border outside the ROI was filled');
plain = plot.rescale_map_core(td.in, td.x, td.y, td.img_size, false, 'bilinear', false, []);
testCase.verifyEqual(out(td.inner & in_roi), plain(td.inner & in_roi), 'inside the grid unchanged');
end

function test_angles_are_interpolated_over_the_wrap(testCase)
% direction in degrees: between 350 and 10 degrees the interpolation passes 0, not 180
td = testCase.TestData;
in = zeros(size(td.x)) + 350;
in(:, 2:2:end) = 10;
out = plot.rescale_map_core(in, td.x, td.y, td.img_size, true, 'bilinear', false, []);
inside = out(td.rows, td.cols);
deviation = min(abs(inside), abs(abs(inside) - 360));   % distance to 0 degrees
testCase.verifyLessThanOrEqual(max(deviation(:)), 10 + 1e-9, 'angles interpolated through 180 degrees');
end

function test_same_size_is_returned_unchanged(testCase)
% maps that already have the image size (optical flow) are returned as they are
in = rand(30, 40);
[x, y] = meshgrid(1:40, 1:30);
out = plot.rescale_map_core(in, x, y, [30 40], false, 'bilinear', true, []);
testCase.verifyEqual(out, in);
end
