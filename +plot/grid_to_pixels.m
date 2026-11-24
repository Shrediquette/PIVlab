function out = grid_to_pixels(in, xg, yg, rows, cols, method)
%GRID_TO_PIXELS Map on the vector grid at image pixel centres (no GUI).
%   out = plot.grid_to_pixels(in, xg, yg, rows, cols, method)
%   in       map on the vector grid: numel(yg) x numel(xg)
%   xg, yg   positions of the vector columns / rows in pixels (regular spacing)
%   rows     image rows, cols image columns (pixel (r, c) has its centre at x = c, y = r)
%   method   'bilinear', 'bicubic' or 'nearest'
%   out      numel(rows) x numel(cols), double
%
%   The kernels and the border are those of imresize (triangle, cubic convolution a = -0.5,
%   nearest with ties to the next vector; symmetric padding: the outermost values continue in the
%   half cell outside the grid), but taken at the true positions of the pixels. The former
%   imresize to the size of the region did not know the vector positions: the map was shifted by
%   0.5 px (grids on whole pixels) or 1 px (grids on half pixels).
%   NaN (masked vectors) spread only to the pixels whose kernel uses them with a weight other than 0.
%   A map that is not on the vector grid (e.g. the LIC texture, made at its own resolution) has no
%   vector positions: it is stretched over the region with imresize, as before.
if size(in, 1) ~= numel(yg) || size(in, 2) ~= numel(xg)
    out = imresize(in, [numel(rows) numel(cols)], method);
    return
end
Wy = kernel_weights(double(yg(:)), double(rows(:)), method);
Wx = kernel_weights(double(xg(:)), double(cols(:)), method);
out = full((Wy * double(in)) * Wx.');
end

function W = kernel_weights(g, q, method)
% sparse weights: W(i, k) is the weight of vector k for the query position q(i)
n = numel(g);
m = numel(q);
if n == 1
    W = sparse(1:m, ones(1, m), 1, m, 1);
    return
end
step = (g(end) - g(1)) / (n - 1);
u = (q - g(1)) / step + 1;      % fractional index of the query position in the grid
switch lower(method)
    case 'nearest'
        k = min(max(floor(u + 0.5), 1), n);
        W = sparse(1:m, k, 1, m, n);
    case 'bilinear'
        uc = min(max(u, 1), n);
        k0 = min(floor(uc), n - 1);
        t = uc - k0;
        W = sparse([(1:m)'; (1:m)'], [k0; k0 + 1], [1 - t; t], m, n);
    case 'bicubic'
        k0 = floor(u);
        K = k0 + (-1:2);                     % the four neighbours
        w = keys_cubic(u - K);
        K(K < 1) = 1 - K(K < 1);             % symmetric padding (as imresize)
        K(K > n) = 2 * n + 1 - K(K > n);
        K = min(max(K, 1), n);               % very short grids (n < 3)
        w = w ./ sum(w, 2);
        W = sparse(repmat((1:m)', 1, 4), K, w, m, n);   % zero weights are not stored
    otherwise
        error('plot:grid_to_pixels:method', 'Unknown interpolation method "%s".', method);
end
end

function w = keys_cubic(d)
% cubic convolution kernel with a = -0.5 (the bicubic kernel of imresize)
a = abs(d);
w = (1.5 * a.^3 - 2.5 * a.^2 + 1) .* (a <= 1) + ...
    (-0.5 * a.^3 + 2.5 * a.^2 - 4 * a + 2) .* (a > 1 & a <= 2);
end
