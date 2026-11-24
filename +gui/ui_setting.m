function h = ui_setting(parent, style, position, group, tag, varargin)
% A control of the PIVlab window that is a setting, with its position in characters.
%   h = gui.ui_setting(parent, style, position, group, tag, Name, Value, ...)
% tag is the name of the setting and the Tag of the control. group is the group of the defaults
% (e.g. default.analysis, see gui.default_settings) that holds its start value: an edit field
% shows it as text (gui.setting_text), every other style gets it as Value. The value is set
% last, so a popup menu or list box already has its String.
value = group.(tag);
if strcmp(style, 'edit')
    value_property = {'String', gui.setting_text(value)};
else
    value_property = {'Value', value};
end
h = uicontrol(parent, 'Style', style, 'Units', 'characters', 'Position', position, 'Tag', tag, ...
    varargin{:}, value_property{:});
end
