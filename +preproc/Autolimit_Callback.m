function Autolimit_Callback(~, ~, ~)
handles=gui.gui_gethand;
if get(handles.Autolimit, 'value') == 1
	filepath=gui.gui_retr('filepath');
	if size(filepath,1) >1 || gui.gui_retr('video_selection_done') == 1
		toggler=gui.gui_retr('toggler');
		filepath=gui.gui_retr('filepath');
		selected=2*floor(get(handles.fileselector, 'value'))-(1-toggler);
		[img,~]=import.import_get_img(selected);
		if size(img,3)>1
			img = rgb2gray(img);
		end
		stretcher = stretchlim(img,[0.01 0.995]);
		set(handles.minintens, 'String',stretcher(1));
		set(handles.maxintens, 'String',stretcher(2));
	end
end

