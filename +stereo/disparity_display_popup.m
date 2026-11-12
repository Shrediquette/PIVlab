function key = disparity_display_popup(handles, request)
%DISPARITY_DISPLAY_POPUP Popup "Show:" of the Stereo-PIV panel: the displays that have data, and the one selected.
%   key = stereo.disparity_display_popup(handles)            key of the display selected (stereo.draw_disparity):
%                                                            'image', 'measured', 'fitted', 'remaining', 'residual'
%   stereo.disparity_display_popup(handles, 'update')        list only the displays that have data (disparity
%                                                            measured, ANALYZE done); keeps the selection if it is
%                                                            still listed, else 'image'
%   stereo.disparity_display_popup(handles, key)             update and select key (if it is listed)
popup = handles.stereo_disp_show;
[keys, labels] = items;
key = selected_key(popup, keys, labels);
if nargin < 2
    return
end
if ~strcmp(request, 'update')
    key = request;
end
available = true(size(keys));
disparity = gui.retr('stereo_disparity');
available(ismember(keys, {'measured', 'fitted', 'remaining'})) = ~isempty(disparity);
stereo_vel = gui.retr('stereo_vel');
available(strcmp(keys, 'residual')) = ~isempty(stereo_vel) && isfield(stereo_vel, 'residual') && ~isempty(stereo_vel.residual);
if ~isequal(gui.retr('stereomode'), 1) || isempty(gui.retr('stereo_calib'))
    available(2:end) = false;
end
keys = keys(available);
labels = labels(available);
value = find(strcmp(keys, key), 1);
if isempty(value)
    value = 1;
end
key = keys{value};
set(popup, 'String', labels, 'Value', value);
end

function [keys, labels] = items
keys   = {'image',        'measured',                    'fitted',                'remaining',           'residual'};
labels = {'Camera image', 'Disparity: measured vectors', 'Disparity: fitted map', 'Remaining disparity', 'Reconstruction residual'};
end

function key = selected_key(popup, keys, labels)
shown = cellstr(get(popup, 'String'));
value = get(popup, 'Value');
key = 'image';
if value >= 1 && value <= numel(shown)
    k = find(strcmp(labels, shown{value}), 1);
    if ~isempty(k)
        key = keys{k};
    end
end
end
