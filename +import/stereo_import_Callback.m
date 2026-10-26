function stereo_import_Callback(~, ~, paths)
%STEREO_IMPORT_CALLBACK "Import stereo images": the images of camera 1 and camera 2 (stereo-PIV, 2D3C).
% The normal PIVlab image dialog opens twice, for camera 1 and for camera 2. Both cameras use the same
% sequencing style and must give the same number of images (recorded simultaneously). Camera 2 is
% loaded first and kept in the stereo camera state, then camera 1 is loaded and shown; the camera
% switch (Tools panel) changes between them (stereo.switch_camera).
% New images in stereo mode (e.g. the next recording with the same setup): like new images in 2D, the
% results, background images, masks and velocity limits are removed; the lens calibrations, board images,
% stereo calibration, disparity and region of interest stay when both cameras give images of the same
% size as before.
% paths (optional, no dialogs): {files of camera 1, files of camera 2}, each a cell array of file names.
batch = isequal(gui.retr('batchModeActive'), 1);
if nargin < 3
    paths = {};
end
was_stereo = isequal(gui.retr('stereomode'), 1);
if isempty(paths) && was_stereo && ~batch
    answer = gui.custom_msgbox('quest', getappdata(0,'hgui'), 'Stereo-PIV', ['Load new images of both cameras?' newline newline ...
        'Results, masks and background images are removed. The calibrations stay if ' ...
        'the new images have the same size.'], 'modal', {'Yes','No'}, 'Yes');
    if ~strcmp(answer, 'Yes')
        return
    end
elseif isempty(paths) && ~isempty(gui.retr('filepath')) && ~batch
    answer = gui.custom_msgbox('quest', getappdata(0,'hgui'), 'Stereo-PIV', ['Start a stereo-PIV session with two cameras?' ...
        newline newline 'The images, calibrations and results that are loaded now are removed.'], 'modal', {'Yes','No'}, 'Yes');
    if ~strcmp(answer, 'Yes')
        return
    end
end

%% images of both cameras
selection = cell(1, 2);
multitiff = [0 0];
if isempty(paths) % the image import dialog with one list per camera (it also sets the sequencing style)
    folder = gui.get_preference('stereo_folder_cam1', '');
    if isempty(folder) || ~isfolder(folder)
        folder = gui.retr('pathname');
    end
    paths = gui.image_import_dialog('stereo', folder);
    if isempty(paths)
        return % cancelled
    end
    gui.set_preference('stereo_folder_cam1', fileparts(paths{1}{1}));
end
for k = 1:2
    names = cellstr(paths{k});
    multitiff(k) = is_multitiff(names{1});
    selection{k} = struct('name', names(:), 'isdir', num2cell(false(numel(names), 1)));
end
sequencer = gui.retr('sequencer');
if isempty(sequencer)
    sequencer = 1;
end
n_images = [0 0];
for k = 1:2
    [filepath, ~, ~, ~, used_sequencer] = import.build_file_list({selection{k}.name}, sequencer, multitiff(k));
    n_images(k) = numel(filepath);
    if k == 1
        sequencer_1 = used_sequencer;
    elseif used_sequencer ~= sequencer_1
        gui.custom_msgbox('error', getappdata(0,'hgui'), 'Stereo-PIV', 'The images of camera 1 and camera 2 need the same sequencing style (e.g. both pco double images).', 'modal');
        return
    end
end
if n_images(1) ~= n_images(2)
    gui.custom_msgbox('error', getappdata(0,'hgui'), 'Stereo-PIV', sprintf(['Camera 1 has %d images, camera 2 has %d images.' newline newline ...
        'Both cameras must have the same number of images (recorded at the same time).'], n_images(1), n_images(2)), 'modal');
    return
end
if n_images(1) < 2
    gui.custom_msgbox('error', getappdata(0,'hgui'), 'Stereo-PIV', 'Each camera needs at least two images (one image pair).', 'modal');
    return
end

%% a fresh session: no stereo data, no camera calibration, no region of interest
kept = [];
if was_stereo
    kept = calibration_of_both_cameras; % back after loading, if the image size is the same
end
stereo.leave_stereo_mode
clear_camera_calibration
gui.put('roirect', []);

%% camera 2 first (kept in the stereo state), then camera 1 (shown)
gui.put('multitiff', multitiff(2));
import.loadimgsbutton_Callback([], [], 0, selection{2});
if isempty(gui.retr('filepath'))
    return
end
camera2 = stereo.collect_camera;
clear_camera_calibration
gui.put('multitiff', multitiff(1));
import.loadimgsbutton_Callback([], [], 0, selection{1});
gui.put('stereomode', 1);
gui.put('stereo_active_camera', 1);
gui.put('stereo_cam_state', {struct(), camera2});
stereo.store_active_camera
kept_message = '';
if ~isempty(kept)
    kept_message = restore_calibration(kept);
end
stereo.show_active_camera
if ~batch && ~isempty(kept_message)
    gui.custom_msgbox('success', getappdata(0,'hgui'), 'Stereo-PIV', ['Images of both cameras loaded (' int2str(n_images(1) / 2) ...
        ' image pairs each).' newline newline kept_message], 'modal');
