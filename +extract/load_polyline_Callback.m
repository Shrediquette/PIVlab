function load_polyline_Callback (caller,~)
filepath=gui.retr('filepath');
handles=gui.gethand;
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
				extract.clear_plot_Callback
				gui.put('xposition',xposition);
				gui.put('yposition',yposition);
				gui.put('extract_type',extract_type);
				delete(findobj('tag', 'extractline'))
				delete(findobj('tag','areaint'));
				extract.update_display(extract_type, xposition, yposition);
            else
                gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','You tried to load polyline coordinates from the area extraction panel or vice versa.','modal');
			end
		else
			disp ('No polyline coordinate data found in selected file.')
		end
	end
end

