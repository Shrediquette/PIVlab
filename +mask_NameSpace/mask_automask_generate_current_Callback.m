function mask_automask_generate_current_Callback (~,~,~)
filepath=gui_NameSpace.gui_retr('filepath');
if size(filepath,1) > 1 %did the user load images?
	handles=gui_NameSpace.gui_gethand;
	selected=2*floor(get(handles.fileselector, 'value'))-1;
	mask_generator_settings=mask_NameSpace.mask_get_mask_generator_settings();
	[~,piv_image_A]=import_NameSpace.import_get_img(selected);
	[~,piv_image_B]=import_NameSpace.import_get_img(selected+1);
	if size(piv_image_A,3)>1 %color image cannot be displayed properly when bg subtraction is enabled.
		piv_image_A = rgb2gray(piv_image_A);
		piv_image_B = rgb2gray(piv_image_B);
	end
	pixel_mask=mask_NameSpace.mask_pixel_mask_from_piv_image(piv_image_A,piv_image_B,mask_generator_settings);
	blocations = bwboundaries(pixel_mask,'holes');
	currentframe=floor(get(handles.fileselector, 'value'));
	masks_in_frame=gui_NameSpace.gui_retr('masks_in_frame');
	masks_in_frame{currentframe}=[];%remove any pre-existing mask in the curretn frame
	masks_in_frame=mask_NameSpace.mask_px_to_rois(blocations,currentframe,masks_in_frame);
	gui_NameSpace.gui_put('masks_in_frame',masks_in_frame);
	mask_NameSpace.mask_redraw_masks
	gui_NameSpace.gui_sliderdisp(gui_NameSpace.gui_retr('pivlab_axis'));
end
