function apply_deriv_all_Callback(~, ~, ~)
handles=gui.gethand;
filepath=gui.retr('filepath');
gui.toolsavailable(0,'Busy, please wait...')
for i=1:floor(size(filepath,1)/2)+1
	deriv=get(handles.derivchoice, 'value');
	plot.derivative_calc(i,deriv,1)
	%set (handles.apply_deriv_all, 'string', ['Please wait... (' int2str((i-1)/size(filepath,1)*200) '%)']);
	gui.update_progress((i-1)/size(filepath,1)*200)
end
%set (handles.apply_deriv_all, 'string', 'Apply to all frames');
gui.toolsavailable(1)
gui.update_progress(0)
gui.sliderdisp(gui.retr('pivlab_axis'))