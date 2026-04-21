function img_out = cam_undistort(img_in,method,view,cam_use_calibration,cam_use_rectification,cameraParams,rectification_tform,cam_use_tilted_model,cam_tilted_D,cam_K_opencv)
% Optional tilted-model arguments (nargin >= 8):
%   cam_use_tilted_model : logical, true = use opencv_undistort with full D
%   cam_tilted_D         : 1x14 distortion vector from tilted calibration
%   cam_K_opencv         : 3x3 K in OpenCV format from tilted calibration
if nargin < 8;  cam_use_tilted_model = false; end
if nargin < 9;  cam_tilted_D = [];            end
if nargin < 10; cam_K_opencv = [];            end

if cam_use_calibration
    if cam_use_tilted_model && ~isempty(cam_tilted_D) && ~isempty(cam_K_opencv)
        img_out = opencv.opencv_undistort(img_in, cam_K_opencv, cam_tilted_D, view);
    else
        img_out = undistortImage(img_in, cameraParams, method, 'OutputView', view);
    end
    if cam_use_rectification
        img_out = imwarp(img_out, rectification_tform);
    end
else
    img_out = img_in;
end