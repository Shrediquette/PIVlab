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
noise_levels   = [0, 0.005, 0.01];   % Gaussian noise variance
displacements  = 2:0.25:8;           % true v-displacement [px]
img_size       = 600;               % must match generate_particle_image_pair default
run_comparison = true;               % true: also compute 2nd-peak substitution results
save_images    = true;              % true: save image pairs as 16-bit TIFFs for external PIV tools

% Exclude the edge strip where particles have moved in/out of frame.
% Displacement is vertical only, so the top and bottom margins are empty
% for the largest displacement in the sweep.
margin   = ceil(max(abs(displacements)));
roi_inpt = [margin+1, margin+1, img_size - 2*margin, img_size - 2*margin];

% Ask for output folder now, before the (slow) sweep starts.
if save_images
    save_dir = uigetdir(pwd, 'Select folder to save particle image pairs');
    if isequal(save_dir, 0)
        error('No folder selected — aborting.');
    end
    fprintf('Images will be saved to: %s\n', save_dir);
    % Write CSV header — one row per pair so ground truth can be recovered.
    meta_fid = fopen(fullfile(save_dir, 'pairs_metadata.csv'), 'w');
    fprintf(meta_fid, 'pair_index,noise,displacement_px\n');
end

%% 2. PIV settings — edit here to benchmark algorithm changes
interrogationarea     = 64;
step                  = 32;
subpixfinder          = 1;      % 1 = 3-point Gauss, 2 = 2D Gauss
passes                = 3;
int2                  = 32;
int3                  = 24;
int4                  = 16;
imdeform              = '*spline';
repeat                = 0;
mask_auto             = 0;
do_linear_correlation = 1;
repeat_last_pass      = 0;
delta_diff_min        = 0.025;
limit_peak_search_area = 1;

% Postprocessing validation thresholds (same defaults as PIVlab GUI)
do_stdev_check  = 1;
stdthresh       = 7;
do_local_median = 1;
neigh_thresh    = 3;

%% 3. Pre-allocate result matrices  [noise x displacement]
n_noise = numel(noise_levels);
n_disp  = numel(displacements);
bias_results  = nan(n_noise, n_disp);
rmse_results  = nan(n_noise, n_disp);
time_results  = nan(n_noise, n_disp);
yield_results = nan(n_noise, n_disp);   % % valid vectors after postproc
if run_comparison
    bias_2pk  = nan(n_noise, n_disp);
    rmse_2pk  = nan(n_noise, n_disp);
    yield_2pk = nan(n_noise, n_disp);   % % valid vectors after 2nd-peak rescue
