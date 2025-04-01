function [bin_data] = generate_data_within_bin(bin_centroid, del, streaks)

    % Define the extents of the bin (coordinates)

    x_left = bin_centroid(1,1) - del.x / 2;   % x-coordinate of left extent of bin
    x_right = bin_centroid(1,1) + del.x / 2;  % x-coordinate of right extent of bin
    y_top = bin_centroid(1,2) - del.y / 2;    % y-coordinate of top extent of bin
    y_bottom = bin_centroid(1,2) + del.y / 2; % y-coordinate of bottom extent of bin

    % Filter out streaks within extents of bin using matrix manipulation instead of a for loop

    mat_orig = [streaks.posn.x streaks.posn.y streaks.disp.x streaks.disp.y];
    mat_filt1 = mat_orig(mat_orig(:,2) > y_top & mat_orig(:,2) <= y_bottom, :); % y_extents
    mat_filt2 = mat_filt1(mat_filt1(:,1) > x_left & mat_filt1(:,1) <= x_right, :); % x_extents

    if isempty(mat_filt2)
        mean_disp_x = nan;
        std_disp_x = 0;
        mean_disp_y = nan;
        std_disp_y = 0;
        no_streaks = 0;
    else
        mean_disp_x = mean(mat_filt2(:,3));
        std_disp_x = std(mat_filt2(:,3));
        mean_disp_y = mean(mat_filt2(:,4));
        std_disp_y = std(mat_filt2(:,4));
        no_streaks = size(mat_filt2, 1); % MATLAB's size function requires two arguments or uses default
    end

    bin_data = [mean_disp_x, mean_disp_y, std_disp_x, std_disp_y, no_streaks];

end