function [I, cornersPx] = charuco_image(cam, opts)
% Image of a ChArUco calibration board seen by camera cam (see simulate.camera).
% The board lies in the plane z = 0 of its own coordinates, which are the
% coordinates of patternWorldPoints("charuco-board", PatternDims, CheckerSize):
% the first inner corner is the origin, x along the columns, y along the rows.
% BoardPose places the board in the world (default: board = world).
%
% [I, cornersPx] = simulate.charuco_image(cam, PatternDims=[23 24], CheckerSize=10, MarkerSize=7)
% I:         uint8 image
% cornersPx: exact image positions of the inner corners, in the order of
%            patternWorldPoints / detectCharucoBoardPoints (ground truth)
arguments
    cam struct
    opts.PatternDims (1,2) double = [23 24]     % number of checkers [rows columns]
    opts.MarkerFamily = "DICT_4X4_1000"
    opts.CheckerSize (1,1) double = 10          % world units (e.g. mm)
    opts.MarkerSize (1,1) double = 7            % world units (e.g. mm)
    opts.OriginCheckerColor = "black"
    opts.MinMarkerID (1,1) double = 0
    opts.BoardPose = []                         % rigidtform3d, board -> world; default: identity
    opts.Margin (1,1) double = 1                % white border around the checkers [checkers]
    opts.Black (1,1) double = 20                % intensity of black board areas [counts]
    opts.White (1,1) double = 200               % intensity of white board areas [counts]
    opts.Background double = 5                  % intensity outside of the board [counts]: scalar, or an image of the camera size
    opts.Blur (1,1) double = 0                  % Gaussian blur sigma [px], e.g. to mimic limited depth of field
    opts.Noise (1,1) double = 0                 % Gaussian noise variance as in imnoise
    opts.Decorated (1,1) logical = false        % board as PIVlab prints it: QR codes, logo and text in a margin of 3 checkers
    opts.Texture = []                           % texture from simulate.board_texture (reused, e.g. for many views of the same board)
end
boardPose = opts.BoardPose;
if isempty(boardPose)
    boardPose = rigidtform3d;
end
dims = opts.PatternDims;
checker = opts.CheckerSize;
if ~isempty(opts.Texture) % the board of the texture
    dims = opts.Texture.board.PatternDims;
    checker = opts.Texture.board.CheckerSize;
end

% ground truth corner positions
wp = patternWorldPoints("charuco-board", dims, checker);
cornersPx = simulate.project(cam, transformPointsForward(boardPose, [wp, zeros(size(wp, 1), 1)]));

% board texture with about two texels per image pixel
tex = opts.Texture;
if isempty(tex)
    outline = [-1 -1; dims(2) - 1, -1; dims(2) - 1, dims(1) - 1; -1, dims(1) - 1] * checker; % outer corners of the checkers
    outline_px = simulate.project(cam, transformPointsForward(boardPose, [outline, zeros(4, 1)]));
    px_per_checker = max(vecnorm(diff(outline_px([1:4 1], :)), 2, 2) ./ dims([2 1 2 1])');
    board = struct('PatternDims', dims, 'CheckerSize', checker, 'MarkerSize', opts.MarkerSize, ...
        'MarkerFamily', opts.MarkerFamily, 'OriginCheckerColor', opts.OriginCheckerColor);
    tex = simulate.board_texture(board, min(256, max(16, ceil(2 * px_per_checker))), ...
        Decorated=opts.Decorated, Margin=opts.Margin, MinMarkerID=opts.MinMarkerID); % texels per checker
end
c = tex.c;
m = tex.m;
texture = griddedInterpolant(tex.image, 'linear', 'none'); % texel values 0..255

% render with 2x2 supersampling, in blocks of rows to limit memory
h = cam.imageSize(1);
w = cam.imageSize(2);
I = zeros(h, w);
sub = [-0.25 0.25];
background = opts.Background;
if ~isscalar(background) && ~isequal(size(background), [h w])
    error('simulate:charuco_image:background', 'The background image must have the size of the camera image (%d x %d px).', h, w);
end
rows_per_block = max(1, floor(2e6 / w));
for r0 = 1:rows_per_block:h
    rows = r0:min(r0 + rows_per_block - 1, h);
    [X, Y] = meshgrid(1:w, rows);
    block = zeros(size(X));
    for ox = sub
        for oy = sub
            [xy, valid] = simulate.pixel_to_plane(cam, [X(:) + ox, Y(:) + oy], boardPose);
            col = m + 0.5 + c * (1 + xy(:, 1) / checker);
            row = m + 0.5 + c * (1 + xy(:, 2) / checker);
            val = opts.Black + (opts.White - opts.Black) / 255 * double(texture(row, col));
            outside = isnan(val) | ~valid;
            if isscalar(background)
                val(outside) = background;
            else
                bg = background(rows, :);
                val(outside) = bg(outside);
            end
            block = block + reshape(val, size(X));
        end
    end
    I(rows, :) = block / numel(sub)^2;
end
if opts.Blur > 0
    I = imgaussfilt(I, opts.Blur);
end
I = uint8(I);
if opts.Noise > 0
    I = imnoise(I, 'gaussian', 0, opts.Noise);
end
end
