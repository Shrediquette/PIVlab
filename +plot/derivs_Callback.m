function derivs_Callback(~, ~, ~)
handles=gui.gethand;
gui.switchui('multip08');
if (gui.retr('calu')==1 || gui.retr('calu')==-1) && gui.retr('calxy')==1
	set(handles.derivchoice,'String',{'Vectors in px/frame';'Vorticity in 1/frame';'Magnitude in px/frame';'u component in px/frame';'v component in px/frame';'Divergence in 1/frame';'Vortex locator';'Simple shear rate in 1/frame';'Simple strain rate in 1/frame';'Line integral convolution (LIC)' ; 'Vector direction in degrees'; 'Correlation coefficient'});
	set(handles.text35,'String','u in px/frame:')
	set(handles.text36,'String','v in px/frame:')
else
	set(handles.derivchoice,'String',{'Vectors in m/s';'Vorticity in 1/s';'Magnitude in m/s';'u component in m/s';'v component in m/s';'Divergence in 1/s';'Vortex locator';'Simple shear rate in 1/s';'Simple strain rate in 1/s';'Line integral convolution (LIC)'; 'Vector direction in degrees'; 'Correlation coefficient'});
	set(handles.text35,'String','u in m/s:')
	set(handles.text36,'String','v in m/s:')
end
plot.derivchoice_Callback(handles.derivchoice)

