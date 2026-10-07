function ok = parity_compare(dirA, dirB, scenarios)
%PARITY_COMPARE Compare two parity_run outputs. Numbers must be isequaln, PNGs pixel-identical.
% Timing fields (runtime, t_*) are reported, not compared.
if nargin < 3 || isempty(scenarios)
    L = dir(fullfile(dirA,'*.mat')); scenarios = erase({L.name},'.mat');
end
ok = true;
rootA = run_root(dirA); rootB = run_root(dirB);
for k = 1:numel(scenarios)
    fa = fullfile(dirA,[scenarios{k} '.mat']); fb = fullfile(dirB,[scenarios{k} '.mat']);
    if ~isfile(fb), fprintf('MISSING %s in B\n', scenarios{k}); ok = false; continue; end
    A = load(fa); B = load(fb);
    A = normalize(A, dirA, rootA); B = normalize(B, dirB, rootB);
    diffs = {};
    diffs = cmp(A, B, scenarios{k}, diffs);
    tA = timings(A); tB = timings(B);
    if isempty(diffs)
        fprintf('SAME  %-28s %s\n', scenarios{k}, timing_str(tA,tB));
    else
        ok = false;
        fprintf('DIFF  %-28s %d differences %s\n', scenarios{k}, numel(diffs), timing_str(tA,tB));
        for d = 1:min(numel(diffs),25), fprintf('      %s\n', diffs{d}); end
    end
end
% PNGs
P = dir(fullfile(dirA,'*.png'));
npng = 0; nbad = 0;
for k = 1:numel(P)
    fb = fullfile(dirB,P(k).name);
    if ~isfile(fb), fprintf('PNG MISSING %s\n',P(k).name); nbad = nbad+1; continue; end
    a = imread(fullfile(dirA,P(k).name)); b = imread(fb);
    npng = npng+1;
    if ~isequal(size(a),size(b))
        fprintf('PNG SIZE %s %s vs %s\n',P(k).name,mat2str(size(a)),mat2str(size(b))); nbad = nbad+1;
    elseif ~isequal(a,b)
        d = any(a~=b,3);
        fprintf('PNG DIFF %s: %d pixels differ\n',P(k).name,nnz(d)); nbad = nbad+1;
    end
end
fprintf('PNGs: %d compared, %d differ\n', npng, nbad);
ok = ok && nbad == 0;
end

function diffs = cmp(a, b, path, diffs)
if numel(diffs) > 200, return; end
if isstruct(a) && isstruct(b)
    fa = fieldnames(a); fb = fieldnames(b);
    fa = fa(~is_timing(fa)); fb = fb(~is_timing(fb));
    only_a = setdiff(fa,fb); only_b = setdiff(fb,fa);
    for k = 1:numel(only_a), diffs{end+1} = sprintf('%s.%s only in A', path, only_a{k}); end %#ok<AGROW>
    for k = 1:numel(only_b), diffs{end+1} = sprintf('%s.%s only in B', path, only_b{k}); end %#ok<AGROW>
    if ~isequal(size(a),size(b)), diffs{end+1} = sprintf('%s struct size %s vs %s',path,mat2str(size(a)),mat2str(size(b))); return; end
    common = intersect(fa,fb);
    for i = 1:numel(a)
        for k = 1:numel(common)
            p = path; if numel(a)>1, p = sprintf('%s(%d)',path,i); end
            diffs = cmp(a(i).(common{k}), b(i).(common{k}), [p '.' common{k}], diffs);
        end
    end
elseif iscell(a) && iscell(b)
    if ~isequal(size(a),size(b)), diffs{end+1} = sprintf('%s cell size %s vs %s',path,mat2str(size(a)),mat2str(size(b))); return; end
    for i = 1:numel(a)
        diffs = cmp(a{i}, b{i}, sprintf('%s{%d}',path,i), diffs);
    end
else
    if ~isequaln(a,b)
        if isnumeric(a) && isnumeric(b) && isequal(size(a),size(b)) && ~isempty(a)
            dd = abs(double(a(:))-double(b(:))); dd(isnan(dd)) = inf;
            diffs{end+1} = sprintf('%s numeric: %d of %d differ, max |d| = %g, class %s/%s', path, nnz(dd>0), numel(a), max(dd), class(a), class(b));
        else
            diffs{end+1} = sprintf('%s differs (%s %s vs %s %s)', path, class(a), mat2str(size(a)), class(b), mat2str(size(b)));
        end
    end
end
end

function tf = is_timing(names)
tf = strcmp(names,'runtime') | startsWith(names,'t_') | strcmp(names,'t') | strcmp(names,'totaltime') | strcmp(names,'num_handle_calls') | ...
    strcmp(names,'homedir') | strcmp(names,'pathname') | ... % remembered folders from PIVlab_settings_default.mat
    strcmp(names,'saved');   % time when a settings / session file was written
end

function x = normalize(x, d, r)
% replace run-folder paths and random tempname ids, so they do not count as differences
if ischar(x) && size(x,1) <= 1
    x = replace_folders(x, d, r);
    x = regexprep(x, '^tp[0-9a-f]{8}_[0-9a-f_]+$', '<TEMPNAME>');
elseif isstring(x)
    x = replace_folders(x, d, r);
elseif iscell(x)
    for i = 1:numel(x), x{i} = normalize(x{i}, d, r); end
elseif isstruct(x)
    f = fieldnames(x);
    for i = 1:numel(x)
        for k = 1:numel(f)
            x(i).(f{k}) = normalize(x(i).(f{k}), d, r);
        end
    end
end
end

function T = timings(S)
T = struct();
f = fieldnames(S);
for k = 1:numel(f)
    if is_timing(f(k)) && isnumeric(S.(f{k})), T.(f{k}) = S.(f{k}); end
end
end

function s = timing_str(A,B)
s = '';
f = intersect(fieldnames(A),fieldnames(B));
for k = 1:numel(f)
    s = [s sprintf(' %s %.1f->%.1f', f{k}, A.(f{k}), B.(f{k}))]; %#ok<AGROW>
end
end


function r = run_root(d)
% PIVlab folder the run was made with (written by parity_run)
r = '<no root.txt in this run folder>';
f = fullfile(d,'root.txt');
if isfile(f), r = strtrim(fileread(f)); end
end

function x = replace_folders(x, d, r)
% the run folder and the PIVlab folder, written with / or \ (file lists use \ on Windows)
x = strrep(x, d, '<RUN>'); x = strrep(x, strrep(d,'/','\'), '<RUN>'); x = strrep(x, strrep(d,'\','/'), '<RUN>');
x = strrep(x, r, '<ROOT>'); x = strrep(x, strrep(r,'/','\'), '<ROOT>'); x = strrep(x, strrep(r,'\','/'), '<ROOT>');
end
