function load_settings_Callback(~, ~, ~)
[FileName,PathName] = uigetfile('*.mat','Load PIVlab settings','PIVlab_settings.mat');
if ~isequal(FileName,0)
	handles=gui.gethand;
	try
		fileboxcontents=get (handles.filenamebox, 'string');
	catch
	end
	import.read_panel_width (FileName,PathName) %read panel settings, apply, rebuild UI
	gui.destroyUI %needed to adapt panel width etc. to changed values in the settings file.
	gui.generateUI
	import.read_settings (FileName,PathName) %When UI is set up, read settings.
	gui.switchui('multip01')
	try
		gui.put('expected_image_size',[])
		gui.put('existing_handles',[]);
		handles=gui.gethand;
		gui.sliderrange(1)
		set (handles.filenamebox, 'string', fileboxcontents);
		gui.sliderdisp(gui.retr('pivlab_axis'))
	catch
	end
end

