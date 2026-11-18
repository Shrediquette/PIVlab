function residual_enable_Callback(~, ~, ~)
%"Reconstruction residual filter" of the stereo based validation panel: "Show residual map" is only
%available while the filter is ticked (gui.update_dependent_controls); unticking removes the map
handles = gui.gethand;
map_was_shown = get(handles.stereo_show_residual, 'Value') == 1 && isequal(gui.retr('stereomode'), 1) && strcmp(get(handles.multip32, 'Visible'), 'on');
gui.update_dependent_controls(handles);
if map_was_shown
    gui.sliderdisp(gui.retr('pivlab_axis')) %vectors instead of the residual map
end
