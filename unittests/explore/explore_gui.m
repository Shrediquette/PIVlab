function report = explore_gui(seeds, nsteps, keep_open, stereo)
%EXPLORE_GUI Random click sequences in the PIVlab window, with checks after every step.
%   report = explore_gui(seeds, nsteps) runs one sequence of nsteps random actions per seed
%   (default seeds 1:10, nsteps 40) and returns the failures. Every sequence starts a fresh
%   PIVlab window and loads 1-3 image pairs of Example_data. Actions: menu entries, controls of
%   the panels (random values, also wrong ones), buttons, and scripted replacements for the actions
%   that need a file dialog or mouse drawing (export, session, masks, ROI, calibration, extraction).
%   Excluded: cameras / synchronizer, file dialogs, interactive drawing, optical flow (downloads
%   filter matrices), parallel pool.
%   Checks after every step:
%     - no error thrown by the action, no error printed in the Command Window
%     - PIVlab idle: no busy strip, no busy watchdog, menus enabled
%     - result list consistent (sizes of the rows of every analysed frame, derived maps)
%     - the display can be redrawn (gui.sliderdisp)
%   A failing sequence is stopped; report(k) has the seed, the step, the actions so far and the
%   error. explore_gui(report(k).actions) repeats exactly these actions (same checks),
%   explore_gui(report(k).actions, [], true) leaves the PIVlab window open afterwards.
%   explore_gui(seeds, nsteps, false, true): stereo-PIV, every sequence starts with a calibrated
%   synthetic stereo recording (4 pairs, made once in tempdir) and switches cameras instead of
%   loading 2D images.
%   Opens the PIVlab window (steals the focus). Run with: report = explore_gui(1:10, 40)
if nargin < 1
    seeds = 1:10;
end
if nargin < 2 || isempty(nsteps)
    nsteps = 40;
end
if nargin < 3 || isempty(keep_open)
    keep_open = false;
end
if nargin < 4
    stereo = false;
end
replay = iscell(seeds);
if replay
    list = seeds;
    seeds = 0;
end
root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
addpath(root);
addpath(fullfile(root, 'unittests'));
cd(root);
setappdata(0, 'PIVlabTestMode', true);
tmp = fullfile(tempdir, 'pivlab_explore');
if ~isfolder(tmp)
    mkdir(tmp);
end
report = struct('seed', {}, 'step', {}, 'actions', {}, 'problem', {}, 'output', {});
for seed = seeds
    rng(seed, 'twister');
    actions = {};
    first = 'start';
    if stereo || (replay && strcmp(list{1}, 'start_stereo'))
        first = 'start_stereo';
    end
    [ok, problem, out] = run_action(first, tmp);
    actions{end+1} = first; %#ok<AGROW>
    step = 0;
    if replay
        nsteps = numel(list) - 1; % list{1} is 'start'
    end
    while ok && step < nsteps
        step = step + 1;
        if replay
            a = list{step + 1};
        else
            a = pick_action(strcmp(first, 'start_stereo'));
        end
        [ok, problem, out] = run_action(a, tmp);
        actions{end+1} = a; %#ok<AGROW>
        if ok
            [ok, problem, waiting] = check_state(out);
            % PIVlab waits for the user (uneven number of images: only "Remove images" works)
            tries = 0;
            while ok && waiting && tries < 3 && ~replay
                tries = tries + 1;
                a = sprintf('script|remove_images|%f', rand);
                [ok, problem, out] = run_action(a, tmp);
                actions{end+1} = a; %#ok<AGROW>
                if ok
                    [ok, problem, waiting] = check_state(out);
                end
            end
            if ok && waiting && ~replay
                ok = false; problem = 'still waiting for the user after removing 3 more images';
            end
        end
    end
    if ~ok
        report(end+1) = struct('seed', seed, 'step', step, 'actions', {actions}, 'problem', problem, 'output', out); %#ok<AGROW>
        fprintf('seed %d: FAILED at step %d (%s): %s\n', seed, step, actions{end}, problem);
    else
        fprintf('seed %d: %d steps ok\n', seed, nsteps);
    end
    if ~keep_open
        close_extra_figures();
    end
