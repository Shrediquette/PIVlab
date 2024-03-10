function plot_apply_deriv_all_Callback(~, ~, ~)
handles=gui_NameSpace.gui_gethand;
filepath=gui_NameSpace.gui_retr('filepath');
gui_NameSpace.gui_toolsavailable(0,'Busy, please wait...')
for i=1:floor(size(filepath,1)/2)+1
	deriv=get(handles.derivchoice, 'value');
	plot_NameSpace.plot_derivative_calc(i,deriv,1)
	set (handles.apply_deriv_all, 'string', ['Please wait... (' int2str((i-1)/size(filepath,1)*200) '%)']);
	drawnow;
end
set (handles.apply_deriv_all, 'string', 'Apply to all frames');
gui_NameSpace.gui_toolsavailable(1)
gui_NameSpace.gui_sliderdisp(gui_NameSpace.gui_retr('pivlab_axis'))
