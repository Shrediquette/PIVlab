function s = defaults()
%DEFAULTS Default settings of the stereo-PIV specific steps (stereo.run).
%   s = stereo.defaults() returns a struct with the groups
%     s.calibration     stereo.calibrate       (common output grid, corner filter)
%     s.disparity       stereo.measure_disparity (misalignment of the two rectified views)
%     s.reconstruction  stereo.reconstruct     (three velocity components)
%     s.Parallel        true: parallel pool for the disparity measurement and the PIV
%   Image pre-processing, PIV, vector validation and smoothing of the two cameras are ordinary
%   PIVlab settings (pivlab.defaults), the same for both cameras.

% common output grid: square pixels, cropped to the overlap of both views
s.calibration.PixelSize = [];               % [mm] per output pixel, [] = pixel size of the finer camera
s.calibration.CornerFilter = true;          % reject wrongly identified board corners (RANSAC)

% disparity: PIV between the A images of camera 1 and camera 2 (rectified). The values that the
% Stereo-PIV panel shows come from gui.default_settings (one list of defaults for GUI and scripts).
g = gui.default_settings;
models = stereo.disparity_models;
s.disparity.Pairs = g.analysis.stereo_disp_pairs;   % image pairs used, spread over the series ([] = all)
s.disparity.Model = models(g.analysis.stereo_disp_model); % smooth model of the disparity map: "poly2"
                                            % (2nd-order polynomial), "poly1", "projective"
s.disparity.Passes = g.analysis.stereo_disp_passes; % measure again on the corrected images, add the residual
s.disparity.StopThreshold = 0.1;            % [px] stop when the largest residual is smaller
s.disparity.InterrogationArea = [];         % [px] first pass, [] = 1/5 of the smaller image side
if g.analysis.stereo_disp_ia > 0
    s.disparity.InterrogationArea = g.analysis.stereo_disp_ia;
end
s.disparity.PassSize2 = 256;                % [px] second pass
s.disparity.StdevThreshold = g.analysis.stereo_disp_stdev; % validation of the disparity vectors
s.disparity.LocalMedianThreshold = g.analysis.stereo_disp_median;
s.disparity.SmoothFrame = 2;                % smoothn of the map of every image pair
s.disparity.SmoothMean = 5;                 % smoothn of the mean map
s.disparity.MinBackground = true;           % subtract a minimum-intensity background (all A images of
                                            % each camera): static features would give wrong peaks
s.disparity.MinBackgroundFrames = 10;       % fewer A images: no background (the minimum would
                                            % remove the particles)

% reconstruction (coordinates like PIVlab: x right, y down; W positive away from the cameras)
s.reconstruction.SheetFromDisparity = true; % light sheet position from the disparity (else: on the board)
s.reconstruction.DisparityGradient = true;  % correct the displacements for the varying disparity shift

s.Parallel = false;
end
