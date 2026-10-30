function fig = preview_3d(setup, opts)
% 3D preview of the 3D particle image generator: board, light sheet, cameras and their views,
% and the image of the board in the light sheet that every camera sees.
%   fig = simulate.preview_3d(setup)
%   fig = simulate.preview_3d(setup, OnChange=@(setup) ...)
% setup: see simulate.setup_3d. If the preview window is open already, it shows the new setup
% (and keeps its view).
% Mouse in the 3D view: drag a camera to move it (parallel to the screen; Shift + drag: closer or
% farther), drag one of the arrows at a camera to move it along x, y or z of the board, drag an aim
% point (diamond on the board) to move it on the board, drag elsewhere to rotate the view, drag with
% the right mouse button to pan the view, mouse wheel to zoom. After every drag, OnChange is called with the new setup.
arguments
    setup struct
    opts.OnChange = []
    opts.Visible = 'on'
end
fig = findall(groot, 'Type', 'figure', 'Tag', 'PIVlab_sim3d_preview');
if isempty(fig)
    fig = create_figure(opts.Visible);
else
    fig = fig(1);
end
S = getappdata(fig, 'sim3d');
S.setup = setup;
if ~isempty(opts.OnChange)
    S.onchange = opts.OnChange;
end
setappdata(fig, 'sim3d', S);
draw(fig, 2);
if strcmp(opts.Visible, 'on') && ~strcmp(fig.Visible, 'on')
    fig.Visible = 'on';
end
end

%% ---------------------------------------------------------------- figure

function fig = create_figure(visible)
fig = figure('Name', 'PIVlab: 3D particle image generator - setup', 'NumberTitle', 'off', 'Tag', 'PIVlab_sim3d_preview', ...
    'MenuBar', 'none', 'ToolBar', 'none', 'DockControls', 'off', 'Units', 'pixels', 'Visible', visible, ...
    'HandleVisibility', 'callback');
screen = get(groot, 'ScreenSize');
w = min(1400, screen(3) - 100);
h = min(820, screen(4) - 120);
fig.Position = [max(20, (screen(3) - w) / 2), max(40, (screen(4) - h) / 2), w, h];
view3d = uipanel(fig, 'Units', 'normalized', 'Position', [0.005 0.195 0.635 0.8], 'BorderType', 'none', 'Tag', 'sim3d_view3d'); % clips the 3D scene
S.ax3 = axes(view3d, 'Units', 'normalized', 'Position', [0 0 1 1], 'Tag', 'sim3d_ax3', 'Visible', 'off');
S.axcam = gobjects(1, 2);
S.axcam(1) = axes(fig, 'Units', 'normalized', 'Position', [0.655 0.61 0.33 0.35], 'Tag', 'sim3d_axcam1');
S.axcam(2) = axes(fig, 'Units', 'normalized', 'Position', [0.655 0.235 0.33 0.35], 'Tag', 'sim3d_axcam2');
S.info = uicontrol(fig, 'Style', 'edit', 'Max', 2, 'Enable', 'inactive', 'Units', 'normalized', 'Position', [0.01 0.01 0.84 0.17], ...
    'HorizontalAlignment', 'left', 'FontName', 'FixedWidth', 'Tag', 'sim3d_info');
uicontrol(fig, 'Style', 'pushbutton', 'String', 'Reset view', 'Units', 'normalized', 'Position', [0.86 0.11 0.13 0.06], ...
    'Callback', @(~, ~) reset_view(fig), 'Tag', 'sim3d_resetview', 'TooltipString', 'Look from behind the cameras onto the board');
uicontrol(fig, 'Style', 'pushbutton', 'String', 'Update camera images', 'Units', 'normalized', 'Position', [0.86 0.03 0.13 0.06], ...
    'Callback', @(~, ~) draw(fig, 2), 'Tag', 'sim3d_updateviews', 'TooltipString', 'Render the views of the cameras again');
S.onchange = [];
S.drag = [];
S.clock = tic; % for limiting the rate of the camera images while dragging
S.view_cost = 0;
S.view_end = -inf;
S.tex = [];
S.board_key = '';
S.board_surface = gobjects(0);
S.dynamic = {};
S.view_set = false;
S.cam_visible = true(1, 2);
setappdata(fig, 'sim3d', S);
set(fig, 'WindowButtonDownFcn', @mouse_down, 'WindowButtonUpFcn', @mouse_up, 'WindowScrollWheelFcn', @mouse_wheel);
end

