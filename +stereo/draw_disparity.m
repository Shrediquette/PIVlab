function draw_disparity(target_axis, key)
%DRAW_DISPARITY Disparity displays of the Stereo-PIV panel on the main image.
%   stereo.draw_disparity(target_axis, key), key of the popup "Show:" (stereo.disparity_display_popup):
%   'image'      camera image only (removes the displays and their colour bar)
%   'measured'   measured disparity vectors after all passes: the correction of the passes before plus what
%                the last pass measured (= the first measurement with one pass); green = used by the fit of the
%                first measurement, red = rejected by it
%   'fitted'     fitted disparity map, i.e. the correction (colour = magnitude, arrows)
%   'remaining'  remaining disparity (measured, what the correction leaves: stereo.disparity_remaining)
%   'residual'   reconstruction residual of the image pair shown (after ANALYZE): how well the 2D results of both
%                cameras fit one 3D velocity; large where one camera measured something the other one does not
%                confirm
% The colour maps start at 0 px and have a colour bar (plot.scale_colorbar, position and number format of the
% plot settings; inside the image when the plot settings have no colour bar). 'remaining' and 'residual' end at
% the 95th percentile (larger values saturate), so that a few outliers do not hide the pattern.
target_fig = ancestor(target_axis, 'figure');
delete(findobj(target_axis, 'Tag', 'stereo_disparity_display'));
delete(findobj(target_fig, 'Tag', 'stereo_disparity_colorbar'));
draw(target_axis, key);
% room for the colour bar next to the image (gui.MainWindow_ResizeFcn), or no more room. Remembered in
% 'stereo_colorbar_room': the colour bar itself is already gone when the image is drawn again (the particle
% image is drawn with the high-level image(), which clears the axes)
has_bar = ~isempty(findobj(target_fig, 'Tag', 'stereo_disparity_colorbar'));
if isequal(target_fig, getappdata(0, 'hgui')) && ~isequal(gui.retr('stereo_colorbar_room'), has_bar)
    gui.put('stereo_colorbar_room', has_bar);
    gui.MainWindow_ResizeFcn(target_fig)
end
end

function draw(target_axis, key)
calib = gui.retr('stereo_calib');
if strcmp(key, 'image') || isempty(calib)
    return
end
if strcmp(key, 'residual')
    draw_residual(target_axis);
    return
end
disparity = gui.retr('stereo_disparity');
if isempty(disparity)
    note(target_axis, 'Measure the disparity first.');
    return
end
x = double(disparity.x);
y = double(disparity.y);
switch key
    case 'measured'
        [u, v, passes] = measured_disparity(disparity);
        good = disparity.fit.used & disparity.fit.weight > 0;
        bad = disparity.fit.used & disparity.fit.weight == 0;
        s = arrow_scale(calib, u(good), v(good));
        arrows(target_axis, x(good), y(good), u(good), v(good), s, [0.2 1 0.2]);
        arrows(target_axis, x(bad), y(bad), u(bad), v(bad), s, [1 0.2 0.2]);
        if passes > 1
            what = sprintf('Measured after %d passes', passes);
        else
            what = 'Measured';
        end
        note(target_axis, sprintf('%s (green: used, red: rejected), arrows x%.0f', what, s));
    case 'fitted'
        u = disparity.u_mean_smooth; v = disparity.v_mean_smooth;
        magnitude = sqrt(u .^ 2 + v .^ 2);
        colour_map(target_axis, x, y, magnitude, max(magnitude(:)), 'Disparity [px]');
        s = arrow_scale(calib, u, v);
        sparse_arrows(target_axis, x, y, u, v, s);
        note(target_axis, sprintf('Fitted: %.1f ... %.1f px, arrows x%.0f', min(magnitude(:)), max(magnitude(:)), s));
    case 'remaining'
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
        % the map is the measurement (with its noise); the label gives the numbers of the report (without it)
        magnitude = sqrt(u .^ 2 + v .^ 2);
        p95 = prctile(magnitude(:), 95);
        colour_map(target_axis, x, y, magnitude, p95, 'Remaining disparity [px]');
        s = arrow_scale(calib, u, v);
        sparse_arrows(target_axis, x, y, u, v, s);
        if isfield(disparity, 'remaining') && isfield(disparity.remaining, 'p95_measured') && ~isnan(disparity.remaining.noise)
            note(target_axis, sprintf('Remaining: rms %.2f px, up to %.1f px without the noise (%.2f px rms), arrows x%.0f', ...
                disparity.remaining.rms, disparity.remaining.p95, disparity.remaining.noise, s));
        else % measured before the noise was removed from "up to"
            note(target_axis, sprintf('Remaining (measured): up to %.1f px (95 %%), arrows x%.0f', p95, s));
        end
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
colour_map(target_axis, double(resultslist{1, frame}), double(resultslist{2, frame}), residual, ...
    prctile(residual(:), 95), 'Reconstruction residual [px]');
