function [imagePoints, mirrored, sharpened_img] = cam_detect_rectification_board(img, patternDims, markerFamily, checkerSize, markerSize, originCheckerColor)
% ChArUco corners in the target image of the image rectification.
% A camera behind the light sheet sees the board mirrored (transparent board, or a board printed on
% both sides). If less than half of the corners are found in the image as it is, the board is also
% detected in the mirrored image (as stereo.calibrate does), and the try with more corners is used.
% imagePoints: corners in the order of patternWorldPoints (NaN = not detected), in the coordinates
%              of the image as recorded (also when mirrored)
% mirrored:    true: the board was seen from behind. The board coordinates must then be mirrored
%              (x -> -x) to get a rectified image that is not mirrored against the camera image.
% sharpened_img: the image as used for the detection (grey, imadjust, imsharpen, not mirrored)
if size(img, 3) > 1
    img = rgb2gray(img);
end
img = imadjust(img);
img = imsharpen(img);
sharpened_img = img;
n_corners = (patternDims(1) - 1) * (patternDims(2) - 1);
imagePoints = [];
mirrored = false;
n_found = 0;
for t = 1:2
    if t == 1
        try_img = img;
    else
        try_img = fliplr(img);
    end
    % downscales high resolution images (large markers), removes corners of wrongly decoded markers
    p = preproc.cam_detectCharucoBoardPoints_scaled(try_img, patternDims, markerFamily, checkerSize, markerSize, 'MinMarkerID', 0, ...
        'OriginCheckerColor', originCheckerColor, 'RefineCorners', true, 'ResolutionPerBit', 16, 'MarkerSizeRange', [0.005 1]);
    if isempty(p)
        n = 0;
    else
        n = nnz(all(~isnan(p), 2));
    end
    if n > n_found
        if t == 2
            p(:, 1) = size(img, 2) + 1 - p(:, 1); % back to the coordinates of the image as recorded
        end
        imagePoints = p;
        mirrored = (t == 2);
        n_found = n;
    end
    if n_found >= 0.5 * n_corners
        break % more than half of the board found as it is: a mirrored board can not give that
    end
end
