function tecplot_all_Callback(~, ~, ~)
handles=gui.gethand;
filepath=gui.retr('filepath');
resultslist=gui.retr('resultslist');
[FileName,PathName] = uiputfile('*.dat','Save vector data as...','PIVlab.dat'); %framenummer in dateiname
if isequal(FileName,0) | isequal(PathName,0)
else
	gui.toolsavailable(0,'Busy, please wait...')
	for i=1:floor(size(filepath,1)/2)
		%if analysis exists
		if size(resultslist,2)>=i && numel(resultslist{1,i})>0
			[Dir, Name, Ext] = fileparts(FileName);
			FileName_nr=[Name sprintf('_%.4d', i) Ext];
			export.file_save(i,FileName_nr,PathName,4)
			set (handles.tecplot_all, 'string', ['Please wait... (' int2str((i-1)/size(filepath,1)*200) '%)']);
			drawnow;
		end
	end
	gui.toolsavailable(1)
	set (handles.tecplot_all, 'string', 'Export all frames');
end

