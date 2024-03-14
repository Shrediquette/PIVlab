function plot_licres_Callback(~,~,~)
handles=gui.gui_gethand;
value=num2str(round(get(handles.licres,'Value')*10)/10);
set(handles.LIChint2,'String',value)

