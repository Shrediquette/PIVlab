function out = compose(img1, img2, F)
%COMPOSE One larger image from the raw images of two cameras (larger field of view).
%   out = fov.compose(img1, img2, F)
%   img1, img2  raw images of camera 1 and 2 (colour images are converted to grey values)
%   F           fov.maps (cam.fov)
%   out         combined image, size F.size; pixels that no camera sees are 0. Integer images give uint16
%               (as stereo.rectify_map), floating point images keep their class.
% Lens undistortion and the projective transform onto the board grid in one interpolation per camera, only
% at the pixels the camera gives (F.owner).
p1 = stereo.rectify_map(img1, F.map{1});
p2 = stereo.rectify_map(img2, F.map{2});
out = zeros(F.size, 'like', p1);
out(F.owner == 1) = p1;
out(F.owner == 2) = cast(p2, 'like', p1);
end
