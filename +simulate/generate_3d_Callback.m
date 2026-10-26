function generate_3d_Callback(~, ~, folder)
% "Generate images..." (panel Particle image generator): all images and the ground truth
% (simulate.recording_3d) in a folder that the user selects. Simple setup: the image pairs are
% then loaded into PIVlab.
% folder (optional, no dialogs): output folder
handles = gui.gethand;
batch = isequal(gui.retr('batchModeActive'), 1);
setup = simulate.setup_3d_from_gui(handles);
mess = check_inputs(setup);
if ~isempty(mess) % empty or wrong text gives NaN (crashed deep inside the generator)
    gui.custom_msgbox('error', getappdata(0, 'hgui'), 'Particle image generator', mess, 'modal');
    return
end
g = simulate.geometry_3d(setup);
if ~g.ok
    gui.custom_msgbox('error', getappdata(0, 'hgui'), 'Particle image generator', g.message, 'modal');
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
    existing = [dir(fullfile(folder, 'camera*')); dir(fullfile(folder, 'particle_images'))];
    if ~batch && (~isempty(existing) || isfile(fullfile(folder, 'ground_truth.mat')))
        answer = gui.custom_msgbox('quest', getappdata(0, 'hgui'), 'Particle image generator', ...
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
    gui.custom_msgbox('error', getappdata(0, 'hgui'), 'Particle image generator', err.message, 'modal');
    return
end
gui.toolsavailable(1);
gui.put('sim3d_result', result);
if g.simple
    status(sprintf('Done: %d image pairs.\nFolder: %s', setup.output.Pairs, folder));
    load_into_pivlab(result.particle_images{1}, batch);
    return
end
n = numel(setup.cameras);
status(sprintf('Done: %d image pairs and %d calibration images per camera.\nFolder: %s', ...
    setup.output.Pairs, setup.output.CalibrationImages, folder));
if ~batch
    gui.custom_msgbox('msg', getappdata(0, 'hgui'), 'Particle image generator', ...
        sprintf(['Synthetic recording of %d camera(s) saved in' newline '%s' newline newline ...
        'README.txt in this folder explains the files and the workflow in PIVlab ' ...
        '(lens calibration, stereo calibration, disparity correction, comparison with ground_truth.mat).'], n, folder), 'modal', {'OK'}, 'OK');
end
end

function mess = check_inputs(setup)
% messages for missing or impossible values
mess = {};
names = {'Image width', 'Image height', 'Pixel size in the sheet', 'Light sheet thickness', 'Particles per pixel', ...
    'Particle diameter', 'Image pairs'};
values = [setup.sensor.ImageSize([2 1]), setup.Simple.PixelSize, setup.sheet.Thickness, setup.particles.Density, ...
    setup.particles.Diameter, setup.output.Pairs];
for i = 1:numel(values)
    if ~isfinite(values(i)) || values(i) <= 0
        mess{end + 1} = [names{i} ' must be a number > 0']; %#ok<AGROW>
    end
end
others = [setup.flow.InPlane, setup.flow.Radius, setup.flow.OutOfPlane, setup.flow.Distance, setup.flow.Diameter, ...
    setup.flow.Spacing, setup.particles.DiameterVariation, setup.particles.Noise, setup.output.CalibrationImages, ...
    setup.sheet.Offset, setup.sheet.TiltX, setup.sheet.TiltY, setup.sensor.PixelPitch, setup.sensor.FocalLength];
for k = 1:numel(setup.cameras)
    others = [others, setup.cameras(k).Position, setup.cameras(k).Target, setup.cameras(k).RadialDistortion]; %#ok<AGROW>
end
if ~all(isfinite(others))
    mess{end + 1} = 'All settings must be numbers';
end
end

function load_into_pivlab(files, batch)
% the image pairs of the simple setup as a new PIVlab session (pairwise: A, B, A, B, ...)
if isempty(files)
    return
end
if ~batch && ~isempty(gui.retr('filepath'))
    answer = gui.custom_msgbox('quest', getappdata(0, 'hgui'), 'Particle image generator', ...
        ['Load the generated images into PIVlab?' newline newline 'The images and results that are loaded now are removed.'], ...
        'modal', {'Yes', 'No'}, 'Yes');
    if ~strcmp(answer, 'Yes')
        return
    end
end
names = cellstr(files);
gui.put('sequencer', 1);
gui.put('multitiff', 0);
import.loadimgsbutton_Callback([], [], 0, struct('name', names(:), 'isdir', num2cell(false(numel(names), 1))));
end

function set_status(handles, text)
set(handles.sim3d_status, 'String', text);
drawnow limitrate
end
