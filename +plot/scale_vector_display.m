function [vecskip, vecscale] = scale_vector_display(handles, x, y, u, v)
%vector skip and scale factor from the GUI settings
%(calculation shared with the command-line API: plot.vector_scale_core)
autoscale_vec=get(handles.autoscale_vec, 'Value');
vecskip=str2double(get(handles.nthvect,'String'));
vectorscale=[];
if autoscale_vec ~= 1
	vectorscale=str2num(get(handles.vectorscale,'string')); %#ok<*ST2NM>
end
vecscale = plot.vector_scale_core(x, y, u, v, autoscale_vec, vecskip, vectorscale);
