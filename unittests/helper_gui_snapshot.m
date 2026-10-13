function S = helper_gui_snapshot(hgui)
%HELPER_GUI_SNAPSHOT State of the PIVlab window, to compare a reset window with a newly started one.
%   S = helper_gui_snapshot()        S = helper_gui_snapshot(hgui)
%   S.appdata   all data of the window (gui.put), graphics handles replaced by their type
%   S.controls  every control in creation order: Tag, Style, String, Value, Enable, Visible
%   S.panels, S.menus, S.axes, S.figure   panels, menus, axes and callbacks of the window
%   Compare two snapshots with helper_snapshot_differences.
if nargin < 1
    hgui = getappdata(0, 'hgui');
end
% values that change by themselves (handle cache counter, the start state itself), and the folders
% that PIVlab remembers for the next start (also kept by "Reset PIVlab GUI", like at a new start)
skip = {'num_handle_calls', 'existing_handles', 'startup_appdata', 'homedir', 'pathname'};
A = getappdata(hgui);
names = sort(fieldnames(A));
S.appdata = struct();
for k = 1:numel(names)
    if any(strcmp(names{k}, skip))
        continue
    end
    S.appdata.(names{k}) = plain(A.(names{k}));
end
c = findall(hgui, 'Type', 'uicontrol');
S.controls = cell(numel(c), 1);
for k = 1:numel(c)
    S.controls{k} = sprintf('%s|%s|%s|%s|%s|%s', c(k).Tag, c(k).Style, text_of(c(k).String), mat2str(c(k).Value, 6), ...
        char(c(k).Enable), char(c(k).Visible));
end
p = findall(hgui, 'Type', 'uipanel');
S.panels = cell(numel(p), 1);
for k = 1:numel(p)
    S.panels{k} = sprintf('%s|%s|%s', p(k).Tag, text_of(p(k).Title), char(p(k).Visible));
end
m = findall(hgui, 'Type', 'uimenu');
S.menus = cell(numel(m), 1);
for k = 1:numel(m)
    S.menus{k} = sprintf('%s|%s|%s|%s|%s', m(k).Tag, m(k).Text, char(m(k).Checked), char(m(k).Enable), char(m(k).Visible));
end
% axes, colour bars, legends, annotations. An empty annotation layer is left out: MATLAB creates and
% removes it by itself (it is there after the start and goes when images are shown).
others = findall(hgui, '-depth', 1, '-not', 'Type', 'figure', '-not', 'Type', 'uimenu', '-not', 'Type', 'uicontrol', '-not', 'Type', 'uipanel');
S.axes = {};
for k = 1:numel(others)
    if strcmp(others(k).Type, 'annotationpane')
        if ~isempty(others(k).Children)
            S.axes{end+1, 1} = sprintf('annotationpane with %d annotations', numel(others(k).Children));
        end
    else
        S.axes{end+1, 1} = others(k).Type;
    end
end
ax = getappdata(hgui, 'pivlab_axis');
ch = ax.Children;
types = cell(numel(ch), 1);
for k = 1:numel(ch)
    types{k} = ch(k).Type;
end
S.pivlab_axis = sprintf('children %s | xlim %s | ylim %s | ydir %s | visible %s', strjoin(types', ','), ...
    mat2str(ax.XLim, 6), mat2str(ax.YLim, 6), ax.YDir, char(ax.Visible));
props = {'Name', 'Pointer', 'WindowButtonDownFcn', 'WindowButtonMotionFcn', 'WindowButtonUpFcn', ...
    'WindowScrollWheelFcn', 'WindowKeyPressFcn', 'WindowKeyReleaseFcn', 'KeyPressFcn', 'KeyReleaseFcn', ...
    'ResizeFcn', 'CloseRequestFcn'};
for k = 1:numel(props)
    S.figure.(props{k}) = text_of(hgui.(props{k}));
end
end

function v = plain(v)
% comparable copy: graphics and other handle objects by type, maps by content
if isa(v, 'matlab.graphics.Graphics')
    t = cell(numel(v), 1);
    for k = 1:numel(v)
        if isvalid(v(k))
            t{k} = ['graphics ' v(k).Type];
        else
            t{k} = 'deleted graphics';
        end
    end
    v = t;
elseif isa(v, 'containers.Map')
    keys = v.keys;
    values = v.values;
    s = struct('key', keys, 'value', values);
    v = s;
elseif isa(v, 'function_handle')
    v = func2str(v);
elseif isstruct(v)
    out = v;
    for n = 1:numel(v)
        f = fieldnames(v);
        for j = 1:numel(f)
            out(n).(f{j}) = plain(v(n).(f{j}));
        end
    end
    v = out;
elseif iscell(v)
    for k = 1:numel(v)
        v{k} = plain(v{k});
    end
elseif isobject(v) && ~isstring(v) && ~isdatetime(v) && ~isduration(v) && ~istable(v)
    v = ['object ' class(v)];
end
end

function t = text_of(v)
% a String / Title / callback as one line of text
if isa(v, 'function_handle')
    t = func2str(v);
elseif iscell(v)
    parts = cell(1, numel(v));
    for k = 1:numel(v)
        parts{k} = text_of(v{k});
    end
    t = ['{' strjoin(parts, ';') '}'];
elseif isstring(v)
    t = char(strjoin(v, ';'));
elseif ischar(v)
    if size(v, 1) > 1
        t = strjoin(cellstr(v)', ';');
    else
        t = v;
    end
else
    t = mat2str(v, 6);
end
end
