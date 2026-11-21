function [message, ok, pose] = charuco_pose(imagePoints, patternDims, checkerSize, mirrored, intrinsics, flip_xy)
%CHARUCO_POSE Camera pose from the corners of a ChArUco board, as text for the calibration overlay.
%   [message, ok, pose] = acquisition.charuco_pose(imagePoints, patternDims, checkerSize, mirrored, intrinsics, flip_xy)
%   imagePoints   inner corners in the camera image, in the order of detectCharucoBoardPoints (NaN: not found)
%   patternDims   [rows columns] of the board, checkerSize in mm
%   mirrored      true: the board is seen from behind
%   intrinsics    cameraIntrinsics of the camera (lens calibration)
%   flip_xy       [x y]: true = axis direction reversed (calibration panel: x_axis_direction / y_axis_direction)
%   message       'Yaw: .. ; Pitch: .. ; Roll: ..' newline 'Camera X: .. ; Y: .. ; Z: .. mm'
%                 (or a hint when too few corners are known)
%   ok            false when the pose could not be estimated (message empty)
%   pose          .extrinsics (rigidtform3d, board -> camera) and .world_points (the corners used, N x 2 mm) in the
%                 board coordinates of the pose (seen from behind: turned about y; more rows than columns: turned
%                 about z); [] without a pose
%   Used by the live ChArUco detection (PIVlab_capture_charuco_detector), "Show camera position" of the camera
%   calibration (preproc.cam_rectification_show_cam_position_Callback) and, with the exact corners, by the 3D
%   preview of the particle image generator (simulate.preview_3d), which therefore shows what the live image
%   would show.
ok = true;
pose = [];
detector = vision.calibration.monocular.CharucoBoardDetector();
worldPoints1 = generateWorldPoints(detector, 'PatternDims', patternDims, 'CheckerSize', checkerSize);
if mirrored
	worldPoints1(:,1) = -worldPoints1(:,1); %board seen from behind: board turned by 180 deg about y, camera in front
end
if patternDims(1) > patternDims(2) %Fixes the issue that high slender calibration bards result in rotated output
	% swap axes
	worldPoints1 = worldPoints1(:, [2 1]);
	% flip y axis
	worldPoints1(:,2) = -worldPoints1(:,2);
end
%board centre in board coordinates
board_centre=[(min(worldPoints1(:,1))+max(worldPoints1(:,1)))/2; (min(worldPoints1(:,2))+max(worldPoints1(:,2)))/2; 0];
worldPoints1(isnan(imagePoints))=NaN;
imagePoints1 = rmmissing(imagePoints); %matching world points are removed too
worldPoints1 = rmmissing(worldPoints1);
if size(worldPoints1,1) <= 3
	message='Perform camera calibration to display yaw / pitch / roll angle of camera';
	return
end
try
	imagePoints1 = undistortPoints(imagePoints1,intrinsics); %estimateExtrinsics ignores the lens distortion (strong barrel distortion: Z about 2 % too large)
	camExtrinsics1 = estimateExtrinsics(imagePoints1,worldPoints1,intrinsics);
catch
	message = '';
	ok = false;
	return
end
pose.extrinsics = camExtrinsics1;
pose.world_points = worldPoints1;
R1=camExtrinsics1.R;
t1=camExtrinsics1.Translation;
z_cam = [0; 0; 1];
z_world1 = R1 * z_cam;
alpha1 = atan2(z_world1(1), z_world1(3));   % yaw (X-Z plane)
beta1  = atan2(z_world1(2), z_world1(3));   % pitch (Y-Z plane)
alpha_deg = rad2deg(alpha1); %should be camera yaw
beta_deg  = rad2deg(beta1); % should be camera pitch
% Roll (untested)
% camera -> world rotation
R_wc = R1.';
% x axis of the camera in world coordinates
x_cam_w = R_wc(:,1);
% projected into the world x-y plane
x_proj = x_cam_w;
x_proj(3) = 0;
x_proj = x_proj / norm(x_proj);
% roll (rotation about the optical axis)
roll = atan2(x_proj(2), x_proj(1));
roll_deg = rad2deg(roll);
% Camera position relative to the board centre, in board coordinates (mm).
% R1 and t1 map board to camera coordinates, so the camera centre in board coordinates is -R1'*t1.
% X and Y run along the board (right / down in the image, like PIV x / y), Z is the distance in front of the board.
cam_pos = -R_wc*t1(:) - board_centre;
% axis directions as set for the PIV data (calibration panel)
if flip_xy(1)
	cam_pos(1) = -cam_pos(1);
end
if flip_xy(2)
	cam_pos(2) = -cam_pos(2);
end
message=['Yaw: ' num2str(round(alpha_deg)) ' ; Pitch: ' num2str(round(beta_deg)) ' ; Roll: ' num2str(round(roll_deg,1)) newline 'Camera X: ' num2str(round(cam_pos(1))) ' ; Y: ' num2str(round(cam_pos(2))) ' ; Z: ' num2str(round(abs(cam_pos(3)))) ' mm'];
end
