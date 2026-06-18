function show_mode_overlay()
% show_mode_overlay  Display Basic / Advanced mode selector over the PIVlab logo.
% Called once at startup after the main window becomes visible.
% The mode is already applied; buttons let the user confirm or change it.

hgui = getappdata(0,'hgui');
ax   = gui.retr('pivlab_axis');

remembered = gui.retr('ui_mode');   % already applied at startup
if isempty(remembered)
    remembered = 'advanced';
end

% drawnow ensures the layout engine has settled before reading positions,
% so Position reflects the actual rendered axis bounds.
drawnow;

% Use Position (inner data area) in normalised figure units — more reliable
% than OuterPosition for an axis that has no tick labels.
set(ax,'Units','normalized');
ax_norm = get(ax,'Position');   % [left bottom width height]
set(ax,'Units','characters');   % restore original units

btn_h  = 0.06;
btn_w  = 0.15;
gap    = 0.02;
btn_y  = ax_norm(2) + ax_norm(4) * 0.05;          % near the bottom of the logo
center = ax_norm(1) + ax_norm(3) / 2;

pos_basic = [center - btn_w - gap/2,  btn_y,  btn_w,  btn_h];
pos_adv   = [center + gap/2,           btn_y,  btn_w,  btn_h];

col_bg_active   = [0.18 0.52 0.89];   % blue background = current choice
col_bg_inactive = [0.30 0.30 0.30];   % grey background = other choice
col_fg_active   = [0.30 1.00 0.30];   % green text     = current choice
col_fg_inactive = [1.00 1.00 1.00];   % white text     = other choice

if strcmp(remembered,'basic')
    bg_b = col_bg_active;   fg_b = col_fg_active;
    bg_a = col_bg_inactive; fg_a = col_fg_inactive;
else
    bg_b = col_bg_inactive; fg_b = col_fg_inactive;
    bg_a = col_bg_active;   fg_a = col_fg_active;
end

tip_basic = ['Basic mode hides buttons and functions that are not required ' ...
    'for basic PIV analysis, for a simpler and less cluttered interface.'];
tip_adv = 'Advanced mode shows all of PIVlab''s buttons and functions.';

uicontrol(hgui, 'Style','pushbutton', ...
    'String','Basic mode', ...
    'Units','normalized', 'Position', pos_basic, ...
    'FontSize', 14, 'FontWeight', 'bold', ...
    'BackgroundColor', bg_b, 'ForegroundColor', fg_b, ...
    'Tag','mode_btn_basic', 'TooltipString', tip_basic, ...
    'Callback', @(~,~) choose_mode('basic'));

uicontrol(hgui, 'Style','pushbutton', ...
    'String','Advanced mode', ...
    'Units','normalized', 'Position', pos_adv, ...
    'FontSize', 14, 'FontWeight', 'bold', ...
    'BackgroundColor', bg_a, 'ForegroundColor', fg_a, ...
    'Tag','mode_btn_advanced', 'TooltipString', tip_adv, ...
    'Callback', @(~,~) choose_mode('advanced'));

drawnow;

    function choose_mode(mode)
        % request_mode_switch handles the confirmation + reset; on success it
        % calls apply_ui_mode, which updates the button highlight. On cancel
        % the buttons stay reflecting the unchanged mode, so nothing to do here.
        gui.request_mode_switch(mode);
        drawnow;
    end
end
