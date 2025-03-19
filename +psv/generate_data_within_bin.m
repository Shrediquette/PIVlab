function [bin_data] = generate_data_within_bin(bin_centroid, del, streaks)

% define the extents of the bin (coordinates)

x_left = bin_centroid(1, 1) - del.x / 2;   % x-coordinate of left extent of bin
x_right = bin_centroid(1, 1) + del.x / 2;  % x-coordinate of right extent of bin
y_top = bin_centroid(1, 2) - del.y / 2;    % y-coordinate of top extent of bin
y_bottom = bin_centroid(1, 2) + del.y / 2; % y-coordinate of bottom extent of bin

% loop through streaks, filter out streaks within bin and generate necessary information
disp_x = [];
disp_y = [];
no_data_points = size(streaks.posn.x, 1);
for i = 1:no_data_points
    if streaks.posn.x(i, 1) >= x_left && streaks.posn.x(i, 1) <= x_right && streaks.posn.y(i, 1) >= y_top && streaks.posn.y(i, 1) <= y_bottom
        disp_x = [disp_x; streaks.disp.x(i)];
        disp_y = [disp_y; streaks.disp.y(i)];
    end
end

if isempty(disp_x)
    mean_disp_x = 0;
    std_disp_x = 0;
else
    mean_disp_x = mean(disp_x);
    std_disp_x = std(disp_x);
end

if isempty(disp_y)
    mean_disp_y = 0;
    std_disp_y = 0;
else
    mean_disp_y = mean(disp_y);
    std_disp_y = std(disp_y);
end

no_streaks = size(disp_x, 1);

bin_data = [mean_disp_x, mean_disp_y, std_disp_x, std_disp_y, no_streaks];

end

