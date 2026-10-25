function [P, n_rejected] = cam_filter_charuco_corners(P, patternDims)
% Remove ChArUco corners of wrongly decoded markers. A marker decoded with a wrong ID puts
% its corners at a wrong board position, so the corner does not fit its neighbours.
% Three checks, all local (lens distortion, also fisheye, and perspective do not matter):
% 1) Image neighbours: of two corners at the same place in the image (one of them is wrong),
%    the one that fits its board neighbours worse is removed. The nearest corners in the
%    image must also be near on the board.
%    For each of the 8 nearest corners in the image, the distance on the board [checkers]
%    must match the distance in the image divided by the local checker size. A corner is
%    rejected if most of its image neighbours do not match. This finds wrong corners also
%    in groups (several wrong markers that fit each other).
% 2) Board neighbours: each corner is predicted from its neighbours along the board rows and
%    columns (interpolation between two neighbours, extrapolation from two neighbours on one
%    side) and rejected if most predictions are off by more than a quarter checker
%    (interpolation) or half a checker (extrapolation: it doubles the error of a slightly
%    misplaced neighbour, which would otherwise remove its correct neighbours). A wrong ID
%    moves a corner by whole checkers.
%    In 1) and 2) the worst corners are removed first; good corners next to a wrong one are
%    disturbed by it and recover once it is gone.
% 3) Corners outside the connected blocks of at least 6 confirmed corners (isolated corners,
%    small groups) must fit a projective transform of the nearest block corners in the image.
%    If there is no such block, the detection can not be verified and all corners are rejected.
% P: corners as from detectCharucoBoardPoints (NaN = not detected), patternDims: [rows columns]
% Rejected corners are set to NaN.
n_neighbours = 8;      % check 1: nearest corners in the image
tolerance_interpolation = 0.25; % check 2: max distance from the prediction [checkers]
tolerance_extrapolation = 0.5;  % check 2: an extrapolation doubles the error of a neighbour
n_reference = 12;      % check 3: nearest block corners in the image
min_block = 6;         % check 3: smaller largest block: the detection can not be trusted
max_ratio_far = 0.5;   % check 3: max distance from the prediction [checkers]
n_rejected = 0;
n_rows = patternDims(1) - 1; % corners
n_cols = patternDims(2) - 1;
if isempty(P) || size(P, 1) ~= n_rows * n_cols
    return
end
grid = patternWorldPoints("charuco-board", patternDims, 1); % corner positions [checkers]
row_of = round(grid(:, 2)) + 1;
col_of = round(grid(:, 1)) + 1;
X = nan(n_rows, n_cols);
Y = nan(n_rows, n_cols);
for k = 1:size(P, 1)
    X(row_of(k), col_of(k)) = P(k, 1);
    Y(row_of(k), col_of(k)) = P(k, 2);
end

