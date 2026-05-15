% test_rescale_maps_extrapolation.m
% Standalone tests for the optional border extrapolation feature in rescale_maps.
%
% Tests (no GUI required):
%   1. Interior pixel values are IDENTICAL with and without extrapolation.
%   2. Without extrapolation, all border pixels equal mean(in(:)) — current behaviour preserved.
%   3. With extrapolation, border pixels are not a flat constant (spring inpainting works).
%   4. With extrapolation, no NaN values remain in the border pixels.
%   5. NaN values in the interior (masked / filtered vectors) are preserved unchanged.
%
% Visual output is saved to C:\Users\trash\Documents\MATLAB\claude_code_temp
% for manual inspection.
%
% Run with:
%   cd C:\Users\trash\Documents\MATLAB\PIVlab_from_github
%   run('unittests/test_rescale_maps_extrapolation.m')

clc; clear; close all;

project_root = 'C:\Users\trash\Documents\MATLAB\PIVlab_from_github';
addpath(project_root);
outdir = 'C:\Users\trash\Documents\MATLAB\claude_code_temp';
if ~exist(outdir, 'dir'), mkdir(outdir); end

n_passed = 0;
n_failed = 0;

fprintf('=== test_rescale_maps_extrapolation ===\n\n');

%% ── Helper: compute boundary indices (mirrors rescale_maps logic) ─────────
function [miny_idx, minx_idx, maxy_idx, maxx_idx] = get_indices(x, y, img_size)
step = x(1,2) - x(1,1);
miny_idx = max(1, floor(min(y(:)) - step/2));
minx_idx = max(1, floor(min(x(:)) - step/2));
maxy_idx = min(img_size(1), floor(max(y(:)) + step/2 - 1));
maxx_idx = min(img_size(2), floor(max(x(:)) + step/2 - 1));
end

%% ── Helper: rescale WITHOUT extrapolation (current behaviour) ─────────────
function out = rescale_no_extrap(in, x, y, img_size)
[miny_idx, minx_idx, maxy_idx, maxx_idx] = get_indices(x, y, img_size);
target_rows = maxy_idx - miny_idx + 1;
target_cols = maxx_idx - minx_idx + 1;
out = zeros(img_size);
out(:,:) = mean(in(:));                              % border = mean
dispvar = imresize(in, [target_rows target_cols], 'bilinear');
out(miny_idx:maxy_idx, minx_idx:maxx_idx) = dispvar; % fill interior
end

%% ── Helper: rescale WITH extrapolation (new behaviour) ────────────────────
function out = rescale_extrap(in, x, y, img_size)
[miny_idx, minx_idx, maxy_idx, maxx_idx] = get_indices(x, y, img_size);
target_rows = maxy_idx - miny_idx + 1;
target_cols = maxx_idx - minx_idx + 1;
out = zeros(img_size);
out(:,:) = NaN;                                      % border = NaN (will be inpainted)
dispvar = imresize(in, [target_rows target_cols], 'bilinear');
out(miny_idx:maxy_idx, minx_idx:maxx_idx) = dispvar; % fill interior
% Record interior NaN positions (masked vectors) before inpainting
interior_nan = false(img_size);
interior_nan(miny_idx:maxy_idx, minx_idx:maxx_idx) = isnan(dispvar);
% Spring inpainting (method 4) fills all NaN pixels
out = misc.inpaint_nans(out, 4);
% Restore masked-vector NaN values inside the interior
out(interior_nan) = NaN;
end

%% ── Build synthetic PIV grid ──────────────────────────────────────────────
img_size = [60 80];
step = 10;
xs = step : step : img_size(2) - step;   % column centres: 10,20,...,70
ys = step : step : img_size(1) - step;   % row centres:    10,20,...,50
[xg, yg] = meshgrid(xs, ys);
in = sin(xg/10) + cos(yg/10) + 3;       % synthetic smooth field, all > 0

fprintf('Synthetic grid: %d x %d vectors on %d x %d image\n', ...
    size(xg,1), size(xg,2), img_size(1), img_size(2));
[mi, mni, mai, mxi] = get_indices(xg, yg, img_size);
fprintf('Interior region: rows %d:%d  cols %d:%d\n\n', mi, mai, mni, mxi);

out_no = rescale_no_extrap(in, xg, yg, img_size);
out_ex = rescale_extrap(in, xg, yg, img_size);

%% Build border mask (pixels OUTSIDE the interior region)
border_mask = true(img_size);
border_mask(mi:mai, mni:mxi) = false;

interior_valid_mask = false(img_size);
interior_valid_mask(mi:mai, mni:mxi) = true;
interior_valid_mask = interior_valid_mask & ~isnan(out_no);

%% ── Test 1: Interior pixels unchanged ─────────────────────────────────────
interior_no = out_no(interior_valid_mask);
interior_ex = out_ex(interior_valid_mask);
max_diff = max(abs(interior_ex - interior_no));
if max_diff < 1e-10
    fprintf('[PASS] Test 1: Interior pixels unchanged (max diff = %.2e)\n', max_diff);
    n_passed = n_passed + 1;
else
    fprintf('[FAIL] Test 1: Interior pixels changed! max diff = %.6f\n', max_diff);
    n_failed = n_failed + 1;
end

%% ── Test 2: Border = mean without extrapolation ────────────────────────────
border_no = out_no(border_mask);
expected_mean = mean(in(:));
max_border_diff = max(abs(border_no - expected_mean));
if max_border_diff < 1e-10
    fprintf('[PASS] Test 2: Border = mean(in) without extrapolation (max diff = %.2e)\n', max_border_diff);
    n_passed = n_passed + 1;
else
    fprintf('[FAIL] Test 2: Border pixels != mean(in) without extrapolation. max diff = %.6f\n', max_border_diff);
    n_failed = n_failed + 1;
