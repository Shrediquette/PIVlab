function licres_Callback(~,~,~)
handles=gui.gethand;
value=num2str(round(get(handles.licres,'Value')*10)/10);
set(handles.LIChint2,'String',value)

