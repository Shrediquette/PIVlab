function stereo_value_Callback(hObject, ~, ~)
%number fields of the stereo based validation panel (residual threshold, W median threshold, W limits)
misc.check_comma(hObject)
handles = gui.gethand;
if hObject == handles.residual_thresh && validate.residual_map_shown(handles)
    gui.sliderdisp(gui.retr('pivlab_axis')) %colours and removed vectors of the residual map for the new threshold
end
