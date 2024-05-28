function apply_deriv_Callback(~, ~, ~)
handles=gui.gui_gethand;
currentframe=floor(get(handles.fileselector, 'value'));
deriv=get(handles.derivchoice, 'value');
plot.plot_derivative_calc (currentframe,deriv,1)
gui.gui_sliderdisp(gui.gui_retr('pivlab_axis'))

