function update_dependent_controls(handles)
% Sets Enable / Visible of all controls that depend on the value of a setting (and the texts
% that only show a value derived from a setting). It only reads the current values: no dialogs,
% no data changes, no redraw, no hardware. It can be called any number of times and always
% gives the same result, so after loading settings it does not matter in which order the
% values were set. Value couplings (e.g. ticking pass 4 also ticks pass 2 and 3) stay in the
% callbacks of the controls: they only happen when the user clicks.
% In Basic mode, the elements hidden by Basic mode are hidden again at the end.
if nargin < 1
    handles = gui.gethand;
end

%% PIV settings
algorithm = get(handles.algorithm_selection, 'Value');
is_fft = algorithm == 1;
is_ensemble = algorithm == 2;
is_ofv = algorithm == 4;
show(handles.uipanel42, is_fft || is_ensemble);          % passes 2-4
show(handles.uipanel41, ~is_ofv);                        % pass 1
show(handles.correlation_robustness, is_fft || is_ensemble);
show(handles.text914, is_fft || is_ensemble);
show(handles.disable_autocorrelation, is_fft || is_ensemble);
show(handles.AnalyzeSingle, ~is_ensemble);
show(handles.Settings_Apply_current, ~is_ensemble);
show(handles.text14, ~is_ofv);
show(handles.subpixel_estimator, ~is_ofv);
show(handles.uipanel_ofv1, is_ofv);
show(handles.uipanel_ofv2, is_ofv);
show(handles.textSuggest, ~is_ofv);
show(handles.SuggestSettings, true);
show(handles.uncertainty_enable, is_fft);
show([handles.text_parallelpatches handles.ofv_parallelpatches], isequal(gui.retr('parallel'), 1)); % optical flow patches: parallel processing only

pass2 = get(handles.pass2_enable, 'Value') == 1;
enable(handles.pass2_size, pass2);
enable(handles.pass3_size, get(handles.pass3_enable, 'Value') == 1);
enable(handles.pass4_size, get(handles.pass4_enable, 'Value') == 1);
repeat_possible = pass2 && ~is_ensemble;
enable(handles.repeat_last_enable, repeat_possible);
enable(handles.repeat_last_threshold, repeat_possible && get(handles.repeat_last_enable, 'Value') == 1);
set(handles.pass2_step, 'String', half_of(handles.pass2_size));
set(handles.pass3_step, 'String', half_of(handles.pass3_size));
set(handles.pass4_step, 'String', half_of(handles.pass4_size));
piv.overlappercent % overlap of the pass 1 windows in %

%% Vector validation
set(handles.interpol_missing2, 'Value', get(handles.interpol_missing, 'Value')); % shows the same setting

%% Calibration: the axis directions and offsets need a reference distance
enable(findobj(handles.uipanel_offsets, 'Type', 'uicontrol'), ~isempty(gui.retr('pointscali')));

%% Derive parameters
enable(handles.mapscale_min, get(handles.autoscaler, 'Value') == 0);
enable(handles.mapscale_max, get(handles.autoscaler, 'Value') == 0);
smooth_mode = get(handles.smooth_mode, 'Value');
show(handles.temporal_window, smooth_mode == 3 || smooth_mode == 4);
show(handles.text_temporal_window, smooth_mode == 3 || smooth_mode == 4);
is_lic = get(handles.derivchoice, 'Value') == 10;
show(handles.LIChint1, is_lic);
show(handles.LIChint2, is_lic);
show(handles.licres, is_lic);
set(handles.LIChint2, 'String', num2str(round(get(handles.licres, 'Value') * 10) / 10));
derivatives = get(handles.derivchoice, 'String');
if iscell(derivatives) % before results exist, the list is just 'N/A'
    unit = derivatives{get(handles.derivchoice, 'Value')};
    unit = unit(strfind(unit, '['):end);
    set(handles.text39, 'String', ['min ' unit ':']);
    set(handles.text40, 'String', ['max ' unit ':']);
end

%% Plot appearance
enable(handles.vectorscale, get(handles.autoscale_vec, 'Value') == 0);

%% Image masking
expert = get(handles.mask_basic_expert, 'Value') == 2;
show(handles.uipanel25_1, ~expert);
show(handles.uipanel25_9, ~expert);
show(handles.uipanel25_2, expert);
show(handles.uipanel25_10, ~expert);
generator = get(handles.mask_bright_or_dark, 'Value');
show(handles.uipanel25_3, generator == 1);
show(handles.uipanel25_5, generator == 2);
show(handles.uipanel25_7, generator == 3);
bright = [handles.mask_medfilt_enable handles.median_size handles.binarize_threshold ...
    handles.mask_imopen_imclose_enable handles.imopen_imclose_size handles.mask_imdilate_imerode_enable ...
    handles.imopen_imclose_selection handles.imdilate_imerode_size handles.imdilate_imerode_selection ...
    handles.mask_remove_enable handles.remove_size handles.mask_fill_enable];
