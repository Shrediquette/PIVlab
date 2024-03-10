function gui_filenamebox_Callback (~, ~)
handles=gui_NameSpace.gui_gethand;
box_select=get(handles.filenamebox,'value');
set(handles.fileselector, 'value',ceil(box_select/2));
if mod(box_select,2) == 1 %ungerade
	toggler=0;
else
	toggler=1;
end

set(handles.togglepair, 'Value',toggler);
gui_NameSpace.gui_put('toggler',toggler);
try %if user presses buttons too quickly, error occurs.
	gui_NameSpace.gui_sliderdisp(gui_NameSpace.gui_retr('pivlab_axis'))
catch
end
