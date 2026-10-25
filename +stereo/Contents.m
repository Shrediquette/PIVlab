% STEREO  Stereo-PIV (2D3C): three velocity components in a light sheet seen by two cameras
%
% The image pre-processing, PIV analysis and vector validation of each camera are ordinary PIVlab
% steps (pivlab.*); this package adds the stereo calibration, the disparity correction and the
% reconstruction of the three components. Type "help stereo.<function>" for details.
%
% Typical workflow (camera k = 1, 2; recorded simultaneously)
%   imgs{k} = pivlab.readImages(files{k}, "pairwise");
%   imgs{k} = pivlab.preprocess(imgs{k}, Camera=lens_calibration_file{k});   % lens calibration of camera k
%   res     = pivlab.stereo(imgs, {board_image_1, board_image_2}, board);    % everything below in one call
%   res     = pivlab.filter(res);                                             % validation (both cameras), U, V, W
%
% Steps
%   calibrate          - Stereo calibration from a ChArUco board in the light sheet (common output grid)
%   rectified_images   - Image sets that read rectified, disparity-corrected images (cam.stereo_map)
%   measure_disparity  - Misalignment of the two rectified views, fitted with a smooth model
%   reconstruct        - U, V, W from the PIV results of both cameras
%   combine_cameras    - U, V, W and the vector types from the 2D results of both cameras (GUI and API)
%   limit_test         - Vectors of a 3D result outside the velocity limits (GUI and API)
%   defaults           - Settings of the stereo steps
%
% Building blocks
%   camera_map         - Raw-image position of every output pixel (lens + rectification + disparity)
%   rectify_map        - Apply such a map to an image (one interpolation)
%   distort_points     - Lens distortion (MATLAB model, OpenCV model with tilted sensor / Scheimpflug)
%   square_grid        - Common output grid with square pixels, cropped to the overlap
%   filter_corners     - Reject wrongly identified board corners (RANSAC)
%   fit_disparity      - Robust polynomial / projective model of the disparity map
%   disparity_field    - Full-size disparity maps from the disparity vectors
%   min_background     - Minimum-intensity background of the A images (for the disparity)
%   auto_roi           - Largest rectangle inside the overlap of both cameras
%   robust_lsq         - Weighted least squares with Tukey bisquare weights
%   sheet_position     - Position of the light sheet relative to the board, from the disparity
%   geometry_report    - Viewing angles, angle between the cameras, expected error of W
%   opposite_sides     - True if the cameras are on opposite sides of the light sheet
%   w_direction        - Direction of positive W in words
%
% Camera arrangements: side by side, above each other or diagonal, on the same side of the light sheet or
% on opposite sides (the camera behind the board sees it mirrored: transparent board, detected
% automatically). Both cameras must look at the sheet from clearly different directions.
%
% Coordinates like PIVlab: x to the right, y down (rectified image, as seen from camera 1), W positive
% away from camera 1 (= away from the cameras when both are on the same side).
% World coordinates = board coordinates in mm.