end
if ~keep_open
    helper_close_pivlab();
    rmappdata(0, 'PIVlabTestMode');
end
end

%% ------------------------------------------------------------------ actions

function a = pick_action(stereo)
% action string: kind|detail|random value (the value is drawn here, so a replay is exact)
r = rand;
if r < 0.07 && stereo
    a = sprintf('script|switch_camera|%f', rand); % stereo: no 2D images (would leave stereo mode)
elseif r < 0.07
    a = sprintf('load|%d|%d', randi(3), randi([0 1]));
elseif r < 0.17
    a = sprintf('frame|%f', rand);
elseif r < 0.30
    menus = menu_list();
    a = ['menu|' menus{randi(numel(menus))}];
elseif r < 0.55
    a = sprintf('control|%f|%f', rand, rand);
elseif r < 0.70
    a = sprintf('button|%f', rand);
elseif r < 0.80
    a = sprintf('analyze|%d', randi(3));
else
    s = scripted_list();
    a = sprintf('script|%s|%f', s{randi(numel(s))}, rand);
end
end

function [ok, problem, out] = run_action(a, tmp)
ok = true;
problem = '';
try
    out = evalc('do_action(a, tmp)');
catch ME
    ok = false;
    out = '';
    problem = sprintf('error: %s (%s)', ME.message, stack_string(ME));
    return
end
if contains(out, 'Error') || contains(out, 'error using') || contains(out, 'Error using')
    ok = false;
    problem = 'error message in the Command Window';
end
end

function do_action(a, tmp)
parts = split(a, '|');
kind = parts{1};
hgui = getappdata(0, 'hgui');
switch kind
    case 'start'
        helper_start_pivlab();
        helper_gui_load_images(helper_files('jet', 2));
    case 'start_stereo'
        helper_start_pivlab();
        start_stereo(tmp);
    case 'load'
        helper_gui_load_images(helper_files('jet', str2double(parts{2})), str2double(parts{3}));
    case 'frame'
        h = gui.gethand;
        smax = get(h.fileselector, 'Max');
        smin = get(h.fileselector, 'Min');
        v = round(smin + str2double(parts{2}) * (smax - smin));
        if smax > smin && strcmp(get(h.fileselector, 'Enable'), 'on') % a user cannot move a disabled slider
            set(h.fileselector, 'Value', v);
            gui.fileselector_Callback(h.fileselector, [], []);
        end
    case 'menu'
        call_menu(hgui, parts{2});
    case 'control'
        use_control(str2double(parts{2}), str2double(parts{3}));
    case 'button'
        press_button(str2double(parts{2}));
    case 'analyze'
        h = gui.gethand;
        set(h.update_display_checkbox, 'Value', 0);
        switch str2double(parts{2})
            case 1
                piv.AnalyzeSingle_Callback(h.AnalyzeSingle, []);
            case 2
                piv.AnalyzeAll_Callback(h.AnalyzeAll, []);
            otherwise
                piv.do_analys_Callback([], []);
        end
    case 'script'
        scripted(parts{2}, str2double(parts{3}), tmp);
end
drawnow;
end

function m = menu_list()
m = {'2D particle image generator', 'ANALYZE!', 'All results to Matlab workspace', ...
    'Calibrate using current or external image', 'Correlation matrices', ...
    'Define masks (exclude regions from analysis)', 'Define region of interest (ROI)', ...
    'Image based validation', 'Image pre-processing / enhancement', 'MAT file', ...
    'Markers / distance / angle', 'Modify plot appearance', 'New session', 'PIV settings', ...
    'Parameters from area', 'Parameters from poly-line', 'Paraview binary VTK', ...
    'Spatial: Derive parameters / modify data', 'Statistics', 'Stereo-PIV', 'Still image or animation', ...
    'Streamlines', 'Tecplot file', 'Temporal: Derive parameters', 'Text file (ASCII)', ...
    'Velocity based validation', 'Preferences', 'Camera 1', 'Setup / define / generate marker board', ...
    'Basic', 'Advanced', 'About'};
end

