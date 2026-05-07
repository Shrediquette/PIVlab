% Bias error and RMSE benchmark for piv.piv_FFTmulti.
%
% Generates synthetic particle image pairs in-memory (no disk I/O),
% runs PIV on each pair, and collects bias, RMSE, and processing time
% as a function of displacement and noise level.
%
% Edit sections 1 and 2 to change the test sweep or PIV algorithm settings.
% Results are stored in the workspace and visualised by plot_bias_rmse.

clear; clc;
addpath(fullfile(fileparts(fileparts(mfilename('fullpath'))), '..'));

%% 1. Test sweep parameters
noise_levels  = [0, 0.005, 0.01];   % Gaussian noise variance
displacements = 2:0.25:8;          % true v-displacement [px]
img_size      = 1600;               % must match generate_particle_image_pair default

% Exclude the edge strip where particles have moved in/out of frame.
% Displacement is vertical only, so the top and bottom margins are empty
% for the largest displacement in the sweep.
margin   = ceil(max(abs(displacements)));
roi_inpt = [margin+1, margin+1, img_size - 2*margin, img_size - 2*margin];

%% 2. PIV settings — edit here to benchmark algorithm changes
interrogationarea     = 64;
step                  = 32;
subpixfinder          = 1;      % 1 = 3-point Gauss, 2 = 2D Gauss
passes                = 3;
int2                  = 32;
int3                  = 24;
int4                  = 16;
imdeform              = '*linear';
repeat                = 0;
mask_auto             = 0;
do_linear_correlation = 0;
repeat_last_pass      = 0;
delta_diff_min        = 0.025;
limit_peak_search_area = 1;

%% 3. Pre-allocate result matrices  [noise x displacement]
n_noise = numel(noise_levels);
n_disp  = numel(displacements);
bias_results = nan(n_noise, n_disp);
rmse_results = nan(n_noise, n_disp);
time_results = nan(n_noise, n_disp);

%% 4. Main sweep
total_pairs = n_noise * n_disp;
pair_count  = 0;
fprintf('Running %d image pairs...\n', total_pairs);

for i_noise = 1:n_noise
    for i_disp = 1:n_disp
        pair_count = pair_count + 1;
        disp_val   = displacements(i_disp);
        noise_val  = noise_levels(i_noise);

        %% Generate image pair in memory (no disk I/O)
        [A, B] = simulate.generate_particle_image_pair(disp_val, noise_val, img_size=img_size);

        %% Run PIV — no preprocessing for a standardised test
        t0 = tic;
        [~, ~, ~, v_raw, typevector] = piv.piv_FFTmulti( ...
            image1=A, ...
            image2=B, ...
            interrogationarea=interrogationarea, ...
            step=step, ...
            subpixfinder=subpixfinder, ...
            mask_inpt=[], ...
            roi_inpt=roi_inpt, ...
            passes=passes, ...
            int2=int2, ...
            int3=int3, ...
            int4=int4, ...
            imdeform=imdeform, ...
            repeat=repeat, ...
            mask_auto=mask_auto, ...
            do_linear_correlation=do_linear_correlation, ...
            repeat_last_pass=repeat_last_pass, ...
            delta_diff_min=delta_diff_min, ...
            limit_peak_search_area=limit_peak_search_area);
        time_results(i_noise, i_disp) = toc(t0);

        %% Compute bias and RMSE using valid vectors only
        valid_v = v_raw(typevector == 1);
        bias_results(i_noise, i_disp) = disp_val - mean(valid_v, 'omitnan');
        rmse_results(i_noise, i_disp) = std(valid_v, 0, 'all', 'omitnan');

        fprintf('  [%3d/%3d] noise=%.3f  disp=%5.2f px  bias=%+.4f  rmse=%.4f  t=%.2fs\n', ...
            pair_count, total_pairs, noise_val, disp_val, ...
            bias_results(i_noise, i_disp), rmse_results(i_noise, i_disp), ...
            time_results(i_noise, i_disp));
    end
end

fprintf('Done. Mean processing time per pair: %.2f s\n', mean(time_results(:), 'omitnan'));

%% 5. Visualise
plot_bias_rmse(displacements, noise_levels, bias_results, rmse_results);
