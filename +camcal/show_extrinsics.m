function show_extrinsics(cameraParams, fig, board)
%SHOW_EXTRINSICS 3D view of the calibration board and the camera positions of the calibration images.
%   camcal.show_extrinsics(cameraParams, fig)
%   camcal.show_extrinsics(cameraParams, fig, board)
%   cameraParams  cameraParameters of camcal.estimate_camera_parameters (PatternExtrinsics: board -> camera;
%                 world points in the numbering of the detector)
%   fig           figure to draw into (empty)
%   board         ChArUco board (stereo.board_from_gui): drawn as printed. Without it (or if it does not
%                 fit the world points): a plain plate with the corners.
% The board stays where it is, the cameras are around it (scene3d: axes of the results, floor).
if nargin < 3
    board = [];
end
wp = cameraParams.WorldPoints;
if ~isempty(board) && size(wp, 1) ~= prod(board.PatternDims - 1)
    board = [];
end
n = numel(cameraParams.PatternExtrinsics);
[~, ax] = scene3d.window(@(ax) draw(ax, cameraParams, board), Figure=fig);
scene3d.caption(ax, sprintf('%d calibration images: camera positions relative to the board', n));
end

function draw(ax, cameraParams, board)
poses = cameraParams.PatternExtrinsics; % rigidtform3d, board -> camera
t = cameraParams.TranslationVectors;
wp = cameraParams.WorldPoints;
if isempty(board)
    scene3d.board(ax, [], Points=wp);
else % the world points of the detector -> board as printed (tall boards: turned back)
    scene3d.board(ax, board, Frame=scene3d.frame_transform(wp, preproc.cam_board_corners(board.PatternDims, board.CheckerSize)));
end
n = numel(poses);
cols = scene3d.colors('sequence', n);
distance = median(vecnorm(t, 2, 2));
centre = [mean(wp, 1), 0]; % centre of the board: lines of sight
for i = 1:n
    scene3d.camera(ax, poses(i), cols(i, :), sprintf('%d', i), Size=0.05 * distance, Sight=centre);
end
end