function draw(fig, with_views)
% everything; with_views: also render the camera images (slower): 0 none, 1 simplified
% (small, while dragging), 2 full
S = getappdata(fig, 'sim3d');
view_px = 360;
if with_views == 1
    view_px = 75;
end
setup = S.setup;
ax = S.ax3;
try
    g = simulate.geometry_3d(setup);
catch err
    S.info.String = {['Setup not possible: ' err.message]};
    return
end
S = board_surface(S, setup.board);
for i = 1:numel(S.dynamic) % objects of the previous drawing (not the board)
    if isvalid(S.dynamic{i})
        delete(S.dynamic{i});
    end
end
h = {}; %#ok<*AGROW> (a few objects per camera)
hold(ax, 'on');
n = numel(g.cams);
pose = g.sheet_pose;

%% light sheet (box of all views, enlarged) and the views of the cameras
r = g.region;
grow = 0.15 * [-(r(2) - r(1)), r(2) - r(1), -(r(4) - r(3)), r(4) - r(3)];
r = r + grow;
corners = transformPointsForward(pose, [r([1 2 2 1])', r([3 3 4 4])', zeros(4, 1)]);
h{end + 1} = patch(ax, corners(:, 1), corners(:, 2), corners(:, 3), [0.2 0.85 0.3], 'FaceAlpha', 0.22, 'EdgeColor', [0.1 0.6 0.2], ...
    'HitTest', 'off', 'DisplayName', 'light sheet');
[ox, oy] = boundary(g.overlap);
if n > 1 && ~isempty(ox)
    P = transformPointsForward(pose, [ox, oy, zeros(size(ox))]);
    h{end + 1} = patch(ax, P(:, 1), P(:, 2), P(:, 3), [0.2 0.85 0.3], 'FaceAlpha', 0.45, 'EdgeColor', 'none', 'HitTest', 'off', ...
        'DisplayName', 'overlap of the views');
end
if any(strcmp(setup.flow.Type, {'sphere', 'jet'})) && isfield(setup.flow, 'Diameter') && setup.flow.Diameter > 0
    % the sphere of the sphere wake, or the nozzle (pipe, one diameter long) of the jet
    c = simulate.flow_origin_3d(g, setup.flow.Type, setup.flow.Diameter);
    radius = setup.flow.Diameter / 2;
    if strcmp(setup.flow.Type, 'sphere')
        [sx, sy, sz] = sphere(24);
        P = [c(1) + radius * sx(:), c(2) + radius * sy(:), radius * sz(:)];
    else
        [cy, cz, cx] = cylinder(1.1 * radius, 24); % axis along x (the jet direction)
        sx = c(1) - 2 * radius * (1 - cx);
        sy = c(2) + cy;
        sz = cz;
        P = [sx(:), sy(:), sz(:)];
    end
    P = transformPointsForward(pose, P);
    h{end + 1} = surf(ax, reshape(P(:, 1), size(sx)), reshape(P(:, 2), size(sx)), reshape(P(:, 3), size(sx)), ...
        'FaceColor', [0.55 0.55 0.6], 'EdgeColor', [0.4 0.4 0.45], 'EdgeAlpha', 0.3, 'HitTest', 'off', 'DisplayName', setup.flow.Type);
end
cam_size = camera_symbol_size(setup.board); % fixed relative to the board
for k = 1:n
    col = camera_color(k);
    [vx, vy] = boundary(g.views(k));
    if ~isempty(vx)
        P = transformPointsForward(pose, [vx, vy, zeros(size(vx))]);
        h{end + 1} = plot3(ax, P(:, 1), P(:, 2), P(:, 3), '-', 'Color', col, 'LineWidth', 1.5, 'HitTest', 'off', ...
            'DisplayName', sprintf('view of camera %d', k));
    end
    C = g.centre(k, :);
    T = [setup.cameras(k).Target 0];
    h{end + 1} = plot3(ax, [C(1) T(1)], [C(2) T(2)], [C(3) T(3)], '--', 'Color', col, 'HitTest', 'off', 'HandleVisibility', 'off');
    cam = plotCamera(AbsolutePose=extr2pose(g.cams{k}.pose), Size=cam_size, Color=col, Label=sprintf('Camera %d', k), ...
        AxesVisible=false, Opacity=0.25, Parent=ax);
    h{end + 1} = cam;
    cam.ButtonDownFcn = @(~, ~) start_drag(fig, 'camera', k);
    h{end + 1} = plot3(ax, C(1), C(2), C(3), 'o', 'MarkerSize', 11, 'MarkerFaceColor', col, 'MarkerEdgeColor', 'k', ...
        'ButtonDownFcn', @(~, ~) start_drag(fig, 'camera', k), 'HandleVisibility', 'off');
    h{end + 1} = plot3(ax, T(1), T(2), T(3), 'd', 'MarkerSize', 11, 'MarkerFaceColor', [1 0.85 0.1], 'MarkerEdgeColor', col, 'LineWidth', 1.5, ...
        'ButtonDownFcn', @(~, ~) start_drag(fig, 'target', k), 'HandleVisibility', 'off');
    h = [h, camera_arrows(fig, ax, C, k, arrow_length(setup.board))];
