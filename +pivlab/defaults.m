function s = defaults()
%DEFAULTS Default settings of the PIVlab command-line API.
%   s = pivlab.defaults() returns the settings the PIVlab GUI starts with (gui.default_settings).
%   The struct has one field per processing step:
%
%     s.preprocess   used by pivlab.preprocess   (CLAHE, Highpass, Background, Roi, Mask, ...)
%     s.analysis     used by pivlab.analyze      (Algorithm, InterrogationArea, Passes, ...)
%     s.filter       used by pivlab.filter       (StdevThreshold, LocalMedianThreshold, ...)
%     s.calibration  used by pivlab.toMetric     (PIVlab calibration variables)
%     s.derive       used by pivlab.derive       (Smoothing, ...)
%     s.display      used by pivlab.display      (Colormap, VectorScale, ...)
%
%   Change fields and pass the struct to the API functions with Settings=s, e.g.
%       s = pivlab.defaults();
%       s.analysis.InterrogationArea = 48;
%       res = pivlab.analyze(imgs, Settings=s);
%   Name=value arguments of the API functions override the values in Settings.
%
%   See also pivlab.loadSettings
s = base_settings();
s = gui_settings_to_api(gui.default_settings, s);
s.filter.LimitUnits = "result";
end