enable(bright, get(handles.binarize_enable, 'Value') == 1);
dark = [handles.mask_medfilt_enable_2 handles.median_size_2 handles.binarize_threshold_2 ...
    handles.mask_imopen_imclose_enable_2 handles.imopen_imclose_size_2 handles.mask_imdilate_imerode_enable_2 ...
    handles.imopen_imclose_selection_2 handles.imdilate_imerode_size_2 handles.imdilate_imerode_selection_2 ...
    handles.mask_remove_enable_2 handles.remove_size_2 handles.mask_fill_enable_2];
enable(dark, get(handles.binarize_enable_2, 'Value') == 1);
low_contrast = [handles.low_contrast_mask_threshold_suggest handles.mask_medfilt_enable_3 handles.median_size_3 ...
    handles.low_contrast_mask_threshold handles.mask_imopen_imclose_enable_3 handles.imopen_imclose_size_3 ...
    handles.mask_imdilate_imerode_enable_3 handles.imopen_imclose_selection_3 handles.imdilate_imerode_size_3 ...
    handles.imdilate_imerode_selection_3 handles.mask_remove_enable_3 handles.remove_size_3 handles.mask_fill_enable_3];
enable(low_contrast, get(handles.low_contrast_mask_enable, 'Value') == 1);

%% Extraction
enable(handles.extraction_choice, get(handles.draw_what, 'Value') ~= 3);

%% Image export
formats = get(handles.export_still_or_animation, 'String');
if iscell(formats) && numel(formats) >= get(handles.export_still_or_animation, 'Value')
    format = formats{get(handles.export_still_or_animation, 'Value')};
    if any(strcmp(format, {'PNG', 'JPG', 'PDF', 'Matlab Figure', 'Archival AVI', 'MPEG-4'})) % not the placeholder 'Please wait...'
        enable(handles.quality_setting, strcmp(format, 'MPEG-4'));
        enable(handles.fps_setting, any(strcmp(format, {'Archival AVI', 'MPEG-4'})));
        enable(handles.resolution_setting, any(strcmp(format, {'PNG', 'JPG', 'PDF'})));
    end
end

%% Particle image generator: setup, settings page, camera 2, parameters of the flow type
page = get(handles.sim3d_page, 'Value');
show(handles.sim3d_page1, page == 1);
show(handles.sim3d_page2, page == 2);
setup3d = get(handles.sim3d_setup, 'Value'); % 1 simple, 2 one camera, 3 two cameras
simple = setup3d == 1;
show(handles.sim3d_simple, simple);
show([handles.sim3d_cams handles.sim3d_boardinfo], ~simple);
enable([handles.sim3d_sheet_offset handles.sim3d_sheet_tiltx handles.sim3d_sheet_tilty handles.sim3d_ncalib handles.sim3d_preview], ~simple);
camera2 = [handles.sim3d_c2x handles.sim3d_c2y handles.sim3d_c2z handles.sim3d_c2ax handles.sim3d_c2ay ...
    handles.sim3d_c2k1 handles.sim3d_c2k2 handles.sim3d_cam2_title];
enable(camera2, setup3d == 3);
if simple
    set(handles.sim3d_sheetpanel, 'Title', 'Light sheet');
    set(handles.sim3d_pairs_text, 'String', 'Image pairs:');
    set(handles.sim3d_outputinfo, 'String', ['Particle image pairs (particle_images), ground_truth.mat (U, V, W in mm and ' ...
        'in px) and README.txt. The images are loaded into PIVlab.']);
else
    set(handles.sim3d_sheetpanel, 'Title', 'Light sheet (relative to the board)');
    set(handles.sim3d_pairs_text, 'String', 'Image pairs per camera:');
    set(handles.sim3d_outputinfo, 'String', ['Per camera: particle image pairs, calibration images, the board in the ' ...
        'light sheet and the true lens. Plus ground_truth.mat (U, V, W) and README.txt.']);
end
flow3d = simulate.flow_types_3d;
flow3d = flow3d{get(handles.sim3d_flow, 'Value')};
enable(handles.sim3d_radius, any(strcmp(flow3d, {'vortex_jet', 'rankine', 'oseen'})));
enable(handles.sim3d_vortex_distance, any(strcmp(flow3d, {'rankine', 'oseen'})));
if strcmp(flow3d, 'vortex_jet')
    set(handles.sim3d_w_text, 'String', 'Jet: max. out-of-plane [mm]:');
else
    set(handles.sim3d_w_text, 'String', 'Out-of-plane displ. [mm]:');
end
% sphere wake, free jet: the rows of the vortex radius and of w hold the diameter and the time between the pairs
simulation = any(strcmp(flow3d, {'sphere', 'jet'}));
show(handles.sim3d_radius, ~simulation);
show(handles.sim3d_w, ~simulation);
show(handles.sim3d_diameter, simulation);
show(handles.sim3d_pair_time, simulation);
if simulation
    set(handles.sim3d_w_text, 'String', 'Time between pairs [D/U]:');
