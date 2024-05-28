function autogenerate_current_Callback (~,~,~)
filepath=gui.retr('filepath');
if size(filepath,1) > 1 %did the user load images?
	handles=gui.gethand;
	selected=2*floor(get(handles.fileselector, 'value'))-1;
	mask_generator_settings=mask.get_mask_generator_settings();
	[~,piv_image_A]=import.get_img(selected);
	[~,piv_image_B]=import.get_img(selected+1);
	if size(piv_image_A,3)>1 %color image cannot be displayed properly when bg subtraction is enabled.
		piv_image_A = rgb2gray(piv_image_A);
		piv_image_B = rgb2gray(piv_image_B);
	end
	pixel_mask=mask.pixel_mask_from_piv_image(piv_image_A,piv_image_B,mask_generator_settings);
	blocations = bwboundaries(pixel_mask,'holes');
	currentframe=floor(get(handles.fileselector, 'value'));
	masks_in_frame=gui.retr('masks_in_frame');
	masks_in_frame{currentframe}=[];%remove any pre-existing mask in the curretn frame
	masks_in_frame=mask.px_to_rois(blocations,currentframe,masks_in_frame);
	gui.put('masks_in_frame',masks_in_frame);
	mask.redraw_masks
	gui.sliderdisp(gui.retr('pivlab_axis'));
end

