function V = settings_to_gui_vars(s)
%SETTINGS_TO_GUI_VARS Convert API settings to the PIVlab variables stored in session files.
%   Inverse of gui_vars_to_settings. Strings and values are stored in the format of the GUI
%   controls (edit boxes as char, checkboxes and popups as numbers).
p = s.preprocess; a = s.analysis; f = s.filter; c = s.calibration; d = s.derive; g = s.display;
V.clahe_enable = double(p.CLAHE);
V.clahe_size = num2str(p.CLAHESize);
V.enable_highpass = double(p.Highpass);
V.highp_size = num2str(p.HighpassSize);
V.enable_intenscap = double(p.IntensityCapping);
V.wienerwurst = double(p.Wiener);
V.wienerwurstsize = num2str(p.WienerSize);
V.Autolimit = double(p.AutoLimit);
V.minintens = num2str(p.MinIntensity);
V.maxintens = num2str(p.MaxIntensity);

algos = ["fft","ensemble","dcc","ofv"];
V.algorithm_selection = find(algos == lower(string(a.Algorithm)));
V.intarea = num2str(a.InterrogationArea);
V.stepsize = num2str(a.Step);
finders = ["gauss3point","gauss2d"];
if isnumeric(a.SubpixelFinder)
    V.subpix = a.SubpixelFinder;
else
    V.subpix = find(finders == lower(string(a.SubpixelFinder)));
end
V.pass2 = double(a.Passes >= 2);
V.pass3 = double(a.Passes >= 3);
V.pass4 = double(a.Passes >= 4);
V.pass2val = num2str(a.PassSizes(1));
V.pass3val = num2str(a.PassSizes(2));
V.pass4val = num2str(a.PassSizes(3));
V.step2 = num2str(a.PassSizes(1)/2);
V.step3 = num2str(a.PassSizes(2)/2);
V.step4 = num2str(a.PassSizes(3)/2);
V.mask_auto_box = double(a.DisableAutocorrelation);
rob = ["standard","high","extreme"];
if isnumeric(a.Robustness)
    V.CorrQuality_nr = a.Robustness;
else
    V.CorrQuality_nr = find(rob == lower(string(a.Robustness)));
end
V.repeat_last = double(a.RepeatLastPass);
V.repeat_last_thresh = num2str(a.RepeatLastPassThreshold);

V.stdev_check = double(f.StdevCheck);
V.stdev_thresh = num2str(f.StdevThreshold);
V.loc_median = double(f.LocalMedian);
V.loc_med_thresh = num2str(f.LocalMedianThreshold);
V.interpol_missing = double(f.Interpolate);
V.do_corr2_filter = double(f.CorrelationFilter);
V.corr_filter_thresh = num2str(f.CorrelationThreshold);
V.notch_filter = double(f.NotchFilter);
V.notch_L_thresh = num2str(f.NotchLimits(1));
V.notch_H_thresh = num2str(f.NotchLimits(2));
V.do_contrast_filter = double(f.ContrastFilter);
V.contrast_filter_thresh = num2str(f.ContrastThreshold);
V.do_bright_filter = double(f.BrightnessFilter);
V.bright_filter_thresh = num2str(f.BrightnessThreshold);

V.calxy = c.calxy; V.calu = c.calu; V.calv = c.calv;
V.offset_x_true = c.offset_x_true; V.offset_y_true = c.offset_y_true;
V.x_axis_direction = c.x_axis_direction; V.y_axis_direction = c.y_axis_direction;
V.realdist_string = num2str(c.realdist);
V.time_inp_string = num2str(c.time_inp);
V.pointscali = c.pointscali;
V.displacement_only = double(c.displacement_only);

modes = ["none","spatial","temporal","spatiotemporal"];
V.smooth_mode_val = find(modes == lower(string(d.Smoothing)));
V.smooth_param_str = num2str(d.SmoothingStrength);
V.temporal_window_str = num2str(d.TemporalWindow);

maps = ["parula","hsv","jet","hsb","hot","cool","spring","summer","autumn","winter","gray","bone","copper","pink","lines","plasma"];
V.colormap_choice = find(maps == lower(string(g.Colormap)));
steps = [256 128 64 32 16 8 4 2];
V.colormap_steps = find(steps == g.ColormapSteps, 1);
if isempty(V.colormap_steps), V.colormap_steps = 1; end
interp = ["bilinear","bicubic","nearest"];
V.colormap_interpolation = find(interp == lower(string(g.MapInterpolation)));
if isstring(g.VectorScale) || ischar(g.VectorScale)
    V.autoscale_vec = 1; V.vectorscale = '5';
else
    V.autoscale_vec = 0; V.vectorscale = num2str(g.VectorScale);
end
V.enhance_disp = double(g.EnhanceImage);
% GUI elements without an API equivalent: PIVlab defaults
V.addfileinfo = 1; V.add_header = 1; V.delimiter = 1; V.img_not_mask = 0;
V.holdstream = 1; V.streamlamount = '10'; V.streamlcolor = 1;
V.valid_color_idx = 1; V.secondpeak_color_idx = 2; V.interp_color_idx = 3; V.deriv_color_idx = 4;
V.extrapolate_border = 0;
end
