function clear_combined
%CLEAR_COMBINED Remove the data of two combined cameras from the PIVlab window (e.g. before a new import).
%   fov.clear_combined
gui.put('fov_calib', []);
gui.put('fov_src2', []);
gui.put('fov_maps', []);
end
