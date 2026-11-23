function finish(ax)
%FINISH Floor of the scene: grid, shadows of board and cameras, lines down to the floor.
%   scene3d.finish(ax)
% Call after the board, the cameras and scene3d.add_points; again after they changed (the shadows are
% replaced, the grid only if it no longer fits: dragging a camera stays fast and the floor stays put).
% The floor is below everything (board upright) or just behind the board (board lying flat),
% see scene3d.up. Grid of 1, 2, 2.5 or 5 x 10^n mm, about 10 lines across the scene, every fifth
% line stronger, fading out towards the edges.
S = getappdata(ax, 'scene3d');
delete(findall(ax, 'Tag', 'scene3d_shadow')); % findall: HandleVisibility off
P = scene3d.view_points(ax, false);
if isempty(P)
    return
end
u = scene3d.up(ax);
e1 = [1 0 0]; % floor axes
if abs(u(2)) > 0.5
    e2 = [0 0 1];
else
    e2 = [0 1 0];
end
hgt = P * u';
a = P * e1';
b = P * e2';
span = max([max(a) - min(a), max(b) - min(b), 1]);
if S.lying
    hf = min(hgt) - 0.04 * span;
else
    hf = min(hgt) - 0.12 * (max(hgt) - min(hgt)) - 0.05 * span;
end
step = nice_step(span / 10);
pad = 0.6 * span;
ar = [floor((min(a) - pad) / step), ceil((max(a) + pad) / step)] * step;
br = [floor((min(b) - pad) / step), ceil((max(b) + pad) / step)] * step;
fg = ax.XColor;
bg = background(ax);
quiet = {'HitTest', 'off', 'PickableParts', 'none', 'HandleVisibility', 'off'};
layout = struct('ar', ar, 'br', br, 'height', hf, 'up', u, 'step', step);
if ~still_fits(S.floor, layout, min(a), max(a), min(b), max(b), span) || isempty(findall(ax, 'Tag', 'scene3d_floor'))
    delete(findall(ax, 'Tag', 'scene3d_floor'));
    draw_grid(ax, layout, e1, e2, fg, bg, [quiet, {'Tag', 'scene3d_floor', 'FaceLighting', 'none'}]);
    S.floor = layout;
    setappdata(ax, 'scene3d', S);
end

