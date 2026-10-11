function out = rectify_map(img, map)
%RECTIFY_MAP Rectified and disparity-corrected image in ONE interpolation (map of stereo.camera_map).
%   out = stereo.rectify_map(img, map)
%   img          raw camera image (colour images are converted to grey values)
%   map.x/map.y  raw-image position of every output pixel; outside the raw image: 0
%   Integer images (uint8, uint16) give uint16 (no precision lost in the interpolation),
%   floating point images keep their class and value range. Cubic interpolation (the kernel of
%   imwarp).
if size(img, 3) > 1
    img = rgb2gray(img);
end
if isinteger(img)
    out = im2uint16(interp2(im2single(img), map.x, map.y, 'cubic', 0));
else
    out = cast(interp2(single(img), map.x, map.y, 'cubic', 0), 'like', img);
end
end
