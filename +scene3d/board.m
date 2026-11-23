function [h, tex] = board(ax, board, opts)
%BOARD The ChArUco board as printed and the axes of the results at its '0'.
%   [h, tex] = scene3d.board(ax, board)
%   [h, tex] = scene3d.board(ax, [], Points=wp)        without board definition: plain plate with the corners
%   [h, tex] = scene3d.board(ax, board, Frame=T)       the data of the scene (cameras, views, ...) are in other
%                                                      coordinates than the printed board: T, frame -> printed
%                                                      (scene3d.frame_transform; mirrored or turned boards)
% board: PatternDims, CheckerSize [mm], MarkerSize, MarkerFamily, OriginCheckerColor (stereo.board_from_gui).
% h: graphics objects (Tag opts.Tag), tex: texture of the board (simulate.board_texture; [] without board).
% Sets the board and the frame of the scene (scene3d.result, scene3d.to_board, scene3d.finish).
arguments
    ax
    board
    opts.Points = []
    opts.Frame = rigidtform3d
    opts.Tag = 'scene3d_board'
end
S = getappdata(ax, 'scene3d');
S.frame = opts.Frame;
tex = [];
hold(ax, 'on');
common = {'HitTest', 'off', 'PickableParts', 'none', 'HandleVisibility', 'off', 'Tag', opts.Tag};
if ~isempty(board)
    checker = board.CheckerSize;
    origin = simulate.result_axes([0 0], board); % the '0' of the board: [0 y0]
    S.y0 = origin(2);
    c = max(8, min(40, round(1200 / (board.PatternDims(2) + 2)))); % about 1200 texels across
    tex = simulate.board_texture(board, c, Decorated=true);
    img = double(tex.image) / 255;
    x = ([0, size(img, 2)] - tex.m) / tex.c - 1;
    y = ([0, size(img, 1)] - tex.m_top) / tex.c - 1;
    [X, Y] = meshgrid(x * checker, y * checker);
    R = scene3d.to_result([X(:), Y(:), zeros(4, 1)], S.y0); % printed board: no frame
    h = surface(ax, reshape(R(:, 1), 2, 2), reshape(R(:, 2), 2, 2), reshape(R(:, 3), 2, 2), repmat(img, 1, 1, 3), ...
        'FaceColor', 'texturemap', 'EdgeColor', [0.45 0.45 0.45], 'FaceLighting', 'none', common{:});
    rect = R([1 2 4 3], :);
else % plain plate with the corners (as given: no frame)
    S.frame = rigidtform3d;
    wp = opts.Points;
    checker = spacing(wp);
    S.y0 = max(wp(:, 2));
    lo = min(wp, [], 1) - checker;
    hi = max(wp, [], 1) + checker;
    rect = scene3d.to_result([lo(1) lo(2); hi(1) lo(2); hi(1) hi(2); lo(1) hi(2)], S.y0);
    h = patch(ax, rect(:, 1), rect(:, 2), rect(:, 3), [0.85 0.85 0.85], 'EdgeColor', [0.45 0.45 0.45], 'FaceLighting', 'none', common{:});
    D = scene3d.to_result(wp, S.y0);
    h(end + 1) = plot3(ax, D(:, 1), D(:, 2), D(:, 3) + 0.01 * checker, '.', 'Color', [0.2 0.2 0.2], 'MarkerSize', 7, common{:});
end
S.board_rect = rect;
S.board_size = max(max(rect, [], 1) - min(rect, [], 1));
setappdata(ax, 'scene3d', S);

%% axes of the results at the '0' (the origin of the results)
L = 3 * checker;
names = 'xyz';
cols = scene3d.colors('axes');
for a = 1:3
    d = zeros(1, 3);
    d(a) = 1;
    h = [h, arrow(ax, [0 0 0.004 * L], d, L, cols(a, :), common)]; %#ok<AGROW>
    h(end + 1) = text(ax, 1.2 * L * d(1), 1.2 * L * d(2), 1.2 * L * d(3), names(a), 'Color', cols(a, :), ...
        'FontWeight', 'bold', 'FontSize', 11, 'HorizontalAlignment', 'center', common{:}); %#ok<AGROW>
end
end

function h = arrow(ax, O, d, L, col, common)
% line with a cone at its end, along the axis d (a unit vector of x, y or z)
E = O + 0.78 * L * d;
h = plot3(ax, [O(1) E(1)], [O(2) E(2)], [O(3) E(3)], '-', 'Color', col, 'LineWidth', 2.5, common{:});
[cx, cy, cz] = cylinder([0.09 0] * L, 16);
cz = cz * 0.25 * L;
switch find(d)
    case 1
        R = [0 0 1; 0 1 0; -1 0 0];
    case 2
        R = [1 0 0; 0 0 1; 0 -1 0];
    otherwise
        R = eye(3);
end
Q = R * [cx(:) cy(:) cz(:)]';
h(2) = surface(ax, reshape(Q(1, :), size(cx)) + E(1), reshape(Q(2, :), size(cx)) + E(2), reshape(Q(3, :), size(cx)) + E(3), ...
    'FaceColor', col, 'EdgeColor', 'none', 'FaceLighting', 'none', common{:});
end

function s = spacing(wp)
% distance of neighbouring corners
x = unique(round(wp(:, 1), 6));
s = min(diff(x));
if isempty(s) || ~isfinite(s) || s <= 0
    s = 10;
end
end
