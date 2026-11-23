function save_session_Callback(auto_save_session, auto_save_session_filename)
sessionpath=gui.retr('sessionpath');
if isempty(sessionpath)
	sessionpath=gui.retr('pathname');
end
if auto_save_session ~= 1
	[FileName,PathName] = uiputfile('*.mat','Save current session as...',fullfile(sessionpath,'PIVlab_session.mat'));
else
	[PathName,FileName,ext] = fileparts(auto_save_session_filename);
	FileName = [FileName ext];
end
if ~isequal(FileName,0) && ~isequal(PathName,0)
	gui.put('sessionpath',PathName );
	export.save_session_function (PathName,FileName)
end