function call_menu(hgui, text)
m = findall(hgui, 'Type', 'uimenu', 'Text', text);
if isempty(m)
    return
end
m = m(1);
cb = m.MenuSelectedFcn;
if isempty(cb)
    cb = m.Callback;
end
if isempty(cb)
    return
end
if iscell(cb)
    feval(cb{1}, m, [], cb{2:end});
else
    feval(cb, m, []);
end
end

function use_control(r1, r2)
% a control (edit, checkbox, popupmenu, slider) of the visible panel or of the settings panels
c = controls();
if isempty(c)
    return
end
k = c(1 + floor(r1 * numel(c)));
switch k.Style
    case 'edit'
        vals = {'', 'abc', '-1', '0', '0.5', '1', '2', '3', '8', '16', '32', '64', '100', '1e5', 'NaN'};
        set(k, 'String', vals{1 + floor(r2 * numel(vals))});
    case 'checkbox'
        set(k, 'Value', 1 - get(k, 'Value'));
    case 'popupmenu'
        n = numel(cellstr(get(k, 'String')));
        v = 1 + floor(r2 * n);
        if strcmp(k.Tag, 'algorithm_selection') && v == 4
            v = 1; % optical flow downloads the filter matrices
        end
        if strcmp(k.Tag, 'mask_bright_or_dark') && v == 4
            v = 1; % custom script: file dialog
        end
        set(k, 'Value', v);
    case 'slider'
        set(k, 'Value', get(k, 'Min') + r2 * (get(k, 'Max') - get(k, 'Min')));
end
cb = k.Callback;
if ~isempty(cb)
    if iscell(cb)
        feval(cb{1}, k, [], cb{2:end});
    else
        feval(cb, k, []);
    end
end
end

function c = controls()
h = gui.gethand;
panels = {'multip02', 'multip25', 'multip03', 'multip04', 'multip06', 'multip07', 'multip08', 'multip09', ...
    'multip12', 'multip13', 'multip14', 'multip16', 'multip17', 'multip18', 'multip22', 'multip23', ...
    'multip26', 'multip27', 'multip28', 'multip29', 'multip30'};
c = gobjects(0);
for p = 1:numel(panels)
    if ~isfield(h, panels{p}) || ~strcmp(get(h.(panels{p}), 'Visible'), 'on')
        continue % only what a user can click: the panel that is shown
    end
    k = findobj(h.(panels{p}), 'Type', 'uicontrol');
    for i = 1:numel(k)
        s = k(i).Style;
        if any(strcmp(s, {'edit', 'checkbox', 'popupmenu', 'slider'})) && clickable(k(i)) && ~blocked(k(i))
            c(end+1) = k(i); %#ok<AGROW>
        end
    end
end
end

function tf = clickable(k)
% enabled and visible, also all parents (sub-panels can be hidden)
tf = strcmp(k.Enable, 'on') && strcmp(k.Visible, 'on');
p = k.Parent;
while tf && ~isa(p, 'matlab.ui.Figure')
    tf = strcmp(p.Visible, 'on');
    p = p.Parent;
end
end

function press_button(r)
h = gui.gethand;
panels = {'multip01', 'multip02', 'multip25', 'multip03', 'multip04', 'multip05', 'multip06', 'multip07', ...
    'multip08', 'multip12', 'multip13', 'multip14', 'multip17', 'multip18', 'multip22', ...
    'multip23', 'multip26', 'multip27', 'multip29', 'multip30'};
b = gobjects(0);
for p = 1:numel(panels)
    if ~strcmp(get(h.(panels{p}), 'Visible'), 'on')
        continue
    end
    k = findobj(h.(panels{p}), 'Type', 'uicontrol', 'Style', 'pushbutton');
    for i = 1:numel(k)
        if ~isempty(k(i).Callback) && clickable(k(i)) && ~blocked(k(i))
            b(end+1) = k(i); %#ok<AGROW>
        end
    end
end
if clickable(h.togglepair)
    b(end+1) = h.togglepair;
end
if isempty(b)
    return
end
k = b(1 + floor(r * numel(b)));
if k == h.togglepair
    set(k, 'Value', 1 - get(k, 'Value'));
