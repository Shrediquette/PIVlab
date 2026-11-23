function h = info(ax, lines, tag)
%INFO Text box of the 3D view (top left, below the header line), e.g. the report of a calibration.
%   h = scene3d.info(ax, lines)
%   h = scene3d.info(ax, lines, tag)
% Colours of the theme, so that it is readable in dark and light mode.
if nargin < 3
    tag = 'scene3d_info';
end
panel = ax.Parent;
h = findall(panel, 'Tag', tag);
if isempty(h)
    h = annotation(panel, 'textbox', [0.01 0.7 0.45 0.22], 'FitBoxToText', 'on', 'FontSize', 9, 'Interpreter', 'none', ...
        'VerticalAlignment', 'top', 'Tag', tag);
end
h = h(1);
bg = panel.BackgroundColor;
set(h, 'String', lines, 'Color', ax.XColor, 'BackgroundColor', bg, ...
    'EdgeColor', scene3d.colors('mix', ax.XColor, bg, 0.7));
end
