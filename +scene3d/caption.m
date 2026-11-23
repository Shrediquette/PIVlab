function caption(ax, str)
%CAPTION Header line of the 3D view (top left, above the scene).
%   scene3d.caption(ax, str)
% The colours follow the theme (dark / light mode).
panel = ax.Parent;
h = findall(panel, 'Tag', 'scene3d_caption');
if isempty(h)
    h = annotation(panel, 'textbox', [0.01 0.93 0.98 0.06], 'EdgeColor', 'none', 'FontSize', 11, 'FontWeight', 'bold', ...
        'Interpreter', 'none', 'VerticalAlignment', 'top', 'Tag', 'scene3d_caption');
end
set(h(1), 'String', str, 'Color', ax.XColor);
end