%% shadows (redrawn every time)
quiet = [quiet, {'Tag', 'scene3d_shadow'}];
flat = [quiet, {'EdgeColor', 'none', 'FaceLighting', 'none'}];
shadow = scene3d.colors('shadow', bg);
lift = 0.001 * span;
foot = @(Q) Q - (Q * u' - hf - lift) * u;
if ~isempty(S.board_rect)
    R = foot(S.board_rect);
    if S.lying
        patch(ax, R(:, 1), R(:, 2), R(:, 3), shadow, 'FaceAlpha', 0.3, flat{:});
    else % upright: the board stands on two posts, its shadow is a band
        w = 0.012 * span;
        x = [min(R(:, 1)) max(R(:, 1))];
        z = mean(R(:, 3));
        band = [x(1) R(1, 2) z - w; x(2) R(1, 2) z - w; x(2) R(1, 2) z + w; x(1) R(1, 2) z + w];
        patch(ax, band(:, 1), band(:, 2), band(:, 3), shadow, 'FaceAlpha', 0.35, flat{:});
        [~, i] = sort(S.board_rect * u');
        post_col = scene3d.colors('mix', fg, bg, 0.5);
        for k = i(1:2)'
            Q = S.board_rect(k, :);
            F = foot(Q);
            plot3(ax, [Q(1) F(1)], [Q(2) F(2)], [Q(3) F(3)], '-', 'Color', post_col, 'LineWidth', 1.2, quiet{:});
        end
    end
end
t = linspace(0, 2 * pi, 40)';
for k = 1:numel(S.cams)
    C = S.cams(k).centre;
    col = S.cams(k).color;
    F = foot(C);
    for ring = 1:3 % soft edge
        r = 0.7 * S.cams(k).size * (1 + 0.35 * (ring - 1));
        D = F + r * cos(t) * e1 + r * sin(t) * e2 + ring * lift * u;
        patch(ax, D(:, 1), D(:, 2), D(:, 3), shadow, 'FaceAlpha', 0.16, flat{:});
    end
    plot3(ax, [C(1) F(1)], [C(2) F(2)], [C(3) F(3)], '--', 'Color', [col 0.55], 'LineWidth', 0.8, quiet{:});
    plot3(ax, F(1), F(2), F(3), 'o', 'MarkerSize', 4, 'MarkerFaceColor', col, 'MarkerEdgeColor', 'none', quiet{:});
end
daspect(ax, [1 1 1]);
end

function ok = still_fits(old, new, a0, a1, b0, b1, span)
% the grid drawn before still serves (e.g. while a camera is dragged): same direction, step and height
% (within a tenth of the step), and it reaches at least 30 % of the scene beyond the objects
ok = ~isempty(old) && isequal(old.up, new.up) && old.step == new.step && abs(old.height - new.height) < 0.1 * new.step && ...
    old.ar(1) <= a0 - 0.3 * span && old.ar(2) >= a1 + 0.3 * span && old.br(1) <= b0 - 0.3 * span && old.br(2) >= b1 + 0.3 * span;
end

function draw_grid(ax, g, e1, e2, fg, bg, props)
% fill and grid lines of the floor (alpha per vertex: fades out towards the edges)
line_col = scene3d.colors('mix', fg, bg, 0.4);
fill_col = scene3d.colors('mix', fg, bg, 0.75);
lines_a = g.ar(1):g.step:g.ar(2);
lines_b = g.br(1):g.step:g.br(2);
[A, B] = meshgrid(lines_a, lines_b);
[X, Y, Z] = place(A, B, g, e1, e2, 0);
surface(ax, X, Y, Z, 'FaceColor', fill_col, 'FaceAlpha', 'interp', 'AlphaData', 0.14 * fade(A, B, g), ...
    'AlphaDataMapping', 'none', 'EdgeColor', 'none', props{:});
lift = 0.0005 * max(diff(g.ar), diff(g.br));
fine_a = linspace(g.ar(1), g.ar(2), 4 * numel(lines_a) - 3);
fine_b = linspace(g.br(1), g.br(2), 4 * numel(lines_b) - 3);
[A, B] = meshgrid(fine_a, lines_b); % lines along a
grid_lines(ax, A, B, B, g, e1, e2, lift, line_col, props);
[B, A] = meshgrid(fine_b, lines_a); % lines along b
grid_lines(ax, A, B, A, g, e1, e2, lift, line_col, props);
end

function grid_lines(ax, A, B, across, g, e1, e2, lift, col, props)
% the rows of A, B as lines (MeshStyle row); every fifth line (position across) stronger
major = 5 * g.step;
strong = abs(mod(across + major / 2, major) - major / 2) < g.step / 10;
[X, Y, Z] = place(A, B, g, e1, e2, lift);
surface(ax, X, Y, Z, 'FaceColor', 'none', 'EdgeColor', col, 'EdgeAlpha', 'interp', 'MeshStyle', 'row', ...
    'AlphaData', fade(A, B, g) .* (0.35 + 0.35 * strong), 'AlphaDataMapping', 'none', props{:});
end

function [X, Y, Z] = place(A, B, g, e1, e2, lift)
% floor coordinates (a, b) -> axes of the results
h = g.height + lift;
X = A * e1(1) + B * e2(1) + h * g.up(1);
Y = A * e1(2) + B * e2(2) + h * g.up(2);
Z = A * e1(3) + B * e2(3) + h * g.up(3);
end

function f = fade(A, B, g)
% 1 in the middle of the floor, 0 at its edge
r = hypot((A - mean(g.ar)) / (diff(g.ar) / 2), (B - mean(g.br)) / (diff(g.br) / 2));
f = min(1, max(0, (1 - r) / 0.55)) .^ 2;
end

function bg = background(ax)
% colour behind the (invisible) axes
p = ax.Parent;
if isprop(p, 'BackgroundColor')
    bg = p.BackgroundColor;
elseif isprop(p, 'Color')
    bg = p.Color;
else
    bg = [1 1 1];
end
if ischar(bg) || isstring(bg)
    bg = [1 1 1];
end
end

function s = nice_step(x)
e = 10 ^ floor(log10(x));
m = [1 2 2.5 5 10];
[~, i] = min(abs(log(m * e / x)));
s = m(i) * e;
end
