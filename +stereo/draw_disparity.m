function draw_disparity(target_axis, mode)
%DRAW_DISPARITY Disparity displays of the Stereo-PIV panel on the main image.
%   stereo.draw_disparity(target_axis, mode), mode = value of the popup "Show:"
%   2 measured disparity vectors (first measurement; green = used by the fit, red = rejected)
%   3 fitted disparity map (colour = magnitude, arrows)
%   4 remaining disparity (measured, what the correction leaves: stereo.disparity_remaining)
%   5 overlay camera 1 (red) / camera 2 (cyan) with the disparity correction
%   6 overlay without the disparity correction
%   7 reconstruction residual of the image pair shown (after ANALYZE): how well the 2D results of both cameras
%     fit one 3D velocity; large where one camera measured something the other one does not confirm
% Grey in the overlay: both cameras see the same particles at the same place.
delete(findobj(target_axis, 'Tag', 'stereo_disparity_display'));
calib = gui.retr('stereo_calib');
disparity = gui.retr('stereo_disparity');
if mode <= 1 || isempty(calib)
    return
end
if mode == 7
    draw_residual(target_axis);
    return
end
if mode >= 5
    handles = gui.gethand;
    selected = 2 * floor(get(handles.fileselector, 'Value')) - (1 - gui.retr('toggler'));
    corrected = mode == 5;
    A = cell(1, 2);
    for k = 1:2
        img = im2double(stereo.camera_image(k, selected, corrected));
        limits = stretchlim(img);
        A{k} = imadjust(img, limits);
    end
    overlay = cat(3, A{1}, A{2}, A{2});
    image(target_axis, 'CData', overlay, 'Tag', 'stereo_disparity_display', 'HitTest', 'off', 'PickableParts', 'none');
    if ~corrected || isempty(disparity)
        label = 'cam 1 red / cam 2 cyan, NOT corrected';
    else
        label = 'cam 1 red / cam 2 cyan, corrected';
    end
    note(target_axis, label);
    return
end
if isempty(disparity)
    note(target_axis, 'Measure the disparity first.');
    return
end
x = double(disparity.x);
y = double(disparity.y);
switch mode
    case 2
        u = disparity.raw.u; v = disparity.raw.v;
        good = disparity.fit.used & disparity.fit.weight > 0;
        bad = disparity.fit.used & disparity.fit.weight == 0;
        s = arrow_scale(calib, u(good), v(good));
        arrows(target_axis, x(good), y(good), u(good), v(good), s, [0.2 1 0.2]);
        arrows(target_axis, x(bad), y(bad), u(bad), v(bad), s, [1 0.2 0.2]);
        note(target_axis, sprintf('Measured (green: used, red: rejected), arrows x%.0f', s));
    case 3
        u = disparity.u_mean_smooth; v = disparity.v_mean_smooth;
        magnitude = sqrt(u .^ 2 + v .^ 2);
        colour_map(target_axis, x, y, magnitude);
        s = arrow_scale(calib, u, v);
        arrows(target_axis, x, y, u, v, s, [1 1 1]);
        note(target_axis, sprintf('Fitted: %.1f ... %.1f px, arrows x%.0f', min(magnitude(:)), max(magnitude(:)), s));
    case 4
        % measured disparity that the correction leaves (stereo.disparity_remaining), only at the points that
        % the fit used (inside the overlap, valid often enough): e.g. vectors at a water surface would dominate
        % the colour scale
        if isfield(disparity, 'remaining')
            u = disparity.remaining.u; v = disparity.remaining.v;
        else % measured before 2026-10-19
            u = disparity.fit.residual_u; v = disparity.fit.residual_v;
            u(~disparity.fit.used) = NaN;
            v(~disparity.fit.used) = NaN;
        end
        magnitude = sqrt(u .^ 2 + v .^ 2);
        colour_map(target_axis, x, y, magnitude);
        s = arrow_scale(calib, u, v);
        arrows(target_axis, x, y, u, v, s, [1 1 1]);
        note(target_axis, sprintf('Remaining (measured): up to %.1f px, arrows x%.0f', prctile(magnitude(:), 95), s));
end
end

function draw_residual(target_axis)
% reconstruction residual of the image pair shown (gui.retr('stereo_vel').residual, px of the common grid per
% image pair, NaN where masked)
handles = gui.gethand;
frame = floor(get(handles.fileselector, 'Value'));
stereo_vel = gui.retr('stereo_vel');
resultslist = gui.retr('resultslist');
if isempty(stereo_vel) || ~isfield(stereo_vel, 'residual') || isempty(resultslist)
    note(target_axis, 'Reconstruction residual: run ANALYZE first.');
    return
end
if frame > size(stereo_vel.residual, 3) || frame > size(resultslist, 2) || isempty(resultslist{1, frame}) ...
        || all(isnan(stereo_vel.residual(:, :, frame)), 'all')
    note(target_axis, 'Reconstruction residual: none for this frame (e.g. a mean frame).');
    return
end
residual = abs(double(stereo_vel.residual(:, :, frame))); % the sign has no meaning for the user
colour_map(target_axis, double(resultslist{1, frame}), double(resultslist{2, frame}), residual);
note(target_axis, sprintf('Reconstruction residual: rms %.2f px, max %.2f px', ...
    sqrt(mean(residual(:) .^ 2, 'omitnan')), max(residual(:), [], 'omitnan')));
end

function s = arrow_scale(calib, u, v)
% longest arrow = 4 % of the image width
m = max(sqrt(u(:) .^ 2 + v(:) .^ 2), [], 'omitnan');
if isempty(m) || m == 0 || isnan(m)
    m = 1;
end
s = max(1, round(0.04 * calib.Ravg.ImageSize(2) / m));
end

function arrows(ax, x, y, u, v, s, colour)
if isempty(x)
    return
end
was_held = ishold(ax);
hold(ax, 'on');
quiver(ax, x(:), y(:), u(:) * s, v(:) * s, 0, 'Color', colour, 'LineWidth', 1.5, 'MaxHeadSize', 0.4, ...
    'Tag', 'stereo_disparity_display', 'HitTest', 'off', 'PickableParts', 'none');
if ~was_held
    hold(ax, 'off');
end
end

function colour_map(ax, x, y, values)
% semi-transparent colour image of values on the vector grid
cmap = parula(256);
lo = min(values(:), [], 'omitnan');
hi = max(values(:), [], 'omitnan');
if hi <= lo
    hi = lo + 1;
end
index = round((values - lo) / (hi - lo) * 255) + 1;
index(isnan(index)) = 1;
rgb = ind2rgb(index, cmap);
image(ax, 'XData', [x(1, 1) x(1, end)], 'YData', [y(1, 1) y(end, 1)], 'CData', rgb, 'AlphaData', 0.55, ...
    'Tag', 'stereo_disparity_display', 'HitTest', 'off', 'PickableParts', 'none');
end

function note(ax, label)
text(ax, 0.01, 0.01, [' ' label ' '], 'Units', 'normalized', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [0 0 0], 'Color', [1 1 1], 'FontSize', 10, 'Margin', 2, 'Interpreter', 'none', ...
    'Tag', 'stereo_disparity_display', 'HitTest', 'off', 'PickableParts', 'none');
end
