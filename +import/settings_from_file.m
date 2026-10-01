function [S, filetype] = settings_from_file(file)
%SETTINGS_FROM_FILE Read the analysis settings stored in a PIVlab settings or session file (no GUI needed).
%   [S, filetype] = import.settings_from_file(file)
%
%   S         struct with the settings under their PIVlab variable names (e.g. clahe_enable,
%             intarea, stdev_thresh, calu, ...). Only variables that exist in the file are returned.
%   filetype  'session'  - PIVlab session (contains resultslist)
%             'settings' - settings file saved with "File -> Save settings" or PIVlab_settings_default.mat
%             'results'  - MAT file exported with "File -> Export -> MAT file" (no settings inside)
%
%   Session files store the calibration distances as realdist_string / time_inp_string, settings
%   files as realdist / time_inp. Both are returned as realdist / time_inp.

if ~isfile(file)
    error('import:settings_from_file:notFound','File not found: %s', file);
end
vars = who('-file', file);
if ismember('resultslist', vars)
    filetype = 'session';
elseif any(ismember({'intarea','clahe_enable','stepsize'}, vars))
    filetype = 'settings';
elseif any(ismember({'u_original','u_filtered','typevector_original'}, vars))
    filetype = 'results';
else
    error('import:settings_from_file:unknownFile', ...
        'The file %s is neither a PIVlab session nor a PIVlab settings file.', file);
end

names = setting_names();
if strcmp(filetype,'session')
    names = [names, {'realdist_string','time_inp_string','roirect','velrect','bg_mode','sequencer', ...
        'masks_in_frame','bg_img_A','bg_img_B','bg_subtract'}];
end
names = intersect(names, vars, 'stable');
if isempty(names)
    S = struct();
else
    S = load(file, names{:});
end
if isfield(S,'realdist_string') && ~isfield(S,'realdist')
    S.realdist = S.realdist_string;
end
if isfield(S,'time_inp_string') && ~isfield(S,'time_inp')
    S.time_inp = S.time_inp_string;
end
S = rmfield(S, intersect(fieldnames(S), {'realdist_string','time_inp_string'}));
end

function n = setting_names()
n = {'clahe_enable','clahe_size','enable_highpass','highp_size','wienerwurst','wienerwurstsize', ...
    'enable_intenscap','Autolimit','minintens','maxintens', ...
    'algorithm_selection','intarea','stepsize','subpix','pass2','pass3','pass4', ...
    'pass2val','pass3val','pass4val','mask_auto_box','CorrQuality_nr','repeat_last','repeat_last_thresh', ...
    'stdev_check','stdev_thresh','loc_median','loc_med_thresh','interpol_missing', ...
    'do_corr2_filter','corr_filter_thresh','notch_filter','notch_L_thresh','notch_H_thresh', ...
    'do_contrast_filter','contrast_filter_thresh','do_bright_filter','bright_filter_thresh', ...
    'calxy','calu','calv','realdist','time_inp','pointscali','x_axis_direction','y_axis_direction', ...
    'offset_x_true','offset_y_true','points_offsetx','points_offsety','size_of_the_image', ...
    'smooth_mode_val','smooth_param_str','temporal_window_str', ...
    'vectorscale','autoscale_vec','nthvect','colormap_choice','colormap_steps','colormap_interpolation', ...
    'enhance_disp','img_not_mask','extrapolate_border', ...
    'valid_color_idx','secondpeak_color_idx','interp_color_idx','deriv_color_idx', ...
    'calib_viewtype','calib_usecalibration','calib_userectification','calib_use_tilted_model'};
end
