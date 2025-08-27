function [centroids] = detect_blobs(img, sigma)
%DETECT_BLOBS Summary of this function goes here
%   Detailed explanation goes here
if ndims(img) > 2
    img = rgb2gray(img);
end
blobs = lap_of_grad(img, sigma);
blobs = blobs - min(blobs(:));
blobs = blobs / max(blobs(:));
stats = [];
for threshold = 0.2:0.2:0.8
    CC = bwconncomp(blobs < threshold);
    stats_for_threshold = regionprops("table", CC, "Area", "FilledArea", "BoundingBox", "Centroid");
    stats = [stats; stats_for_threshold];
    CC = bwconncomp(blobs > threshold);
    stats_for_threshold = regionprops("table", CC, "Area", "FilledArea", "BoundingBox", "Centroid");
    stats = [stats; stats_for_threshold];
end
selection = stats.Area > 1000 & stats.Area < 5000;
objs = stats(selection,:);
[~, ~, indx] = selectStrongestBbox(objs.BoundingBox, objs.Area);
centroids = table2array(objs(indx,"Centroid"));
end