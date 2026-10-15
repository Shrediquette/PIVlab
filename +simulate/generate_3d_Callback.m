function generate_3d_Callback(~, ~, folder)
% "Generate images..." (panel 3D particle image generator): all images and the ground truth
% (simulate.recording_3d) in a folder that the user selects.
% folder (optional, no dialogs): output folder
handles = gui.gethand;
batch = isequal(gui.retr('batchModeActive'), 1);
setup = simulate.setup_3d_from_gui(handles);
g = simulate.geometry_3d(setup);
if ~g.ok
    gui.custom_msgbox('error', getappdata(0, 'hgui'), '3D particle image generator', g.message, 'modal');
    return
end
if nargin < 3 || isempty(folder)
    start = gui.retr('pathname');
    if isempty(start) || ~ischar(start) || ~isfolder(start)
        start = pwd;
    end
    folder = uigetdir(start, 'Select an output folder for the synthetic recording');
    if isequal(folder, 0)
        return
    end
    existing = dir(fullfile(folder, 'camera*'));
    if ~batch && (~isempty(existing) || isfile(fullfile(folder, 'ground_truth.mat')))
        answer = gui.custom_msgbox('quest', getappdata(0, 'hgui'), '3D particle image generator', ...
            ['The folder contains a synthetic recording already.' newline 'Overwrite it?'], 'modal', {'Overwrite', 'Cancel'}, 'Cancel');
        if ~strcmp(answer, 'Overwrite')
            return
        end
    end
end
status = @(text) set_status(handles, text);
gui.toolsavailable(0, 'Generating synthetic images...');
try
    result = simulate.recording_3d(setup, folder, Progress=status);
catch err
    gui.toolsavailable(1);
    status(['Error: ' err.message]);
    gui.custom_msgbox('error', getappdata(0, 'hgui'), '3D particle image generator', err.message, 'modal');
    return
end
gui.toolsavailable(1);
gui.put('sim3d_result', result);
n = numel(setup.cameras);
status(sprintf('Done: %d image pairs and %d calibration images per camera.\nFolder: %s', ...
    setup.output.Pairs, setup.output.CalibrationImages, folder));
if ~batch
    gui.custom_msgbox('msg', getappdata(0, 'hgui'), '3D particle image generator', ...
        sprintf(['Synthetic recording of %d camera(s) saved in' newline '%s' newline newline ...
        'README.txt in this folder explains the files and the workflow in PIVlab ' ...
        '(lens calibration, stereo calibration, disparity correction, comparison with ground_truth.mat).'], n, folder), 'modal', {'OK'}, 'OK');
end
end

function set_status(handles, text)
set(handles.sim3d_status, 'String', text);
drawnow limitrate
end