end
fade_arrows(ax);
S.dynamic = h;
axis(ax, 'equal');
ax.Visible = 'off';
setappdata(fig, 'sim3d', S);
if ~S.view_set
    reset_view(fig, g);
    S = getappdata(fig, 'sim3d');
end
if isempty(S.drag) % not while dragging: after it
    visible = cameras_in_view(S.ax3, g, setup.board);
    before = S.cam_visible;
    m = min(numel(before), numel(visible));
    if any(before(1:m) & ~visible(1:m)) % a camera left the view: show everything again (same direction)
        fit_view(S.ax3, g, setup.board, S.ax3.CameraPosition - S.ax3.CameraTarget);
        visible = cameras_in_view(S.ax3, g, setup.board);
    end
    S.cam_visible = visible;
end

%% report
lines = simulate.geometry_report_3d(g, setup.board);
if ~g.ok
    lines = [{['Warning: ' g.message]}, lines];
end
lines{end + 1} = sprintf('Light sheet: %+.2f mm from the board (towards camera 1), tilted %.2f%s about x and %.2f%s about y, %.2f mm thick', ...
    setup.sheet.Offset, setup.sheet.TiltX, char(176), setup.sheet.TiltY, char(176), setup.sheet.Thickness);
lines{end + 1} = ['Mouse: drag a camera to move it (Shift + drag: closer / farther), drag an arrow at a camera to move it along x, y or z, ' ...
    'drag a diamond to move the aim point, drag elsewhere to rotate the view, right drag to pan, wheel to zoom.'];
S.info.String = lines;

%% what the cameras see
if with_views
    t_views = toc(S.clock);
    for k = 1:2
        cla(S.axcam(k));
        if k > n
            title(S.axcam(k), '');
            S.axcam(k).Visible = 'off';
            continue
        end
        S.axcam(k).Visible = 'on';
        camera_view(S.axcam(k), g, k, S.tex, view_px);
    end
    S.view_cost = toc(S.clock) - t_views;
    S.view_end = toc(S.clock);
end
setappdata(fig, 'sim3d', S);
drawnow limitrate
end

function S = board_surface(S, board)
% the board as printed (QR codes, logo), drawn once per board
key = sprintf('%g_', board.PatternDims, board.CheckerSize, board.MarkerSize, double(char(board.OriginCheckerColor)), double(char(board.MarkerFamily)));
if strcmp(key, S.board_key) && ~isempty(S.board_surface) && isvalid(S.board_surface)
    return
end
delete(findobj(S.ax3, 'Tag', 'sim3d_board'));
c = max(8, min(40, round(1200 / (board.PatternDims(2) + 6)))); % about 1200 texels across
S.tex = simulate.board_texture(board, c, Decorated=true);
img = S.tex.image / 255;
checker = board.CheckerSize;
x = ([0, size(img, 2)] - S.tex.m) / c - 1;
y = ([0, size(img, 1)] - S.tex.m) / c - 1;
[X, Y] = meshgrid(x * checker, y * checker);
hold(S.ax3, 'on');
S.board_surface = surface(S.ax3, X, Y, zeros(2), repmat(img, 1, 1, 3), 'FaceColor', 'texturemap', 'EdgeColor', [0.4 0.4 0.4], ...
    'HitTest', 'off', 'Tag', 'sim3d_board', 'DisplayName', 'board');
