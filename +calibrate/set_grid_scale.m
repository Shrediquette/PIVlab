function set_grid_scale(width, mm_per_px)
%SET_GRID_SCALE Spatial calibration (px -> mm) of the PIVlab window from an image grid with a known pixel size.
%   calibrate.set_grid_scale(width, mm_per_px)
% Like a rectified image: a reference distance along x (calibrate.grid_reference), the time step stays to be
% entered. Used after the 3D alignment of stereo-PIV and of two combined cameras.
[n_px, distance_mm] = calibrate.grid_reference(width, mm_per_px);
gui.put('pointscali', [1 1; 1 + n_px 1]);
handles = gui.gethand;
set(handles.realdist, 'String', num2str(distance_mm));
calibrate.pixeldist_changed_Callback()
end