%% 1) image neighbours must be board neighbours
% two corners at the same place in the image (less than 0.3 checkers apart): one of them has a
% wrong ID (e.g. a marker one checker off). The one that fits its board neighbours worse is
% removed, both if that is not clear.
[rows, cols] = find(~isnan(X));
n = numel(rows);
if n >= 2
    idx = sub2ind([n_rows n_cols], rows, cols);
    pitch = local_pitch(X, Y, rows, cols);
    distance = sqrt((X(idx) - X(idx)') .^ 2 + (Y(idx) - Y(idx)') .^ 2);
    distance(1:n + 1:end) = Inf;
    remove = false(n, 1);
    for k = 1:n
        % smaller checker size of the two (a wrong corner can have a huge one: far board neighbours)
        m = find(distance(k, :) < 0.3 * min(pitch(k), pitch'), 1);
        if isempty(m) || m < k
            continue % no duplicate, or the pair was decided already
        end
        % fit of each corner to its board neighbours, without the other one
        Xk = X;
        Xk(idx(m)) = NaN;
        off_k = board_offset(Xk, Y, rows(k), cols(k), tolerance_interpolation, tolerance_extrapolation);
        Xm = X;
        Xm(idx(k)) = NaN;
        off_m = board_offset(Xm, Y, rows(m), cols(m), tolerance_interpolation, tolerance_extrapolation);
        if off_k <= 1 && ~(off_m <= off_k)
            remove(m) = true;
        elseif off_m <= 1 && ~(off_k <= off_m)
            remove(k) = true;
        else
            remove([k m]) = true;
        end
    end
    X(idx(remove)) = NaN;
    Y(idx(remove)) = NaN;
    n_rejected = n_rejected + nnz(remove);
end
for iteration = 1:100
    [rows, cols] = find(~isnan(X));
    n = numel(rows);
    if n < 4
        break
    end
    idx = sub2ind([n_rows n_cols], rows, cols);
    x = X(idx);
    y = Y(idx);
    pitch = local_pitch(X, Y, rows, cols); % [px per checker], NaN without board neighbours
    distance = (x - x') .^ 2 + (y - y') .^ 2;
    distance(1:n + 1:end) = Inf;
    [distance, nearest] = mink(distance, min(n_neighbours, n - 1), 2);
    distance = sqrt(distance);
    mismatch = nan(n, 1);
    for k = 1:n
        neighbours = nearest(k, :);
        board_distance = hypot(rows(neighbours) - rows(k), cols(neighbours) - cols(k))';
        expected = distance(k, :) ./ pitch(neighbours)'; % board distance from the image distance
        valid = ~isnan(expected);
        if nnz(valid) >= 3
            wrong = abs(board_distance - expected) > 1 + 0.25 * board_distance;
            mismatch(k) = nnz(wrong & valid) / nnz(valid);
        end
    end
    % remove the corners with most mismatches among their image neighbours
    remove = false(n, 1);
    for k = 1:n
        if mismatch(k) > 0.5
            worst_neighbour = max(mismatch(nearest(k, :)), [], 'omitnan');
            remove(k) = isnan(worst_neighbour) || mismatch(k) >= worst_neighbour;
        end
    end
    if ~any(remove)
        break
    end
    X(idx(remove)) = NaN;
    Y(idx(remove)) = NaN;
    n_rejected = n_rejected + nnz(remove);
end

%% 2) prediction from the board neighbours
for iteration = 1:100
    ratio = nan(n_rows, n_cols); % median distance from the predictions / their tolerance
    for i = 1:n_rows
        for j = 1:n_cols
            if ~isnan(X(i, j))
                ratio(i, j) = board_offset(X, Y, i, j, tolerance_interpolation, tolerance_extrapolation);
            end
        end
    end
    remove = false(n_rows, n_cols);
    for i = 1:n_rows
        for j = 1:n_cols
            if ratio(i, j) > 1
                window = ratio(max(1, i - 2):min(n_rows, i + 2), max(1, j - 2):min(n_cols, j + 2));
                remove(i, j) = ratio(i, j) >= max(window(:));
            end
        end
    end
    if ~any(remove(:))
        break
    end
    X(remove) = NaN;
    Y(remove) = NaN;
    n_rejected = n_rejected + nnz(remove);
end

%% 3) corners outside the confirmed blocks must fit the nearest block corners
confirmed = ratio <= 1;
blocks = bwconncomp(confirmed, 8);
remove = false(n_rows, n_cols);
if blocks.NumObjects == 0
    remove = ~isnan(X); % nothing confirmed: the detection can not be trusted