L = 3 * checker;
plot3(S.ax3, [0 L], [0 0], [0 0], 'r-', 'LineWidth', 2, 'HitTest', 'off', 'Tag', 'sim3d_board');
plot3(S.ax3, [0 0], [0 L], [0 0], 'g-', 'LineWidth', 2, 'HitTest', 'off', 'Tag', 'sim3d_board');
plot3(S.ax3, [0 0], [0 0], [0 -L], 'b-', 'LineWidth', 2, 'HitTest', 'off', 'Tag', 'sim3d_board');
text(S.ax3, L, 0, 0, ' x', 'Color', 'r', 'HitTest', 'off', 'Tag', 'sim3d_board');
text(S.ax3, 0, L, 0, ' y', 'Color', [0 0.6 0], 'HitTest', 'off', 'Tag', 'sim3d_board');
text(S.ax3, 0, 0, -L, ' -z', 'Color', 'b', 'HitTest', 'off', 'Tag', 'sim3d_board');
S.board_key = key;
end

function camera_view(ax, g, k, tex, view_px)
% low resolution image (view_px on the long side) of the board in the light sheet, as camera k
% sees it, with its view of the overlap and the board origin
cam = g.cams{k};
sz = cam.imageSize;
small = max(1, round(sz * min(1, view_px / max(sz))));
s = small([2 1]) ./ sz([2 1]); % [x y] scale
if any(s < 1)
    intr = cam.intrinsics;
    k_small = cameraIntrinsics(intr.FocalLength .* s, (intr.PrincipalPoint - 0.5) .* s + 0.5, small, ...
        'RadialDistortion', intr.RadialDistortion, 'TangentialDistortion', intr.TangentialDistortion);
    cam.intrinsics = k_small;
    cam.imageSize = small;
end
I = simulate.charuco_image(cam, Texture=tex);
imagesc(ax, ([1 small(2)] - 0.5) / s(1) + 0.5, ([1 small(1)] - 0.5) / s(2) + 0.5, I); % full-resolution pixel coordinates
colormap(ax, gray(256));
clim(ax, [0 255]);
axis(ax, 'image');
hold(ax, 'on');
[ox, oy] = boundary(g.overlap);
if numel(g.cams) > 1 && ~isempty(ox)
    q = simulate.project(g.cams{k}, transformPointsForward(g.sheet_pose, [ox, oy, zeros(size(ox))]));
    plot(ax, q(:, 1), q(:, 2), '-', 'Color', [0.2 0.9 0.3], 'LineWidth', 1.5, 'HitTest', 'off');
end
o = simulate.project(g.cams{k}, [0 0 0]);
plot(ax, o(1), o(2), 'g*', 'MarkerSize', 10, 'HitTest', 'off');
xlim(ax, [0.5 sz(2) + 0.5]);
ylim(ax, [0.5 sz(1) + 0.5]);
title(ax, sprintf('Camera %d: board in the light sheet (%d x %d px)', k, sz(2), sz(1)), 'Color', camera_color(k));
ax.XTick = [];
ax.YTick = [];
hold(ax, 'off');
end

function col = camera_color(k)
col = stereo.camera_colors(k);
end

function h = camera_arrows(fig, ax, C, k, len)
% three arrows at camera k along the board axes (x, y, -z and colours as the axes on the board);
% drag one to move the camera along it
dirs = arrow_directions();
cols = [1 0 0; 0 1 0; 0 0 1];
h = cell(1, 6);
for a = 1:3
    E = C + len * dirs(a, :);
    info.base = C;
    info.dir = dirs(a, :);
    info.color = cols(a, :);
    h{2 * a - 1} = plot3(ax, [C(1) E(1)], [C(2) E(2)], [C(3) E(3)], '-', 'Color', cols(a, :), 'LineWidth', 3, ...
        'ButtonDownFcn', @(~, ~) start_drag(fig, 'axis', k, a), 'Tag', 'sim3d_arrow', 'UserData', info, 'HandleVisibility', 'off');
    h{2 * a} = plot3(ax, E(1), E(2), E(3), 'o', 'MarkerSize', 8, 'Color', cols(a, :), 'MarkerFaceColor', cols(a, :), 'MarkerEdgeColor', cols(a, :), ...
        'ButtonDownFcn', @(~, ~) start_drag(fig, 'axis', k, a), 'Tag', 'sim3d_arrow', 'UserData', info, 'HandleVisibility', 'off');
end
end

