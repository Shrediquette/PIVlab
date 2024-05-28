function suppress_vec_Callback (hObject,~)
handles=gui.gui_gethand;
if get(hObject,'Value')==1
	set(handles.nthvect,'String','100000');
	set(handles.vectorscale,'String','0');
else
	set(handles.nthvect,'String','1');
	set(handles.vectorscale,'String','8');
end

