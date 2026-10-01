function reference_vector(x,y,vecscale,target_axis,ref_position)
%Reference vector with the settings of the GUI (drawing shared with the command-line API:
%plot.reference_vector_core)
handles=gui.gethand;
reference_length = str2double(get(handles.ref_vect_scl,'String'));
plot.reference_vector_core(x,y,vecscale,target_axis,ref_position,reference_length, ...
    gui.retr('calu'),gui.retr('calxy'),gui.retr('displacement_only'));
end
