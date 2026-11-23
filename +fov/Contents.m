% +FOV  Two cameras for a larger field of view (one combined 2D image)
%
% Two cameras side by side see different parts of one light sheet. A ChArUco board that both cameras see
% (stereo.calibrate, calib.use = "fov") places both on one board grid; their raw images are combined into
% one larger image, which is then analysed like a normal 2D PIVlab image (import.read_frame, cam.fov).
%
%   maps       - everything import.read_frame needs (owner map, per-camera maps, camera-2 frame list)
%   owner_map  - which camera gives each pixel (hard seam in the middle of the overlap)
%   compose    - one combined image from the raw images of both cameras
%   subset     - camera settings for a part of the frame list
%   is_combined - true for camera settings that combine two cameras
%   report, overlap_width - report of the 3D alignment (overlap width, warnings)
%   measure_sheet - light sheet position from the disparity in the overlap; both cameras mapped onto the sheet
%   on_sheet   - the alignment moved from the board onto a light sheet plane; sheet_report - its report lines
%   auto_roi   - automatic region of interest inside the part the cameras see
%   GUI: enter_combined, apply_alignment, measure_sheet_Callback, update_maps, clear_combined, gui_active
%
% API: pivlab.combineCameras. Plan: dev_notes/two_camera_fov_plan.md
