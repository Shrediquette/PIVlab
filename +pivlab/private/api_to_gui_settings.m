function G = api_to_gui_settings(s)
%API_TO_GUI_SETTINGS Convert API settings to PIVlab GUI settings (inverse of gui_settings_to_api).
%   G = api_to_gui_settings(s) returns gui.default_settings with the values of s, in the types of
%   the GUI settings (numbers, popup menus as index), plus G.calibration_data.
%   GUI settings without an API equivalent keep their default value.
G = gui.default_settings;
p = s.preprocess; a = s.analysis; f = s.filter; c = s.calibration; d = s.derive; g = s.display;

%% pre-processing
G.analysis.clahe_enable = double(p.CLAHE);
G.analysis.clahe_size = p.CLAHESize;
G.analysis.highpass_enable = double(p.Highpass);
G.analysis.highpass_size = p.HighpassSize;
G.analysis.intenscap_enable = double(p.IntensityCapping);
G.analysis.wiener_enable = double(p.Wiener);
G.analysis.wiener_size = p.WienerSize;
G.analysis.autolimit_enable = double(p.AutoLimit);
G.analysis.minintens = p.MinIntensity;
G.analysis.maxintens = p.MaxIntensity;
G.analysis.bg_subtract = index_of(["none","mean","min"], p.Background, 1);

%% PIV
G.analysis.algorithm_selection = index_of(["fft","ensemble","dcc","ofv"], a.Algorithm, 1);
G.analysis.pass1_size = a.InterrogationArea;
G.analysis.pass1_step = a.Step;
G.analysis.subpixel_estimator = index_of(["gauss3point","gauss2d"], a.SubpixelFinder, 1);
G.analysis.pass2_enable = double(a.Passes >= 2);
G.analysis.pass3_enable = double(a.Passes >= 3);
G.analysis.pass4_enable = double(a.Passes >= 4);
G.analysis.pass2_size = a.PassSizes(1);
G.analysis.pass3_size = a.PassSizes(2);
G.analysis.pass4_size = a.PassSizes(3);
G.analysis.disable_autocorrelation = double(a.DisableAutocorrelation);
G.analysis.correlation_robustness = index_of(["standard","high","extreme"], a.Robustness, 1);
G.analysis.repeat_last_enable = double(a.RepeatLastPass);
G.analysis.repeat_last_threshold = a.RepeatLastPassThreshold;
G.analysis.uncertainty_enable = double(a.Uncertainty);

%% vector validation
G.analysis.stdev_enable = double(f.StdevCheck);
G.analysis.stdev_thresh = f.StdevThreshold;
G.analysis.loc_median_enable = double(f.LocalMedian);
G.analysis.loc_med_thresh = f.LocalMedianThreshold;
G.analysis.interpol_missing = double(f.Interpolate);
G.analysis.corr_filter_enable = double(f.CorrelationFilter);
G.analysis.corr_filter_thresh = f.CorrelationThreshold;
G.analysis.notch_enable = double(f.NotchFilter);
G.analysis.notch_L_thresh = f.NotchLimits(1);
G.analysis.notch_H_thresh = f.NotchLimits(2);
G.analysis.contrast_filter_enable = double(f.ContrastFilter);
G.analysis.contrast_filter_thresh = f.ContrastThreshold;
G.analysis.bright_filter_enable = double(f.BrightnessFilter);
G.analysis.bright_filter_thresh = f.BrightnessThreshold;

%% calibration
G.calibration.x_axis_direction = c.x_axis_direction;
G.calibration.y_axis_direction = c.y_axis_direction;
G.calibration.realdist = c.realdist;
G.calibration.time_inp = c.time_inp;
G.calibration_data = struct('pointscali', c.pointscali, 'points_offsetx', [], 'points_offsety', [], 'size_of_the_image', []);

%% smoothing
G.analysis.smooth_mode = index_of(["none","spatial","temporal","spatiotemporal"], d.Smoothing, 1);
G.analysis.smooth_param = d.SmoothingStrength;
G.analysis.temporal_window = d.TemporalWindow;

%% display
G.display.colormap_choice = index_of(["parula","hsv","jet","hsb","hot","cool","spring","summer","autumn","winter","gray","bone","copper","pink","lines","plasma"], g.Colormap, 1);
steps = find([256 128 64 32 16 8 4 2] == g.ColormapSteps, 1);
if isempty(steps), steps = 1; end
G.display.colormap_steps = steps;
G.display.colormap_interpolation = index_of(["bilinear","bicubic","nearest"], g.MapInterpolation, 1);
if isstring(g.VectorScale) || ischar(g.VectorScale)
    G.display.autoscale_vec = 1;
else
    G.display.autoscale_vec = 0;
    G.display.vectorscale = g.VectorScale;
end
G.display.nthvect = g.VectorSkip;
G.display.enhance_images = double(g.EnhanceImage);
end

function k = index_of(names, value, default)
% position of value (name, or already a number) in names
k = default;
if isnumeric(value) && isscalar(value)
    k = value;
    return
end
hit = find(names == lower(string(value)), 1);
if ~isempty(hit)
    k = hit;
end
end
