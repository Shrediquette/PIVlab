function filenamebox_Callback (~, ~)
handles=gui.gui_gethand;
box_select=get(handles.filenamebox,'value');
set(handles.fileselector, 'value',ceil(box_select/2));
if mod(box_select,2) == 1 %ungerade
	toggler=0;
else
	toggler=1;
end

set(handles.togglepair, 'Value',toggler);
gui.gui_put('toggler',toggler);
try %if user presses buttons too quickly, error occurs.
	gui.gui_sliderdisp(gui.gui_retr('pivlab_axis'))
catch
end

