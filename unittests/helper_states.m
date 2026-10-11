function S = helper_states(hgui)
%HELPER_STATES Enable and Visible of every tagged uicontrol and uipanel of the PIVlab window.
%   S.(Tag) = 'Enable/Visible'
if nargin < 1
    hgui = getappdata(0, 'hgui');
end
h = [findall(hgui, 'Type', 'uicontrol'); findall(hgui, 'Type', 'uipanel')];
S = struct();
for k = 1:numel(h)
    t = h(k).Tag;
    if isempty(t) || ~isvarname(t)
        continue
    end
    e = '';
    if isprop(h(k), 'Enable')
        e = char(h(k).Enable);
    end
    S.(t) = [e '/' char(h(k).Visible)];
end
end
