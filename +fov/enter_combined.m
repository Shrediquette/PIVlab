function enter_combined(calib)
%ENTER_COMBINED Two cameras -> ONE combined 2D data set in the PIVlab window (larger field of view).
%   fov.enter_combined(calib)
%   calib  stereo.calibrate with calib.use = "fov", plus calib.boards (board image files of both cameras) and
%          calib.cameras (per-camera calibration data, kept for a new import of the same cameras)
% Called in stereo mode (after "Compute 3D alignment") with the images of both cameras loaded. Afterwards the
% window holds a normal 2D data set: the frame list of camera 1, and in gui.retr('fov_src2') that of camera 2;
% every frame is the combination of both cameras (import.read_frame with cam.fov). The camera switch
% disappears, the spatial calibration (px -> mm) is filled in, the part no camera sees is masked in all frames,
% the region of interest is the whole image. Lens calibration and rectification are in the combined images.
if gui.retr('stereo_active_camera') ~= 1
    stereo.switch_camera(1); % the window shows camera 1: its frame list stays
end
stereo.store_active_camera
state = gui.retr('stereo_cam_state');
src2 = import.frame_list(state{2});
stereo.leave_stereo_mode
gui.put('fov_src2', src2);
handles = gui.gethand;
% lens undistortion and rectification are in the combined images (fov.maps): the 2D ones stay off
gui.put('cam_use_calibration', 0);
gui.put('cam_use_rectification', 0);
set([handles.calib_usecalibration handles.calib_userectification], 'Value', 0);
gui.put('fov_calib', []); % a new alignment: nothing of an earlier one is kept
fov.apply_alignment(calib)
end