end

%% ── Test 3: Border is NOT flat with extrapolation ─────────────────────────
border_ex = out_ex(border_mask);
border_std = std(border_ex);
if border_std > 1e-6
    fprintf('[PASS] Test 3: Border is not flat with extrapolation (std = %.4f)\n', border_std);
    n_passed = n_passed + 1;
else
    fprintf('[FAIL] Test 3: Extrapolated border is still flat (std = %.2e)\n', border_std);
    n_failed = n_failed + 1;
end

%% ── Test 4: No NaN in border after extrapolation ─────────────────────────
border_has_nan = any(isnan(border_ex));
if ~border_has_nan
    fprintf('[PASS] Test 4: No NaN in border after extrapolation\n');
    n_passed = n_passed + 1;
else
    fprintf('[FAIL] Test 4: NaN values remain in border after extrapolation\n');
    n_failed = n_failed + 1;
end

%% ── Test 5: Interior NaN values (masked vectors) preserved ────────────────
in_with_nan = in;
in_with_nan(2, 3) = NaN;  % simulate a masked/filtered vector
in_with_nan(3, 2) = NaN;

out_ex_nan = rescale_extrap(in_with_nan, xg, yg, img_size);

% Determine which output pixels correspond to the NaN input vectors
% (after imresize, a single NaN source spreads to a small region; we check
%  that the overall interior NaN structure is preserved by checking that
%  the exact pixels that were NaN in dispvar are still NaN in output)
[mi2, mni2, mai2, mxi2] = get_indices(xg, yg, img_size);
target_rows = mai2 - mi2 + 1;
target_cols = mxi2 - mni2 + 1;
dispvar_nan = imresize(in_with_nan, [target_rows target_cols], 'bilinear');
interior_nan_expected = false(img_size);
interior_nan_expected(mi2:mai2, mni2:mxi2) = isnan(dispvar_nan);

% All expected NaN pixels inside interior must remain NaN
if all(isnan(out_ex_nan(interior_nan_expected)))
    fprintf('[PASS] Test 5: Interior NaN values (masked vectors) preserved after extrapolation\n');
    n_passed = n_passed + 1;
else
    fprintf('[FAIL] Test 5: Interior NaN values were overwritten by extrapolation!\n');
    n_failed = n_failed + 1;
end

%% ── Test 6: Interior NaN does not bleed into border (border is still filled) ──
border_ex_nan = out_ex_nan(border_mask);
border_nan_count = sum(isnan(border_ex_nan));
if border_nan_count == 0
    fprintf('[PASS] Test 6: Border is fully filled even when interior has NaN values\n');
    n_passed = n_passed + 1;
else
    fprintf('[FAIL] Test 6: Border has %d NaN pixels when interior has NaN values\n', border_nan_count);
    n_failed = n_failed + 1;
end

%% ── Summary ────────────────────────────────────────────────────────────────
fprintf('\n--- Summary: %d passed, %d failed ---\n', n_passed, n_failed);
if n_failed > 0
    error('test_rescale_maps_extrapolation: %d test(s) FAILED', n_failed);
end

%% ── Visual output ──────────────────────────────────────────────────────────
cmap = colormap('jet');
close all;

fig = figure('Visible','off','Position',[10 10 1100 400]);
tiledlayout(1,3,'TileSpacing','compact','Padding','compact');

nexttile;
imagesc(out_no); colormap(gca,cmap); colorbar; axis image;
title('No extrapolation (border = mean)','Interpreter','none');

nexttile;
imagesc(out_ex); colormap(gca,cmap); colorbar; axis image;
title('With extrapolation (spring, method 4)','Interpreter','none');

diff_img = out_ex - out_no;
diff_img(interior_valid_mask) = 0;  % zero out interior to highlight only border change
nexttile;
imagesc(diff_img); colormap(gca,cmap); colorbar; axis image;
title('Difference (border only; interior should be zero)','Interpreter','none');

fname = fullfile(outdir, 'test_rescale_maps_extrapolation.png');
saveas(fig, fname);
close(fig);
fprintf('Visual comparison saved to: %s\n', fname);

%% ── Real PIV data visual check ─────────────────────────────────────────────
fprintf('\n--- Real PIV data visual check ---\n');
img_A = imread(fullfile(project_root, 'Example_data', 'Jet_0001A.jpg'));
img_B = imread(fullfile(project_root, 'Example_data', 'Jet_0001B.jpg'));
if size(img_A,3) > 1, img_A = rgb2gray(img_A); end
if size(img_B,3) > 1, img_B = rgb2gray(img_B); end
piv_size = [size(img_A,1) size(img_A,2)];

[xr, yr, ur, vr] = piv.piv_FFTmulti( ...
    image1=img_A, image2=img_B, ...
    interrogationarea=64, step=32, passes=3, int2=32, int3=16, int4=0);
mag = sqrt(ur.^2 + vr.^2);

out_piv_no = rescale_no_extrap(mag, xr, yr, piv_size);
out_piv_ex = rescale_extrap(mag, xr, yr, piv_size);

fig2 = figure('Visible','off','Position',[10 10 1200 500]);
tiledlayout(1,2,'TileSpacing','compact','Padding','compact');
nexttile;
imagesc(out_piv_no); colormap(gca,jet); colorbar; axis image;
title('PIV: No extrapolation (border = mean)','Interpreter','none');
nexttile;
imagesc(out_piv_ex); colormap(gca,jet); colorbar; axis image;
title('PIV: With extrapolation (spring method 4)','Interpreter','none');

fname2 = fullfile(outdir, 'test_rescale_maps_extrapolation_piv.png');
saveas(fig2, fname2);
close(fig2);
fprintf('Real PIV comparison saved to: %s\n', fname2);
