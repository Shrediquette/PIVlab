function [ok, is_pending, note] = set_setting_control(control, value, text)
% Sets one setting control (used by gui.apply_settings, gui.apply_pending_popup).
%   value  edit field: number or text (shown with gui.setting_text); other controls: Value
%   text   popup menu / list box: the text of the wanted item ('' = select by value)
% ok = false: the value could not be applied (note says why). is_pending = true: the popup list
% is not filled yet (placeholder), the text should be applied later.
ok = true;
is_pending = false;
note = '';
switch control.Style
    case 'edit'
        if ((isnumeric(value) || islogical(value)) && numel(value) <= 1) || ischar(value) || isstring(value)
            control.String = gui.setting_text(value); % numbers are shown as text
        else
            ok = false;
            note = ['Setting "' control.Tag '" has an invalid value and was not changed.'];
        end
    case {'popupmenu', 'listbox'}
        [index, is_placeholder] = find_item(control, text);
        if ~isempty(index)
            control.Value = index;
        elseif isempty(text) && is_valid_index(control, value)
            control.Value = value; % no text stored (e.g. a settings struct made by a script)
        elseif is_placeholder && ~isempty(text)
            is_pending = true; % the list is filled later (gui.apply_pending_popup)
        else
            ok = false;
            note = ['"' text '" is not available for setting "' control.Tag '", it was not changed.'];
        end
    otherwise % checkbox, slider, toggle button
        if (isnumeric(value) || islogical(value)) && isscalar(value)
            control.Value = double(value);
        else
            ok = false;
            note = ['Setting "' control.Tag '" has an invalid value and was not changed.'];
        end
end
end

function [index, is_placeholder] = find_item(control, text)
% index of the item with this text; units in the text (e.g. "Vorticity in 1/s" vs. "in 1/frame")
% may differ, because they depend on the calibration
index = [];
items = control.String;
if ischar(items)
    items = cellstr(items);
end
is_placeholder = numel(items) <= 1; % lists that are filled at runtime start with 'N/A' or similar
if isempty(text)
    return
end
index = find(strcmp(items, text), 1);
if isempty(index)
    base = without_unit(text);
    for k = 1:numel(items)
        if strcmp(without_unit(items{k}), base)
            index = k;
            break
        end
    end
end
end

function s = without_unit(s)
k = strfind(s, ' in ');
if ~isempty(k)
    s = s(1:k(end)-1);
end
k = strfind(s, '[');
if ~isempty(k)
    s = strtrim(s(1:k(1)-1));
end
end

function tf = is_valid_index(control, value)
items = control.String;
if ischar(items)
    count = size(items, 1);
else
    count = numel(items);
end
tf = isnumeric(value) && ~isempty(value) && all(value >= 1) && all(value <= count) && all(value == round(value));
end
