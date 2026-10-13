function d = helper_snapshot_differences(A, B)
%HELPER_SNAPSHOT_DIFFERENCES Differences of two helper_gui_snapshot results, one line each ({} = none).
%   d = helper_snapshot_differences(fresh, reset)
%   Data that is missing in one window and empty in the other counts as equal (gui.retr gives [] for
%   both; e.g. the image acquisition settings of the preferences create empty structs).
d = {};
% data of the window
fa = fieldnames(A.appdata);
fb = fieldnames(B.appdata);
for k = 1:numel(fa)
    if ~isfield(B.appdata, fa{k})
        if ~is_nothing(A.appdata.(fa{k}))
            d{end+1, 1} = sprintf('data "%s": only in the first window (%s)', fa{k}, short(A.appdata.(fa{k}))); %#ok<AGROW>
        end
    elseif ~isequaln(A.appdata.(fa{k}), B.appdata.(fa{k}))
        d{end+1, 1} = sprintf('data "%s": %s -> %s', fa{k}, short(A.appdata.(fa{k})), short(B.appdata.(fa{k}))); %#ok<AGROW>
    end
end
for k = 1:numel(fb)
    if ~isfield(A.appdata, fb{k}) && ~is_nothing(B.appdata.(fb{k}))
        d{end+1, 1} = sprintf('data "%s": only in the second window (%s)', fb{k}, short(B.appdata.(fb{k}))); %#ok<AGROW>
    end
end
% controls, panels, menus, axes: lists in creation order
lists = {'controls', 'panels', 'menus', 'axes'};
for j = 1:numel(lists)
    a = A.(lists{j});
    b = B.(lists{j});
    if numel(a) ~= numel(b)
        d{end+1, 1} = sprintf('%s: %d -> %d', lists{j}, numel(a), numel(b)); %#ok<AGROW>
    end
    for k = 1:min(numel(a), numel(b))
        if ~strcmp(a{k}, b{k})
            d{end+1, 1} = sprintf('%s %d: %s -> %s', lists{j}, k, a{k}, b{k}); %#ok<AGROW>
        end
    end
end
if ~strcmp(A.pivlab_axis, B.pivlab_axis)
    d{end+1, 1} = sprintf('axes: %s -> %s', A.pivlab_axis, B.pivlab_axis);
end
f = fieldnames(A.figure);
for k = 1:numel(f)
    if ~strcmp(A.figure.(f{k}), B.figure.(f{k}))
        d{end+1, 1} = sprintf('window %s: %s -> %s', f{k}, A.figure.(f{k}), B.figure.(f{k})); %#ok<AGROW>
    end
end
end

function tf = is_nothing(v)
% empty, or a struct without fields
tf = isempty(v) || (isstruct(v) && isscalar(v) && isempty(fieldnames(v)));
end

function t = short(v)
% short description of a value for the message
if ischar(v)
    t = ['''' v ''''];
elseif isnumeric(v) || islogical(v)
    if numel(v) <= 6
        t = mat2str(v, 5);
    else
        t = sprintf('%s %s', class(v), mat2str(size(v)));
    end
else
    t = sprintf('%s %s', class(v), mat2str(size(v)));
end
if numel(t) > 80
    t = [t(1:77) '...'];
end
end
