function update_panel(handles)
%UPDATE_PANEL Checklist, disparity report and displays of the popup "Show:" of the Stereo-PIV panel (the
%calibration report is in "Show 3D setup").
if nargin < 1
    handles = gui.gethand;
end
stereo.disparity_display_popup(handles, 'update'); % only the displays that have data
rows = zeros(1, 7);
for k = 1:7
    rows(k) = handles.(['stereo_step_' int2str(k)]);
end
if fov.gui_active % two cameras combined into one image: a normal 2D data set, only the time step is left
    calib = gui.retr('fov_calib');
    measured = isfield(calib, 'sheet') && ~isempty(calib.sheet);
    done = [true true true true measured time_step_applied(calib)];
    names = {'Images of both cameras', 'Lens calibration', 'Board in the light sheet', ...
        '3D alignment: larger field of view (u, v)', 'Light sheet position (disparity in the overlap)', ...
        'Time step (calibration panel, CTRL+Z)'};
    set(handles.stereo_steps, 'Visible', 'off');
    set_rows(rows, done, names);
    if measured
        set(handles.stereo_disp_report, 'String', fov.sheet_report(calib));
    else
        set(handles.stereo_disp_report, 'String', 'Not measured yet.');
    end
    return
end
if ~isequal(gui.retr('stereomode'), 1)
    set(rows, 'Visible', 'off');
    set(handles.stereo_steps, 'Visible', 'on', 'String', 'Load the images of both cameras first (Input data panel: "Import multi-camera images").');
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
done = [true, all(has_lens), all(has_board), ~isempty(calib), ~isempty(gui.retr('stereo_disparity')), ...
    ~isempty(gui.retr('roirect')), time_step_applied(calib)];
names = {'Images of both cameras', ['Lens calibration' cameras_missing(has_lens)], ...
    ['Board in the light sheet' cameras_missing(has_board)], '3D alignment', ...
    'Disparity correction', 'Region of interest', 'Time step (calibration panel, CTRL+Z)'};
set(handles.stereo_steps, 'Visible', 'off');
set_rows(rows, done, names);
disparity = gui.retr('stereo_disparity');
if isempty(disparity) || ~isfield(disparity, 'report')
    set(handles.stereo_disp_report, 'String', 'Not measured yet.');
else
    set(handles.stereo_disp_report, 'String', disparity.report);
end
end

function set_rows(rows, done, names)
% the checklist: green done, red open, the first open step bold; rows without a step are hidden
next = find(~done, 1);
for k = 1:numel(rows)
    if k > numel(done)
        set(rows(k), 'Visible', 'off');
        continue
    end
    if done(k)
        color = [0.10 0.60 0.10]; % green
    else
        color = [0.85 0.15 0.15]; % red
    end
    weight = 'normal';
    if isequal(k, next)
        weight = 'bold';
    end
    set(rows(k), 'String', [mark(done(k)) ' ' names{k}], 'ForegroundColor', color, 'FontWeight', weight, 'Visible', 'on');
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
    s = [' (missing: cam ' strjoin(cellstr(num2str(find(~present)')), ' + ') ')']; % one row of the Steps panel
end
end
