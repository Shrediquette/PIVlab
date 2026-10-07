function value = setting_value(control, default_value)
% The value of a setting control, in the type of its default value (gui.default_settings):
%   edit field with a numeric default: number (NaN if the text is not a number)
%   edit field with a text default:    char
%   all other controls:                Value (number)
if strcmp(control.Style, 'edit')
    text = control.String;
    if iscell(text)
        text = strjoin(text, newline);
    end
    if isnumeric(default_value) || islogical(default_value)
        value = str2double(text);
    else
        value = text;
    end
else
    value = control.Value;
end
end
