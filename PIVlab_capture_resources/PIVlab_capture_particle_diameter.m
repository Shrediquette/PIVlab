function result = PIVlab_capture_particle_diameter(input_image, n_cols, n_rows, max_size)
%Particle image diameter per image region, from the width of the autocorrelation peak.
%   result = PIVlab_capture_particle_diameter(input_image) splits the image into 3 x 3 regions.
%   result = PIVlab_capture_particle_diameter(input_image, n_cols, n_rows) uses n_cols x n_rows regions.
%   result = PIVlab_capture_particle_diameter(input_image, n_cols, n_rows, tile_size) uses tiles of
%   tile_size x tile_size pixels (default 256, smaller images: a sixth of the smaller side, >= 128).
%
%   Each region is split into tiles (up to 4 x 4, evenly spread). Each tile is tested for particle
%   images on its own; the region value is the median of the particle tiles. Obstacles, walls, shadows
%   and reflections only remove the tiles they cover. A region needs 20 % of its tiles (at least 2)
%   with particles.
%
%   The diameter (e^-2 intensity diameter in pixels) depends on the focus, but hardly on the seeding
%   density, the particle brightness or the background. So the regions can be compared with each
%   other: focus until the middle is smallest, then turn the Scheimpflug adapter until the left and
%   right columns have the same diameter.
%
%   result.diameter     n_rows x n_cols, median over the particle tiles of the mean x and y diameter [px]
%                       (no particle tiles: median over all tiles, only the size of the image structures);
%                       NaN: nothing found
%   result.diameter_x   n_rows x n_cols, diameter along x [px]
%   result.diameter_y   n_rows x n_cols, diameter along y [px]
%   result.saturated    n_rows x n_cols, fraction of saturated pixels (saturated particles look bigger)
%   result.is_particles n_rows x n_cols, true if the region looks like particle images (bright spots on a
%                       dark background, Gaussian autocorrelation peak, diameter <= 50 px); false e.g. for a
%                       board or a photo, where the diameter only reflects the size of the image structures
%   result.n_tiles      n_rows x n_cols, number of tiles; result.n_valid: number of particle tiles
%   result.col_edges    1 x n_cols+1, region borders in pixels (column i: col_edges(i)+1 .. col_edges(i+1))
%   result.row_edges    1 x n_rows+1
%
%   Method: in each tile, a plane is subtracted (background, uneven light sheet) and the autocorrelation is computed. For Gaussian particle
%   images, the autocorrelation peak is a Gaussian with twice the variance of a particle image. The
%   zero lag is not used (camera noise only adds to that lag). A Gaussian is fitted to the lags
%   1, 2, ... in x and y. The pixel size (100 % fill factor, variance 1/12 px^2) is removed from the
%   result, so the diameter is the diameter of the particle image before it is sampled by the pixels.

if nargin < 2
	n_cols = 3;
end
if nargin < 3
	n_rows = 3;
end
if nargin < 4
	%[px]: 256 for large images, else a sixth of the smaller image side (more tiles for small images)
	tile_size = max(128, min(256, round(min(size(input_image, [1 2])) / 6)));
else
	tile_size = max_size;
end
max_tiles = 4;       %per region and direction (4 x 4 tiles at most)
min_valid_fraction = 0.2; %of the tiles of a region must look like particles, and at least min_valid tiles
min_valid = 2;
max_lag = 32;        %largest lag used for the fit; enough for diameters up to about 40 px (strongly defocused)
check_lag = 64;      %lags up to here are compared with the fitted Gaussian ("particle image" test)
max_deviation = 0.35; %largest deviation from the Gaussian (real particles <= 0.33, boards 0.28-0.89)
min_skewness = 1.5;  %of the intensities (real particle regions 1.9-10; board and photo tiles up to 1.14)
max_diameter = 50;   %[px]

saturation_value = [];
if isinteger(input_image)
	saturation_value = double(intmax(class(input_image)));
end
if size(input_image,3) > 1
	input_image = input_image(:,:,1);
end

[height, width] = size(input_image);
col_edges = round(linspace(0, width, n_cols+1));
row_edges = round(linspace(0, height, n_rows+1));

result.diameter = nan(n_rows, n_cols);
result.diameter_x = nan(n_rows, n_cols);
result.diameter_y = nan(n_rows, n_cols);
result.saturated = zeros(n_rows, n_cols);
result.is_particles = false(n_rows, n_cols);
result.col_edges = col_edges;
result.row_edges = row_edges;

