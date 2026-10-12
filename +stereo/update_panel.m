function update_panel(handles)
%UPDATE_PANEL Checklist and disparity report of the Stereo-PIV panel (the calibration report is in "Show 3D setup").
if nargin < 1
    handles = gui.gethand;
end
if ~isequal(gui.retr('stereomode'), 1)
    set(handles.stereo_steps, 'String', 'Load the images of both cameras first (Input data panel: "Import stereo images").');
    set(handles.stereo_disp_report, 'String', 'Not measured yet.');
    return
end
active = gui.retr('stereo_active_camera');
state = gui.retr('stereo_cam_state');
cams = cell(1, 2);
for k = 1:2
    if k == active || ~iscell(state) || numel(state) < k
        cams{k}.cameraParams = gui.retr('cameraParams');
        cams{k}.cam_selected_rectification_image = gui.retr('cam_selected_rectification_image');
    else
        cams{k} = state{k};
    end
end
has_lens = [has(cams{1}, 'cameraParams'), has(cams{2}, 'cameraParams')];
has_board = [has(cams{1}, 'cam_selected_rectification_image'), has(cams{2}, 'cam_selected_rectification_image')];
calib = gui.retr('stereo_calib');
steps = {};
steps{end + 1} = [mark(true) ' Images of both cameras'];
steps{end + 1} = [mark(all(has_lens)) ' Lens calibration' cameras_missing(has_lens)];
steps{end + 1} = [mark(all(has_board)) ' Board image in the light sheet' cameras_missing(has_board)];
steps{end + 1} = [mark(~isempty(calib)) ' Stereo calibration'];
steps{end + 1} = [mark(~isempty(gui.retr('stereo_disparity'))) ' Disparity correction'];
steps{end + 1} = [mark(~isempty(gui.retr('roirect'))) ' Region of interest'];
steps{end + 1} = [mark(time_step_applied(calib)) ' Time step (calibration panel, CTRL+Z)'];
set(handles.stereo_steps, 'String', steps);
disparity = gui.retr('stereo_disparity');
if isempty(disparity) || ~isfield(disparity, 'report')
    set(handles.stereo_disp_report, 'String', 'Not measured yet.');
else
    set(handles.stereo_disp_report, 'String', disparity.report);
end
end

function tf = time_step_applied(calib)
% the spatial calibration of the stereo grid is applied with a time step (velocities, not displacements);
% a calibration applied before the stereo calibration (other scale) does not count
tf = false;
if isempty(calib)
    return
end
calxy = gui.retr('calxy'); % m per px
displacement_only = gui.retr('displacement_only');
if isempty(calxy) || isequal(calxy, 1) || isequal(displacement_only, 1)
    return
end
mm_per_px = calib.Ravg.PixelExtentInWorldX;
tf = abs(calxy * 1000 - mm_per_px) < 0.01 * mm_per_px;
end

function tf = has(camera, field)
tf = isfield(camera, field) && ~isempty(camera.(field));
end

function m = mark(done)
if done
    m = char(10003); % check mark
else
    m = char(10007); % cross
end
end

function s = cameras_missing(present)
s = '';
if ~all(present)
    s = [' (missing: camera ' strjoin(cellstr(num2str(find(~present)')), ' and ') ')'];
end
end
