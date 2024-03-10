function mask_automask_preview_Callback(~,~,~)
filepath=gui_NameSpace.gui_retr('filepath');
handles=gui_NameSpace.gui_gethand;
if size(filepath,1) > 1 %did the user load images?
	handles=gui_NameSpace.gui_gethand;
	selected=2*floor(get(handles.fileselector, 'value'))-1;
	mask_generator_settings=mask_NameSpace.mask_get_mask_generator_settings();
	[~,piv_image_A]=import_NameSpace.import_get_img(selected);%[piv_image_A,~]=get_img(selected); would respect background subtraction
	[~,piv_image_B]=import_NameSpace.import_get_img(selected+1);

	if size(piv_image_A,3)>1 %color image cannot be displayed properly when bg subtraction is enabled.
		piv_image_A = rgb2gray(piv_image_A);
		piv_image_B = rgb2gray(piv_image_B);
	end

	pixel_mask=mask_NameSpace.mask_pixel_mask_from_piv_image(piv_image_A,piv_image_B,mask_generator_settings);
	piv_image=im2double(piv_image_A)/2 + im2double(piv_image_B)/2;
	if size(piv_image,3)>1 % color image
		piv_image=rgb2gray(piv_image); %convert to gray, always.
	end
	if get(handles.enhance_images, 'Value')
		piv_image=imadjust(piv_image);
	end
	image(cat(3, piv_image, piv_image, piv_image), 'parent',gui_NameSpace.gui_retr('pivlab_axis'), 'cdatamapping', 'scaled');
	hold on;
	colormap('gray');
	axis image
	set(gui_NameSpace.gui_retr('pivlab_axis'),'ytick',[])
	set(gui_NameSpace.gui_retr('pivlab_axis'),'xtick',[])
	image(cat(3, pixel_mask*0.7, pixel_mask*0.1, pixel_mask*0.1), 'parent',gui_NameSpace.gui_retr('pivlab_axis'), 'cdatamapping', 'direct','AlphaData',pixel_mask*0.9);
	hold off
end