function dirs = arrow_directions()
dirs = [1 0 0; 0 1 0; 0 0 -1];
end

function fade_arrows(ax)
% arrows that point (almost) along the line of sight (within 15 degrees) cannot be dragged sensibly:
% faded and not clickable
bg = ax.Parent.BackgroundColor;
arrows = findall(ax, 'Tag', 'sim3d_arrow');
for i = 1:numel(arrows)
    info = arrows(i).UserData;
    sight = info.base - ax.CameraPosition;
    if abs(dot(info.dir, sight)) > cosd(15) * norm(sight)
        col = 0.2 * info.color + 0.8 * bg;
        pickable = 'none';
    else
        col = info.color;
        pickable = 'visible';
    end
    set(arrows(i), 'Color', col, 'MarkerFaceColor', col, 'MarkerEdgeColor', col, 'PickableParts', pickable);
end
end

function reset_view(fig, g)
% look from behind and above the cameras onto the board, everything in view
S = getappdata(fig, 'sim3d');
if nargin < 2
    g = simulate.geometry_3d(S.setup);
end
[cx, cy] = centroid(g.overlap);
if isnan(cx)
    cx = mean(g.region(1:2));
    cy = mean(g.region(3:4));
end
sheet_centre = transformPointsForward(g.sheet_pose, [cx cy 0]);
if all(g.centre(:, 3) < 0) || all(g.centre(:, 3) > 0)
    behind = mean(g.centre, 1) - sheet_centre; % from behind the cameras
    behind = behind / norm(behind);
else
    behind = [0.83 0 -0.55]; % cameras on both sides: from the side
end
fit_view(S.ax3, g, S.setup.board, behind + [0 -0.6 0]); % and from above (y is down)
S.view_set = true;
setappdata(fig, 'sim3d', S);
end

function fit_view(ax, g, board, direction)
% camera of the 3D view: looks along -direction at the centre of the scene, from the distance at
% which the board, the light sheet and all cameras are in view (fixed view angle)
P = scene_points(g, board);
direction = direction / norm(direction);
target = (min(P, [], 1) + max(P, [], 1)) / 2;
up = [0 -1 0] - dot([0 -1 0], direction) * direction;
if norm(up) < 1e-6 % looking along y
    up = [0 0 -1] - dot([0 0 -1], direction) * direction;
end
up = up / norm(up);
right = cross(direction, up);
[tan_h, tan_v] = view_tangents(ax, 30);
q = P - target;
along = q * direction';
distance = max(along + max(abs(q * up') / tan_v, abs(q * right') / tan_h)) * 1.08; % 8 % margin
camproj(ax, 'perspective');
set(ax, 'CameraTarget', target, 'CameraPosition', target + distance * direction, 'CameraUpVector', up, 'CameraViewAngle', 30);
fade_arrows(ax);
end

function [tan_h, tan_v] = view_tangents(ax, angle)
% half-angle tangents of the view horizontally / vertically (the view angle is for the shorter side)
pos = getpixelposition(ax);
w = max(pos(3), 1);
h = max(pos(4), 1);
t = tand(angle / 2);
if w >= h
    tan_v = t;
    tan_h = t * w / h;
else
    tan_h = t;
    tan_v = t * h / w;
end
end

function inside = all_in_view(ax, P)
% true if all points P (N x 3) are in the current view of the 3D axes
f = ax.CameraTarget - ax.CameraPosition;
f = f / norm(f);
up = ax.CameraUpVector - dot(ax.CameraUpVector, f) * f;
up = up / norm(up);
right = cross(f, up);
[tan_h, tan_v] = view_tangents(ax, ax.CameraViewAngle);
q = P - ax.CameraPosition;
along = q * f';
inside = all(along > 0) && all(abs(q * up') <= tan_v * along) && all(abs(q * right') <= tan_h * along);
end

function visible = cameras_in_view(ax, g, board)
% per camera: true if its symbol is in the current view of the 3D axes
s = camera_symbol_size(board);
visible = false(1, size(g.centre, 1));
for k = 1:numel(visible)
    visible(k) = all_in_view(ax, g.centre(k, :) + s * [-1 -1 -1; 1 1 1]);
end
end

