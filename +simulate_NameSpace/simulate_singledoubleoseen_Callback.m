function simulate_singledoubleoseen_Callback(hObject, ~, ~)
handles=gui_NameSpace.gui_gethand;
contents = get(hObject,'value');
set(handles.oseenx1,'visible','off');
set(handles.oseenx2,'visible','off');
set(handles.oseeny1,'visible','off');
set(handles.oseeny2,'visible','off');
set(handles.text110,'visible','off');
set(handles.text111,'visible','off');
set(handles.text112,'visible','off');
if contents==1
	set(handles.oseenx1,'visible','on');
	set(handles.oseeny1,'visible','on');
elseif contents==2
	set(handles.oseenx1,'visible','on');
	set(handles.oseeny1,'visible','on');
	set(handles.oseenx2,'visible','on');
	set(handles.oseeny2,'visible','on');
	set(handles.text110,'visible','on');
	set(handles.text111,'visible','on');
	set(handles.text112,'visible','on');
end
