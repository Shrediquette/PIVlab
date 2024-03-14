function import_load_settings_Callback(~, ~, ~)
[FileName,PathName] = uigetfile('*.mat','Load PIVlab settings','PIVlab_settings.mat');
if ~isequal(FileName,0)
	handles=gui.gui_gethand;
	try
		fileboxcontents=get (handles.filenamebox, 'string');
	catch
	end
	import.import_read_panel_width (FileName,PathName) %read panel settings, apply, rebuild UI
	gui.gui_destroyUI %needed to adapt panel width etc. to changed values in the settings file.
	gui.gui_generateUI
	import.import_read_settings (FileName,PathName) %When UI is set up, read settings.
	gui.gui_switchui('multip01')
	try
		gui.gui_put('expected_image_size',[])
		gui.gui_put('existing_handles',[]);
		handles=gui.gui_gethand;
		gui.gui_sliderrange(1)
		set (handles.filenamebox, 'string', fileboxcontents);
		gui.gui_sliderdisp(gui.gui_retr('pivlab_axis'))
	catch
	end
end

