function settings = collect_settings(hgui)
% Reads all settings of the PIVlab window into one struct, grouped like gui.default_settings:
%   settings.analysis.pass2_size = 32, settings.masks.mask_copy_frames = '1:end', ...
% Every setting has the type of its default value (number, or char for text fields).
% Popup menus and list boxes store their Value and, in settings.popup_texts.<Tag>, the selected
% text (gui.apply_settings selects by text first, so a changed list still loads the right item).
% settings.camera_settings: the settings of the camera windows (gui.camera_setting).
if nargin < 1
    hgui = getappdata(0, 'hgui');
end
default = gui.default_settings;
groups = fieldnames(default);
settings = struct();
for g = 1:numel(groups)
    settings.(groups{g}) = struct();
end
settings.popup_texts = struct();
[controls, tags] = gui.setting_controls(hgui);
for k = 1:numel(controls)
    c = controls(k);
    group = '';
    for g = 1:numel(groups)
        if isfield(default.(groups{g}), tags{k})
            group = groups{g};
        end
    end
    if isempty(group)
        continue % a control without default value (unittests/test_settings finds it)
    end
    % numbers as numbers, text as text (the type of the default value)
    settings.(group).(tags{k}) = gui.setting_value(c, default.(group).(tags{k}));
    if any(strcmp(c.Style, {'popupmenu', 'listbox'}))
        settings.popup_texts.(tags{k}) = gui.popup_text(c);
    end
end
% settings of the camera / trigger settings windows (gui.camera_setting), part of 'acquisition'
settings.camera_settings = gui.retr('camera_settings');
if ~isstruct(settings.camera_settings)
    settings.camera_settings = struct();
end
end