else
    block_size = zeros(blocks.NumObjects, 1);
    for b = 1:blocks.NumObjects
        block_size(b) = numel(blocks.PixelIdxList{b});
    end
    % blocks of at least min_block corners confirm themselves (the corners of one wrong marker
    % can not form such a block, they have no neighbours in line) and are the reference
    trusted = false(n_rows, n_cols);
    for b = 1:blocks.NumObjects
        if block_size(b) >= min_block
            trusted(blocks.PixelIdxList{b}) = true;
        end
    end
    [ref_rows, ref_cols] = find(trusted);
    ref_x = X(trusted);
    ref_y = Y(trusted);
    if max(block_size) < min_block
        remove = ~isnan(X); % no block of reasonable size: the detection can not be trusted
    else
        for i = 1:n_rows
            for j = 1:n_cols
                if isnan(X(i, j)) || trusted(i, j)
                    continue
                end
                [~, order] = sort((ref_x - X(i, j)) .^ 2 + (ref_y - Y(i, j)) .^ 2);
                near = order(1:min(n_reference, numel(order)));
                if numel(unique(ref_rows(near))) < 2 || numel(unique(ref_cols(near))) < 2
                    continue % reference corners on one line: no transform
                end
                tform = fitgeotform2d([ref_cols(near), ref_rows(near)], [ref_x(near), ref_y(near)], 'projective');
                pred = transformPointsForward(tform, [j i; j + 1 i; j i + 1]);
                spacing = mean([norm(pred(2, :) - pred(1, :)), norm(pred(3, :) - pred(1, :))]);
                % the further from the reference corners, the less exact the transform
                gap = min(hypot(ref_rows(near) - i, ref_cols(near) - j));
                remove(i, j) = norm([X(i, j), Y(i, j)] - pred(1, :)) / spacing > max_ratio_far + 0.1 * gap;
            end
        end
    end
end
X(remove) = NaN;
n_rejected = n_rejected + nnz(remove);

for k = 1:size(P, 1)
    if isnan(X(row_of(k), col_of(k)))
        P(k, :) = NaN;
    end
end
end

function offset = board_offset(X, Y, i, j, tolerance_interpolation, tolerance_extrapolation)
% Distance of corner (i, j) from its predictions by the board neighbours, divided by the
% tolerance of each prediction; median of all predictions (> 1: does not fit).
% NaN with fewer than two predictions (isolated corner).
directions = [0 1; 1 0; 0 -1; -1 0];
off = zeros(0, 1);
for d = 1:4
    % extrapolation from two neighbours on one side
    [ok, a, b] = two_corners(X, Y, i + directions(d, 1), j + directions(d, 2), ...
        i + 2 * directions(d, 1), j + 2 * directions(d, 2));
    if ok
        off(end + 1, 1) = norm([X(i, j), Y(i, j)] - (2 * a - b)) / (norm(a - b) * tolerance_extrapolation); %#ok<AGROW>
    end
    % interpolation between the neighbours on both sides
    if d <= 2
        [ok, a, b] = two_corners(X, Y, i + directions(d, 1), j + directions(d, 2), ...
            i - directions(d, 1), j - directions(d, 2));
        if ok
            off(end + 1, 1) = norm([X(i, j), Y(i, j)] - (a + b) / 2) / (norm(a - b) / 2 * tolerance_interpolation); %#ok<AGROW>
        end
    end
end
offset = NaN;
if numel(off) >= 2
    offset = median(off);
end
end

function pitch = local_pitch(X, Y, rows, cols)
% median image distance [px] to the detected neighbours along the board rows and columns
[n_rows, n_cols] = size(X);
pitch = nan(numel(rows), 1);
steps = [0 1; 1 0; 0 -1; -1 0];
for k = 1:numel(rows)
    d = [];
    for s = 1:4
        i = rows(k) + steps(s, 1);
        j = cols(k) + steps(s, 2);
        if i >= 1 && i <= n_rows && j >= 1 && j <= n_cols && ~isnan(X(i, j))
            d(end + 1) = hypot(X(i, j) - X(rows(k), cols(k)), Y(i, j) - Y(rows(k), cols(k))); %#ok<AGROW>
        end
    end
    if ~isempty(d)
        pitch(k) = median(d);
    end
end
end

function [ok, a, b] = two_corners(X, Y, i1, j1, i2, j2)
% two detected corners at the board positions (i1, j1) and (i2, j2)
ok = false;
a = [];
b = [];
[n_rows, n_cols] = size(X);
if min([i1 i2 j1 j2]) < 1 || max([i1 i2]) > n_rows || max([j1 j2]) > n_cols
    return
end
if isnan(X(i1, j1)) || isnan(X(i2, j2))
    return
end
a = [X(i1, j1), Y(i1, j1)];
b = [X(i2, j2), Y(i2, j2)];
ok = true;
end