end
if strcmp(flow3d, 'sphere')
    set(handles.sim3d_displ_text, 'String', 'Free stream displ. [mm]:');
    set(handles.sim3d_radius_text, 'String', 'Sphere diameter [mm]:');
elseif strcmp(flow3d, 'jet')
    set(handles.sim3d_displ_text, 'String', 'Jet displacement [mm]:');
    set(handles.sim3d_radius_text, 'String', 'Jet diameter [mm]:');
else
    set(handles.sim3d_displ_text, 'String', 'In-plane displacement [mm]:');
    set(handles.sim3d_radius_text, 'String', 'Vortex core radius [mm]:');
end

%% Stereo-PIV: camera switch and the menus of camera 2 only in stereo mode
stereo_mode = isequal(gui.retr('stereomode'), 1);
show(handles.stereo_camera_toggle, stereo_mode);
hgui = getappdata(0, 'hgui');
stereo_menus = [findall(hgui, 'Tag', 'menu_camcalib_cam2'); findall(hgui, 'Tag', 'menu_rect_cam2')];
enable(stereo_menus, stereo_mode);
if stereo_mode
    active = gui.retr('stereo_active_camera');
    if isempty(active)
        active = 1;
    end
    [cam_color, cam_text_color] = stereo.camera_colors(active);
    set(handles.stereo_camera_toggle, 'String', ['CAM ' int2str(active)], 'BackgroundColor', cam_color, 'ForegroundColor', cam_text_color);
    set([handles.calib_undist_cam_label handles.calib_rect_cam_label], 'String', ['Current camera: CAMERA ' int2str(active)], 'ForegroundColor', cam_color);
    set(handles.stereo_rect_note, 'ForegroundColor', cam_color);
end
% stereo-PIV rectifies both cameras with the stereo calibration: no 2D rectification and upscaling
show([handles.calib_userectification handles.calib_upscale handles.calib_upscale_label], ~stereo_mode);
show(handles.stereo_rect_note, stereo_mode);
% Statistics panel: w in the histogram list (item 5; items 1-4 as in 2D) and a 3D scatter plot
hist_items = {'u velocity'; 'v velocity'; 'velocity magnitude'; 'sub-pixels'};
if stereo_mode
    hist_items{end + 1, 1} = 'w velocity';
    set(handles.scatterplotter, 'String', 'Scatter plot u, v, w', 'TooltipString', '3D scatter plot of the u, v and w velocities');
else
    set(handles.scatterplotter, 'String', 'Scatter plot u & v', 'TooltipString', 'Scatter plot u vs. v velocities');
end
if ~isequal(get(handles.hist_select, 'String'), hist_items)
    set(handles.hist_select, 'String', hist_items);
    if get(handles.hist_select, 'Value') > numel(hist_items) % w velocity chosen, back in 2D mode
        set(handles.hist_select, 'Value', 1);
    end
    gui.apply_pending_popup(handles.hist_select);
end
% Extraction panels: the w component in the lists only in stereo mode. The lists are filled when a panel
% is opened (extract.update_choice_lists); here only a filled list that does not fit the mode is refreshed.
line_items = get(handles.extraction_choice, 'String');
if iscell(line_items) && startsWith(line_items{end}, 'w component') ~= stereo_mode
    extract.update_choice_lists(handles);
end
% stereo-PIV always undistorts when lens parameters exist (stereo.camera_lens): the switch only changes the display
if stereo_mode
    set(handles.calib_usecalibration, 'String', 'Show undistorted image', 'TooltipString', ...
        ['Display only. Stereo-PIV always undistorts both cameras when lens parameters exist ' ...
        '("Estimate cam parameters" or "Load parameters"), also when this is not ticked.']);
else
    set(handles.calib_usecalibration, 'String', 'Enable camera calibration', 'TooltipString', 'Enable camera calibration / undistortion');
end
enable([handles.stereo_calibrate handles.stereo_show_3d], stereo_mode);
enable([handles.stereo_measure_disparity handles.stereo_disp_show], stereo_mode && ~isempty(gui.retr('stereo_calib')));
if stereo_mode && strcmp(get(handles.multip30, 'Visible'), 'on')
    stereo.update_panel(handles);
end

%% Basic mode hides some of the elements again
if strcmp(gui.retr('ui_mode'), 'basic')
    gui.apply_ui_mode('basic');
end
end

function show(h, tf)
if tf
    set(h, 'Visible', 'on');
else
    set(h, 'Visible', 'off');
end
end

function enable(h, tf)
if tf
    set(h, 'Enable', 'on');
else
    set(h, 'Enable', 'off');
end
end

function s = half_of(edit_field)
s = int2str(str2double(get(edit_field, 'String')) / 2);
end
