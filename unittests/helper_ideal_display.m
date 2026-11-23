function ref = helper_ideal_display(full, g)
%HELPER_IDEAL_DISPLAY The full resolution frame as the display at screen resolution should show it (unit tests).
%   ref = helper_ideal_display(full, g)
%   full  full resolution frame (import.read_frame); g  display grid (plot.display_grid)
%   ref   double: full averaged over the n x n blocks of g and taken at the display centres (cubic), within
%         the grey value range of the class of full
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
