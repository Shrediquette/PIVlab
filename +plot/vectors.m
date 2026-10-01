function [q, q2] = vectors(target_axis,handles, vecskip, x, typevector, y, u, vecscale, v, vectorcolor)
%Collects the vector display settings of the GUI and draws the vectors.
%The drawing itself (plot.draw_vectors) is shared with the command-line API (pivlab.display).
colors_cell = gui.vec_preset_colors();
o.interp_color     = colors_cell{get(handles.interp_color,    'Value'), 2};
o.secondpeak_color = colors_cell{get(handles.secondpeak_color,'Value'), 2};
o.uniform = get(handles.uniform_vector_scale,'Value')==1;
o.power = get(handles.power_vector_scale,'Value')==1;
o.power_factor = str2double(get(handles.power_vector_scale_factor,'String'));
o.vecwidth = str2double(get(handles.vecwidth,'string'));
o.masktransp = str2num(get(handles.masktransp,'String')); %#ok<ST2NM>
ref_choices=get(handles.ref_vect_pos,'String');
o.ref_position = ref_choices{get(handles.ref_vect_pos,'Value')};
o.ref_length = str2double(get(handles.ref_vect_scl,'String'));
o.calu = gui.retr('calu');
o.calv = gui.retr('calv');
o.calxy = gui.retr('calxy');
o.displacement_only = gui.retr('displacement_only');
o.subtr_u = gui.retr('subtr_u');
o.subtr_v = gui.retr('subtr_v');
avail_maps = get(handles.colormap_choice,'string');
selected_index = get(handles.colormap_choice,'value');
if selected_index < 1 || selected_index > numel(avail_maps)
	selected_index = 1;
end
o.colormap_name = avail_maps{selected_index};
steps_list = get(handles.colormap_steps,'String');
o.colormap_steps = str2double(steps_list{get(handles.colormap_steps,'Value')});
posichoice = get(handles.colorbarpos,'String');
o.colorbar_position = posichoice{get(handles.colorbarpos,'Value')};
o.colorbar_format = get(handles.colorbarnumberformat,'Value');
[q, q2] = plot.draw_vectors(target_axis, x, y, u, v, typevector, vecskip, vecscale, vectorcolor, o);
end
