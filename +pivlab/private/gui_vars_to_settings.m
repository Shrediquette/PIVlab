function s = gui_vars_to_settings(V, s)
%GUI_VARS_TO_SETTINGS Convert PIVlab variables (as stored in settings/session files) to API settings.
%   s = gui_vars_to_settings(V, s) overwrites the fields of the API settings struct s with the
%   values found in V (struct with PIVlab variable names, see import.settings_from_file).

%% pre-processing
s.preprocess.CLAHE            = get_flag(V,'clahe_enable',s.preprocess.CLAHE);
s.preprocess.CLAHESize        = get_num(V,'clahe_size',s.preprocess.CLAHESize);
s.preprocess.Highpass         = get_flag(V,'enable_highpass',s.preprocess.Highpass);
s.preprocess.HighpassSize     = get_num(V,'highp_size',s.preprocess.HighpassSize);
s.preprocess.IntensityCapping = get_flag(V,'enable_intenscap',s.preprocess.IntensityCapping);
s.preprocess.Wiener           = get_flag(V,'wienerwurst',s.preprocess.Wiener);
s.preprocess.WienerSize       = get_num(V,'wienerwurstsize',s.preprocess.WienerSize);
s.preprocess.AutoLimit        = get_flag(V,'Autolimit',s.preprocess.AutoLimit);
s.preprocess.MinIntensity     = get_num(V,'minintens',s.preprocess.MinIntensity);
s.preprocess.MaxIntensity     = get_num(V,'maxintens',s.preprocess.MaxIntensity);
if isfield(V,'roirect')
    s.preprocess.Roi = V.roirect;
end
if isfield(V,'bg_mode') && ~isempty(V.bg_mode)
    modes = ["none","mean","min"];
    s.preprocess.Background = modes(min(max(V.bg_mode,1),3));
end

%% PIV
if isfield(V,'algorithm_selection')
    algos = ["fft","ensemble","dcc","ofv"];
    s.analysis.Algorithm = algos(V.algorithm_selection);
end
s.analysis.InterrogationArea = get_num(V,'intarea',s.analysis.InterrogationArea);
s.analysis.Step              = get_num(V,'stepsize',s.analysis.Step);
if isfield(V,'subpix')
    finders = ["gauss3point","gauss2d"];
    s.analysis.SubpixelFinder = finders(V.subpix);
end
if all(isfield(V,{'pass2','pass3','pass4'}))
    passes = 1;
    if V.pass2 == 1, passes = 2; end
    if V.pass3 == 1, passes = 3; end
    if V.pass4 == 1, passes = 4; end
    s.analysis.Passes = passes;
end
sizes = s.analysis.PassSizes;
sizes(1) = get_num(V,'pass2val',sizes(1));
sizes(2) = get_num(V,'pass3val',sizes(2));
sizes(3) = get_num(V,'pass4val',sizes(3));
s.analysis.PassSizes = sizes;
s.analysis.DisableAutocorrelation = get_flag(V,'mask_auto_box',s.analysis.DisableAutocorrelation);
if isfield(V,'CorrQuality_nr')
    rob = ["standard","high","extreme"];
    s.analysis.Robustness = rob(V.CorrQuality_nr);
end
s.analysis.RepeatLastPass          = get_flag(V,'repeat_last',s.analysis.RepeatLastPass);
s.analysis.RepeatLastPassThreshold = get_num(V,'repeat_last_thresh',s.analysis.RepeatLastPassThreshold);

