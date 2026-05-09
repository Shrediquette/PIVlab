% Example script: visualize results from PIVlab_ensemble_commandline.m
% Run PIVlab_ensemble_commandline.m first.
%
% This script shows how to:
% 1) display the ensemble velocity field
% 2) display the velocity magnitude
% 3) extract a profile along a line from the velocity magnitude
% 4) visualize the correlation map as a measure of PIV quality

clc
close all

%% Check whether the required variables already exist
if ~exist('x', 'var') || ~exist('y', 'var') || ...
        ~exist('u_filt', 'var') || ~exist('v_filt', 'var') || ...
        ~exist('image_folder', 'var') || ~exist('image_names', 'var')
    error(['Please run PIVlab_ensemble_commandline.m first so that x, y, u_filt, ' ...
        'v_filt, image_folder, and image_names exist in the workspace.'])
end

disp('Visualizing ensemble PIV result.')

%% Calculate derived quantities
speed_filt = sqrt(u_filt.^2 + v_filt.^2);

%% Prepare background image for nicer plots
background_image = imread(fullfile(image_folder, image_names{1}));
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
profile_col = round(size(speed_filt, 2) / 2);
profile_x = x(:, profile_col);
profile_y = y(:, profile_col);
speed_profile = speed_filt(:, profile_col);

%% Plot 1: ensemble velocity field overlaid on the background image
figure
imshow(background_image)
hold on
quiver(x, y, u_filt, v_filt, 'g')
hold off
title('Ensemble velocity field')

%% Plot 2: velocity magnitude overlaid on the background image
f2 = figure;
axh2 = axes(f2);
imshow(background_image_rgb)
hold on
contourf(x, y, speed_filt, 64, 'LineColor', 'none');
set(findobj(axh2, 'Type', 'Contour'), 'FaceAlpha', 0.75)
quiver(x, y, u_filt, v_filt, 'k')
plot(profile_x, profile_y, 'w-', 'LineWidth', 2)
hold off
c = colorbar;
c.Label.String = ['Velocity magnitude in ' velocity_unit_label];
title('Ensemble velocity magnitude')

%% Plot 3: velocity magnitude profile along the selected line
f3 = figure;
axh3 = axes(f3); %#ok<NASGU>
plot(profile_y, speed_profile, 'b', 'LineWidth', 1.5)
grid on
title('Velocity magnitude along the selected line')
xlabel('y position')
ylabel(['Velocity magnitude in ' velocity_unit_label])

%% Plot 4: correlation map (higher values indicate better PIV quality)
f4 = figure;
axh4 = axes(f4);
imshow(background_image_rgb)
hold on
contourf(x, y, correlation_map, 64, 'LineColor', 'none');
set(findobj(axh4, 'Type', 'Contour'), 'FaceAlpha', 0.75)
hold off
c2 = colorbar;
c2.Label.String = 'Peak correlation [-]';
title('Correlation map (higher = better quality)')

disp('DONE.')
