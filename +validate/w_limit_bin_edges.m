function edges = w_limit_bin_edges(W)
%Bin edges of the W histogram (validate.w_limit_select_Callback): 100 bins across the central 99 % of W,
%the same bin width out to the smallest and largest W (at most 2000 bins), so that the main peak is
%resolved and the outliers far away are still in the histogram.
W = sort(W(:));
n = numel(W);
lo = W(1);
hi = W(end);
spread = W(max(1, round(0.995 * n))) - W(max(1, round(0.005 * n)));
if spread <= 0
    spread = hi - lo;
end
if spread <= 0 % all W equal
    spread = max(abs(lo), 1) * 0.1;
    lo = lo - spread / 2;
    hi = hi + spread / 2;
end
width = spread / 100;
bins = ceil((hi - lo) / width);
if bins > 2000
    bins = 2000;
    width = (hi - lo) / bins;
end
if bins < 1
    bins = 1;
end
edges = lo + (0:bins) * width;
if edges(end) < hi
    edges(end) = hi;
end
