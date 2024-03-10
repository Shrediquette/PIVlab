function import_load_settings_Callback(~, ~, ~)
[FileName,PathName] = uigetfile('*.mat','Load PIVlab settings','PIVlab_settings.mat');
if ~isequal(FileName,0)
	handles=gui_NameSpace.gui_gethand;
	try
		fileboxcontents=get (handles.filenamebox, 'string');
	catch
	end
	import_NameSpace.import_read_panel_width (FileName,PathName) %read panel settings, apply, rebuild UI
	gui_NameSpace.gui_destroyUI %needed to adapt panel width etc. to changed values in the settings file.
	gui_NameSpace.gui_generateUI
	import_NameSpace.import_read_settings (FileName,PathName) %When UI is set up, read settings.
	gui_NameSpace.gui_switchui('multip01')
	try
		gui_NameSpace.gui_put('expected_image_size',[])
		gui_NameSpace.gui_put('existing_handles',[]);
		handles=gui_NameSpace.gui_gethand;
		gui_NameSpace.gui_sliderrange(1)
		set (handles.filenamebox, 'string', fileboxcontents);
		gui_NameSpace.gui_sliderdisp(gui_NameSpace.gui_retr('pivlab_axis'))
	catch
	end
end
