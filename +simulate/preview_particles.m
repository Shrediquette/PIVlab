function fig = preview_particles(setup, opts)
% Preview of the particle images of the particle image generator: one image pair per camera in
% full resolution, to judge seeding density and particle size. The button "Show image B" switches
% between image A and B (how far do the particles move?). The images can be zoomed and moved with
% the tools of the figure toolbar.
%   fig = simulate.preview_particles(setup)
% setup: see simulate.setup_3d. If the preview window is open already, it shows the new images.
% Sphere wake and free jet: the first preview runs the flow simulation (about a minute); it is
% kept, so the next previews with the same flow settings are fast.
%   fig = simulate.preview_particles(setup, Progress=@(text) disp(text))
arguments
    setup struct
    opts.Progress = @(text) []      % function handle, called with a status text
end
result = simulate.recording_3d(setup, '', Preview=true, Progress=opts.Progress);p = result.preview;
n = numel(p.A);

fig = findall(groot, 'Type', 'figure', 'Tag', 'PIVlab_sim3d_particles');
if isempty(fig)
    fig = figure('Name', 'PIVlab: particle image generator - particle images', 'NumberTitle', 'off', 'MenuBar', 'none', ...
        'ToolBar', 'figure', 'DockControls', 'off', 'Tag', 'PIVlab_sim3d_particles', 'HandleVisibility', 'callback');
    screen = get(groot, 'ScreenSize');
    fig.Position = [max(20, (screen(3) - 1200) / 2), max(40, (screen(4) - 700) / 2), min(1200, screen(3) - 100), min(700, screen(4) - 120)];
else
    fig = fig(1);
    delete(findall(fig, 'Type', 'axes'));
    delete(findall(fig, 'Type', 'uicontrol'));
end
data.A = p.A;
data.B = p.B;
data.show = 'A';
data.ax = gobjects(1, n);
data.im = gobjects(1, n);
for k = 1:n
    data.ax(k) = axes(fig, 'Units', 'normalized', 'Position', [(k - 1) / n + 0.01, 0.16, 1 / n - 0.02, 0.78]);
    data.im(k) = imagesc(data.ax(k), p.A{k});
    colormap(data.ax(k), gray(256));
    clim(data.ax(k), [0 255]);
    axis(data.ax(k), 'image');
    sz = size(p.A{k});
    title(data.ax(k), sprintf('Camera %d: image A (%d x %d px)', k, sz(2), sz(1)), 'Color', stereo.camera_colors(k));
end
if n > 1
    linkaxes(data.ax); % zoom and pan both cameras together
end

d = setup.particles;
lines = cell(1, n);
for k = 1:n
    disp_px = sort(p.displacement{k});
    if isempty(disp_px)
        shift = 'no particles in the image';
    else
        shift = sprintf('displacement of the particles: median %.1f px, 95 %% up to %.1f px', ...
            disp_px(ceil(0.5 * numel(disp_px))), disp_px(ceil(0.95 * numel(disp_px))));
    end
    lines{k} = sprintf('Camera %d: %.3f particles/px = %.1f per 16 x 16 px window, mean diameter %.1f px, %s', ...
        k, d.Density, d.Density * 16 ^ 2, d.Diameter, shift);
end
data.info = uicontrol(fig, 'Style', 'text', 'String', lines, 'Units', 'normalized', 'Position', [0.01 0.01 0.72 0.1], ...
    'HorizontalAlignment', 'left', 'Tag', 'sim3d_particles_info');
data.button = uicontrol(fig, 'Style', 'pushbutton', 'String', 'Toggle images', 'Units', 'normalized', 'Position', [0.76 0.02 0.22 0.07], ...
    'Callback', @toggle_image, 'Tag', 'sim3d_particles_toggle', 'TooltipString', 'Switch between image A and B of the pair');
setappdata(fig, 'sim3d_particles', data);
end

function toggle_image(button, ~)
fig = ancestor(button, 'figure');
data = getappdata(fig, 'sim3d_particles');
if strcmp(data.show, 'A')
    data.show = 'B';
    images = data.B;
else
    data.show = 'A';
    images = data.A;
end
for k = 1:numel(images)
    data.im(k).CData = images{k};
    sz = size(images{k});
    title(data.ax(k), sprintf('Camera %d: image %s (%d x %d px)', k, data.show, sz(2), sz(1)), 'Color', stereo.camera_colors(k));
end
setappdata(fig, 'sim3d_particles', data);
end
