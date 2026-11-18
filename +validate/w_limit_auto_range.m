function range = w_limit_auto_range(W, edges)
%"Auto" of the W limits: the range of the main peak of the W histogram, i.e. the connected bins around
%the highest bin that hold at least 0.1 % of its count (counts smoothed over 3 bins, so that a single
%empty bin does not end the peak). range = [W min, W max].
counts = histcounts(W, edges);
smoothed = movmean(counts, 3);
[peak, k] = max(smoothed);
above = smoothed >= peak * 0.001;
left = k;
while left > 1 && above(left - 1)
    left = left - 1;
end
right = k;
while right < numel(counts) && above(right + 1)
    right = right + 1;
end
range = [edges(left), edges(right + 1)];
