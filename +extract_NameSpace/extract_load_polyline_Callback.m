function extract_load_polyline_Callback (caller,~)
filepath=gui_NameSpace.gui_retr('filepath');
handles=gui_NameSpace.gui_gethand;
if size(filepath,1) > 1 %did the user load images?
	[polyfile,polypath] = uigetfile('*.mat','Load coordinate','PIVlab_coordinates.mat');
	if isequal(polyfile,0) | isequal(polypath,0)
		%do nothing
	else
		loading_correct_data=0;
		load(fullfile(polypath,polyfile),'xposition','yposition','extract_type');
		if ~isempty(xposition) && ~isempty(yposition) && ~isempty(extract_type)
			if strcmp (caller.Parent.Tag,'multip12') %called from polyline panel
				if strcmp(extract_type, 'extract_poly') || strcmp(extract_type, 'extract_circle') || strcmp(extract_type, 'extract_circle_series')
					loading_correct_data=1;
				end
			end
			if strcmp (caller.Parent.Tag,'multip17') %called from area extract panel
				if strcmp(extract_type, 'extract_poly_area') ||  strcmp(extract_type, 'extract_circle_area') ||  strcmp(extract_type, 'extract_circle_series_area') || strcmp(extract_type, 'extract_rectangle_area')
					loading_correct_data=1;
				end
			end
			if loading_correct_data==1
				extract_NameSpace.extract_clear_plot_Callback
				gui_NameSpace.gui_put('xposition',xposition);
				gui_NameSpace.gui_put('yposition',yposition);
				gui_NameSpace.gui_put('extract_type',extract_type);
				delete(findobj('tag', 'extractline'))
				delete(findobj('tag','areaint'));
				extract_NameSpace.extract_update_display(extract_type, xposition, yposition);
			else
				msgbox('You tried to load polyline coordinates from the area extraction panel or vice versa.','Error','error','modal')
			end
		else
			disp ('No polyline coordinate data found in selected file.')
		end
	end
end
