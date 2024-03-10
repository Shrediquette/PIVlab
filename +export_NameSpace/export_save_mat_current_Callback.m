function export_save_mat_current_Callback(~, ~, ~)
handles=gui_NameSpace.gui_gethand;
resultslist=gui_NameSpace.gui_retr('resultslist');
currentframe=floor(get(handles.fileselector, 'value'));
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
	[FileName,PathName] = uiputfile('*.mat','Save MATLAB file as...','PIVlab.mat'); %framenummer in dateiname
	if isequal(FileName,0) | isequal(PathName,0)
	else
		export_NameSpace.export_mat_file_save(currentframe,FileName,PathName,1); %option 1 = only currentframe
	end
end
