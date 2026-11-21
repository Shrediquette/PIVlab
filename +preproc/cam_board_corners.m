function wp = cam_board_corners(patternDims, checkerSize)
% Inner corners of a ChArUco board in the order in which detectCharucoBoardPoints returns them, at their
% positions on the board: origin = first inner corner, x along the columns, y along the rows
% (the coordinates of patternWorldPoints("charuco-board", ...)).
%   wp = preproc.cam_board_corners(patternDims, checkerSize)   N x 2, N = prod(patternDims - 1)
% For boards with more columns than rows (and square ones) this is patternWorldPoints. Boards with more rows than
% columns the detector numbers as if turned by 90 degrees (its own world points, generateWorldPoints, are turned
% too): here they are turned back onto the board.
detector = vision.calibration.monocular.CharucoBoardDetector();
wp = generateWorldPoints(detector, 'PatternDims', patternDims, 'CheckerSize', checkerSize);
if patternDims(1) > patternDims(2)
    wp = [wp(:, 2), (patternDims(1) - 2) * checkerSize - wp(:, 1)];
end
end