function P = scene_points(g, board)
% corners of the board (with its margin) and of the light sheet, and the cameras
c = board.CheckerSize;
d = board.PatternDims;
x = [-4, d(2) + 2] * c; % margin of three checkers
y = [-4, d(1) + 2] * c;
P = [x([1 2 2 1])', y([1 1 2 2])', zeros(4, 1)];
r = g.region;
P = [P; transformPointsForward(g.sheet_pose, [r([1 2 2 1])', r([3 3 4 4])', zeros(4, 1)])];
s = camera_symbol_size(board);
for k = 1:size(g.centre, 1)
    P = [P; g.centre(k, :) + s * [-1 -1 -1; 1 1 1]]; % the camera symbol around its centre
    P = [P; g.centre(k, :) + arrow_length(board) * arrow_directions()]; % tips of its arrows
end
end

function len = arrow_length(board)
len = 2.5 * camera_symbol_size(board);
end

function s = camera_symbol_size(board)
% size of the camera symbols in the 3D view: fixed relative to the board (with its margin)
s = 0.06 * (board.PatternDims(2) + 6) * board.CheckerSize;
end

%% ---------------------------------------------------------------- mouse

function start_drag(fig, kind, k, a)
% a: number of the arrow (1 x, 2 y, 3 z) for kind 'axis'
if strcmp(fig.SelectionType, 'alt') % right button: pans the view, also over a camera (mouse_down)
    return
end
S = getappdata(fig, 'sim3d');
ax = S.ax3;
d.kind = kind;
d.k = k;
d.mode = fig.SelectionType; % 'normal', 'extend' (Shift), 'alt' (right / Ctrl)
d.mouse0 = fig.CurrentPoint;
d.setup0 = S.setup;
d.view_dir = (ax.CameraTarget - ax.CameraPosition) / norm(ax.CameraTarget - ax.CameraPosition);
ray = ax.CurrentPoint;
switch kind
    case 'camera'
        C0 = S.setup.cameras(k).Position;
        d.offset = C0 - intersect_plane(ray, C0, d.view_dir);
    case 'axis'
        dirs = arrow_directions();
        d.axis_dir = dirs(a, :);
        d.offset = position_on_line(ray, S.setup.cameras(k).Position, d.axis_dir); % where the arrow was grabbed
        if isnan(d.offset)
            d.offset = 0;
        end
    case 'target'
        d.offset = [S.setup.cameras(k).Target 0] - intersect_plane(ray, [0 0 0], [0 0 1]);
end
S.drag = d;
setappdata(fig, 'sim3d', S);
set(fig, 'WindowButtonMotionFcn', @mouse_move);
end

function mouse_down(fig, ~)
% runs before the ButtonDownFcn of a camera or aim point, which then replaces the orbit by its drag
S = getappdata(fig, 'sim3d');
if ~over_axes(fig, S.ax3)
    return
end
d.kind = 'orbit';
if strcmp(fig.SelectionType, 'alt') % right button (or Ctrl + left)
    d.kind = 'pan';
end
d.mouse0 = fig.CurrentPoint;
S.drag = d;
setappdata(fig, 'sim3d', S);
set(fig, 'WindowButtonMotionFcn', @mouse_move);
end

function mouse_move(fig, ~)
S = getappdata(fig, 'sim3d');
d = S.drag;
if isempty(d)
    return
