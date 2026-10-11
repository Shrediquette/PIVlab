function [ip, wp, n_rejected] = filter_corners(ip, wp, max_distance)
%FILTER_CORNERS Remove board corners that do not fit a projective mapping (wrong marker IDs).
% ip: image points [n x 2], wp: world points [n x 2], max_distance in world units (mm).
% RANSAC with a fixed random seed, so the result is reproducible. The global random state is restored.
rng_state = rng;
rng(0);
[~, inliers] = estgeotform2d(ip, wp, 'projective', 'MaxDistance', max_distance, 'MaxNumTrials', 5000, 'Confidence', 99.9);
rng(rng_state);
n_rejected = nnz(~inliers);
ip = ip(inliers, :);
wp = wp(inliers, :);
end
