function acquisition_stereo_mode()
%ACQUISITION_STEREO_MODE Stereo-PIV mode that follows "Stereo (2 cameras)" of the Image Acquisition panel.
%   stereo.acquisition_stereo_mode
% Ticked (two cameras record): PIVlab goes to stereo-PIV mode, also without images, so that the lens
% calibration is made per camera (CAM 1 / CAM 2 in the calibration panels) and the live ChArUco detection
% shows the orientation of each camera. 2D images that are loaded are removed (the user is asked first);
% a 2D lens calibration without images stays as the one of camera 1. The images recorded later are
% loaded with "Import stereo images", which keeps the calibrations when the image size fits.
% Not ticked: back to 2D when the stereo session holds nothing that would be lost (no images, no
% calibration of the other camera, no stereo calibration).
if acquisition.capture_cameras == 2
    if isequal(gui.retr('stereomode'), 1)
        return
    end
    if ~isempty(gui.retr('filepath'))
        if ~isequal(gui.retr('batchModeActive'), 1)
            answer = gui.custom_msgbox('quest', getappdata(0,'hgui'), 'Stereo-PIV', ['Stereo acquisition records two cameras. ' ...
                'Switch PIVlab to stereo-PIV mode, so that each camera gets its own camera calibration?' newline newline ...
                'The images and results that are loaded now are removed.'], 'modal', {'Yes','No'}, 'Yes');
            if ~strcmp(answer, 'Yes')
                return
            end
        end
        remove_images
    end
    camera2 = empty_camera;
    gui.put('stereomode', 1);
    gui.put('stereo_active_camera', 1);
    gui.put('stereo_cam_state', {struct(), camera2});
    stereo.store_active_camera
    gui.put('charuco_camera_states', []) % live ChArUco detection: again per camera
    gui.update_dependent_controls(gui.gethand);
elseif isequal(gui.retr('stereomode'), 1) && nothing_to_lose
    stereo.leave_stereo_mode
end
end

function tf = nothing_to_lose
% stereo session without images, without calibration of the other camera and without stereo calibration
tf = isempty(gui.retr('filepath')) && isempty(gui.retr('stereo_calib'));
active = gui.retr('stereo_active_camera');
if isempty(active)
    active = 1;
end
state = gui.retr('stereo_cam_state');
if tf && iscell(state) && numel(state) == 2
    other = state{3 - active};
    if isfield(other, 'filepath') && ~isempty(other.filepath)
        tf = false;
    end
    if isfield(other, 'cameraParams') && ~isempty(other.cameraParams)
        tf = false;
    end
end
end

function camera = empty_camera
% per-camera data of a camera without images and without lens calibration
camera = struct();
keys = stereo.camera_data_keys;
for i = 1:numel(keys)
    camera.(keys{i}) = [];
end
camera.video_selection_done = 0;
camera.multitiff = 0;
camera.pcopanda_dbl_image = 0;
camera.cam_use_calibration = 0;
camera.cam_use_rectification = 0;
camera.cam_use_tilted_model = 0;
camera.controls = struct();
tags = stereo.camera_controls;
for i = 1:numel(tags)
    camera.controls.(tags{i}) = 0;
end
end

function remove_images
% the loaded 2D images and everything that belongs to them (the lens calibration stays for camera 1)
image_keys = {'filepath', 'filename', 'framenum', 'framepart', 'video_frame_selection', 'expected_image_size', ...
    'size_of_the_image', 'masks_in_frame', 'bg_img_A', 'bg_img_B', 'stereo_result', 'stereo_check', ...
    'resultslist', 'derived', 'ismean', 'framemanualdeletion', 'manualdeletion', 'streamlinesX', 'streamlinesY'};
for i = 1:numel(image_keys)
    gui.put(image_keys{i}, []);
end
gui.put('video_selection_done', 0);
gui.put('multitiff', 0);
gui.put('pcopanda_dbl_image', 0);
gui.put('displaywhat', 1);
handles = gui.gethand;
set(handles.filenamebox, 'String', {''}, 'Value', 1);
set(handles.bg_subtract, 'Value', 1);
gui.sliderrange(1)
validate.clear_vel_limit_Callback([], [])
roi.clear_roi_Callback
extract.clear_plot_Callback
end
