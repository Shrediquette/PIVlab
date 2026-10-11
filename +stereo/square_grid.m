function [Ravg, info] = square_grid(tforms, image_sizes, pixel_size)
%SQUARE_GRID Common output grid with square pixels, cropped to the overlap of both camera views.
% tforms{k}: projective transform of camera k, undistorted image pixels -> world (board) coordinates
% image_sizes{k}: [rows cols] of camera k
% pixel_size: [world units] per output pixel; [] = the finer camera: for each camera, the median size of one
%             camera pixel on the sheet (square root of its area) inside the overlap; the smaller of the two.
% Ravg covers the bounding box of the overlap (the parts seen by only one camera are masked later).
% info.footprint: [world units] per camera pixel for camera 1 and 2, info.pixel_size, info.overlap (polyshape),
% info.views: polyshape of the view of camera 1 and 2 (image border on the board)
polys = cell(1, 2);
for k = 1:2
    H = image_sizes{k}(1);
    W = image_sizes{k}(2);
    corners = [0.5 0.5; W + 0.5 0.5; W + 0.5 H + 0.5; 0.5 H + 0.5];
    wc = transformPointsForward(tforms{k}, corners);
    polys{k} = polyshape(wc(:, 1), wc(:, 2));
end
overlap = intersect(polys{1}, polys{2});
if overlap.NumRegions == 0
    error('stereo:square_grid', 'The two camera views do not overlap.');
end
[xl, yl] = boundingbox(overlap);

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
    in = isinterior(overlap, p0(:, 1), p0(:, 2));
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
info.views = polys;
end