limits.max_lag = max_lag;
limits.check_lag = check_lag;
limits.max_deviation = max_deviation;
limits.min_skewness = min_skewness;
limits.max_diameter = max_diameter;
result.n_tiles = zeros(n_rows, n_cols);
result.n_valid = zeros(n_rows, n_cols);
for r = 1:n_rows
	for c = 1:n_cols
		%tiles of tile_size x tile_size px, evenly spread over the region (at most max_tiles x max_tiles)
		row_starts = tile_starts(row_edges(r)+1, row_edges(r+1), tile_size, max_tiles);
		col_starts = tile_starts(col_edges(c)+1, col_edges(c+1), tile_size, max_tiles);
		n = numel(row_starts) * numel(col_starts);
		d = nan(n, 1);
		dx = nan(n, 1);
		dy = nan(n, 1);
		valid = false(n, 1);
		n_saturated = 0;
		n_pixels = 0;
		i = 0;
		for tr = 1:numel(row_starts)
			for tc = 1:numel(col_starts)
				i = i + 1;
				rows = row_starts(tr):min(row_starts(tr) + tile_size - 1, row_edges(r+1));
				cols = col_starts(tc):min(col_starts(tc) + tile_size - 1, col_edges(c+1));
				tile = input_image(rows, cols);
				if ~isempty(saturation_value)
					n_saturated = n_saturated + nnz(tile >= saturation_value);
				end
				n_pixels = n_pixels + numel(tile);
				[dx(i), dy(i), valid(i)] = analyse_tile(tile, limits);
				d(i) = (dx(i) + dy(i)) / 2;
			end
		end
		result.n_tiles(r,c) = n;
		result.n_valid(r,c) = nnz(valid);
		result.saturated(r,c) = n_saturated / max(n_pixels, 1);
		%obstacles, shadows, reflections only remove the tiles they cover; the median ignores single wrong tiles
		result.is_particles(r,c) = nnz(valid) >= max(min(min_valid, n), min_valid_fraction * n);
		if any(valid)
			use = valid;
		else
			use = ~isnan(d); %no particle tiles: the value only shows the size of the image structures
		end
		if any(use)
			result.diameter(r,c) = median(d(use));
			result.diameter_x(r,c) = median(dx(use));
			result.diameter_y(r,c) = median(dy(use));
		end
	end
end
end

function [diameter_x, diameter_y, valid] = analyse_tile(tile, limits)
diameter_x = NaN;
diameter_y = NaN;
valid = false;
tile = remove_plane(single(tile));
[h, w] = size(tile);
lags = min(limits.check_lag, min(h, w) - 1);
if lags < 2
	return
end
%autocorrelation (zero padded by the largest lag, so there is no wrap around)
spectrum = fft2(tile, h + lags, w + lags);
correlation = real(ifft2(abs(spectrum).^2));
k = 1:lags;
corr_x = double(correlation(1, k+1)) ./ (h * (w - k));   %normalised by the number of pixel pairs
corr_y = double(correlation(k+1, 1))' ./ ((h - k) * w);
n_fit = min(limits.max_lag, lags);
sigma2_x = fit_gaussian_width(corr_x(1:n_fit));
sigma2_y = fit_gaussian_width(corr_y(1:n_fit));
%particle variance = half the autocorrelation variance, minus the pixel size
diameter_x = particle_diameter(sigma2_x);
diameter_y = particle_diameter(sigma2_y);
%particle images: bright spots on a dark background (skewed intensities) and a Gaussian autocorrelation
%peak. A board, a wall, a shadow edge or a photo has other autocorrelations and no or negative skew.
values = double(tile(:));
skewness = mean(values.^3) / max(mean(values.^2), eps)^1.5;
valid = (diameter_x + diameter_y) / 2 <= limits.max_diameter && skewness > limits.min_skewness && ...
	gaussian_deviation(corr_x, sigma2_x) <= limits.max_deviation && gaussian_deviation(corr_y, sigma2_y) <= limits.max_deviation;
end

function starts = tile_starts(first, last, tile_size, max_tiles)
%start pixels of the tiles, evenly spread over first..last (one tile if the range is smaller than a tile)
n = last - first + 1;
count = min(max_tiles, max(1, floor(n / tile_size)));
if count == 1
	starts = first + max(0, floor((n - tile_size) / 2));
else
	starts = round(linspace(first, last - tile_size + 1, count));
end
end

function deviation = gaussian_deviation(corr, sigma2)
%largest deviation of the autocorrelation (normalised to lag 1) from the fitted Gaussian, all checked lags
if isnan(sigma2) || corr(1) <= 0
	deviation = Inf;
	return
end
k = 1:numel(corr);
model = exp(-(k.^2 - 1) / (2 * sigma2));
deviation = max(abs(corr / corr(1) - model));
end

function region = remove_plane(region)
%subtract the best fitting plane a + b*x + c*y (background, uneven light sheet)
[h, w] = size(region);
x = (1:w) - (w + 1) / 2;
y = ((1:h) - (h + 1) / 2)';
region = region - mean(region(:));
slope_x = sum(region * x') / (h * sum(x.^2));
slope_y = sum(y' * region) / (w * sum(y.^2));
region = region - slope_x * x - slope_y * y;
end

function sigma2 = fit_gaussian_width(corr)
%Least squares fit of log(corr) = a - k^2 / (2 sigma^2), lags k = 1, 2, ... while corr is above
%20 % of corr(1) (always at least lags 1 and 2). NaN if the values are not usable.
sigma2 = NaN;
if numel(corr) < 2 || corr(1) <= 0 || corr(2) <= 0 || corr(2) >= corr(1)
	return
end
n = 2;
while n < numel(corr) && corr(n+1) > 0.2 * corr(1) && corr(n+1) < corr(n)
	n = n + 1;
end
k2 = (1:n).^2;
log_corr = log(corr(1:n));
slope_matrix = [ones(n,1) k2'];
coefficients = slope_matrix \ log_corr';
if coefficients(2) >= 0
	return
end
sigma2 = -1 / (2 * coefficients(2));
end

function d = particle_diameter(sigma2_correlation)
particle_sigma2 = sigma2_correlation / 2 - 1/12;
if isnan(particle_sigma2) || particle_sigma2 <= 0
	d = NaN;
else
	d = 4 * sqrt(particle_sigma2);
end
end
