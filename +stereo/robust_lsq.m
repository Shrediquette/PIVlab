function [coef, w] = robust_lsq(A, b, w0, point_id)
%ROBUST_LSQ Weighted least squares with Tukey bisquare reweighting (outliers get weight 0).
% A [rows x params], b [rows x 1], w0 [points x 1] prior weights (e.g. number of valid frames),
% point_id [rows x 1]: the point each row belongs to. All rows of a point get the same weight;
% the residual of a point is the norm of its rows (e.g. u and v of one vector).
n_points = numel(w0);
w = ones(n_points, 1);
coef = zeros(size(A, 2), 1);
for it = 1:30
    W = w0(point_id) .* w(point_id);
    sw = sqrt(W);
    coef_new = (A .* sw) \ (b .* sw);
    r = b - A * coef_new;
    r_point = sqrt(accumarray(point_id, r .^ 2, [n_points 1]));
    used = w0 > 0;
    s = 1.4826 * median(r_point(used & w > 0));
    if s == 0
        s = eps;
    end
    t = r_point / (4.685 * s);
    w = (1 - t .^ 2) .^ 2;
    w(t >= 1) = 0;
    if it > 1 && max(abs(coef_new - coef)) <= 1e-9 * max(1, max(abs(coef_new)))
        coef = coef_new;
        break
    end
    coef = coef_new;
end
end
