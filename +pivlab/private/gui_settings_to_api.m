function s = gui_settings_to_api(G, s)
%GUI_SETTINGS_TO_API Convert PIVlab GUI settings (gui.default_settings / settings file) to API settings.
%   s = gui_settings_to_api(G, s) overwrites the fields of the API settings struct s with the
%   values in G (struct with the groups of gui.default_settings, e.g. G.analysis.pass1_size = 64,
%   optional G.calibration_data). Settings missing in G keep their value in s.
%   This is the one translation table between the GUI (Tags) and the API (names).
%   GUI settings of the groups analysis / calibration that the API does not use are listed in
%   gui_only below (unittests/test_settings checks that every such setting is in one of the two).

A = group(G, 'analysis');
C = group(G, 'calibration');
D = group(G, 'display');

%% pre-processing
s.preprocess.CLAHE            = get_flag(A,'clahe_enable',s.preprocess.CLAHE);
s.preprocess.CLAHESize        = get_num(A,'clahe_size',s.preprocess.CLAHESize);
s.preprocess.Highpass         = get_flag(A,'highpass_enable',s.preprocess.Highpass);
s.preprocess.HighpassSize     = get_num(A,'highpass_size',s.preprocess.HighpassSize);
s.preprocess.IntensityCapping = get_flag(A,'intenscap_enable',s.preprocess.IntensityCapping);
s.preprocess.Wiener           = get_flag(A,'wiener_enable',s.preprocess.Wiener);
s.preprocess.WienerSize       = get_num(A,'wiener_size',s.preprocess.WienerSize);
s.preprocess.AutoLimit        = get_flag(A,'autolimit_enable',s.preprocess.AutoLimit);
s.preprocess.MinIntensity     = get_num(A,'minintens',s.preprocess.MinIntensity);
s.preprocess.MaxIntensity     = get_num(A,'maxintens',s.preprocess.MaxIntensity);
if isfield(A,'bg_subtract')
    modes = ["none","mean","min"];
    s.preprocess.Background = modes(min(max(A.bg_subtract,1),3));
end

%% PIV
if isfield(A,'algorithm_selection')
    algos = ["fft","ensemble","dcc","ofv"];
    s.analysis.Algorithm = algos(A.algorithm_selection);
end
s.analysis.InterrogationArea = get_num(A,'pass1_size',s.analysis.InterrogationArea);
s.analysis.Step              = get_num(A,'pass1_step',s.analysis.Step);
if isfield(A,'subpixel_estimator')
    finders = ["gauss3point","gauss2d"];
    s.analysis.SubpixelFinder = finders(A.subpixel_estimator);
end
if all(isfield(A,{'pass2_enable','pass3_enable','pass4_enable'}))
    passes = 1;
    if A.pass2_enable == 1, passes = 2; end
    if A.pass3_enable == 1, passes = 3; end
    if A.pass4_enable == 1, passes = 4; end
    s.analysis.Passes = passes;
end
sizes = s.analysis.PassSizes;
sizes(1) = get_num(A,'pass2_size',sizes(1));
sizes(2) = get_num(A,'pass3_size',sizes(2));
sizes(3) = get_num(A,'pass4_size',sizes(3));
s.analysis.PassSizes = sizes;
s.analysis.DisableAutocorrelation = get_flag(A,'disable_autocorrelation',s.analysis.DisableAutocorrelation);
if isfield(A,'correlation_robustness')
    rob = ["standard","high","extreme"];
    s.analysis.Robustness = rob(A.correlation_robustness);
end
s.analysis.RepeatLastPass          = get_flag(A,'repeat_last_enable',s.analysis.RepeatLastPass);
s.analysis.RepeatLastPassThreshold = get_num(A,'repeat_last_threshold',s.analysis.RepeatLastPassThreshold);
s.analysis.Uncertainty             = get_flag(A,'uncertainty_enable',s.analysis.Uncertainty);

%% vector validation
s.filter.StdevCheck           = get_flag(A,'stdev_enable',s.filter.StdevCheck);
s.filter.StdevThreshold       = get_num(A,'stdev_thresh',s.filter.StdevThreshold);
s.filter.LocalMedian          = get_flag(A,'loc_median_enable',s.filter.LocalMedian);
s.filter.LocalMedianThreshold = get_num(A,'loc_med_thresh',s.filter.LocalMedianThreshold);
s.filter.Interpolate          = get_flag(A,'interpol_missing',s.filter.Interpolate);
s.filter.CorrelationFilter    = get_flag(A,'corr_filter_enable',s.filter.CorrelationFilter);
s.filter.CorrelationThreshold = get_num(A,'corr_filter_thresh',s.filter.CorrelationThreshold);
s.filter.NotchFilter          = get_flag(A,'notch_enable',s.filter.NotchFilter);
s.filter.NotchLimits          = [get_num(A,'notch_L_thresh',s.filter.NotchLimits(1)) get_num(A,'notch_H_thresh',s.filter.NotchLimits(2))];
s.filter.ContrastFilter       = get_flag(A,'contrast_filter_enable',s.filter.ContrastFilter);
s.filter.ContrastThreshold    = get_num(A,'contrast_filter_thresh',s.filter.ContrastThreshold);
s.filter.BrightnessFilter     = get_flag(A,'bright_filter_enable',s.filter.BrightnessFilter);
s.filter.BrightnessThreshold  = get_num(A,'bright_filter_thresh',s.filter.BrightnessThreshold);

