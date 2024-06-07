function preprocess_Callback(~, ~, ~)
filepath=gui.retr('filepath');
if size(filepath,1) > 1 %did the user load images?
	sessionpath=gui.retr('sessionpath');
	if isempty(sessionpath)
		sessionpath=gui.retr('pathname');
	end

	preproc.preview_preprocess_Callback
	preprocessed_img=findobj(gca,'type','image');
	preprocessed_img=(preprocessed_img.CData);
	toggler=gui.retr('toggler');
	if toggler==0
		img_idx='_A';
	else
		img_idx='_B';
	end
	[FileName,PathName] = uiputfile('*.tif','Save preprocessed image as...',fullfile(sessionpath,['PIVlab_preproc' img_idx '.tif']));
	if isequal(FileName,0) | isequal(PathName,0)
	else
		imwrite(preprocessed_img,fullfile(PathName,FileName),'Compression','none');
	end
end

