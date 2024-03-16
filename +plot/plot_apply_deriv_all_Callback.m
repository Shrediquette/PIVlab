function plot_apply_deriv_all_Callback(~, ~, ~)
handles=gui.gui_gethand;
filepath=gui.gui_retr('filepath');
gui.gui_toolsavailable(0,'Busy, please wait...')
tic
for i=1:floor(size(filepath,1)/2)+1
	deriv=get(handles.derivchoice, 'value');
	plot.plot_derivative_calc(i,deriv,1)
	set (handles.apply_deriv_all, 'string', ['Please wait... (' int2str((i-1)/size(filepath,1)*200) '%)']);
	gui.gui_update_progress((i-1)/size(filepath,1)*200)
end
set (handles.apply_deriv_all, 'string', 'Apply to all frames');
gui.gui_toolsavailable(1)
gui.gui_update_progress(0)
gui.gui_sliderdisp(gui.gui_retr('pivlab_axis'))
toc

