function load_settings_Callback(~, ~, ~)
% File -> Load settings: applies the groups analysis, calibration and masks of a settings file
% (or of a session). Results and images are kept.
[FileName,PathName] = uigetfile('*.mat','Load PIVlab settings','PIVlab_settings.mat');
if isequal(FileName,0)
	return
end
[settings, message] = import.read_settings_file(fullfile(PathName,FileName));
if isempty(settings)
	gui.custom_msgbox('error',getappdata(0,'hgui'),'Load settings',message,'modal');
	return
end
handles = gui.gethand;
bg_mode_before = get(handles.bg_subtract,'Value');
gui.apply_settings(settings, {'analysis','calibration','masks'}, false);
if isfield(settings,'calibration_data')
	calibrate.apply_calibration_data(settings.calibration_data);
else
	calibrate.apply_calibration_data(struct());
end
filepath = gui.retr('filepath');
images_loaded = size(filepath,1) > 1 || gui.retr('video_selection_done') == 1;
if get(handles.bg_subtract,'Value') ~= bg_mode_before
	% background images of the previous mode do not fit anymore
	gui.put('bg_img_A',[]);
	gui.put('bg_img_B',[]);
	if get(handles.bg_subtract,'Value') > 1 && images_loaded % make them like the pre-processing preview
		if gui.retr('video_selection_done') == 0 && gui.retr('parallel')==1
			preproc.generate_BG_img_parallel
		else
			preproc.generate_BG_img
		end
	end
end
if images_loaded
	gui.sliderdisp(gui.retr('pivlab_axis'))
end
end