end
cb = k.Callback;
if iscell(cb)
    feval(cb{1}, k, [], cb{2:end});
else
    feval(cb, k, []);
end
end

function tf = blocked(k)
% callbacks with a file dialog, mouse drawing, hardware, downloads or other windows
cb = k.Callback;
if isempty(cb)
    tf = false;
    return
end
if iscell(cb)
    cb = cb{1};
end
if isa(cb, 'function_handle')
    name = func2str(cb);
else
    name = char(cb);
end
bad = {'acquisition.', 'pivlabmanual', 'load_session', 'convertvideobutton', 'stereo_import', 'loadimgsbutton', ...
    'roi.select', 'mask.load', 'mask.save', 'mask.import', 'mask.add', 'export.', 'bg_load', 'bg_save', ...
    'SuggestPIVsettings', 'rejectsingle', 'vel_limit_Callback', 'draw_line', 'load_ext_img', 'set_offset', ...
    'save_data', 'load_polyline', 'save_polyline', 'draw_extraction', 'putmarkers', 'set_points', 'save_imgs', ...
    'drawstreamlines', 'streamrake', 'test_sync', 'flash_sync', 'phase_mean', 'loadimages', 'loadparams', ...
    'saveparams', 'generateboard', 'find_charuco', 'toggle_parallel', 'change_theme', 'cancelbutt'};
tf = false;
for i = 1:numel(bad)
    if contains(name, bad{i})
        tf = true;
        return
    end
end
end

function s = scripted_list()
s = {'roi', 'roi_clear', 'mask_rect', 'mask_clear', 'calibrate', 'calibrate_clear', 'extract_line', ...
    'extract_circle', 'extract_area', 'export', 'session', 'reset', 'remove_images', 'temporal_mean', ...
    'remove_temporal', 'derive_all', 'velocity_limits', 'stereo_button', 'statistics'};
end

function scripted(what, r, tmp)
h = gui.gethand;
sz = gui.retr('expected_image_size');
if isempty(sz)
    sz = [1040 1392];
