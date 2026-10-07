function reset_to_defaults()
% reset_to_defaults  Revert the settings of the PIVlab window to their default values
% (gui.default_settings). Used when the Basic/Advanced mode is switched.
%
% Analysis results (resultslist) are NOT touched. Not reset: the calibration (it belongs to
% the reference distance of the data), the image acquisition panel and the controls whose data
% only exists in sessions (camera calibration, rectification, stereo mode).
gui.apply_settings(gui.default_settings, {'analysis','masks','display','export','tools'}, false);
end
