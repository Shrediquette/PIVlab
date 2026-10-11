function imgs = rectified_images(imgs, calib, disparity)
%RECTIFIED_IMAGES Image sets of both cameras that read rectified (and disparity-corrected) images.
%   imgs = stereo.rectified_images(imgs, calib, disparity)
%   imgs       1x2 cell, pivlab image sets of camera 1 and 2 (pivlab.readImages)
%   calib      stereo.calibrate
%   disparity  stereo.measure_disparity, or [] for the rectification without disparity correction
% Every image of camera k is then read through the map of stereo.camera_map (imgs{k}.cam.stereo_map):
% lens undistortion, rectification onto the common grid of both cameras and the disparity correction
% in one interpolation. The lens calibration stays in calib.cams{k}.
for k = 1:2
    cam = calib.cams{k};
    cam.stereo_map = stereo.camera_map(calib, k, disparity);
    imgs{k}.cam = cam;
    imgs{k}.imageSize = calib.Ravg.ImageSize;
end
end
