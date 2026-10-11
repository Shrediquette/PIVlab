function show_active_camera
%SHOW_ACTIVE_CAMERA Update the GUI for the active camera (image list, frame slider, controls, image).
%   stereo.show_active_camera
% Used after stereo.switch_camera and after a stereo import. The frame number stays the same (both
% cameras have the same number of image pairs).
handles = gui.gethand;
filename = gui.retr('filename');
if ~isempty(filename)
    value = min(max(get(handles.filenamebox, 'Value'), 1), numel(filename));
    set(handles.filenamebox, 'String', filename, 'Value', value);
end
gui.sliderrange(0);
gui.update_dependent_controls(handles);
if ~isempty(gui.retr('filepath'))
    gui.sliderdisp(gui.retr('pivlab_axis'));
end
end
