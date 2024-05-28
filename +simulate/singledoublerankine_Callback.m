function singledoublerankine_Callback(hObject, ~, ~)
handles=gui.gui_gethand;
contents = get(hObject,'value');
set(handles.rankx1,'visible','off');
set(handles.rankx2,'visible','off');
set(handles.ranky1,'visible','off');
set(handles.ranky2,'visible','off');
set(handles.text102,'visible','off');
set(handles.text103,'visible','off');
set(handles.text104,'visible','off');
if contents==1
	set(handles.rankx1,'visible','on');
	set(handles.ranky1,'visible','on');
elseif contents==2
	set(handles.rankx1,'visible','on');
	set(handles.ranky1,'visible','on');
	set(handles.rankx2,'visible','on');
	set(handles.ranky2,'visible','on');
	set(handles.text102,'visible','on');
	set(handles.text103,'visible','on');
	set(handles.text104,'visible','on');
end

