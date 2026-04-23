function bg_load_Callback(~,~,~)
%Load bg images from previously saved file or from PIVlab session
handles=gui.gethand;
sessionpath=gui.retr('sessionpath');
if isempty(sessionpath)
	sessionpath=gui.retr('pathname');
end
[FileName,PathName]  = uigetfile({'*.mat','PIVlab background'; '*.tif','TIF image background'; '*.png','PNG image background'; '*.jpg','JPG image background'},'Load background',fullfile(sessionpath, 'background.mat'));
pause(0.01)
if ~isequal(FileName,0) && ~isequal(PathName,0)
	[~,~,ext] =fileparts(FileName);
	piv_filepath = gui.retr('filepath');
	piv_images_loaded = ~isempty(piv_filepath);
	if strcmpi(ext,'.mat') % user import pivlab mat background
		load(fullfile(PathName,FileName),'bg_mode','bg_img_A','bg_img_B');
		if exist ('bg_mode',"var") && exist ('bg_img_A',"var") && exist ('bg_img_B',"var") && ~isempty(bg_img_A) && ~isempty(bg_img_B) && (bg_mode == 2 || bg_mode==3)
			if piv_images_loaded
				pivsize=size(import.get_img(1));
				bgsize=size(bg_img_A);
				if (pivsize(1) ~= bgsize(1)) || (pivsize(2) ~= bgsize(2))
					gui.custom_msgbox("error",getappdata(0,'hgui'),'Error','The background image does not have the same size as your PIV images.','modal');
					return
				end
			end
			set(handles.bg_subtract,'Value',bg_mode)
			gui.put('bg_img_A',bg_img_A);
			gui.put('bg_img_B',bg_img_B);
		else
			gui.custom_msgbox("error",getappdata(0,'hgui'),'Error','This file is not containing valid background images. There must be three vars in the mat file: bg_mode, bg_img_A and bg_img_B. bg_mode must be 2 or 3, the other vars need to be image data with the same size as your PIV data.','modal');
		end
	elseif strcmpi(ext,'.tif') || strcmpi(ext,'.png') || strcmpi(ext,'.jpg') % user imports custom image file
		A=imread(fullfile(PathName,FileName));
		if piv_images_loaded
			pivsize=size(import.get_img(1));
			bgsize=size(A);
			if (pivsize(1) ~= bgsize(1)) || (pivsize(2) ~= bgsize(2))
				gui.custom_msgbox("error",getappdata(0,'hgui'),'Error','The background image does not have the same size as your PIV images.','modal');
				return
			end
		end
		set(handles.bg_subtract,'Value',2) % we don't know which mode was used to generate the images, so we just set some mode
		gui.put('bg_img_A',A); % we assign the same background image to A and B.
		gui.put('bg_img_B',A);
	end
end