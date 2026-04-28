% Example script: visualize results from PIVlab_process_commandline.m
% Run PIVlab_process_commandline.m first.
%
% This script shows how to:
% 1) display a single velocity field
% 2) calculate temporal mean values
% 3) calculate temporal standard deviations
% 4) create clear plots from the processed vector data
% 5) extract a profile along a line from the mean velocity magnitude
% 6) visualize the mean correlation map as a measure of PIV quality

clc
close all

%% Check whether the required variables already exist
if ~exist('x', 'var') || ~exist('y', 'var') || ...
        ~exist('u_filt', 'var') || ~exist('v_filt', 'var') || ...
        ~exist('image_folder', 'var') || ~exist('image_names', 'var')
    error(['Please run PIVlab_process_commandline.m first so that x, y, u_filt, ' ...
        'v_filt, image_folder, and image_names exist in the workspace.'])
end

%% Basic information about the data
num_pairs = size(u_filt, 3);
disp(['Visualizing ' num2str(num_pairs) ' processed image pairs.'])

%% Calculate derived quantities
speed_filt = sqrt(u_filt.^2 + v_filt.^2);   % instantaneous speed for each image pair

mean_u = mean(u_filt, 3, 'omitnan');         % temporal mean of u
mean_v = mean(v_filt, 3, 'omitnan');         % temporal mean of v
mean_speed = mean(speed_filt, 3, 'omitnan'); % temporal mean speed
std_speed = std(speed_filt, 0, 3, 'omitnan'); % temporal standard deviation of speed

% x and y are stored as 3D matrices as well. For mean plots, we use the
% grid of the first image pair.
x_plot = x(:,:,1);
y_plot = y(:,:,1);

%% Prepare background image for nicer plots
single_field_index = 1;

% Load the first image of the selected pair and enhance its contrast
background_image = imread(fullfile(image_folder, image_names{2 * single_field_index - 1}));
if size(background_image, 3) > 1
    background_image = rgb2gray(background_image);
end
background_image = imadjust(adapthisteq(background_image, 'NumTiles', [24 24]), [0.0 0.5]);

% contourf overlays require an RGB image, so replicate to 3 channels
background_image_rgb = cat(3, background_image, background_image, background_image);

%% Plot settings
if calu == 1 && calv == 1
    velocity_unit_label = 'px/image pair';
else
    velocity_unit_label = 'scaled velocity units';
end

%% Define the line along which the profile will be extracted
profile_col = round(size(mean_speed, 2) / 2);
profile_x = x_plot(:, profile_col);
profile_y = y_plot(:, profile_col);
mean_speed_profile = mean_speed(:, profile_col);

%% Plot 1: one single velocity field
figure
imshow(background_image)
hold on
quiver(x(:,:,single_field_index), y(:,:,single_field_index), ...
    u_filt(:,:,single_field_index), v_filt(:,:,single_field_index), 'g')
hold off
title(['Filtered velocity field of image pair ' num2str(single_field_index)])

%% Plot 2: mean velocity field overlaid on the background image
figure
imshow(background_image)
hold on
quiver(x_plot, y_plot, mean_u, mean_v, 'g')
hold off
title('Mean velocity field')

%% Plot 3: mean velocity magnitude overlaid on the background image
f3=figure;
axh3=axes(f3);
imshow(background_image_rgb)
hold on
contourf(x_plot, y_plot, mean_speed, 64, 'LineColor', 'none');
set(findobj(axh3, 'Type', 'Contour'), 'FaceAlpha', 0.75)
quiver(x_plot, y_plot, mean_u, mean_v, 'k')
plot(profile_x, profile_y, 'w-', 'LineWidth', 2)
hold off
c = colorbar;
c.Label.String = ['Mean velocity magnitude in ' velocity_unit_label];
title('Mean velocity magnitude')

%% Plot 4: temporal standard deviation overlaid on the background image
f4=figure;
axh4=axes(f4);
imshow(background_image_rgb)
hold on
contourf(x_plot, y_plot, std_speed, 64, 'LineColor', 'none');
set(findobj(axh4, 'Type', 'Contour'), 'FaceAlpha', 0.75)
hold off
c1 = colorbar;
c1.Label.String = ['Temporal standard deviation in ' velocity_unit_label];
title('Temporal standard deviation of velocity magnitude')

%% Plot 5: velocity profile along the selected line
f5=figure;
axh5=axes(f5);
plot(profile_y, mean_speed_profile, 'b', 'LineWidth', 1.5)
grid on
title('Mean velocity magnitude along the selected line')
xlabel('y position')
ylabel(['Mean velocity magnitude in ' velocity_unit_label])

%% Plot 6: mean correlation map (higher values indicate better PIV quality)
mean_corr = mean(correlation_map, 3, 'omitnan');

f6=figure;
axh6=axes(f6);
imshow(background_image_rgb)
hold on
contourf(x_plot, y_plot, mean_corr, 64, 'LineColor', 'none');
set(findobj(axh6, 'Type', 'Contour'), 'FaceAlpha', 0.75)
hold off
c2 = colorbar;
c2.Label.String = 'Mean peak correlation [-]';
title('Mean correlation map (higher = better quality)')

disp('DONE.')
