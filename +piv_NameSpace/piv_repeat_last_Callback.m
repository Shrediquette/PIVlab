function piv_repeat_last_Callback (~,~,~)
handles=gui_NameSpace.gui_gethand;
if get (handles.checkbox26,'Value')==1
	if get(handles.repeat_last,'Value')
		set(handles.edit52x,'Enable','on')
	else
		set(handles.edit52x,'Enable','off')
	end
else
	set(handles.edit52x,'Enable','off')
end
