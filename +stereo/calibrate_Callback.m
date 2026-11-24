function calibrate_Callback(~, ~, ~)
%CALIBRATE_CALLBACK "Compute stereo / 3D alignment" (Stereo-PIV / multicam panel): stereo-PIV or larger field of view.
% Uses the lens calibration and the board image in the light sheet of each camera (camera calibration
% panels of camera 1 and 2) and the board definition of the calibration panels. Afterwards both cameras
% show their images on the common grid (stereo.update_maps), the region of interest is the overlap of
% both views and the spatial calibration (px -> mm) is filled in; only the time step is missing (checklist of
% the panel). The report of the set-up is shown in "Show 3D setup".
% Masks, background images and results are reset (they belong to the uncalibrated images).
% Cameras side by side with a small overlap (stereo.camera_use): both are combined into ONE larger 2D image
% instead (fov.enter_combined), analysed like a normal 2D data set.
hgui = getappdata(0, 'hgui');
batch = isequal(gui.retr('batchModeActive'), 1);
if ~isequal(gui.retr('stereomode'), 1)
    gui.custom_msgbox('error', hgui, 'Stereo-PIV / multicam', 'Load the images of both cameras first (Input data panel: "Import stereo / multicam images").', 'modal');
    return
end
stereo.store_active_camera
state = gui.retr('stereo_cam_state');
cams = cell(1, 2);
boards = cell(1, 2);
missing = {};
for k = 1:2
    [cams{k}, message] = stereo.camera_lens(state{k});
    if isempty(cams{k})
        missing{end + 1} = sprintf('Camera %d: %s.', k, message); %#ok<AGROW>
    end
    if ~isfield(state{k}, 'cam_selected_rectification_image') || isempty(state{k}.cam_selected_rectification_image)
        missing{end + 1} = sprintf(['Camera %d: no image of the board in the light sheet (Image settings -> Camera calibration -> ' ...
            'Image rectification -> "Load target image").'], k); %#ok<AGROW>
    else
        boards{k} = state{k}.cam_selected_rectification_image;
    end
end
if ~isempty(missing)
    gui.custom_msgbox('error', hgui, '3D alignment', strjoin([{'Missing for the 3D alignment:'}, missing], newline), 'modal');
    return
end
board = stereo.board_from_gui;
if any(isnan([board.PatternDims board.CheckerSize board.MarkerSize])) || board.MarkerSize >= board.CheckerSize
    gui.custom_msgbox('error', hgui, '3D alignment', 'Check the board definition in the camera calibration panel (rows, columns, checker and marker size).', 'modal');
    return
end
if ~batch
    answer = gui.custom_msgbox('quest', hgui, '3D alignment', ['Masks, region of interest, background images and results ' ...
        'of both cameras are reset. Continue?'], 'modal', {'OK', 'Cancel'}, 'OK');
    if ~strcmp(answer, 'OK')
        return
    end
end

gui.toolsavailable(0, '3D alignment...'); drawnow
try
    calib = stereo.calibrate(cams, boards, board); % stereo-PIV or larger field of view: from the geometry
    if calib.use == "stereo"
        calib.report = stereo.geometry_report(calib);
        calib.report = [{calib.use_info.reason}, calib.report];
    end
catch err
    gui.toolsavailable(1)
    gui.custom_msgbox('error', hgui, '3D alignment', ['The 3D alignment failed: ' err.message], 'modal');
    return
end
if calib.use == "fov"
    % two cameras side by side: ONE combined 2D data set (the camera switch disappears)
    calib.boards = boards;
    calib.cameras = stereo.setup_of_cameras(state); % for a new import of the same cameras
    fov.enter_combined(calib);
    gui.toolsavailable(1)
    gui.update_dependent_controls(gui.gethand) % toolsavailable(1) restores what was disabled before (e.g. Measure disparity)
    if ~batch
        combined = gui.retr('fov_calib');
        report = combined.report;
        gui.custom_msgbox('success', hgui, '3D alignment', strjoin([{['Both cameras are combined into one image. ' ...
            'It is analysed like a normal 2D image; only the time step is missing (calibration panel).'], ''}, report], newline), 'modal');
    end
    return
end
gui.put('stereo_calib', calib);
gui.put('stereo_disparity', []);

% reset what belongs to the uncalibrated images (both cameras)
handles = gui.gethand;
stereo.clear_image_data({'stereo_result', 'stereo_vel', 'stereo_check'});
other = 3 - gui.retr('stereo_active_camera');
state{other}.masks_in_frame = [];
state{other}.bg_img_A = [];
state{other}.bg_img_B = [];
state{other}.stereo_result = [];
state{other}.stereo_check = [];
gui.put('stereo_cam_state', state);

stereo.update_maps
maps = gui.retr('stereo_maps');

% region of interest: inside the overlap of both views
roirect = stereo.auto_roi(~calib.mask, 2);
calib.auto_roi = roirect; % automatic: adapted when the disparity is measured
gui.put('stereo_calib', calib);
gui.put('roirect', roirect);
roi.updateROIinfo

% spatial calibration like the 2D rectification: reference distance along x on the common grid
board_image = imread(boards{1});
gui.put('caliimg', stereo.rectify_map(board_image, maps{1}));
calibrate.set_grid_scale(calib.Ravg.ImageSize(2), calib.Ravg.PixelExtentInWorldX);

gui.toolsavailable(1)
stereo.update_panel(handles)
stereo.show_active_camera
end