%% vector validation
s.filter.StdevCheck           = get_flag(V,'stdev_check',s.filter.StdevCheck);
s.filter.StdevThreshold       = get_num(V,'stdev_thresh',s.filter.StdevThreshold);
s.filter.LocalMedian          = get_flag(V,'loc_median',s.filter.LocalMedian);
s.filter.LocalMedianThreshold = get_num(V,'loc_med_thresh',s.filter.LocalMedianThreshold);
s.filter.Interpolate          = get_flag(V,'interpol_missing',s.filter.Interpolate);
s.filter.CorrelationFilter    = get_flag(V,'do_corr2_filter',s.filter.CorrelationFilter);
s.filter.CorrelationThreshold = get_num(V,'corr_filter_thresh',s.filter.CorrelationThreshold);
s.filter.NotchFilter          = get_flag(V,'notch_filter',s.filter.NotchFilter);
s.filter.NotchLimits          = [get_num(V,'notch_L_thresh',s.filter.NotchLimits(1)) get_num(V,'notch_H_thresh',s.filter.NotchLimits(2))];
s.filter.ContrastFilter       = get_flag(V,'do_contrast_filter',s.filter.ContrastFilter);
s.filter.ContrastThreshold    = get_num(V,'contrast_filter_thresh',s.filter.ContrastThreshold);
s.filter.BrightnessFilter     = get_flag(V,'do_bright_filter',s.filter.BrightnessFilter);
s.filter.BrightnessThreshold  = get_num(V,'bright_filter_thresh',s.filter.BrightnessThreshold);
if isfield(V,'velrect') && numel(V.velrect) == 4
    r = double(V.velrect); % [umin vmin width height] in calibrated units
    s.filter.VelocityLimits = [r(1) r(1)+r(3) r(2) r(2)+r(4)];
end

%% calibration
c = s.calibration;
for n = {'calxy','calu','calv','offset_x_true','offset_y_true','x_axis_direction','y_axis_direction'}
    c.(n{1}) = get_num(V, n{1}, c.(n{1}));
end
c.realdist = get_num(V,'realdist',c.realdist);
c.time_inp = get_num(V,'time_inp',c.time_inp);
if isfield(V,'pointscali'), c.pointscali = V.pointscali; end
c.displacement_only = (c.time_inp == 0);
s.calibration = c;
% velocity / notch limits stored in PIVlab files are in calibrated units
if ~((c.calu==1 || c.calu==-1) && c.calxy==1)
    s.filter.LimitUnits = "calibrated";
end

%% smoothing (Plot -> derive parameters)
if isfield(V,'smooth_mode_val')
    modes = ["none","spatial","temporal","spatiotemporal"];
    s.derive.Smoothing = modes(V.smooth_mode_val);
end
s.derive.SmoothingStrength = get_num(V,'smooth_param_str',s.derive.SmoothingStrength);
s.derive.TemporalWindow    = get_num(V,'temporal_window_str',s.derive.TemporalWindow);

%% display
if isfield(V,'colormap_choice')
    maps = ["parula","hsv","jet","hsb","hot","cool","spring","summer","autumn","winter","gray","bone","copper","pink","lines","plasma"];
    s.display.Colormap = maps(V.colormap_choice);
end
if isfield(V,'colormap_steps')
    steps = [256 128 64 32 16 8 4 2];
    s.display.ColormapSteps = steps(V.colormap_steps);
end
if isfield(V,'colormap_interpolation')
    interp = ["bilinear","bicubic","nearest"];
    s.display.MapInterpolation = interp(V.colormap_interpolation);
end
if isfield(V,'autoscale_vec') && V.autoscale_vec == 0
    s.display.VectorScale = get_num(V,'vectorscale',s.display.VectorScale);
end
s.display.VectorSkip = get_num(V,'nthvect',s.display.VectorSkip);
s.display.EnhanceImage = get_flag(V,'enhance_disp',s.display.EnhanceImage);
end

function v = get_num(V, name, default)
v = default;
if isfield(V,name) && ~isempty(V.(name))
    x = V.(name);
    if ischar(x) || isstring(x) || iscell(x)
        x = str2double(x);
    end
    if ~isnan(x)
        v = double(x);
    end
end
end

function v = get_flag(V, name, default)
v = default;
if isfield(V,name) && ~isempty(V.(name))
    v = logical(V.(name));
end
end
