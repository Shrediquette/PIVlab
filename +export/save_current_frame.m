function save_current_frame(save_function, filter, title, default_name)
% If the frame shown is analysed: asks for a file name and calls save_function(frame, FileName,
% PathName), e.g. @(f,n,p) export.file_save(f,n,p,1).
handles=gui.gethand;
resultslist=gui.retr('resultslist');
currentframe=floor(get(handles.fileselector, 'value'));
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
	[FileName,PathName] = uiputfile(filter,title,default_name);
	if ~isequal(FileName,0) && ~isequal(PathName,0)
		save_function(currentframe,FileName,PathName);
	end
end
