function import_read_panel_width (FileName,PathName)
gui_NameSpace.gui_put('num_handle_calls',0);
handles=gui_NameSpace.gui_gethand;
try
	load(fullfile(PathName,FileName)); %#ok<*LOAD>
	gui_NameSpace.gui_put ('panelwidth',panelwidth);
catch
end
