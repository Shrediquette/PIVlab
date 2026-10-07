function [controls, tags] = setting_controls(hgui)
% All controls of the PIVlab window that are settings: every edit field, checkbox, popup menu,
% list box, slider and toggle button with a Tag, unless it is marked 'UserData','not_a_setting'
% in gui.generateUI. Returns the handles and their Tags.
setting_styles = {'edit','checkbox','popupmenu','listbox','slider','togglebutton'};
all_controls = findall(hgui, 'Type', 'uicontrol');
keep = false(numel(all_controls), 1);
for k = 1:numel(all_controls)
    c = all_controls(k);
    if isempty(c.Tag)
        continue
    end
    if ~any(strcmp(c.Style, setting_styles))
        continue
    end
    if ischar(c.UserData) && strcmp(c.UserData, 'not_a_setting')
        continue
    end
    keep(k) = true;
end
controls = all_controls(keep);
tags = cell(numel(controls), 1);
for k = 1:numel(controls)
    tags{k} = controls(k).Tag;
end
end
