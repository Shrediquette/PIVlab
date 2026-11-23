function [n_px, distance_mm] = grid_reference(width, mm_per_px)
%GRID_REFERENCE Reference distance of an image grid with a known pixel size (stereo-PIV, combined cameras).
%   [n_px, distance_mm] = calibrate.grid_reference(width, mm_per_px)
%   width      image width [px]; mm_per_px: size of one pixel [mm]
%   n_px       reference distance along x [px], up to 1000 px
%   distance_mm  the same in mm, as the "real distance" field shows it (num2str precision), so that the GUI
%              and the API (pivlab.toMetric) give the same calibration factor
% Used by calibrate.set_grid_scale (GUI) and pivlab.toMetric.
n_px = min(1000, width - 1);
distance_mm = str2double(num2str(n_px * mm_per_px));
end
