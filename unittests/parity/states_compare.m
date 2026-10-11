function n = states_compare(fileA, fileB)
%STATES_COMPARE List the differences between two states_run recordings.
%   n = states_compare(fileA, fileB) prints, for every scenario step, the controls whose
%   Enable / Visible state or text differs (A -> B) and returns the number of differences.
%   Controls that exist in only one of the versions are listed once at the end.
A = load(fileA); B = load(fileB);
n = 0;
onlyA = {}; onlyB = {};
scen = fieldnames(A);
for s = 1:numel(scen)
    if ~isfield(B, scen{s})
        fprintf('%s: missing in B\n', scen{s}); n = n + 1; continue
    end
    for e = {'error','error_start'}
        if isfield(A.(scen{s}), e{1}), fprintf('%s: error in A: %s\n', scen{s}, A.(scen{s}).(e{1})); end
        if isfield(B.(scen{s}), e{1}), fprintf('%s: error in B: %s\n', scen{s}, B.(scen{s}).(e{1})); end
    end
    steps = fieldnames(A.(scen{s}));
    for k = 1:numel(steps)
        if ~isfield(B.(scen{s}), steps{k}) || ~isstruct(A.(scen{s}).(steps{k})), continue; end
        a = A.(scen{s}).(steps{k}); b = B.(scen{s}).(steps{k});
        fa = fieldnames(a); fb = fieldnames(b);
        onlyA = union(onlyA, setdiff(fa, fb)); onlyB = union(onlyB, setdiff(fb, fa));
        common = intersect(fa, fb);
        lines = {};
        for c = 1:numel(common)
            if ~strcmp(a.(common{c}), b.(common{c}))
                lines{end+1} = sprintf('    %-32s %s  ->  %s', common{c}, a.(common{c}), b.(common{c})); %#ok<AGROW>
            end
        end
        if ~isempty(lines)
            fprintf('%s / %s:\n%s\n', scen{s}, steps{k}, strjoin(lines, newline));
            n = n + numel(lines);
        end
    end
end
if ~isempty(onlyA), fprintf('only in A: %s\n', strjoin(onlyA, ', ')); end
if ~isempty(onlyB), fprintf('only in B: %s\n', strjoin(onlyB, ', ')); end
fprintf('%d differences\n', n);
end
