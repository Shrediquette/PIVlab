function def_vis = capture_default_visibility()
% capture_default_visibility  Snapshot the factory-default Visible state of
% every tagged UI element, exactly as generateUI/generateMenu created it.
%
% Called once during startup (right after the GUI is built, before any
% settings or callbacks run).  The result is the single source of truth used
% by apply_ui_mode to restore elements when switching back to Advanced mode,
% so visibility defaults are never duplicated in code.

hgui   = getappdata(0,'hgui');
all_h  = findall(hgui);   % findall: include HandleVisibility='off' (menus)
def_vis = containers.Map('KeyType','char','ValueType','char');

for k = 1:numel(all_h)
    h = all_h(k);
    if isprop(h,'Tag') && isprop(h,'Visible')
        tg = h.Tag;
        if ~isempty(tg) && ~isKey(def_vis, tg)
            def_vis(tg) = char(h.Visible);
        end
    end
end
end
