function reset_gui_Callback(~, ~, store_preferences)
%RESET_GUI_CALLBACK "Reset PIVlab GUI" (Input data panel): PIVlab as after a new start, without a new window.
%   gui.reset_gui_Callback()            the button
%   gui.reset_gui_Callback([], [], false)  without storing the last folders first (scripts, unit tests:
%                                       like closing the window with delete, the next state does not
%                                       depend on what was done before)
%   Does what closing and starting PIVlab does: the hardware is released (gui.end_of_session) and the
%   last folders are stored; the data of the window goes back to the state at the end of the start
%   (PIVlab_GUI stores it as 'startup_appdata'), so data added later by any feature is removed; the
%   controls, the axes and the menus are made again. Unlike a new start, the image acquisition panel
%   gets its default settings too (not the ones stored when PIVlab was closed). Kept: the preferences
%   (folders, theme, panel width, Basic/Advanced mode) and the parallel pool. Scripts
%   (batchModeActive = 1) are not asked and stay in batch mode.
if nargin < 3
    store_preferences = true;
end
hgui = getappdata(0, 'hgui');
batch = isequal(gui.retr('batchModeActive'), 1);
if ~batch
    answer = gui.custom_msgbox('quest', hgui, 'Reset PIVlab GUI', ['All images, results, masks and calibrations ' ...
        'are removed, and all settings (also those of the image acquisition panel) get their default values. ' ...
        'Your preferences are kept.' newline newline 'Unsaved work is lost. Continue?'], 'modal', {'Reset', 'Cancel'}, 'Cancel');
    if ~strcmp(answer, 'Reset')
        return
    end
end
startup = gui.retr('startup_appdata');
if isempty(startup)
    gui.custom_msgbox('error', hgui, 'Reset PIVlab GUI', 'The start state of PIVlab is not known. Please close and start PIVlab.', 'modal');
    return
end
gui.toolsavailable(0, 'Resetting PIVlab...'); drawnow
gui.end_of_session(false) % hardware released; the settings of the image acquisition panel are not stored
if store_preferences
    gui.set_preference('homedir', gui.retr('homedir'));
    gui.set_preference('pathname', gui.retr('pathname'));
end

%% data of the window: back to the start state
% read at a new start from the preferences (stored above or when they were changed), or not part of
% the session (parallel pool, batch mode of a script)
keep = {'homedir', 'pathname', 'darkmode', 'panelwidth', 'quickwidth', 'parallel', 'batchModeActive'};
kept = struct();
for k = 1:numel(keep)
    kept.(keep{k}) = getappdata(hgui, keep{k});
end
current = fieldnames(getappdata(hgui));
for k = 1:numel(current)
    if ~isfield(startup, current{k}) && ~strcmp(current{k}, 'startup_appdata')
        rmappdata(hgui, current{k});
    end
end
names = fieldnames(startup);
for k = 1:numel(names)
    setappdata(hgui, names{k}, startup.(names{k}));
end
for k = 1:numel(keep)
    setappdata(hgui, keep{k}, kept.(keep{k}));
end
% image acquisition: the start applied the settings stored at the last close (gui.apply_last_acquisition_settings);
% the reset gives the defaults (no camera window settings, no remembered serial port)
acquisition_data = {'camera_settings', 'pending_popup_texts', 'selected_com_port'};
for k = 1:numel(acquisition_data)
    if isappdata(hgui, acquisition_data{k})
        rmappdata(hgui, acquisition_data{k});
    end
end

%% controls, axes and window: made again as at the start (see PIVlab_GUI)
try
    if ~isMATLABReleaseOlderThan("R2025a") && isMATLABReleaseOlderThan("R2025b")
        gui.reset_GUI_sizing
    end
catch
end
zoom(hgui, 'off');
pan(hgui, 'off');
gui.destroyUI
% axes, colour bars, legends; the annotation layer that MATLAB creates stays (only its content goes)
others = findall(hgui, '-depth', 1, '-not', 'Type', 'figure', '-not', 'Type', 'uimenu', '-not', 'Type', 'annotationpane');
delete(others);
panes = findall(hgui, 'Type', 'annotationpane');
for k = 1:numel(panes)
    delete(panes(k).Children);
end
set(hgui, 'WindowButtonDownFcn', '', 'WindowButtonMotionFcn', '', 'WindowButtonUpFcn', '', ...
    'WindowScrollWheelFcn', '', 'WindowKeyPressFcn', '', 'WindowKeyReleaseFcn', '', 'KeyReleaseFcn', '', ...
    'Pointer', 'arrow', 'Name', ['PIVlab ' gui.retr('PIVver')]);
gui.generateUI
gui.put('num_handle_calls', 0); % fresh handles of the new controls (the image acquisition panel with its defaults)
gui.update_dependent_controls
% 'ui_default_visibility' stays the one of the start: the menus are not made again, and Basic mode may have
% hidden some of them (gui.apply_ui_mode restores them from it)
pivlab_axis = axes('units', 'characters', 'parent', hgui);
axis(pivlab_axis, 'image');
set(pivlab_axis, 'ActivePositionProperty', 'outerposition');
gui.put('pivlab_axis', pivlab_axis);
try
    if ~isMATLABReleaseOlderThan("R2025a") && isMATLABReleaseOlderThan("R2025b")
        gui.fix_R2025a_GUI_sizing
    end
catch
end
gui.MainWindow_ResizeFcn(hgui)
gui.displogo(1);
gui.apply_ui_mode(gui.get_preference('ui_mode', 'advanced'));
gui.toolsavailable(0) % as at the start: remembers the disabled controls of the new window ...
show_parallel_state
gui.toolsavailable(1) % ... and enables the others and the menus again
gui.switchui('multip01');
% GUI data (guidata) as after the start: destroyUI and generateUI stored the handles that existed then
setappdata(hgui, 'UsedByGUIData_m', startup.UsedByGUIData_m);
drawnow
end

function show_parallel_state
% icon of the parallel processing switch (as at the start)
load(fullfile('images', 'icons.mat'), 'parallel_off', 'parallel_on');
if gui.retr('darkmode')
    parallel_on = 1 - parallel_on + 35/255;
    parallel_off = 1 - parallel_off + 35/255;
    parallel_on(parallel_on > 1) = 1;
    parallel_off(parallel_off > 1) = 1;
end
handles = gui.gethand;
if gui.retr('parallel') == 1
    set(handles.toggle_parallel, 'cdata', parallel_on, 'TooltipString', 'Parallel processing on. Click to turn off.');
else
    set(handles.toggle_parallel, 'cdata', parallel_off, 'TooltipString', 'Parallel processing off. Click to turn on.');
end
end
