function plot_bias_rmse(displacements, noise_levels, bias_results, rmse_results)
% Plot bias error and RMSE vs. displacement.
%
% Each figure shows one colored line per noise level.
% Called automatically by run_bias_rmse_test, or can be called manually
% after loading saved results.
%
% plot_bias_rmse(displacements, noise_levels, bias_results, rmse_results)
%   bias_results, rmse_results : [n_noise x n_disp] matrices

n_noise = numel(noise_levels);
colors  = lines(n_noise);

legend_labels = arrayfun(@(n) sprintf('noise = %.4f', n), noise_levels, ...
    'UniformOutput', false);

%% Figure 1 — Bias error
figure('Color', 'w', 'Name', 'Bias error');
hold on;
yline(0, '--k', 'LineWidth', 0.8, 'Alpha', 0.4);
for i = 1:n_noise
    plot(displacements, bias_results(i, :), ...
        'Color', colors(i, :), 'LineWidth', 1.5);
end
hold off;
xlabel('True displacement [px]');
ylabel('Bias error [px]');
title('Bias error vs. displacement');
legend(legend_labels, 'Location', 'best');
grid on;
box on;

%% Figure 2 — RMSE
figure('Color', 'w', 'Name', 'RMSE');
hold on;
for i = 1:n_noise
    plot(displacements, rmse_results(i, :), ...
        'Color', colors(i, :), 'LineWidth', 1.5);
end
hold off;
xlabel('True displacement [px]');
ylabel('RMSE [px]');
title('RMSE vs. displacement');
legend(legend_labels, 'Location', 'best');
grid on;
box on;

end
