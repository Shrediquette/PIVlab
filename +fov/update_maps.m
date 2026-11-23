function update_maps
%UPDATE_MAPS Maps of the combined image of two cameras in the PIVlab window (larger field of view).
%   fov.update_maps
% From the 3D alignment (gui.retr('fov_calib')) and the frame list of camera 2 (gui.retr('fov_src2')):
% fov.maps, kept in gui.retr('fov_maps') (not in sessions: made again after loading).
% import.cam_settings(FromGUI=true) hands them to import.read_frame, which then combines both cameras.
if ~fov.gui_active
    gui.put('fov_maps', []);
    return
end
F = fov.maps(gui.retr('fov_calib')); % camera 2 frames: gui.retr('fov_src2'), added by import.cam_settings
gui.put('fov_maps', F);
gui.put('expected_image_size', F.size);
gui.put('size_of_the_image', F.size);
end