end
frame = floor(get(h.fileselector, 'Value'));
switch what
    case 'roi'
        w = round(64 + r * (sz(2) - 70));
        hh = round(64 + (1 - r) * (sz(1) - 70));
        set(h.ROI_Man_x, 'String', '10'); set(h.ROI_Man_y, 'String', '20');
        set(h.ROI_Man_w, 'String', int2str(w)); set(h.ROI_Man_h, 'String', int2str(hh));
        roi.Man_ROI_Callback(h.ROI_Man_x, []);
    case 'roi_clear'
        roi.clear_roi_Callback([], []);
    case 'mask_rect'
        % like a rectangle drawn with mask.add_Callback (same columns: type, position, colour, label, tag)
        ax = gui.retr('pivlab_axis');
        roiobj = images.roi.Rectangle(ax, 'Position', [100 + r * 500, 100, 200, 150]);
        roiobj.UserData = 'ROI_object_rectangle';
        roiobj.Color = [0 0.45 0.74];
        roiobj.Tag = sprintf('explore_%d', round(1e6 * r));
        m = mask.update_mask_memory(roiobj, frame, gui.retr('masks_in_frame'));
        delete(roiobj);
        gui.put('masks_in_frame', m);
        gui.sliderdisp(ax);
    case 'mask_clear'
        mask.delete_all_Callback([], []);
    case 'calibrate'
        gui.put('pointscali', [10 10; 110 + 300 * r 10]);
        set(h.realdist, 'String', '10');
        set(h.time_inp, 'String', num2str(round(10 * r)));
        calibrate.apply_cali_Callback([], []);
    case 'calibrate_clear'
        calibrate.clear_cali_Callback([], []);
    case 'extract_line'
        extract.poly_extract_Callback([], []);
        gui.put('extract_type', 'extract_poly');
        gui.put('xposition', [100; 600 + 300 * r]); gui.put('yposition', [100; 700]);
        gui.sliderdisp(gui.retr('pivlab_axis'));
        extract.plot_data_Callback(h.plot_data, []);
    case 'extract_circle'
        extract.poly_extract_Callback([], []);
        if r < 0.5
            gui.put('extract_type', 'extract_circle');
        else
            gui.put('extract_type', 'extract_circle_series');
        end
        gui.put('xposition', [700 500]); gui.put('yposition', 50 + 200 * r);
        gui.sliderdisp(gui.retr('pivlab_axis'));
        extract.plot_data_Callback(h.plot_data, []);
    case 'extract_area'
        extract.area_panel_activation_Callback([], []);
        types = {'extract_rectangle_area', 'extract_circle_area', 'extract_circle_series_area', 'extract_poly_area'};
        t = types{1 + floor(r * 4)};
        gui.put('extract_type', t);
        switch t
            case 'extract_rectangle_area'
                gui.put('xposition', [200 400]); gui.put('yposition', [200 300]);
            case 'extract_poly_area'
                gui.put('xposition', [200; 600; 400]); gui.put('yposition', [200; 250; 600]);
            otherwise
                gui.put('xposition', [700 500]); gui.put('yposition', 50 + 200 * r);
        end
        extract.area_panel_activation_Callback([], []);
        extract.plot_data_area_Callback([], []);
    case 'export'
        % like the export buttons: only when the frame has a result
        rl = gui.retr('resultslist');
        if size(rl, 2) >= frame && numel(rl{1, frame}) > 0
            types = [1 2 3 4];
            t = types(1 + floor(r * 4));
            export.file_save(frame, sprintf('explore_%d.out', t), tmp, t);
        end
    case 'session'
        export.save_session_function(tmp, 'explore_session.mat');
        import.load_session_Callback(1, fullfile(tmp, 'explore_session.mat'));
    case 'reset'
        stereo_before = isequal(gui.retr('stereomode'), 1);
        gui.reset_gui_Callback([], []);
        if stereo_before
            start_stereo(tmp);
        else
            helper_gui_load_images(helper_files('jet', 2));
        end
    case 'switch_camera'
        if isequal(gui.retr('stereomode'), 1)
            stereo.switch_camera(1 + (r >= 0.5));
        end
    case 'remove_images'
        n = numel(get(h.filenamebox, 'String'));
        if n > 2
            set(h.filenamebox, 'Value', 1 + floor(r * n));
            import.remove_images_from_list([], []);
        end
    case 'temporal_mean'
        % mean, sum, stdev or TKE button of the temporal panel
        plot.temporal_derivs_Callback([], []);
        k = findobj(h.multip22, 'Style', 'pushbutton');
        b = gobjects(0);
        for i = 1:numel(k)
            cb = k(i).Callback;
            if iscell(cb)
                cb = cb{1};
            end
            if contains(func2str(cb), 'temporal_operation')
                b(end+1) = k(i); %#ok<AGROW>
            end
        end
        b = b(1 + floor(r * numel(b)));
        cb = b.Callback;
        if iscell(cb)
            feval(cb{1}, b, [], cb{2:end});
        else
            feval(cb, b, []);
        end
    case 'remove_temporal'
        plot.remove_temporal_frame_Callback([], []);
    case 'derive_all'
        plot.derivs_Callback([], []);
        n = numel(cellstr(get(h.derivchoice, 'String')));
        set(h.derivchoice, 'Value', 1 + floor(r * n));
        plot.derivchoice_Callback(h.derivchoice, []);
        plot.apply_deriv_all_Callback([], []);
    case 'velocity_limits'
        gui.put('velrect', [-2 + r, -2, 4, 4]);
        validate.apply_filter_all_Callback([], []);
    case 'stereo_button'
        stereo.panel_Callback([], []);
    case 'statistics'
        plot.statistics_Callback([], []);
        plot.histdraw_Callback([], []);
end
end

function start_stereo(tmp)
% calibrated synthetic stereo recording (made once, then reused)
folder = fullfile(tmp, 'stereo_case');
cachefile = fullfile(folder, 'case.mat');
if isfile(cachefile)
    c = load(cachefile);
    c = c.c;
else
    c = helper_stereo_synthetic_case(folder, 4, 0);
    save(cachefile, 'c');
