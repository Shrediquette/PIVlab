function export_save_session_Callback(auto_save_session, auto_save_session_filename)
sessionpath=gui_NameSpace.gui_retr('sessionpath');
if isempty(sessionpath)
	sessionpath=gui_NameSpace.gui_retr('pathname');
end
if auto_save_session ~= 1
	[FileName,PathName] = uiputfile('*.mat','Save current session as...',fullfile(sessionpath,'PIVlab_session.mat'));
else
	[PathName,FileName,ext] = fileparts(auto_save_session_filename);
	FileName = [FileName ext];
end


if isequal(FileName,0) | isequal(PathName,0)
else
	gui_NameSpace.gui_put('expected_image_size',[])
	gui_NameSpace.gui_put('sessionpath',PathName );
	gui_NameSpace.gui_put('existing_handles',[]);gui_NameSpace.gui_put('num_handle_calls',[])
	clear ('existing_handles','num_handle_calls');
	export_NameSpace.export_save_session_function (PathName,FileName)
end
