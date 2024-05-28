function read_panel_width (FileName,PathName)
gui.put('num_handle_calls',0);
handles=gui.gethand;
try
	load(fullfile(PathName,FileName)); %#ok<*LOAD>
	gui.put ('panelwidth',panelwidth);
catch
end

