function import_read_panel_width (FileName,PathName)
gui.gui_put('num_handle_calls',0);
handles=gui.gui_gethand;
try
	load(fullfile(PathName,FileName)); %#ok<*LOAD>
	gui.gui_put ('panelwidth',panelwidth);
catch
end

