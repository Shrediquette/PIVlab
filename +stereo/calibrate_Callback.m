function calibrate_Callback(~, ~, ~)
%CALIBRATE_CALLBACK "Compute stereo calibration" (Stereo-PIV panel).
% Uses the lens calibration and the board image in the light sheet of each camera (camera calibration
% panels of camera 1 and 2) and the board definition of the calibration panels. Afterwards both cameras
% show their images on the common grid (stereo.update_maps), the region of interest is the overlap of
% both views and the spatial calibration (px -> mm) is filled in; only the time step is missing.
% Masks, background images and results are reset (they belong to the uncalibrated images).
hgui = getappdata(0, 'hgui');
batch = isequal(gui.retr('batchModeActive'), 1);
if ~isequal(gui.retr('stereomode'), 1)
    gui.custom_msgbox('error', hgui, 'Stereo-PIV', 'Load the images of both cameras first (Input data panel: "Import stereo images").', 'modal');
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
    gui.custom_msgbox('error', hgui, 'Stereo calibration', strjoin([{'Missing for the stereo calibration:'}, missing], newline), 'modal');
    return
end
board = stereo.board_from_gui;
if any(isnan([board.PatternDims board.CheckerSize board.MarkerSize])) || board.MarkerSize >= board.CheckerSize
    gui.custom_msgbox('error', hgui, 'Stereo calibration', 'Check the board definition in the camera calibration panel (rows, columns, checker and marker size).', 'modal');
    return
end
if ~batch
    answer = gui.custom_msgbox('quest', hgui, 'Stereo calibration', ['Masks, region of interest, background images and results ' ...
        'of both cameras are reset. Continue?'], 'modal', {'OK', 'Cancel'}, 'OK');
    if ~strcmp(answer, 'OK')
        return
    end
end

gui.toolsavailable(0, 'Stereo calibration...'); drawnow
try
    calib = stereo.calibrate(cams, boards, board);
    calib.report = stereo.geometry_report(calib);
catch err
    gui.toolsavailable(1)
    gui.custom_msgbox('error', hgui, 'Stereo calibration', ['The stereo calibration failed: ' err.message], 'modal');
    return
end
gui.put('stereo_calib', calib);
gui.put('stereo_disparity', []);

% reset what belongs to the uncalibrated images (both cameras)
handles = gui.gethand;
for name = {'resultslist', 'derived', 'ismean', 'manualdeletion', 'framemanualdeletion', 'streamlinesX', 'streamlinesY', ...
        'velrect', 'velrect_freehand', 'masks_in_frame', 'bg_img_A', 'bg_img_B', 'stereo_result', 'stereo_vel', 'stereo_check'}
    gui.put(name{1}, []);
end
gui.put('displaywhat', 1);
set(handles.bg_subtract, 'Value', 1);
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
n = min(1000, calib.Ravg.ImageSize(2) - 1);
gui.put('pointscali', [1 1; 1 + n 1]);
set(handles.realdist, 'String', num2str(n * calib.Ravg.PixelExtentInWorldX));
board_image = imread(boards{1});
gui.put('caliimg', stereo.rectify_map(board_image, maps{1}));
calibrate.pixeldist_changed_Callback()

gui.toolsavailable(1)
stereo.update_panel(handles)
stereo.show_active_camera
if ~batch
    gui.custom_msgbox('success', hgui, 'Stereo calibration', strjoin([calib.report, {'', ['Both cameras now show the same ' ...
        'view of the light sheet. Enter the time step in the calibration panel (CTRL+Z) and apply it.']}], newline), 'modal');
end
end
