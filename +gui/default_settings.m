function default = default_settings
% The default values of all PIVlab settings, grouped like the settings file.
% A setting is every edit field, checkbox, popup menu, list box, slider and toggle button that
% gui.generateUI creates (unless marked 'UserData','not_a_setting'). The field name is the
% Tag of the control; the group decides what "Load settings" changes.
% Types (the type of a setting is the type of its default value here):
%   edit field with a number: number (the field shows gui.setting_text(value))
%   edit field with text (e.g. '1:end'): char
%   checkbox, slider, toggle button, popup menu: number (Value)
% gui.generateUI creates the controls with these values; the command-line API uses them too.

%% analysis (pre-processing, PIV settings, data smoothing, vector validation, image based validation)
% Input data
default.analysis.stereocheckbox = 0;
% Image pre-processing
default.analysis.clahe_enable = 1;
default.analysis.clahe_size = 64;
default.analysis.highpass_enable = 0;
default.analysis.highpass_size = 15;
default.analysis.intenscap_enable = 0;
default.analysis.wiener_enable = 0;
default.analysis.wiener_size = 3;
default.analysis.autolimit_enable = 1;
default.analysis.minintens = 0;
default.analysis.maxintens = 1;
default.analysis.bg_subtract = 1;
% PIV settings
default.analysis.algorithm_selection = 1;
default.analysis.ofv_parallelpatches = 6;
default.analysis.ofv_median = 1;
default.analysis.ofv_pyramid_levels = 3;
default.analysis.ofv_eta = 40;
default.analysis.pass1_size = 64;
default.analysis.pass1_step = 32;
default.analysis.pass2_enable = 1;
default.analysis.pass2_size = 32;
default.analysis.pass3_enable = 0;
default.analysis.pass3_size = 32;
default.analysis.pass4_enable = 0;
default.analysis.pass4_size = 32;
default.analysis.repeat_last_enable = 0;
default.analysis.repeat_last_threshold = 0.025;
default.analysis.subpixel_estimator = 1;
default.analysis.disable_autocorrelation = 0;
default.analysis.correlation_robustness = 1;
default.analysis.uncertainty_enable = 0;
% Vector validation
default.analysis.stdev_enable = 1;
default.analysis.stdev_thresh = 8;
default.analysis.loc_median_enable = 1;
default.analysis.loc_med_thresh = 3;
default.analysis.notch_enable = 0;
default.analysis.notch_L_thresh = -1;
default.analysis.notch_H_thresh = 1;
default.analysis.interpol_missing = 1;
% Derive parameters
default.analysis.smooth_mode = 1;
default.analysis.smooth_param = 0.2;
default.analysis.temporal_window = 2;
default.analysis.extrapolate_border = 0;
% Image based validation
default.analysis.contrast_filter_enable = 0;
default.analysis.contrast_filter_thresh = 0;
default.analysis.bright_filter_enable = 0;
default.analysis.bright_filter_thresh = 1;
default.analysis.corr_filter_enable = 0;
default.analysis.corr_filter_thresh = 0.5;

%% calibration (calibration, camera calibration, rectification, marker board)
% Calibration
default.calibration.optimize_calib_img = 1;
default.calibration.realdist = 1;
default.calibration.time_inp = 1;
default.calibration.x_axis_direction = 1;
default.calibration.y_axis_direction = 1;
% Camera calibration
default.calibration.calib_use_tilted_model = 0;
default.calibration.calib_viewtype = 1;
default.calibration.calib_usecalibration = 0;
% Image rectification
default.calibration.calib_upscale = 1;
default.calibration.calib_userectification = 0;
% Marker board setup
default.calibration.calib_boardtype = 1;
default.calibration.calib_origincolor = 1;
default.calibration.calib_rows = 10;
default.calibration.calib_columns = 18;
default.calibration.calib_checkersize = 12;
default.calibration.calib_markersize = 9;

%% masks (mask generator settings (not the masks themselves))
% Image masking
default.masks.mask_basic_expert = 1;
default.masks.mask_bright_or_dark = 1;
default.masks.binarize_enable = 0;
default.masks.binarize_threshold = 0.8;
default.masks.mask_medfilt_enable = 0;
default.masks.median_size = 5;
default.masks.mask_imopen_imclose_enable = 0;
default.masks.imopen_imclose_selection = 1;
default.masks.imopen_imclose_size = 5;
default.masks.mask_imdilate_imerode_enable = 0;
default.masks.imdilate_imerode_selection = 1;
default.masks.imdilate_imerode_size = 5;
default.masks.mask_remove_enable = 0;
default.masks.remove_size = 1000;
default.masks.mask_fill_enable = 0;
default.masks.binarize_enable_2 = 0;
default.masks.binarize_threshold_2 = 0.01;
default.masks.mask_medfilt_enable_2 = 0;
default.masks.median_size_2 = 5;
default.masks.mask_imopen_imclose_enable_2 = 0;
default.masks.imopen_imclose_selection_2 = 1;
default.masks.imopen_imclose_size_2 = 5;
default.masks.mask_imdilate_imerode_enable_2 = 0;
default.masks.imdilate_imerode_selection_2 = 1;
default.masks.imdilate_imerode_size_2 = 5;
default.masks.mask_remove_enable_2 = 0;
default.masks.remove_size_2 = 1000;
default.masks.mask_fill_enable_2 = 0;
default.masks.low_contrast_mask_enable = 0;
default.masks.low_contrast_mask_threshold = 0.01;
default.masks.mask_medfilt_enable_3 = 0;
default.masks.median_size_3 = 5;
default.masks.mask_imopen_imclose_enable_3 = 0;
default.masks.imopen_imclose_selection_3 = 1;
default.masks.imopen_imclose_size_3 = 5;
default.masks.mask_imdilate_imerode_enable_3 = 0;
default.masks.imdilate_imerode_selection_3 = 1;
default.masks.imdilate_imerode_size_3 = 5;
default.masks.mask_remove_enable_3 = 0;
default.masks.remove_size_3 = 1000;
default.masks.mask_fill_enable_3 = 0;
default.masks.mask_copy_frames = '1:end';
default.masks.mask_clear_frames = '1:end';

