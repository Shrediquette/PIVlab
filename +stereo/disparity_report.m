function lines = disparity_report(calib, disparity)
%DISPARITY_REPORT Short description of a disparity measurement (for the Stereo-PIV panel, at most 6 lines).
%   lines = stereo.disparity_report(calib, disparity)
[~, labels] = stereo.disparity_models;
models = stereo.disparity_models;
label = labels{find(models == string(disparity.model), 1)};
lines = {};
lines{end + 1} = sprintf('%d pairs, %s, outliers %.0f %%', numel(disparity.pairs), lower(label), 100 * disparity.fit.outlier_fraction);
measured = sqrt(disparity.raw.u .^ 2 + disparity.raw.v .^ 2);
lines{end + 1} = sprintf('Before the correction: up to %.1f px', max(measured(disparity.fit.used)));
if ~isempty(disparity.residual_history)
    last = disparity.residual_history(end, :);
    lines{end + 1} = sprintf('Remaining: max %.2f px, rms %.2f px', last(1), last(2));
else
    lines{end + 1} = sprintf('Remaining (fit): rms %.2f px', disparity.fit.rms_inliers);
end
sheet = stereo.sheet_position(calib, disparity);
lines{end + 1} = sprintf('Light sheet: %+.2f mm, tilt %.2f%s / %.2f%s', sheet.offset, sheet.tilt(1), char(176), sheet.tilt(2), char(176));
if ~isempty(disparity.residual_history) && disparity.residual_history(end, 1) > 1
    lines{end + 1} = 'Warning: > 1 px remains (check the calibration).';
end
if isempty(disparity.background{1}) || isempty(disparity.background{2})
    lines{end + 1} = 'No minimum background (< 10 pairs).';
end
end
