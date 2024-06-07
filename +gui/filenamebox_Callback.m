function filenamebox_Callback (~, ~)
handles=gui.gethand;
box_select=get(handles.filenamebox,'value');
set(handles.fileselector, 'value',ceil(box_select/2));
if mod(box_select,2) == 1 %ungerade
	toggler=0;
else
	toggler=1;
end

set(handles.togglepair, 'Value',toggler);
gui.put('toggler',toggler);
try %if user presses buttons too quickly, error occurs.
	gui.sliderdisp(gui.retr('pivlab_axis'))
catch
end

