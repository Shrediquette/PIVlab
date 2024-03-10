function acquisition_update_ac_status(status)
handles=gui_NameSpace.gui_gethand;
contents=get(handles.ac_msgbox,'String');
try
	contents=[status;contents];
catch
end
set(handles.ac_msgbox,'String',contents);
