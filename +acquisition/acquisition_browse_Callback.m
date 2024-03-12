function acquisition_browse_Callback(~,~,~)
handles=gui.gui_gethand;
folder_name = uigetdir(gui.gui_retr('pathname'),'Select image folder for saving');
if ~isequal(folder_name,0)
	set(handles.ac_project,'String',folder_name);
	gui.gui_put('pathname',folder_name);
end

