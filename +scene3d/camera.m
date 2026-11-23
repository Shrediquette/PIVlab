function [cam, h] = camera(ax, extrinsics, color, label, opts)
%CAMERA Camera symbol with label, line of sight and the view of the camera on the board.
%   [cam, h] = scene3d.camera(ax, extrinsics, color, label)     label: the number of the camera ('' = none)
%   [cam, h] = scene3d.camera(..., Size=s, View=B, Sight=T, ViewName='view of camera 1', Opacity=0.35)
% extrinsics  rigidtform3d, coordinates of the data of the scene (scene3d.board, Frame) -> camera
% View        N x 3 (or N x 2) coordinates (as extrinsics) of the outline of the view on the board: outline and a
%             faint cone from the camera to it; ViewName: its legend entry ('' = none)
% Sight       coordinates (as extrinsics) of the aim point: dashed line of sight
% Size        size of the symbol [mm]; default 6 % of the board
% LabelHeight how far above the camera centre its number is [mm]; default 2.3 * Size
% cam: the plotCamera object (e.g. for its ButtonDownFcn), h: cell of the other objects.
% Registers the camera in the scene (floor, shadows, scene3d.reset_view).
arguments
    ax
    extrinsics
    color (1,3) double
    label
    opts.Size = []
    opts.View = []
    opts.Sight = []
    opts.ViewName = ''
    opts.Opacity = 0.35
    opts.LabelHeight = []
end
S = getappdata(ax, 'scene3d');
pose = scene3d.result(ax, extrinsics, 'pose');
C = pose.Translation;
cs = opts.Size;
if isempty(cs)
    cs = 0.06 * S.board_size;
end
unpickable = {'HitTest', 'off', 'PickableParts', 'none'};
quiet = [unpickable, {'HandleVisibility', 'off'}]; % not in the legend
h = {};
if ~isempty(opts.View)
    B = scene3d.result(ax, opts.View);
    nb = size(B, 1);
    h{end + 1} = patch(ax, 'Vertices', [C; B], 'Faces', [ones(nb - 1, 1), (2:nb)', (3:nb + 1)'], 'FaceColor', color, ...
        'FaceAlpha', 0.06, 'EdgeColor', 'none', 'FaceLighting', 'none', quiet{:});
    for i = corner_indices(B)
        h{end + 1} = plot3(ax, [C(1) B(i, 1)], [C(2) B(i, 2)], [C(3) B(i, 3)], '-', 'Color', [color 0.45], 'LineWidth', 0.8, quiet{:}); %#ok<AGROW>
    end
    legend_entry = {'HandleVisibility', 'off'};
    if ~isempty(opts.ViewName)
        legend_entry = {'DisplayName', opts.ViewName};
    end
    h{end + 1} = plot3(ax, B(:, 1), B(:, 2), B(:, 3), '-', 'Color', color, 'LineWidth', 1.6, unpickable{:}, legend_entry{:});
end
if ~isempty(opts.Sight)
    T = scene3d.result(ax, opts.Sight);
    h{end + 1} = plot3(ax, [C(1) T(1)], [C(2) T(2)], [C(3) T(3)], '--', 'Color', [color 0.6], quiet{:});
end
cam = plotCamera(AbsolutePose=pose, Size=cs, Color=color, Opacity=opts.Opacity, AxesVisible=false, Parent=ax);
% register first: the label goes above the camera (scene3d.up may depend on the first camera)
S.cams(end + 1) = struct('centre', C, 'color', color, 'size', cs);
setappdata(ax, 'scene3d', S);
lh = opts.LabelHeight;
if isempty(lh)
    lh = 2.3 * cs;
end
L = C + lh * scene3d.up(ax);
h{end + 1} = text(ax, L(1), L(2), L(3), label, 'Color', color, 'FontWeight', 'bold', 'FontSize', 15, ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', quiet{:});
end

function idx = corner_indices(B)
% the four points of the outline that are farthest towards its corners
d = B(:, 1:2) - mean(B(:, 1:2), 1); % the outline is on the board (x-y plane)
s = [-1 -1; 1 -1; 1 1; -1 1];
idx = zeros(1, 4);
for i = 1:4
    [~, idx(i)] = max(d * s(i, :)');
end
idx = unique(idx);
end
