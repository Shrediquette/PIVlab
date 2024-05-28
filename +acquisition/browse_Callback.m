function browse_Callback(~,~,~)
handles=gui.gethand;
folder_name = uigetdir(gui.retr('pathname'),'Select image folder for saving');
if ~isequal(folder_name,0)
	set(handles.ac_project,'String',folder_name);
	gui.put('pathname',folder_name);
end