elseif ~batch
    gui.custom_msgbox('success', getappdata(0,'hgui'), 'Stereo-PIV', ['Images of both cameras loaded (' int2str(n_images(1) / 2) ' image pairs each).' ...
        newline newline 'Camera 1 is shown. Use the "CAM 1 / CAM 2" button in the Tools panel to switch between the cameras. ' ...
        'Masks and the camera calibration belong to the camera that is shown; all other settings are used for both cameras.'], 'modal');
end
end

function tf = is_multitiff(file)
tf = 0;
[~, ~, ext] = fileparts(file);
if any(strcmpi(ext, {'.tif', '.tiff'}))
    tf = double(numel(imfinfo(file)) > 1);
end
end

function kept = calibration_of_both_cameras
% the calibration data of both cameras and the stereo data that can be used for new images of the same size
stereo.store_active_camera
state = gui.retr('stereo_cam_state');
keys = calibration_keys;
kept.cameras = cell(1, 2);
for k = 1:2
    camera = struct();
    for i = 1:numel(keys)
        if isfield(state{k}, keys{i})
            camera.(keys{i}) = state{k}.(keys{i});
        end
    end
    kept.cameras{k} = camera;
    kept.raw_size{k} = raw_image_size(state{k});
end
kept.calib = gui.retr('stereo_calib');
kept.disparity = gui.retr('stereo_disparity');
kept.roirect = gui.retr('roirect');
end

function message = restore_calibration(kept)
% calibrations of the old images for the new images, if both cameras have the same image size as before
state = gui.retr('stereo_cam_state');
same_size = true;
for k = 1:2
    same_size = same_size && ~isempty(kept.raw_size{k}) && isequal(kept.raw_size{k}, raw_image_size(state{k}));
end
calibrated = ~isempty(kept.calib) || isfield(kept.cameras{1}, 'cameraParams') && ~isempty(kept.cameras{1}.cameraParams) ...
    || isfield(kept.cameras{2}, 'cameraParams') && ~isempty(kept.cameras{2}.cameraParams);
message = '';
if ~calibrated
    return
end
if ~same_size
    message = 'The image size is different from the images before: the calibrations were removed.';
    return
end
for k = 1:2
    names = fieldnames(kept.cameras{k});
    for i = 1:numel(names)
        state{k}.(names{i}) = kept.cameras{k}.(names{i});
    end
end
gui.put('stereo_cam_state', state);
camera = state{1}; % camera 1 is shown
names = fieldnames(kept.cameras{1});
for i = 1:numel(names)
    if strcmp(names{i}, 'controls')
        handles = gui.gethand;
        tags = fieldnames(camera.controls);
        for j = 1:numel(tags)
            set(handles.(tags{j}), 'Value', camera.controls.(tags{j}));
        end
    else
        gui.put(names{i}, camera.(names{i}));
    end
end
disparity = kept.disparity;
if ~isempty(disparity)
    disparity.background = {[], []}; % minimum backgrounds of the old images: made again if the disparity is measured again
end
gui.put('stereo_calib', kept.calib);
gui.put('stereo_disparity', disparity);
gui.put('roirect', kept.roirect);
stereo.update_maps
roi.updateROIinfo
message = ['The calibrations of both cameras' stereo_text(kept) ' and the region of interest were kept (same setup). ' ...
    'Use CAM 1 / CAM 2 in the Tools panel to switch between the cameras.'];
end

function text = stereo_text(kept)
text = ''; % the disparity correction stays without a word (user decision)
if ~isempty(kept.calib)
    text = ', the stereo calibration';
end
end

function keys = calibration_keys
% per-camera data that belongs to the setup, not to the images (lens calibration, board image)
keys = {'cameraParams', 'cameraStats', 'cam_use_calibration', 'cam_use_rectification', 'cam_use_tilted_model', ...
    'cam_tilted_D', 'cam_K_opencv', 'rectification_tform', 'cam_selected_target_images', ...
    'cam_selected_rectification_image', 'charuco_qr_params', 'controls'};
end

function sz = raw_image_size(camera)
% size of the first raw camera image (not rectified)
sz = [];
if ~isfield(camera, 'filepath') || isempty(camera.filepath) || ~isfile(camera.filepath{1})
    return %no images, or they were moved / deleted since loading: the calibration is not kept
end
src.filepath = camera.filepath;
src.framenum = camera.framenum;
src.framepart = camera.framepart;
sz = size(import.read_frame(src, 1, import.cam_settings(), []), 1, 2);
end

function clear_camera_calibration
% each camera starts without lens calibration (it is made per camera in the calibration panels)
gui.put('cameraParams', []);
gui.put('cameraStats', []);
gui.put('cam_use_calibration', 0);
gui.put('cam_use_rectification', 0);
gui.put('cam_use_tilted_model', 0);
gui.put('cam_tilted_D', []);
gui.put('cam_K_opencv', []);
gui.put('rectification_tform', []);
gui.put('cam_selected_target_images', []);
gui.put('cam_selected_rectification_image', []);
gui.put('charuco_qr_params', []);
handles = gui.gethand;
tags = stereo.camera_controls;
for i = 1:numel(tags)
    set(handles.(tags{i}), 'Value', 0);
end
end