%% calibration (factors computed from the reference distance, like "Apply calibration")
c = s.calibration;
c.x_axis_direction = get_num(C,'x_axis_direction',c.x_axis_direction);
c.y_axis_direction = get_num(C,'y_axis_direction',c.y_axis_direction);
c.realdist = get_num(C,'realdist',c.realdist);
c.time_inp = get_num(C,'time_inp',c.time_inp);
c.displacement_only = (c.time_inp == 0);
if isfield(G,'calibration_data')
    data = G.calibration_data;
    c.pointscali = field_or_empty(data,'pointscali');
    if ~isempty(c.pointscali)
        cal = calibrate.compute_calibration(c.pointscali, c.realdist, c.time_inp, c.x_axis_direction, c.y_axis_direction, ...
            field_or_empty(data,'points_offsetx'), field_or_empty(data,'points_offsety'), field_or_empty(data,'size_of_the_image'));
        c.calxy = cal.calxy;
        c.calu = cal.calu;
        c.calv = cal.calv;
        c.offset_x_true = cal.offset_x_true;
        c.offset_y_true = cal.offset_y_true;
    end
end
s.calibration = c;
% velocity / notch limits stored in PIVlab files are in calibrated units
if ~((c.calu==1 || c.calu==-1) && c.calxy==1)
    s.filter.LimitUnits = "calibrated";
end

%% smoothing (Plot -> derive parameters)
if isfield(A,'smooth_mode')
    modes = ["none","spatial","temporal","spatiotemporal"];
    s.derive.Smoothing = modes(A.smooth_mode);
end
s.derive.SmoothingStrength = get_num(A,'smooth_param',s.derive.SmoothingStrength);
s.derive.TemporalWindow    = get_num(A,'temporal_window',s.derive.TemporalWindow);

%% display
if isfield(D,'colormap_choice')
    maps = ["parula","hsv","jet","hsb","hot","cool","spring","summer","autumn","winter","gray","bone","copper","pink","lines","plasma"];
    s.display.Colormap = maps(D.colormap_choice);
end
if isfield(D,'colormap_steps')
    steps = [256 128 64 32 16 8 4 2];
    s.display.ColormapSteps = steps(D.colormap_steps);
end
if isfield(D,'colormap_interpolation')
    interp = ["bilinear","bicubic","nearest"];
    s.display.MapInterpolation = interp(D.colormap_interpolation);
end
if isfield(D,'autoscale_vec') && D.autoscale_vec == 0
    s.display.VectorScale = get_num(D,'vectorscale',s.display.VectorScale);
end
s.display.VectorSkip = get_num(D,'nthvect',s.display.VectorSkip);
s.display.EnhanceImage = get_flag(D,'enhance_images',s.display.EnhanceImage);
end

function names = gui_only() %#ok<DEFNU> read by unittests/test_settings
% settings of the groups analysis and calibration that the API does not use (yet)
names = {'stereocheckbox', 'ofv_parallelpatches', 'ofv_median', 'ofv_pyramid_levels', 'ofv_eta', ...
    'extrapolate_border', 'optimize_calib_img', 'calib_use_tilted_model', 'calib_viewtype', ...
    'calib_usecalibration', 'calib_upscale', 'calib_userectification', 'calib_boardtype', ...
    'calib_origincolor', 'calib_rows', 'calib_columns', 'calib_checkersize', 'calib_markersize'};
end

function S = group(G, name)
S = struct();
if isfield(G, name) && isstruct(G.(name))
    S = G.(name);
end
end

function v = field_or_empty(S, name)
v = [];
if isfield(S, name)
    v = S.(name);
end
end

function v = get_num(S, name, default)
v = default;
if isfield(S,name) && ~isempty(S.(name))
    x = S.(name);
    if ischar(x) || isstring(x)
        x = str2double(x);
    end
    if isnumeric(x) && isscalar(x) && ~isnan(x)
        v = double(x);
    end
end
end

function v = get_flag(S, name, default)
v = default;
if isfield(S,name) && ~isempty(S.(name))
    v = logical(S.(name));
end
end