note(target_axis, sprintf('Reconstruction residual: rms %.2f px, max %.2f px', ...
    sqrt(mean(residual(:) .^ 2, 'omitnan')), max(residual(:), [], 'omitnan')));
end

function [u, v, passes] = measured_disparity(disparity)
% measured disparity after all passes [px]: the last pass measured on images corrected by the passes before it,
% so measured = correction of the passes before + last measurement = u_mean_smooth - residual_u + raw_residual.u
passes = 1;
u = disparity.raw.u;
v = disparity.raw.v;
if isfield(disparity, 'raw_residual') && isfield(disparity, 'residual_u')
    passes = size(disparity.residual_history, 1) + 1;
    u = disparity.u_mean_smooth - disparity.residual_u + disparity.raw_residual.u;
    v = disparity.v_mean_smooth - disparity.residual_v + disparity.raw_residual.v;
end
end

function s = arrow_scale(calib, u, v)
% longest arrow = 4 % of the image width
m = max(sqrt(u(:) .^ 2 + v(:) .^ 2), [], 'omitnan');
if isempty(m) || m == 0 || isnan(m)
    m = 1;
end
s = max(1, round(0.04 * calib.Ravg.ImageSize(2) / m));
end

function sparse_arrows(ax, x, y, u, v, s)
% white arrows on a colour map: at most about 25 per row, so that the colours stay readable
step = max(1, ceil(size(x, 2) / 25));
rows = 1:step:size(x, 1);
cols = 1:step:size(x, 2);
arrows(ax, x(rows, cols), y(rows, cols), u(rows, cols), v(rows, cols), s, [1 1 1]);
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

function colour_map(ax, x, y, values, top, label)
% semi-transparent colour image of values on the vector grid, scale 0 ... top (larger values saturate), with a
% colour bar as the derived parameters (colormap, colour steps, position and number format of the plot settings;
% right of the image when the plot settings have no colour bar); transparent where there is no value
handles = gui.gethand;
maps = get(handles.colormap_choice, 'String');
steps = get(handles.colormap_steps, 'String');
cmap = plot.vector_colormap_core(maps{get(handles.colormap_choice, 'Value')}, ...
    str2double(steps{get(handles.colormap_steps, 'Value')}), Inf);
if ~(top > 0) % also NaN
    top = max([values(:); 1], [], 'omitnan');
end
n = size(cmap, 1);
index = min(floor(min(max(values / top, 0), 1) * n) + 1, n);
valid = isfinite(values);
index(~valid) = 1;
rgb = ind2rgb(index, cmap);
image(ax, 'XData', [x(1, 1) x(1, end)], 'YData', [y(1, 1) y(end, 1)], 'CData', rgb, 'AlphaData', 0.55 * valid, ...
    'Tag', 'stereo_disparity_display', 'HitTest', 'off', 'PickableParts', 'none');
% the colour scale of this map replaces the axes colormap: colour bars of a derived parameter or of the vector
% magnitude would be wrong now (they are drawn again with the next display without this map)
delete(findall(ancestor(ax, 'figure'), 'Type', 'colorbar'));
plot.scale_colorbar(ax, cmap, [0 top], label, colorbar_position(handles), get(handles.colorbarnumberformat, 'Value'), ...
    'stereo_disparity_colorbar');
end

function position = colorbar_position(handles)
% position of the plot settings, 'EastOutside' when they have no colour bar (gui.MainWindow_ResizeFcn makes room)
positions = get(handles.colorbarpos, 'String');
position = positions{get(handles.colorbarpos, 'Value')};
if strcmpi(position, 'None')
    position = 'EastOutside';
end
end

function note(ax, label)
text(ax, 0.01, 0.01, [' ' label ' '], 'Units', 'normalized', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [0 0 0], 'Color', [1 1 1], 'FontSize', 10, 'Margin', 2, 'Interpreter', 'none', ...
    'Tag', 'stereo_disparity_display', 'HitTest', 'off', 'PickableParts', 'none');
end
