function [g, s] = resolve_options(group, opts)
%RESOLVE_OPTIONS Merge name=value options with Settings and the defaults.
%   [g, s] = resolve_options(group, opts)
%   opts.Settings (struct from pivlab.defaults / pivlab.loadSettings, or empty struct) is the base,
%   every other field of opts that is not empty overrides s.(group).(field).
%   g is the resulting group struct, s the complete settings struct.
if isfield(opts,'Settings') && ~isempty(opts.Settings) && ~isempty(fieldnames(opts.Settings))
    s = complete_settings(opts.Settings);
else
    s = pivlab.defaults();
end
g = s.(group);
f = fieldnames(opts);
for k = 1:numel(f)
    if strcmp(f{k},'Settings')
        continue
    end
    v = opts.(f{k});
    if isempty(v)
        continue
    end
    if ~isfield(g, f{k})
        error('pivlab:resolve_options:unknownOption','Unknown option "%s" for %s.', f{k}, group);
    end
    if (ischar(v) || iscellstr(v)) && isstring(g.(f{k})) %#ok<ISCLSTR>
        v = string(v);
    end
    g.(f{k}) = v;
end
s.(group) = g;
end

function s = complete_settings(s)
% fill in groups / fields missing in a user-made settings struct
d = pivlab.defaults();
groups = fieldnames(d);
for k = 1:numel(groups)
    if ~isfield(s, groups{k})
        s.(groups{k}) = d.(groups{k});
        continue
    end
    f = fieldnames(d.(groups{k}));
    for j = 1:numel(f)
        if ~isfield(s.(groups{k}), f{j})
            s.(groups{k}).(f{j}) = d.(groups{k}).(f{j});
        end
    end
    unknown = setdiff(fieldnames(s.(groups{k})), f);
    for j = 1:numel(unknown)   % e.g. a misspelled name: it would be ignored without a word
        warning('pivlab:settings:unknownField', 'Settings.%s.%s is not a PIVlab setting and is ignored.', groups{k}, unknown{j});
    end
end
end