%% display (derived parameter display, plot appearance, markers, statistics, stream lines)
% Analyze
default.display.update_display_checkbox = 0;
% Vector validation
default.display.scatter_all_frames = 1;
% Derive parameters
default.display.derivchoice = 1;
default.display.licres = 0.7;
default.display.subtr_u = 0;
default.display.subtr_v = 0;
default.display.autoscaler = 1;
default.display.mapscale_min = -1;
default.display.mapscale_max = 1;
default.display.highp_vectors = 0;
default.display.highpass_strength = 30;
% Modify plot appearance
default.display.autoscale_vec = 0;
default.display.vectorscale = 5;
default.display.vecwidth = 0.5;
default.display.nthvect = 1;
default.display.suppress_vec = 0;
default.display.masktransp = 50;
default.display.uniform_vector_scale = 0;
default.display.power_vector_scale = 0;
default.display.power_vector_scale_factor = 0.3;
default.display.displ_image = 1;
default.display.valid_color = 1;
default.display.secondpeak_color = 2;
default.display.interp_color = 3;
default.display.deriv_color = 4;
default.display.colormapopacity = 75;
default.display.colormap_choice = 1;
default.display.colormap_steps = 1;
default.display.colormap_interpolation = 1;
default.display.img_not_mask = 0;
default.display.colorbarpos = 1;
default.display.colorbarnumberformat = 1;
default.display.ref_vect_scl = 1;
default.display.ref_vect_pos = 1;
default.display.enhance_images = 0;
% Measure distance & angle
default.display.holdmarkers = 0;
default.display.displmarker = 0;
% Statistics
default.display.hist_select = 1;
default.display.nrofbins = 100;
% Stream lines
default.display.holdstream = 1;
default.display.streamlamount = 10;
default.display.streamslicedensity = 1;
default.display.streamlcolor = 1;
default.display.streamlwidth = 1;

%% export (ASCII / MAT / Tecplot / image export, extraction panels)
% Export as text file (ASCII)
default.export.addfileinfo = 1;
default.export.add_header = 1;
default.export.export_vort = 0;
default.export.delimiter = 1;
% Save as MATLAB file
default.export.export_mat_derivatives = 0;
% Extract parameters from poly-line
default.export.draw_what = 1;
default.export.extraction_choice = 1;
default.export.extractLineAll = 0;
default.export.extractionLine_fileformat = 1;
% Save image (sequence)
default.export.export_still_or_animation = 1;
default.export.quality_setting = 100;
default.export.fps_setting = 30;
if isMATLABReleaseOlderThan("R2025a")
    default.export.resolution_setting = 150;
else
    default.export.resolution_setting = 100;
end
default.export.firstframe = 'N/A';
default.export.lastframe = 'N/A';
% Extract parameters from area
default.export.draw_what_area = 1;
default.export.extraction_choice_area = 1;
default.export.extractAreaAll = 0;
default.export.extractionArea_fileformat = 1;
% Save as TECPLOT file
default.export.export_vort_tec = 0;

%% acquisition (image acquisition panel)
% Image acquisition
default.acquisition.ac_project = '';
default.acquisition.ac_config = 1;
default.acquisition.ac_comport = 1;
default.acquisition.ac_fps = 1;
default.acquisition.ac_interpuls = 470;
default.acquisition.ac_power = 5;
default.acquisition.ac_enable_straddling_figure = 0;
default.acquisition.ac_low_energy_mode = 0;
default.acquisition.ac_enable_ext_trigger = 0;
default.acquisition.ac_displ_sharp = 0;
default.acquisition.ac_displ_grid = 0;
default.acquisition.ac_displ_hist = 0;
default.acquisition.calib_dolivedetect = 0;
default.acquisition.ac_realtime_PIV = 0;
default.acquisition.ac_expo = 50;
default.acquisition.ac_imgamount = 100;
default.acquisition.ac_realtime = 0;
default.acquisition.ac_pivcapture_save = 0;

%% tools (synthetic image generator, temporal statistics)
% Particle image generation
default.tools.flow_sim = 1;
default.tools.img_sizex = 800;
default.tools.img_sizey = 600;
default.tools.part_am = 200000;
default.tools.part_size = 3;
default.tools.part_var = 1;
default.tools.sheetthick = 0.5;
default.tools.part_noise = 0.001;
default.tools.part_z = 10;
default.tools.singledoublerankine = 1;
default.tools.rank_core = 100;
default.tools.rank_displ = 8;
default.tools.rankx1 = 200;
default.tools.rankx2 = 600;
default.tools.ranky1 = 300;
default.tools.ranky2 = 300;
default.tools.singledoubleoseen = 1;
default.tools.oseen_displ = 5;
default.tools.oseen_time = 0.05;
default.tools.oseenx1 = 200;
default.tools.oseenx2 = 600;
default.tools.oseeny1 = 300;
default.tools.oseeny2 = 300;
default.tools.rotation_displacement = 5;
default.tools.shiftdisplacement = 5;
% Derive temporal parameters
default.tools.selectedFramesMean = '1:end';
default.tools.append_replace = 1;
default.tools.frames_per_period = 0;

end
