function export_ascii_all_Callback(~, ~, ~)
handles=gui_NameSpace.gui_gethand;
filepath=gui_NameSpace.gui_retr('filepath');
resultslist=gui_NameSpace.gui_retr('resultslist');
[FileName,PathName] = uiputfile('*.txt','Save vector data as...','PIVlab.txt'); %framenummer in dateiname
if isequal(FileName,0) | isequal(PathName,0)
else
	gui_NameSpace.gui_toolsavailable(0,'Busy, please wait...')
	for i=1:floor(size(filepath,1)/2)
		%if analysis exists
		if size(resultslist,2)>=i && numel(resultslist{1,i})>0
			[Dir, Name, Ext] = fileparts(FileName);
			FileName_nr=[Name sprintf('_%.4d', i) Ext];
			export_NameSpace.export_file_save(i,FileName_nr,PathName,1)
			set (handles.ascii_all, 'string', ['Please wait... (' int2str((i-1)/size(filepath,1)*200) '%)']);
			drawnow;
		end
	end
	gui_NameSpace.gui_toolsavailable(1)
	set (handles.ascii_all, 'string', 'Export all frames');
end
