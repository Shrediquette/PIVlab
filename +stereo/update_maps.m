function update_maps
%UPDATE_MAPS Image maps of both cameras from the stereo calibration (and the disparity, if measured).
%   stereo.update_maps
% With a stereo calibration, every image of camera k is read through its map (stereo.camera_map):
% lens undistortion, rectification onto the common grid of both cameras and the disparity correction
% in one interpolation (import.cam_settings(FromGUI=true) hands the map of the active camera to
% import.read_frame). The maps are kept in gui.retr('stereo_maps'), not in sessions (they are made
% again after loading). Both cameras get the image size of the common grid.
calib = gui.retr('stereo_calib');
if ~isequal(gui.retr('stereomode'), 1) || isempty(calib)
    gui.put('stereo_maps', []);
    return
end
disparity = stereo.full_disparity(calib, gui.retr('stereo_disparity')); % stored without the full-size maps
maps = cell(1, 2);
for k = 1:2
    maps{k} = stereo.camera_map(calib, k, disparity);
end
gui.put('stereo_maps', maps);
if isempty(disparity) % the rectification without disparity correction (overlay "not corrected")
    gui.put('stereo_maps_plain', maps);
end
image_size = calib.Ravg.ImageSize;
gui.put('expected_image_size', image_size);
gui.put('size_of_the_image', image_size);
state = gui.retr('stereo_cam_state');
active = gui.retr('stereo_active_camera');
if iscell(state) && numel(state) == 2
    for k = 1:2
        if k ~= active
            state{k}.expected_image_size = image_size;
            state{k}.size_of_the_image = image_size;
        end
    end
    gui.put('stereo_cam_state', state);
end
end
