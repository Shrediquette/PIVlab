function clear_image_data(extra_keys)
%CLEAR_IMAGE_DATA Remove what belongs to the images as they were before a 3D alignment.
%   stereo.clear_image_data
%   stereo.clear_image_data(extra_keys)   also these GUI data entries (e.g. the stereo results)
% Results, derived data, manual deletions, streamlines, velocity limits, masks and background images; the
% display goes back to the image and background subtraction is switched off. Used by "Compute stereo / 3D alignment"
% (stereo.calibrate_Callback, fov.enter_combined).
if nargin < 1
    extra_keys = {};
end
keys = [{'resultslist', 'derived', 'ismean', 'manualdeletion', 'framemanualdeletion', 'streamlinesX', 'streamlinesY', ...
    'velrect', 'velrect_freehand', 'masks_in_frame', 'bg_img_A', 'bg_img_B'}, extra_keys];
for i = 1:numel(keys)
    gui.put(keys{i}, []);
end
gui.put('displaywhat', 1);
handles = gui.gethand;
set(handles.bg_subtract, 'Value', 1);
end
