function h = ui(parent, style, position, varargin)
% A control of the PIVlab window, with its position in characters.
%   h = gui.ui(parent, style, position, Name, Value, ...)
% Units come before Position, so position is read in characters. The other properties follow in
% the given order. See also gui.ui_text, gui.ui_button, gui.ui_setting, gui.ui_panel.
h = uicontrol(parent, 'Style', style, 'Units', 'characters', 'Position', position, varargin{:});
end
