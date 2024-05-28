function low_contrast_threshold_suggest_Callback(~,~,~)
handles=gui.gui_gethand;
filepath=gui.gui_retr('filepath');
if size(filepath,1) > 1 %did the user load images?
	selected=2*floor(get(handles.fileselector, 'value'))-1;
	[~,rawimageA]=import.import_get_img(selected);
	[~,rawimageB]=import.import_get_img(selected+1);

	if size(rawimageA,3)>1
		rawimageA=rawimageA(:,:,1);
	end

	if size(rawimageA,3)>1
		rawimageA=rawimageA(:,:,1);
	end
	rawimage=im2double(rawimageA)/2 + im2double(rawimageB)/2;

	x_orig = 1:size(rawimage,2);
	y_orig = 1:size(rawimage,1);
	[x,y] = meshgrid(x_orig,y_orig);
	u=zeros(size(x));
	v=u;

	[~,~,tresh_suggest,~,~] = PIVlab_image_filter (1,0,x,y,u,v,0,0,rawimage,rawimage,rawimage,rawimage);
	set (handles.low_contrast_mask_threshold,'String',num2str(tresh_suggest));
end

