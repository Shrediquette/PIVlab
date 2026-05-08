function plot_bias_rmse(displacements, noise_levels, bias_results, rmse_results, yield_results, bias_2pk, rmse_2pk, yield_2pk)
% Plot bias error, RMSE, and vector yield vs. displacement.
%
% Each figure shows one colored line per noise level.
% When *_2pk arguments are supplied, dashed lines of the same color are
% overlaid for the 2nd-peak substitution condition.
%
% plot_bias_rmse(displacements, noise_levels, bias, rmse, yield)
% plot_bias_rmse(displacements, noise_levels, bias, rmse, yield, bias_2pk, rmse_2pk, yield_2pk)
%   all result matrices : [n_noise x n_disp], yield in percent [0-100]

do_comparison = nargin == 8 && ~isempty(bias_2pk);

n_noise = numel(noise_levels);
colors  = lines(n_noise);

%% Figure 1 — Bias error
figure('Color', 'w', 'Name', 'Bias error');
hold on;
yline(0, '--k', 'LineWidth', 0.8, 'Alpha', 0.4);
leg_h = gobjects(n_noise * (1 + do_comparison), 1);
leg_i = 0;
for i = 1:n_noise
    leg_i = leg_i + 1;
    leg_h(leg_i) = plot(displacements, bias_results(i, :), '-', ...
        'Color', colors(i, :), 'LineWidth', 1.5);
    if do_comparison
        leg_i = leg_i + 1;
        leg_h(leg_i) = plot(displacements, bias_2pk(i, :), '--', ...
            'Color', colors(i, :), 'LineWidth', 1.5);
    end
end
hold off;
xlabel('True displacement [px]');
ylabel('Bias error [px]');
title('Bias error vs. displacement');
legend(leg_h, build_labels(noise_levels, do_comparison), 'Location', 'best');
grid on;  box on;

%% Figure 2 — RMSE
figure('Color', 'w', 'Name', 'RMSE');
hold on;
leg_h = gobjects(n_noise * (1 + do_comparison), 1);
leg_i = 0;
for i = 1:n_noise
    leg_i = leg_i + 1;
    leg_h(leg_i) = plot(displacements, rmse_results(i, :), '-', ...
        'Color', colors(i, :), 'LineWidth', 1.5);
    if do_comparison
        leg_i = leg_i + 1;
        leg_h(leg_i) = plot(displacements, rmse_2pk(i, :), '--', ...
            'Color', colors(i, :), 'LineWidth', 1.5);
    end
end
hold off;
xlabel('True displacement [px]');
ylabel('RMSE [px]');
title('RMSE vs. displacement');
legend(leg_h, build_labels(noise_levels, do_comparison), 'Location', 'best');
grid on;  box on;

%% Figure 3 — Vector yield
if isempty(yield_results), return; end
figure('Color', 'w', 'Name', 'Vector yield');
hold on;
leg_h = gobjects(n_noise * (1 + do_comparison), 1);
leg_i = 0;
for i = 1:n_noise
    leg_i = leg_i + 1;
    leg_h(leg_i) = plot(displacements, yield_results(i, :), '-', ...
        'Color', colors(i, :), 'LineWidth', 1.5);
    if do_comparison
        leg_i = leg_i + 1;
        leg_h(leg_i) = plot(displacements, yield_2pk(i, :), '--', ...
            'Color', colors(i, :), 'LineWidth', 1.5);
    end
end
hold off;
xlabel('True displacement [px]');
ylabel('Valid vectors [%]');
title('Vector yield vs. displacement');
legend(leg_h, build_labels(noise_levels, do_comparison), 'Location', 'best');
ylim([0 100]);
grid on;  box on;
end

function labels = build_labels(noise_levels, do_comparison)
labels = {};
for i = 1:numel(noise_levels)
    labels{end+1} = sprintf('noise=%.4f', noise_levels(i)); %#ok<AGROW>
    if do_comparison
        labels{end+1} = sprintf('noise=%.4f  +2pk', noise_levels(i)); %#ok<AGROW>
    end
end
end
