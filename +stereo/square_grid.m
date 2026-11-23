function [Ravg, info] = square_grid(tforms, image_sizes, pixel_size, cams, region, views)
%SQUARE_GRID Common output grid with square pixels: the overlap of both camera views, or both views together.
% tforms{k}: projective transform of camera k, undistorted image pixels -> world (board) coordinates
% image_sizes{k}: [rows cols] of camera k
% pixel_size: [world units] per output pixel; [] = the finer camera: for each camera, the median size of one
%             camera pixel on the sheet (square root of its area) inside the covered region (the overlap, or
%             the camera's own view for region "union"); the smaller of the two.
% cams{k} (optional): camera settings with the lens calibration (import.cam_settings), see stereo.view_polygons.
% region (optional): "overlap" (default, stereo-PIV): Ravg covers the bounding box of the overlap (the parts
%             seen by only one camera are masked later). "union" (two cameras for a larger field of view):
%             Ravg covers the bounding box of both views together; the views do not have to overlap.
% views (optional): stereo.view_polygons of tforms / image_sizes / cams, when the caller has them already
% info.footprint: [world units] per camera pixel for camera 1 and 2, info.pixel_size, info.overlap (polyshape,
% may be empty for "union"), info.views: polyshape of the view of camera 1 and 2 (image border on the board),
% info.region
if nargin < 4 || isempty(cams)
    cams = {[], []};
end
if nargin < 5 || isempty(region)
    region = "overlap";
end
region = string(region);
if ~ismember(region, ["overlap", "union"])
    error('stereo:square_grid', 'region must be "overlap" or "union".');
end
if nargin < 6 || isempty(views)
    views = stereo.view_polygons(tforms, image_sizes, cams);
end
overlap = intersect(views{1}, views{2});
if region == "overlap"
    if overlap.NumRegions == 0
        error('stereo:square_grid', 'The two camera views do not overlap.');
    end
    covered = overlap;
    measured = {overlap, overlap}; % where the pixel size of each camera is measured
else
    covered = union(views{1}, views{2});
    measured = views;
end
[xl, yl] = boundingbox(covered);

footprint = [0 0];
for k = 1:2
    H = image_sizes{k}(1);
    W = image_sizes{k}(2);
    [gx, gy] = meshgrid(linspace(1, W - 1, 80), linspace(1, H - 1, 80));
    p0 = transformPointsForward(tforms{k}, [gx(:), gy(:)]);
    px = transformPointsForward(tforms{k}, [gx(:) + 1, gy(:)]);
    py = transformPointsForward(tforms{k}, [gx(:), gy(:) + 1]);
    ex = px - p0;
    ey = py - p0;
    area = abs(ex(:, 1) .* ey(:, 2) - ex(:, 2) .* ey(:, 1)); % world area of one camera pixel
    in = isinterior(measured{k}, p0(:, 1), p0(:, 2));
    footprint(k) = median(sqrt(area(in)));
end
if isempty(pixel_size)
    pixel_size = min(footprint);
end
W = ceil((xl(2) - xl(1)) / pixel_size);
H = ceil((yl(2) - yl(1)) / pixel_size);
Ravg = imref2d([H W], [xl(1), xl(1) + W * pixel_size], [yl(1), yl(1) + H * pixel_size]);
info.footprint = footprint;
info.pixel_size = pixel_size;
info.overlap = overlap;
info.views = views;
info.region = region;
end
