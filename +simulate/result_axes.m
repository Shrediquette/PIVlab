function out = result_axes(in, board)
% Conversion between the axes of the PIVlab results, in which the panel "3D particle image generator"
% shows camera positions, aim points, the light sheet rotation about y and the out-of-plane
% displacement, and the board coordinates of the generator (simulate.setup_3d, geometry_3d,
% recording_3d, the ground truth).
%   setup = simulate.result_axes(setup)          whole setup (setup.board); both directions
%   P     = simulate.result_axes(P, board)        points [x y z] or [x y] (rows), both directions
%
% Result axes (as printed on the board, preproc.cam_board_layout): origin at the inner corner at the
% bottom left (the '0' on the board), x right, y up, z out of the board (toward camera 1 in front
% of the board). Board coordinates: origin at the first inner corner (top left), x right, y down, z
% into the board. The conversion is its own inverse: x = x, y = y0 - y, z = -z with
% y0 = (rows - 2) * checker size; a rotation about y and the displacement along z change sign.
if nargin < 2
    out = in;
    for k = 1:numel(in.cameras)
        out.cameras(k).Position = points(in.cameras(k).Position, in.board);
        out.cameras(k).Target = points(in.cameras(k).Target, in.board);
    end
    out.sheet.TiltY = 0 - in.sheet.TiltY; % 0 - x: no -0 in the panel
    out.flow.OutOfPlane = 0 - in.flow.OutOfPlane;
else
    out = points(in, board);
end
end

function P = points(P, board)
y0 = (board.PatternDims(1) - 2) * board.CheckerSize;
Q = scene3d.to_result(P, y0); % the conversion (also of the 3D views)
P = Q(:, 1:size(P, 2));
end