end
if isempty(getappdata(0, 'hgui')) || ~ishandle(getappdata(0, 'hgui'))
    helper_start_pivlab();
end
h = gui.gethand;
gui.put('sequencer', 1);
import.stereo_import_Callback([], [], {c.files{1}, c.files{2}});
for k = 1:2
    stereo.switch_camera(k);
    gui.put('cameraParams', c.lens{k});
    gui.put('cam_selected_rectification_image', c.boards{k});
end
stereo.switch_camera(1);
set(h.calib_rows, 'String', int2str(c.board.PatternDims(1)));
set(h.calib_columns, 'String', int2str(c.board.PatternDims(2)));
set(h.calib_checkersize, 'String', num2str(c.board.CheckerSize));
set(h.calib_markersize, 'String', num2str(c.board.MarkerSize));
set(h.calib_origincolor, 'Value', 1);
stereo.calibrate_Callback;
end

%% ------------------------------------------------------------------ checks

function [ok, problem, waiting] = check_state(~)
ok = true;
problem = '';
waiting = false;
hgui = getappdata(0, 'hgui');
if isempty(hgui) || ~ishandle(hgui)
    ok = false; problem = 'PIVlab window closed';
    return
end
if ~isempty(gui.retr('busy_since')) || ~isempty(timerfindall('Tag', 'PIVlab_busy_watchdog'))
    ok = false; problem = 'PIVlab still marked as busy (busy_since / watchdog) after the action';
    return
end
if ~isempty(findobj(hgui, 'Tag', 'busyhint'))
    % strip without busy time: PIVlab waits for the user on purpose (gui.toolsavailable(0,msg,true))
    waiting = true;
    return
end
menus = findall(hgui, 'Type', 'uimenu');
enabled = 0;
for i = 1:numel(menus)
    if strcmp(menus(i).Enable, 'on')
        enabled = enabled + 1;
    end
end
if enabled < numel(menus) / 2
    ok = false; problem = sprintf('controls locked: only %d of %d menus enabled', enabled, numel(menus));
    return
end
% result list
rl = gui.retr('resultslist');
filepath = gui.retr('filepath');
nframes = size(filepath, 1) / 2;
if size(rl, 2) > nframes + 0.5 && ~isempty(filepath)
    ok = false; problem = sprintf('result list has %d frames, the image list %g', size(rl, 2), nframes);
    return
end
for f = 1:size(rl, 2)
    if isempty(rl{1, f})
        continue
    end
    sz = size(rl{1, f});
    rows = [2 3 4 5 7 8 9];
    for r = rows
        if r <= size(rl, 1) && ~isempty(rl{r, f}) && ~isequal(size(rl{r, f}), sz)
            ok = false; problem = sprintf('result list frame %d: row %d is %s, x is %s', f, r, mat2str(size(rl{r, f})), mat2str(sz));
            return
        end
    end
end
derived = gui.retr('derived');
for f = 1:min(size(derived, 2), size(rl, 2))
    for q = 1:size(derived, 1)
        d = derived{q, f};
        if ~isempty(d) && ~isempty(rl{1, f}) && q ~= 9 && ~isequal(size(d), size(rl{1, f}))
            ok = false; problem = sprintf('derived parameter %d of frame %d is %s, the vectors are %s', q + 1, f, mat2str(size(d)), mat2str(size(rl{1, f})));
            return
        end
    end
end
% redraw
try
    out = evalc('gui.sliderdisp(gui.retr(''pivlab_axis'')); drawnow;');
catch ME
    ok = false; problem = sprintf('display redraw failed: %s (%s)', ME.message, stack_string(ME));
    return
end
if contains(out, 'Error')
    ok = false; problem = 'error message in the Command Window during the redraw';
end
end

function s = stack_string(ME)
s = '';
for i = 1:min(3, numel(ME.stack))
    s = [s sprintf('%s:%d ', ME.stack(i).name, ME.stack(i).line)]; %#ok<AGROW>
end
end

function close_extra_figures()
hgui = getappdata(0, 'hgui');
f = findall(groot, 'Type', 'figure');
for i = 1:numel(f)
    if ~isequal(f(i), hgui)
        delete(f(i));
    end
end
end
