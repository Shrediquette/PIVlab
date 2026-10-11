function draw_w(target_axis, frame)
%DRAW_W Out-of-plane component W of a stereo-PIV result as a colour map under the vectors.
%   stereo.draw_w(target_axis, frame)   frame = image pair
% Blue = toward the cameras, red = away from the cameras (white = 0). The colour scale is the same for
% all image pairs (99th percentile of |W| of the whole series). With a spatial calibration, W is shown
% in the units of U and V (calu: px per image pair -> m/s).
delete(findobj(target_axis, 'Tag', 'stereo_w_display'));
stereo_vel = gui.retr('stereo_vel');
resultslist = gui.retr('resultslist');
if isempty(stereo_vel) || frame > size(stereo_vel.W, 3) || isempty(resultslist) || frame > size(resultslist, 2) ...
        || isempty(resultslist{1, frame})
    return
end
W = double(stereo_vel.W(:, :, frame));
if all(isnan(W(:)))
    return
end
scale = 1;
unit = 'px/frame';
calu = gui.retr('calu');
if ~isempty(calu) && calu ~= 1 && isequal(gui.retr('displacement_only'), 0)
    scale = calu;
    unit = 'm/s';
end
limit = stereo_vel.W_limit * scale;
if ~(limit > 0)
    limit = 1;
end
x = resultslist{1, frame};
y = resultslist{2, frame};
% blue - white - red
cmap = [linspace(0, 1, 128)', linspace(0.25, 1, 128)', ones(128, 1); ones(128, 1), linspace(1, 0.25, 128)', linspace(1, 0, 128)'];
index = round((min(max(W * scale, -limit), limit) + limit) / (2 * limit) * 255) + 1;
index(isnan(W)) = 128;
rgb = ind2rgb(index, cmap);
alpha = 0.6 * ones(size(W));
alpha(isnan(W)) = 0;
image(target_axis, 'XData', [x(1, 1) x(1, end)], 'YData', [y(1, 1) y(end, 1)], 'CData', rgb, 'AlphaData', alpha, ...
    'Tag', 'stereo_w_display', 'HitTest', 'off', 'PickableParts', 'none');
% low-level image (does not clear the axes); drawn right after the particle image, so it lies under the
% vectors (gui.sliderdisp)
text(target_axis, 0.01, 0.01, sprintf(' W: blue %.3g ... red %+.3g %s (blue = toward the cameras) ', -limit, limit, unit), ...
    'Units', 'normalized', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'BackgroundColor', [0 0 0], ...
    'Color', [1 1 1], 'FontSize', 10, 'Margin', 2, 'Tag', 'stereo_w_display', 'HitTest', 'off', 'PickableParts', 'none');
end
