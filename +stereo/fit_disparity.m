function fit = fit_disparity(calib, raw, model)
%FIT_DISPARITY Smooth model of the measured disparity map (robust least squares).
% raw: x, y (grid, rectified px), u, v (mean of the validated disparity over the image pairs, NaN where never
%      valid), n_valid (number of pairs with a valid vector at each grid point)
% model:
%   "poly1"       u and v as 1st-order polynomials of x, y (6 parameters)
%   "poly2"       u and v as 2nd-order polynomials (12 parameters, Raffel: "low order polynomial")
%   "projective"  perspective transform from camera 1 to camera 2 positions (8 parameters)
% fit.u, fit.v: model on the grid. fit.residual_u/v: measured - model. fit.weight: final robust weight (0 = outlier).
model = char(model);
x = double(raw.x);
y = double(raw.y);
inside = ~calib.mask(sub2ind(size(calib.mask), min(max(round(y), 1), size(calib.mask, 1)), min(max(round(x), 1), size(calib.mask, 2))));
ok = inside & ~isnan(raw.u) & ~isnan(raw.v) & raw.n_valid >= max(1, 0.2 * max(raw.n_valid(:)));
idx = find(ok);
n = numel(idx);
if n < 12
    error('stereo:fit_disparity', 'Only %d valid disparity vectors, too few for the fit. Check the images and the calibration.', n);
end
w0 = double(raw.n_valid(idx));
u = double(raw.u(idx));
v = double(raw.v(idx));
% normalized coordinates (conditioning)
cx = mean(x(idx)); cy = mean(y(idx));
sc = max(std(x(idx)), std(y(idx)));
xn = (x - cx) / sc;
yn = (y - cy) / sc;
fit.model = model;
switch model
    case {'poly1', 'poly2'}
        if strcmp(model, 'poly1')
            P = [ones(numel(x), 1), xn(:), yn(:)];
        else
            P = [ones(numel(x), 1), xn(:), yn(:), xn(:) .^ 2, xn(:) .* yn(:), yn(:) .^ 2];
        end
        p = size(P, 2);
        Pi = P(idx, :);
        A = [Pi, zeros(n, p); zeros(n, p), Pi];
        [coef, w] = stereo.robust_lsq(A, [u; v], w0, [(1:n)'; (1:n)']);
        fit.u = reshape(P * coef(1:p), size(x));
        fit.v = reshape(P * coef(p + 1:end), size(x));
        fit.coef = coef;
    case 'projective'
        % camera 1 position p1 = (x, y), camera 2 position p2 = p1 + d; H maps p1 to p2 (h33 = 1), linear DLT rows
        X1 = xn(idx); Y1 = yn(idx);
        X2 = (x(idx) + u - cx) / sc; Y2 = (y(idx) + v - cy) / sc;
        z0 = zeros(n, 1); o = ones(n, 1);
        A = [X1, Y1, o, z0, z0, z0, -X1 .* X2, -Y1 .* X2; z0, z0, z0, X1, Y1, o, -X1 .* Y2, -Y1 .* Y2];
        [h, w] = stereo.robust_lsq(A, [X2; Y2], w0, [(1:n)'; (1:n)']);
        H = [h(1) h(2) h(3); h(4) h(5) h(6); h(7) h(8) 1];
        den = H(3, 1) * xn + H(3, 2) * yn + 1;
        fit.u = ((H(1, 1) * xn + H(1, 2) * yn + H(1, 3)) ./ den) * sc + cx - x;
        fit.v = ((H(2, 1) * xn + H(2, 2) * yn + H(2, 3)) ./ den) * sc + cy - y;
        fit.coef = H;
    otherwise
        error('stereo:fit_disparity', 'Unknown disparity model "%s" (use "poly2", "poly1" or "projective").', model);
end
fit.weight = zeros(size(x));
fit.weight(idx) = w;
fit.used = ok;
fit.residual_u = NaN(size(x));
fit.residual_v = NaN(size(x));
fit.residual_u(idx) = u - fit.u(idx);
fit.residual_v(idx) = v - fit.v(idx);
good = w > 0;
r = sqrt(fit.residual_u(idx) .^ 2 + fit.residual_v(idx) .^ 2);
fit.rms_inliers = sqrt(sum(w0(good) .* r(good) .^ 2) / sum(w0(good)));
fit.outlier_fraction = 1 - nnz(good) / n;
end
