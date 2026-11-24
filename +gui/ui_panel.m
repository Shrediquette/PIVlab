function h = ui_panel(parent, position, title, varargin)
% A panel of the PIVlab window with a bold title, with its position in characters.
%   h = gui.ui_panel(parent, position, title, Name, Value, ...)
h = uipanel(parent, 'Units', 'characters', 'Position', position, 'Title', title, ...
    'FontWeight', 'bold', varargin{:});
end