end

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

        %% Optionally save image pair as 16-bit TIFFs
        % Filenames use a zero-padded index so external PIV tools can sort them.
        % Ground truth (noise, displacement) is recorded in pairs_metadata.csv.
        if save_images
            base = sprintf('%04d', pair_count);
            imwrite(im2uint16(A), fullfile(save_dir, [base '_A.tif']));
            imwrite(im2uint16(B), fullfile(save_dir, [base '_B.tif']));
            fprintf(meta_fid, '%d,%.6f,%.4f\n', pair_count, noise_val, disp_val);
        end

        %% Run PIV — no preprocessing for a standardised test
        t0 = tic;
        [~, ~, u_raw, v_raw, typevector, ~, ~, ~, u2_raw, v2_raw] = piv.piv_FFTmulti( ...
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

        %% Postprocess to flag outliers
        [u_filt, v_filt] = postproc.PIVlab_postproc( ...
            u=u_raw, v=v_raw, ...
            do_stdev_check=do_stdev_check, stdthresh=stdthresh, ...
            do_local_median=do_local_median, neigh_thresh=neigh_thresh);

        % Propagate postproc rejects into typevector (type 2 = flagged outlier)
        typevector_pp = typevector;
        typevector_pp(typevector == 1 & (isnan(u_filt) | isnan(v_filt))) = 2;

        %% Compute bias and RMSE using valid post-processed vectors only (1st peak)
        valid_v = v_filt(typevector_pp == 1);
        bias_results(i_noise, i_disp) = disp_val - mean(valid_v, 'omitnan');
        rmse_results(i_noise, i_disp) = std(valid_v, 0, 'all', 'omitnan');

        %% Second-peak substitution comparison
        if run_comparison
            typevector_2pk = typevector_pp;
            v_2pk          = v_filt;

            % Candidates: flagged by postproc and have a valid second-peak estimate
            candidates = (typevector_pp == 2) & ~isnan(u2_raw) & ~isnan(v2_raw);

            if any(candidates(:))
                % Build trial field: postprocessed valid vectors + 2nd peak at candidates
                u_trial = u_filt;
                v_trial = v_filt;
                u_trial(candidates) = u2_raw(candidates);
                v_trial(candidates) = v2_raw(candidates);

                % Re-validate substituted field with same thresholds
                [u_trial_filt, v_trial_filt] = postproc.PIVlab_postproc( ...
                    u=u_trial, v=v_trial, ...
                    do_stdev_check=do_stdev_check, stdthresh=stdthresh, ...
                    do_local_median=do_local_median, neigh_thresh=neigh_thresh);

                % Accept only candidates that survive re-validation
                accepted = candidates & ~isnan(u_trial_filt) & ~isnan(v_trial_filt);
                v_2pk(accepted)          = v2_raw(accepted);
                typevector_2pk(accepted) = 3;   % 3 = rescued by second peak
            end

            valid_v_2pk = v_2pk(typevector_2pk == 1 | typevector_2pk == 3);
            bias_2pk(i_noise, i_disp) = disp_val - mean(valid_v_2pk, 'omitnan');
            rmse_2pk(i_noise, i_disp) = std(valid_v_2pk, 0, 'all', 'omitnan');
        end

        n_total_vec  = sum(typevector_pp(:) ~= 0);   % excludes masked
        n_valid_vec  = sum(typevector_pp(:) == 1);
        n_reject_vec = sum(typevector_pp(:) == 2);
        yield_results(i_noise, i_disp) = 100 * n_valid_vec / n_total_vec;
        pct_valid    = yield_results(i_noise, i_disp);
        if run_comparison
            n_rescued   = sum(typevector_2pk(:) == 3);
            pct_rescued = 100 * n_rescued / max(n_reject_vec, 1);
            yield_2pk(i_noise, i_disp) = 100 * (n_valid_vec + n_rescued) / n_total_vec;
            fprintf('  [%3d/%3d] noise=%.3f disp=%5.2f  yield=%.1f%%  rej=%d rescued=%d(%.1f%%)  bias=%+.4f/%+.4f  rmse=%.4f/%.4f  t=%.2fs\n', ...
                pair_count, total_pairs, noise_val, disp_val, ...
                pct_valid, n_reject_vec, n_rescued, pct_rescued, ...
                bias_results(i_noise, i_disp), bias_2pk(i_noise, i_disp), ...
                rmse_results(i_noise, i_disp),  rmse_2pk(i_noise, i_disp), ...
                time_results(i_noise, i_disp));
        else
            fprintf('  [%3d/%3d] noise=%.3f disp=%5.2f  yield=%.1f%%  rej=%d  bias=%+.4f  rmse=%.4f  t=%.2fs\n', ...
                pair_count, total_pairs, noise_val, disp_val, ...
                pct_valid, n_reject_vec, ...
                bias_results(i_noise, i_disp), rmse_results(i_noise, i_disp), ...
                time_results(i_noise, i_disp));
        end
    end
end

fprintf('Done. Mean processing time per pair: %.2f s\n', mean(time_results(:), 'omitnan'));
if save_images
    fclose(meta_fid);
    fprintf('Image pairs and metadata saved to: %s\n', save_dir);
end

%% 5. Visualise
if run_comparison
    plot_bias_rmse(displacements, noise_levels, bias_results, rmse_results, yield_results, bias_2pk, rmse_2pk, yield_2pk);
else
    plot_bias_rmse(displacements, noise_levels, bias_results, rmse_results, yield_results);
end