end
ax = S.ax3;
switch d.kind
    case 'orbit'
        % like the orbit of cameratoolbar with SetCoordSys 'y' (the other 3D views of PIVlab):
        % 1 degree per pixel, about the y axis of the board (y is down), which stays upright
        delta = fig.CurrentPoint - d.mouse0;
        y_axis = [0 -1 0];
        if any(cross(y_axis, ax.CameraPosition - ax.CameraTarget)) % not looking along y
            ax.CameraUpVector = y_axis;
        end
        camorbit(ax, delta(1), -delta(2), 'data', y_axis);
        fade_arrows(ax);
        d.mouse0 = fig.CurrentPoint;
        S.drag = d;
        setappdata(fig, 'sim3d', S);
        drawnow limitrate
        return
    case 'pan' % shifts camera and target of the view parallel to the screen: the scene follows the mouse
        delta = fig.CurrentPoint - d.mouse0;
        f = ax.CameraTarget - ax.CameraPosition;
        distance = norm(f);
        f = f / distance;
        up = ax.CameraUpVector - dot(ax.CameraUpVector, f) * f;
        up = up / norm(up);
        right = cross(f, up);
        pos = getpixelposition(ax);
        [~, tan_v] = view_tangents(ax, ax.CameraViewAngle);
        mm_per_px = 2 * distance * tan_v / pos(4); % in the depth of the target
        shift = -mm_per_px * (delta(1) * right + delta(2) * up);
        set(ax, 'CameraPosition', ax.CameraPosition + shift, 'CameraTarget', ax.CameraTarget + shift);
        d.mouse0 = fig.CurrentPoint;
        S.drag = d;
        setappdata(fig, 'sim3d', S);
        drawnow limitrate
        return
    case 'camera'
        k = d.k;
        C0 = d.setup0.cameras(k).Position;
        if strcmp(d.mode, 'extend') % closer / farther from the aim point
            T = [d.setup0.cameras(k).Target 0];
            factor = exp((fig.CurrentPoint(2) - d.mouse0(2)) / 200);
            C = T + (C0 - T) * factor;
        else
            C = intersect_plane(ax.CurrentPoint, C0, d.view_dir) + d.offset;
        end
        S.setup.cameras(k).Position = round(C * 10) / 10;
    case 'axis' % along one axis of the board
        k = d.k;
        s = position_on_line(ax.CurrentPoint, d.setup0.cameras(k).Position, d.axis_dir);
        if isnan(s)
            return
        end
        C = d.setup0.cameras(k).Position + (s - d.offset) * d.axis_dir;
        S.setup.cameras(k).Position = round(C * 10) / 10;
    case 'target'
        k = d.k;
        p = intersect_plane(ax.CurrentPoint, [0 0 0], [0 0 1]) + d.offset;
        S.setup.cameras(k).Target = round(p(1:2) * 10) / 10;
end
setappdata(fig, 'sim3d', S);
% camera images while dragging: small, and at most so often that rendering takes a third of the time
% (the full images follow on mouse release)
quality = 0;
if toc(S.clock) - S.view_end > max(0.05, 2 * S.view_cost)
    quality = 1;
end
draw(fig, quality);
end

function mouse_up(fig, ~)
S = getappdata(fig, 'sim3d');
set(fig, 'WindowButtonMotionFcn', '');
d = S.drag;
S.drag = [];
setappdata(fig, 'sim3d', S);
if isempty(d)
    return
end
if strcmp(d.kind, 'orbit') || strcmp(d.kind, 'pan')
    remember_cameras_in_view(fig);
    return
end
draw(fig, 2);
if ~isempty(S.onchange)
    S.onchange(S.setup);
end
end

function mouse_wheel(fig, evt)
% zooms the 3D view wherever the mouse is (the CurrentPoint of the figure is not updated while
% the mouse only moves, so it cannot tell where the mouse is)
S = getappdata(fig, 'sim3d');
camzoom(S.ax3, 1.1 ^ (-evt.VerticalScrollCount));
remember_cameras_in_view(fig);
end

function remember_cameras_in_view(fig)
% after the user changed the view: a camera that is outside the view now stays so (draw shows
% everything again only if a camera leaves the view while it is dragged)
S = getappdata(fig, 'sim3d');
try
    g = simulate.geometry_3d(S.setup);
catch
    return
end
S.cam_visible = cameras_in_view(S.ax3, g, S.setup.board);
setappdata(fig, 'sim3d', S);
end

function inside = over_axes(fig, ax)
p = fig.CurrentPoint; % pixels
pos = getpixelposition(ax, true);
inside = p(1) >= pos(1) && p(1) <= pos(1) + pos(3) && p(2) >= pos(2) && p(2) <= pos(2) + pos(4);
end

function p = intersect_plane(ray, P0, n)
% point where the mouse ray (axes CurrentPoint, 2x3) hits the plane through P0 with normal n
a = ray(1, :);
b = ray(2, :);
denom = dot(b - a, n);
if abs(denom) < 1e-12
    p = P0;
    return
end
s = dot(P0 - a, n) / denom;
p = a + s * (b - a);
end

function s = position_on_line(ray, P0, e)
% parameter s of the point P0 + s * e (e: unit vector) of a line that is closest to the mouse ray
% (axes CurrentPoint, 2x3); NaN if the ray is (almost) parallel to the line
a = ray(1, :);
u = ray(2, :) - a;
u = u / norm(u);
b = dot(e, u);
if 1 - b ^ 2 < 1e-6
    s = NaN;
    return
end
w = P0 - a;
s = (b * dot(u, w) - dot(e, w)) / (1 - b ^ 2);
end
