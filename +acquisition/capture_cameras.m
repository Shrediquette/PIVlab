function n = capture_cameras()
%CAPTURE_CAMERAS Number of cameras that record: 2 when "Stereo (2 cameras)" is ticked and the selected
%camera supports stereo acquisition (acquisition.stereo_supported), else 1. Basic mode hides the checkbox
%(PIVlab_hidden_elements.txt): then 1, also when a settings file ticked it.
n = 1;
handles = gui.gethand;
if isfield(handles, 'ac_stereo') && get(handles.ac_stereo, 'Value') == 1 && strcmp(get(handles.ac_stereo, 'Visible'), 'on') ...
        && acquisition.stereo_supported(gui.retr('camera_type'))
    n = 2;
end
end
