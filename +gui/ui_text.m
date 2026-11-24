function h = ui_text(parent, position, str, varargin)
% A text label of the PIVlab window, left aligned, with its position in characters.
%   h = gui.ui_text(parent, position, str, Name, Value, ...)
% A centered label passes 'HorizontalAlignment','center'.
h = uicontrol(parent, 'Style', 'text', 'Units', 'characters', 'Position', position, ...
    'String', str, 'HorizontalAlignment', 'left', varargin{:});
end
