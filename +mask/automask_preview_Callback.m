function automask_preview_Callback(~,~,~)
filepath=gui.retr('filepath');
handles=gui.gethand;
if size(filepath,1) > 1 %did the user load images?
	handles=gui.gethand;
	selected=2*floor(get(handles.fileselector, 'value'))-1;
	mask_generator_settings=mask.get_mask_generator_settings();
	[~,piv_image_A]=import.get_img(selected);%[piv_image_A,~]=get_img(selected); would respect background subtraction
	[~,piv_image_B]=import.get_img(selected+1);

	if size(piv_image_A,3)>1 %color image cannot be displayed properly when bg subtraction is enabled.
		piv_image_A = rgb2gray(piv_image_A);
		piv_image_B = rgb2gray(piv_image_B);
	end

	pixel_mask=mask.pixel_mask_from_piv_image(piv_image_A,piv_image_B,mask_generator_settings);
	piv_image=im2double(piv_image_A)/2 + im2double(piv_image_B)/2;
	if size(piv_image,3)>1 % color image
		piv_image=rgb2gray(piv_image); %convert to gray, always.
	end
	if get(handles.enhance_images, 'Value')
		piv_image=imadjust(piv_image);
	end
	image(cat(3, piv_image, piv_image, piv_image), 'parent',gui.retr('pivlab_axis'), 'cdatamapping', 'scaled');
	hold on;
	colormap('gray');
	axis image
	set(gui.retr('pivlab_axis'),'ytick',[])
	set(gui.retr('pivlab_axis'),'xtick',[])

	alphamap=pixel_mask*0.9;
	alphamap(alphamap>1)=1;
	alphamap(alphamap<0)=0;
	%temporary workaround for bug in R2025 causing slow performance when not using alphadatamapping=scaled
	alphamap(1,1)=0;
	alphamap(end,end)=1;
	image(cat(3, pixel_mask*0.7, pixel_mask*0.1, pixel_mask*0.1), 'parent',gui.retr('pivlab_axis'), 'cdatamapping', 'direct','AlphaData',alphamap,'AlphaDataMapping','scaled');
	hold off
end

