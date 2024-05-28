function derivdropdown(hObject, ~, ~)
handles=gui.gui_gethand;
if get(hObject,'value')==10
	set(handles.LIChint1,'visible','on');
	set(handles.LIChint2,'visible','on');
	%set(handles.LIChint3,'visible','on');
	set(handles.licres,'visible','on');
else
	set(handles.LIChint1,'visible','off');
	set(handles.LIChint2,'visible','off');
	%set(handles.LIChint3,'visible','off');
	set(handles.licres,'visible','off');
end

