function simulate_flow_sim_Callback(hObject, ~, ~)
handles=gui_NameSpace.gui_gethand;
contents = get(hObject,'value');
set(handles.rankinepanel,'visible','off');
set(handles.shiftpanel,'visible','off');
set(handles.rotationpanel,'visible','off');
set(handles.oseenpanel,'visible','off');
if contents==1
	set(handles.rankinepanel,'visible','on');
elseif contents==2
	set(handles.oseenpanel,'visible','on');
elseif contents==3
	set(handles.shiftpanel,'visible','on');
elseif contents==4
	set(handles.rotationpanel,'visible','on');
end
