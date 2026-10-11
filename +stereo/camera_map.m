function map = camera_map(calib, k, disparity)
%CAMERA_MAP Raw-image position of every output pixel of camera k (for stereo.rectify_map).
%   map = stereo.camera_map(calib, k, disparity)
% Output pixel (x, y) of calib.Ravg -> shift by half the disparity (camera 1: -d/2, camera 2: +d/2)
% -> world coordinates (board, mm) -> undistorted camera pixel (inverse of the projective rectification
% calib.tform{k}) -> raw camera pixel (lens model of calib.cams{k}, stereo.distort_points).
% disparity = [] gives the plain rectification.
% map.x, map.y: single, size of calib.Ravg (MATLAB pixel convention: pixel centres at integers).
H = calib.Ravg.ImageSize(1);
W = calib.Ravg.ImageSize(2);
[xo, yo] = meshgrid(1:W, 1:H);
if ~isempty(disparity)
    if k == 1
        xo = xo - disparity.u_full / 2;
        yo = yo - disparity.v_full / 2;
    else
        xo = xo + disparity.u_full / 2;
        yo = yo + disparity.v_full / 2;
    end
end
[xw, yw] = intrinsicToWorld(calib.Ravg, xo, yo);
clear xo yo
pu = transformPointsInverse(calib.tform{k}, [xw(:), yw(:)]);
clear xw yw
pd = stereo.distort_points(pu, calib.cams{k});
map.x = reshape(single(pd(:, 1)), H, W);
map.y = reshape(single(pd(:, 2)), H, W);
end
