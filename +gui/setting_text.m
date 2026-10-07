function text = setting_text(value)
% The text an edit field shows for the value of a setting.
% A number is written with up to 15 significant digits (64 -> '64', 0.025 -> '0.025'),
% so gui.setting_value gives back the same number. Text stays as it is.
if ischar(value)
    text = value;
elseif isstring(value)
    text = char(value);
elseif isempty(value)
    text = '';
else
    text = sprintf('%.15g', double(value(1)));
end
end
