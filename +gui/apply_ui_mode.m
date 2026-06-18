function apply_ui_mode(mode)
% apply_ui_mode  Show or hide UI elements for Basic/Advanced mode.
%   mode: 'basic' or 'advanced'
%
% Pure visibility logic — only elements listed in PIVlab_hidden_elements.txt
% are touched:
%   Basic    : the listed elements are hidden.
%   Advanced : the listed elements are restored to their factory-default
%              visibility (captured at startup by gui.capture_default_visibility).
%
% Interactive switches go through gui.request_mode_switch, which first resets
% all controls to their defaults.  Because the controls then match the factory
% defaults, restoring the factory-default visibility here is always correct —
% no dynamic re-derivation is needed.  Startup calls this directly (the GUI is
% already at its freshly-loaded default state).

hgui = getappdata(0,'hgui');
gui.put('ui_mode', mode);

% ── overlay button colors (blue bg + green text marks the active mode) ──────
col_bg_active   = [0.18 0.52 0.89];
col_bg_inactive = [0.30 0.30 0.30];
col_fg_active   = [0.30 1.00 0.30];
col_fg_inactive = [1.00 1.00 1.00];
h_basic_btn = findobj(hgui, 'Tag', 'mode_btn_basic');
h_adv_btn   = findobj(hgui, 'Tag', 'mode_btn_advanced');
if ~isempty(h_basic_btn) && ~isempty(h_adv_btn)
    if strcmp(mode,'basic')
        set(h_basic_btn, 'BackgroundColor', col_bg_active,   'ForegroundColor', col_fg_active);
        set(h_adv_btn,   'BackgroundColor', col_bg_inactive, 'ForegroundColor', col_fg_inactive);
    else
        set(h_basic_btn, 'BackgroundColor', col_bg_inactive, 'ForegroundColor', col_fg_inactive);
        set(h_adv_btn,   'BackgroundColor', col_bg_active,   'ForegroundColor', col_fg_active);
    end
end

% ── File > Mode menu checkmark ──────────────────────────────────────────────
h_menu_basic = findall(hgui, 'Tag', 'menu_mode_basic');
h_menu_adv   = findall(hgui, 'Tag', 'menu_mode_advanced');
if ~isempty(h_menu_basic) && ~isempty(h_menu_adv)
    if strcmp(mode,'basic')
        set(h_menu_basic, 'Checked', 'on');
        set(h_menu_adv,   'Checked', 'off');
    else
        set(h_menu_basic, 'Checked', 'off');
        set(h_menu_adv,   'Checked', 'on');
    end
end

% ── load config ────────────────────────────────────────────────────────────
tags = read_hidden_tags();
if isempty(tags); return; end

if strcmp(mode, 'basic')
    % Hide all listed elements.
    for i = 1:numel(tags)
        h = findall(hgui, 'Tag', tags{i});
        if ~isempty(h)
            set(h, 'Visible', 'off');
        end
    end

    % If the active panel was hidden, fall back to the always-visible
    % Input data panel (multip01).
    visible_panels = findall(hgui, '-regexp', 'Tag', '^multip\d', 'Visible', 'on');
    if isempty(visible_panels)
        try; gui.switchui('multip01'); catch; end
    end

else % 'advanced'
    def_vis = gui.retr('ui_default_visibility');
    have_defaults = ~isempty(def_vis) && isa(def_vis, 'containers.Map');

    for i = 1:numel(tags)
        tag = tags{i};
        % multip* panels are managed by switchui() — never force their state.
        if ~isempty(regexp(tag, '^multip\d', 'once')); continue; end
        h = findall(hgui, 'Tag', tag);
        if isempty(h); continue; end
        if have_defaults && isKey(def_vis, tag)
            set(h, 'Visible', def_vis(tag));   % restore factory default
        else
            set(h, 'Visible', 'on');           % fallback: show it
        end
    end
end
end

% ── helpers ───────────────────────────────────────────────────────────────
function tags = read_hidden_tags()
[pivlab_dir,~,~] = fileparts(which('PIVlab_GUI.m'));
cfg_file = fullfile(pivlab_dir, 'PIVlab_hidden_elements.txt');
if ~exist(cfg_file,'file')
    warning('PIVlab:apply_ui_mode','Hidden-elements file not found: %s', cfg_file);
    tags = {};
    return
end
cfg   = fileread(cfg_file);
lines = strtrim(strsplit(cfg, newline));
tags  = lines(~startsWith(lines,'#') & ~cellfun(@isempty, lines));
end
