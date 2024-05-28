function apply_deriv_Callback(~, ~, ~)
handles=gui.gethand;
currentframe=floor(get(handles.fileselector, 'value'));
deriv=get(handles.derivchoice, 'value');
plot.derivative_calc (currentframe,deriv,1)
gui.sliderdisp(gui.retr('pivlab_axis'))

