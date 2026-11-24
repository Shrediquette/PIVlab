function h = ui_button(parent, position, str, callback, varargin)
% A push button of the PIVlab window, with its position in characters.
%   h = gui.ui_button(parent, position, str, callback, Name, Value, ...)
% callback: function handle or cell {@fcn, arg, ...}; [] for a button without one.
if isempty(callback)
    h = uicontrol(parent, 'Style', 'pushbutton', 'Units', 'characters', 'Position', position, ...
        'String', str, varargin{:});
else
    h = uicontrol(parent, 'Style', 'pushbutton', 'Units', 'characters', 'Position', position, ...
        'String', str, 'Callback', callback, varargin{:});
end
end
