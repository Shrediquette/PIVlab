function order = disparity_pair_order(n_all)
%DISPARITY_PAIR_ORDER Order in which the automatic disparity measurement uses the image pairs.
%   order = stereo.disparity_pair_order(n_all)
% All pair numbers 1 ... n_all, in an order in which every beginning is spread over the whole series: first and
% last pair, then the middle, then the middles of the halves, and so on (the first five pairs are the same as
% linspace(1, n_all, 5)). The automatic measurement (stereo.measure_disparity, Pairs = 0) takes them in
% batches of five from the beginning, so the pairs measured so far always cover the series.
if n_all <= 2
    order = 1:n_all;
    return
end
order = [1 n_all];
intervals = [1 n_all];
while ~isempty(intervals)
    next = zeros(0, 2);
    for i = 1:size(intervals, 1)
        a = intervals(i, 1);
        b = intervals(i, 2);
        if b - a < 2
            continue % no pair between a and b
        end
        m = round((a + b) / 2);
        order(end + 1) = m; %#ok<AGROW>
        next(end + 1, :) = [a m]; %#ok<AGROW>
        next(end + 1, :) = [m b]; %#ok<AGROW>
    end
    intervals = next;
end
end
