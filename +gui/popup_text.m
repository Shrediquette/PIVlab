function text = popup_text(control, value)
% The text of item number value (default: the selected item) of a popup menu or list box.
% Returns '' when the item does not exist.
if nargin < 2
    value = control.Value;
end
items = control.String;
text = '';
if isempty(value)
    return
end
value = value(1);
if iscell(items)
    if value >= 1 && value <= numel(items)
        text = items{value};
    end
elseif ischar(items)
    if value >= 1 && value <= size(items, 1)
        text = strtrim(items(value, :));
    end
end
end
