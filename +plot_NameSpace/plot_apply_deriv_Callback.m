function plot_apply_deriv_Callback(~, ~, ~)
handles=gui_NameSpace.gui_gethand;
currentframe=floor(get(handles.fileselector, 'value'));
deriv=get(handles.derivchoice, 'value');
plot_NameSpace.plot_derivative_calc (currentframe,deriv,1)
gui_NameSpace.gui_sliderdisp(gui_NameSpace.gui_retr('pivlab_axis'))
