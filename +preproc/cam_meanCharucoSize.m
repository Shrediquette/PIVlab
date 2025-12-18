%{
function [avg_vert,avg_horiz] = meanCharucoSize(P)
x = P(:,1);
y = P(:,2);
% sort points by x (to be robust)
[~, idx] = sort(x);
x_sorted = x(idx);
y_sorted = y(idx);

% differences in x
dx = diff(x_sorted);

% robust threshold to detect big jumps (adjust multiplier if needed)
med = median(abs(dx));
mad = median(abs(abs(dx)-med));
thr = med + 5*mad;        % <-- 5*mad is conservative; lower to 3 if you miss breaks

% find break indices (between points i and i+1)
breaks = find(abs(dx) > thr);

% build column ranges
starts = [1; breaks+1];
ends   = [breaks; length(x_sorted)];

numCols = length(starts);
cols = cell(numCols,1);
col_centers = zeros(numCols,1);

for k = 1:numCols
    rows = starts(k):ends(k);
    cols{k} = [x_sorted(rows) y_sorted(rows)];
    col_centers(k) = mean(cols{k}(:,1));   % column x-center
end

% horizontal spacing = mean diff between sorted column centers
col_centers = sort(col_centers);
avg_horiz = mean(diff(col_centers));

% vertical spacing = mean of dy inside each column
all_dy = [];
for k = 1:numCols
    ys = sort(cols{k}(:,2));
    d = diff(ys);
    all_dy = [all_dy; d];
end
avg_vert = mean(all_dy);

fprintf('Detected %d columns. Avg horizontal spacing = %.3f. Avg vertical spacing = %.3f\n', ...
        numCols, avg_horiz, avg_vert);

%}

%% function with nan handling:
function [avg_vert,avg_horiz] = cam_meanCharucoSize(P)

% remove missing markers (rows with NaN)
valid = all(isfinite(P),2);
P = P(valid,:);

x = P(:,1);
y = P(:,2);

% sort points by x
[x_sorted, idx] = sort(x);
y_sorted = y(idx);

% differences in x
dx = diff(x_sorted);

% remove NaNs from dx (extra safety)
dx = dx(isfinite(dx));

% robust threshold to detect big jumps
med = median(abs(dx));
mad = median(abs(abs(dx)-med));
thr = med + 5*mad;

% find break indices
breaks = find(abs(diff(x_sorted)) > thr);

% build column ranges
starts = [1; breaks+1];
ends   = [breaks; length(x_sorted)];

numCols = length(starts);
cols = cell(numCols,1);
col_centers = nan(numCols,1);

for k = 1:numCols
    rows = starts(k):ends(k);
    c = [x_sorted(rows) y_sorted(rows)];

    % remove NaNs inside each column
    c = c(all(isfinite(c),2),:);

    if size(c,1) >= 2
        cols{k} = c;
        col_centers(k) = mean(c(:,1));
    else
        cols{k} = [];
    end
end

% horizontal spacing (ignore empty columns)
col_centers = col_centers(isfinite(col_centers));
col_centers = sort(col_centers);
avg_horiz = mean(diff(col_centers));

% vertical spacing
all_dy = [];
for k = 1:numCols
    if isempty(cols{k}), continue; end
    ys = sort(cols{k}(:,2));
    d = diff(ys);
    d = d(isfinite(d));
    all_dy = [all_dy; d];
end

% robustly keep only the dominant vertical spacing
m = median(all_dy);
mad_dy = median(abs(all_dy - m));

% keep values close to the median spacing
good = abs(all_dy - m) < 3*mad_dy;
avg_vert = mean(all_dy(good));

%all_dy(good)

disp('avg_vert seems incorrect often. maybe remove?')

fprintf('Detected %d columns. Avg horizontal spacing = %.3f. Avg vertical spacing = %.3f\n', ...
        numCols, avg_horiz, avg_vert);
end
