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

%% Particle image generation
flow = get(handles.flow_sim, 'Value');
show(handles.rankinepanel, flow == 1);
show(handles.oseenpanel, flow == 2);
show(handles.shiftpanel, flow == 3);
show(handles.rotationpanel, flow == 4);
rankine_pair = get(handles.singledoublerankine, 'Value') == 2;
show([handles.rankx2 handles.ranky2 handles.text102 handles.text103 handles.text104], rankine_pair);
oseen_pair = get(handles.singledoubleoseen, 'Value') == 2;
show([handles.oseenx2 handles.oseeny2 handles.text110 handles.text111 handles.text112], oseen_pair);

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
