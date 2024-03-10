function plot_derivs_Callback(~, ~, ~)
handles=gui_NameSpace.gui_gethand;
gui_NameSpace.gui_switchui('multip08');
if (gui_NameSpace.gui_retr('calu')==1 || gui_NameSpace.gui_retr('calu')==-1) && gui_NameSpace.gui_retr('calxy')==1
	set(handles.derivchoice,'String',{'Vectors [px/frame]';'Vorticity [1/frame]';'Magnitude [px/frame]';'u component [px/frame]';'v component [px/frame]';'Divergence [1/frame]';'Vortex locator [1]';'Simple shear rate [1/frame]';'Simple strain rate [1/frame]';'Line integral convolution (LIC) [1]' ; 'Vector direction [degrees]'; 'Correlation coefficient [-]'});
	set(handles.text35,'String','u [px/frame]:')
	set(handles.text36,'String','v [px/frame]:')
else
	set(handles.derivchoice,'String',{'Vectors [m/s]';'Vorticity [1/s]';'Magnitude [m/s]';'u component [m/s]';'v component [m/s]';'Divergence [1/s]';'Vortex locator [1]';'Simple shear rate [1/s]';'Simple strain rate [1/s]';'Line integral convolution (LIC) [1]'; 'Vector direction [degrees]'; 'Correlation coefficient [-]'});
	set(handles.text35,'String','u [m/s]:')
	set(handles.text36,'String','v [m/s]:')
end
plot_NameSpace.plot_derivchoice_Callback(handles.derivchoice)
