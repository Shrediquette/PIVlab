function save_all_frames(type, filter, title, default_name, button, idle_label, busy_text)
% Asks for a file name and saves every analysed frame with export.file_save(frame, ..., type),
% numbered name_0001.ext, name_0002.ext, ... The button shows the progress ("Please wait...")
% and gets idle_label back at the end. button: field name in gui.gethand.
handles=gui.gethand;
filepath=gui.retr('filepath');
resultslist=gui.retr('resultslist');
[FileName,PathName] = uiputfile(filter,title,default_name);
if isequal(FileName,0) || isequal(PathName,0)
	return
end
gui.toolsavailable(0,busy_text)
[~, Name, Ext] = fileparts(FileName);
for i=1:floor(size(filepath,1)/2)
	if size(resultslist,2)>=i && numel(resultslist{1,i})>0 %if analysis exists
		export.file_save(i,[Name sprintf('_%.4d', i) Ext],PathName,type)
		set (handles.(button), 'string', ['Please wait... (' int2str((i-1)/size(filepath,1)*200) '%)']);
		drawnow;
	end
end
gui.toolsavailable(1)
set (handles.(button), 'string', idle_label);
