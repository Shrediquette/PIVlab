function polys = view_polygons(tforms, image_sizes, cams)
%VIEW_POLYGONS View of both cameras on the board plane (image border mapped onto the board).
%   polys = stereo.view_polygons(tforms, image_sizes)
%   polys = stereo.view_polygons(tforms, image_sizes, cams)
% tforms{k}: projective transform of camera k, undistorted image pixels -> world (board) coordinates
% image_sizes{k}: [rows cols] of camera k
% cams{k} (optional): camera settings with the lens calibration (import.cam_settings). The view is then the
%             border of the raw image, undistorted with the lens model (barrel distortion: larger than the
%             undistorted image rectangle, pincushion: smaller). Without cams: the image rectangle.
% polys{k}: polyshape of the view of camera k (world coordinates)
if nargin < 3
    cams = {[], []};
end
polys = cell(1, numel(tforms));
for k = 1:numel(tforms)
    H = image_sizes{k}(1);
    W = image_sizes{k}(2);
    if isempty(cams{k})
        border = [0.5 0.5; W + 0.5 0.5; W + 0.5 H + 0.5; 0.5 H + 0.5];
    else
        border = undistort_points(raw_border(H, W), cams{k});
    end
    wc = transformPointsForward(tforms{k}, border);
    polys{k} = polyshape(wc(:, 1), wc(:, 2));
end
end

function border = raw_border(H, W)
% outer border of the image (pixel edges), 100 points per side, clockwise
s = linspace(0, 1, 101)';
s = s(1:end - 1);
top = [0.5 + s * W, 0 * s + 0.5]; % left -> right
right = [0 * s + W + 0.5, 0.5 + s * H]; % top -> bottom
bottom = [W + 0.5 - s * W, 0 * s + H + 0.5]; % right -> left
left = [0 * s + 0.5, H + 0.5 - s * H]; % bottom -> top
border = [top; right; bottom; left];
end

function pu = undistort_points(pd, cam)
% inverse of stereo.distort_points: raw image points -> undistorted image points (fixed-point iteration)
pu = pd;
for i = 1:100
    err = pd - stereo.distort_points(pu, cam);
    pu = pu + err;
    if max(abs(err(:))) < 1e-3
        break
    end
end
end
