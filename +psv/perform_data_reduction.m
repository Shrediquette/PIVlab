function [bins] = perform_data_reduction(img, streaks, no_bins)

img_extent.x = size(img, 2);    % extent/size of image in pixel units
img_extent.y = size(img, 1);

del.x = img_extent.x / no_bins.x;  % size of bin in pixel units
del.y = img_extent.y / no_bins.y;

total_bins = no_bins.x * no_bins.y;
bins.centroid.x = zeros(total_bins, 1);  % x coordinate of center of bin
bins.centroid.y = zeros(total_bins, 1);  % y coordinate of center of bin
bins.disp.x = nan(total_bins, 1);  % representative x-displacement at center of bin
bins.disp.y = nan(total_bins, 1);  % representative y-displacement at center of bin
bins.std_disp.x = zeros(total_bins, 1);  % standard deviation of x-displacement based on number of streaks within bins
bins.std_disp.y = zeros(total_bins, 1);  % standard deviation of y-displacement based on number of streaks within bins
bins.no_streaks = zeros(total_bins, 1);  % number of streaks within bin

% Loop through bins and compute information
% information includes center of bin, representative displacement, number of streaks within bin and standard deviation of displacements

counter = 1;
for i = 1:no_bins.y
    % in computing coordinates, remember (0,0) coordinate is at top left corner of image such that +y is downwards and +x is right
    top_coord = (i - 1) * del.y;
    y_centroid = top_coord + del.y / 2;

    for j = 1:no_bins.x
        left_coord = (j - 1) * del.x;
        x_centroid = left_coord + del.x / 2;

        bins.centroid.x(counter, 1) = x_centroid;
        bins.centroid.y(counter, 1) = y_centroid;
        bin_data = psv.generate_data_within_bin([x_centroid, y_centroid], del, streaks);
        bins.disp.x(counter, 1) = bin_data(1, 1);   % mean displacement in x-direction
        bins.disp.y(counter, 1) = bin_data(1, 2);   % mean displacement in y-direction
        bins.std_disp.x(counter, 1) = bin_data(1, 3);  % standard deviation of displacement in x-direction
        bins.std_disp.y(counter, 1) = bin_data(1, 4);  % standard deviation of displacement in y-direction
        bins.no_streaks(counter, 1) = bin_data(1, 5);  % number of streaks within bin

        counter = counter + 1;
    end
end

end

