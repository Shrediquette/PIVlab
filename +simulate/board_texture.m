function tex = board_texture(board, texelsPerChecker, opts)
% Texture of a ChArUco board for simulate.charuco_image and the 3D preview of the generator.
%   tex = simulate.board_texture(board, texelsPerChecker)
%   tex = simulate.board_texture(board, texelsPerChecker, Decorated=true)
% board: PatternDims, CheckerSize, MarkerSize, MarkerFamily, OriginCheckerColor (as simulate.charuco_image)
% Decorated = true: the board as PIVlab prints it (preproc.cam_decorate_board): a margin of three
% checkers with the QR code in all corners, the logo and the board parameters. Otherwise a plain
% margin of Margin checkers.
% tex.image   texel values 0..255 (single), rows along board y, columns along board x
% tex.c       texels per checker
% tex.m       margin [texels]
% Texel centre (row, col) is at board x = ((col - m - 0.5) / c - 1) * CheckerSize (y alike with row),
% the board coordinates of patternWorldPoints (origin = first inner corner).
arguments
    board struct
    texelsPerChecker (1,1) double
    opts.Decorated (1,1) logical = false
    opts.Margin (1,1) double = 1          % plain board: margin [checkers]
    opts.MinMarkerID (1,1) double = 0
end
c = round(texelsPerChecker);
dims = board.PatternDims;
if opts.Decorated
    m = 3 * c; % as the printed boards: three checkers
else
    m = round(opts.Margin * c);
end
marker = round(c * board.MarkerSize / board.CheckerSize);
img = generateCharucoBoard(dims * c + 2 * m, dims, board.MarkerFamily, c, marker, ...
    MarginSize=m, OriginCheckerColor=board.OriginCheckerColor, MinMarkerID=opts.MinMarkerID);
if opts.Decorated && m > 0
    img = preproc.cam_decorate_board(double(img) / 255, dims, char(board.MarkerFamily), board.CheckerSize, ...
        board.MarkerSize, char(board.OriginCheckerColor), m, c / board.CheckerSize, true);
    img = img * 255;
end
tex.image = single(img);
tex.c = c;
tex.m = m;
tex.decorated = opts.Decorated;
tex.board = board;
end
