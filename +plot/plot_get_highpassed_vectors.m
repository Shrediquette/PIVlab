function [u, v] = plot_get_highpassed_vectors(handles, u, v)
if get(handles.highp_vectors, 'value')==1 & strncmp(get(handles.multip08, 'visible'), 'on',2) %#ok<AND2> %disable second expression to make highpass filtered data available for export
	strength=54-round(get(handles.highpass_strength, 'value'));
	h = fspecial('gaussian',strength,strength) ;
	h2= fspecial('gaussian',3,3);
	ubg=imfilter(u,h,'replicate');
	vbg=imfilter(v,h,'replicate');
	ufilt=u-ubg;
	vfilt=v-vbg;
	u=imfilter(ufilt,h2,'replicate');
	v=imfilter(vfilt,h2,'replicate');
end

