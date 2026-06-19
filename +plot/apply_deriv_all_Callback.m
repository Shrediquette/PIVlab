function apply_deriv_all_Callback(~, ~, ~)
handles=gui.gethand;
filepath=gui.retr('filepath');
gui.toolsavailable(0,'Busy, please wait...')
nframes=floor(size(filepath,1)/2)+1;
deriv=get(handles.derivchoice, 'value');
smooth_mode=get(handles.smooth_mode, 'Value');
if smooth_mode==3 || smooth_mode==4
	%temporal smoothing: do the 2D smoothing once per frame and a single temporal pass
	%(plot.temporal_smooth_all), then compute the derived quantities from the finished
	%smoothed field. Avoids recomputing the 2D smoothing of every window neighbour per frame.
	plot.temporal_smooth_all();
	for i=1:nframes
		plot.derivative_calc(i,deriv,1,true) %use_smoothed --> derived from {10/11}, no re-smoothing
		gui.update_progress((i-1)/size(filepath,1)*200)
	end
else
	for i=1:nframes
		plot.derivative_calc(i,deriv,1)
		%set (handles.apply_deriv_all, 'string', ['Please wait... (' int2str((i-1)/size(filepath,1)*200) '%)']);
		gui.update_progress((i-1)/size(filepath,1)*200)
	end
end
%set (handles.apply_deriv_all, 'string', 'Apply to all frames');
gui.toolsavailable(1)
gui.update_progress(0)
gui.sliderdisp(gui.retr('pivlab_axis'))