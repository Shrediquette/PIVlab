function k = kernel_settings(pre, ana)
%KERNEL_SETTINGS Convert API pre-processing and analysis settings to the struct of piv.analyze_pair.
%   pre: imgs.preprocess (or s.preprocess), ana: s.analysis (may be empty for pre-processing only)
k.clahe = double(pre.CLAHE);
k.clahesize = pre.CLAHESize;
k.highp = double(pre.Highpass);
k.highpsize = pre.HighpassSize;
k.intenscap = double(pre.IntensityCapping);
k.wienerwurst = double(pre.Wiener);
k.wienerwurstsize = pre.WienerSize;
k.autolimit = double(pre.AutoLimit);
k.minintens = pre.MinIntensity;
k.maxintens = pre.MaxIntensity;
k.roirect = pre.Roi;
if nargin < 2 || isempty(ana)
    return
end
k.algorithm = char(lower(ana.Algorithm));
k.interrogationarea = ana.InterrogationArea;
k.step = ana.Step;
finders = ["gauss3point","gauss2d"];
if isnumeric(ana.SubpixelFinder)
    k.subpixfinder = ana.SubpixelFinder;
else
    k.subpixfinder = find(strcmpi(finders, ana.SubpixelFinder));
    if isempty(k.subpixfinder)
        error('pivlab:analyze:subpixel','SubpixelFinder must be "gauss3point" or "gauss2d".');
    end
end
k.passes = ana.Passes;
sizes = ana.PassSizes;
k.int2 = sizes(1); k.int3 = sizes(2); k.int4 = sizes(3);
k.mask_auto = double(ana.DisableAutocorrelation);
rob = ["standard","high","extreme"];
if isnumeric(ana.Robustness)
    k.corr_quality = ana.Robustness;
else
    k.corr_quality = find(strcmpi(rob, ana.Robustness));
    if isempty(k.corr_quality)
        error('pivlab:analyze:robustness','Robustness must be "standard", "high" or "extreme".');
    end
end
[k.imdeform, k.repeat, k.do_pad] = piv.corr_quality_params(k.corr_quality);
k.repeat_last_pass = double(ana.RepeatLastPass);
k.delta_diff_min = ana.RepeatLastPassThreshold;
k.compute_uncertainty = double(ana.Uncertainty);
k.do_correlation_matrices = 0;
end
