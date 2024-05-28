function tecplot_current_Callback(~, ~, ~)
handles=gui.gui_gethand;
resultslist=gui.gui_retr('resultslist');
currentframe=floor(get(handles.fileselector, 'value'));
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
	[FileName,PathName] = uiputfile('*.dat','Save vector data as...','PIVlab.dat'); %framenummer in dateiname
	if isequal(FileName,0) | isequal(PathName,0) %#ok<*OR2>
	else
		export.export_file_save(currentframe,FileName,PathName,4);
	end
end

