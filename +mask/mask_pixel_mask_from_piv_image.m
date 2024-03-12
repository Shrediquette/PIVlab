function pixel_mask=mask_pixel_mask_from_piv_image(piv_image_A,piv_image_B,mask_generator_settings)

%% bright mask
if size(piv_image_A,3)>1
	piv_image_A=piv_image_A(:,:,1);
end

if size(piv_image_B,3)>1
	piv_image_B=piv_image_B(:,:,1);
end
piv_image=im2double(piv_image_A)/2 + im2double(piv_image_B)/2;

piv_image_2=piv_image;
piv_image_3=piv_image;

if mask_generator_settings.binarize_enable
	if mask_generator_settings.mask_medfilt_enable
		median_size = str2double(mask_generator_settings.median_size);
		piv_image=medfilt2(piv_image,[median_size median_size]);
	end
	piv_image=im2bw(piv_image,str2double(mask_generator_settings.binarize_threshold)); %#ok<IM2BW>

	if mask_generator_settings.mask_imopen_imclose_enable
		SE=strel('disk',str2double(mask_generator_settings.imopen_imclose_size));
		if mask_generator_settings.imopen_imclose_selection==1 %imopen
			piv_image=imopen(piv_image,SE);
		else
			piv_image=imclose(piv_image,SE);
		end
	end

	if mask_generator_settings.mask_imdilate_imerode_enable
		SE=strel('disk',str2double(mask_generator_settings.imdilate_imerode_size));
		if mask_generator_settings.imdilate_imerode_selection==1 %dilate
			piv_image=imdilate(piv_image,SE);
		else
			piv_image=imerode(piv_image,SE);
		end
	end
	if mask_generator_settings.mask_remove_enable
		range=[str2double(mask_generator_settings.remove_size) inf];
		piv_image = bwareafilt(piv_image,range);
	end
	if mask_generator_settings.mask_fill_enable
		piv_image = imfill(piv_image,"holes");
	end
else
	piv_image=zeros(size(piv_image));
end

%% dark mask
if mask_generator_settings.binarize_enable_2
	if mask_generator_settings.mask_medfilt_enable_2
		median_size = str2double(mask_generator_settings.median_size_2);
		piv_image_2=medfilt2(piv_image_2,[median_size median_size]);
	end
	piv_image_2=im2bw(piv_image_2,str2double(mask_generator_settings.binarize_threshold_2)); %#ok<IM2BW>
	piv_image_2=~piv_image_2;


	if mask_generator_settings.mask_imopen_imclose_enable_2
		SE=strel('disk',str2double(mask_generator_settings.imopen_imclose_size_2));
		if mask_generator_settings.imopen_imclose_selection_2==1 %imopen
			piv_image_2=imopen(piv_image_2,SE);
		else
			piv_image_2=imclose(piv_image_2,SE);
		end
	end

	if mask_generator_settings.mask_imdilate_imerode_enable_2
		SE=strel('disk',str2double(mask_generator_settings.imdilate_imerode_size_2));
		if mask_generator_settings.imdilate_imerode_selection_2==1 %dilate
			piv_image_2=imdilate(piv_image_2,SE);
		else
			piv_image_2=imerode(piv_image_2,SE);
		end
	end

	if mask_generator_settings.mask_remove_enable_2
		range=[str2double(mask_generator_settings.remove_size_2) inf];
		piv_image_2 = bwareafilt(piv_image_2,range);
	end
	if mask_generator_settings.mask_fill_enable_2
		piv_image_2 = imfill(piv_image_2,"holes");
	end
else
	piv_image_2=zeros(size(piv_image));
end

%% low contrast mask
if mask_generator_settings.low_contrast_mask_enable
	x_orig = 1:size(piv_image,2);
	y_orig = 1:size(piv_image,1);
	[x,y] = meshgrid(x_orig,y_orig);
	u=zeros(size(x));
	v=u;
	[~,~,~,piv_image_3,~] = PIVlab_image_filter (1,0,x,y,u,v,0,0,piv_image_3,piv_image_3,piv_image_3,piv_image_3);

	if mask_generator_settings.mask_medfilt_enable_3
		median_size = str2double(mask_generator_settings.median_size_3);
		piv_image_3=medfilt2(piv_image_3,[median_size median_size]);
	end
	piv_image_3=im2bw(piv_image_3,str2double(mask_generator_settings.low_contrast_mask_threshold)); %#ok<IM2BW>
	piv_image_3=~piv_image_3;

	if mask_generator_settings.mask_imopen_imclose_enable_3
		SE=strel('disk',str2double(mask_generator_settings.imopen_imclose_size_3));
		if mask_generator_settings.imopen_imclose_selection_3==1 %imopen
			piv_image_3=imopen(piv_image_3,SE);
		else
			piv_image_3=imclose(piv_image_3,SE);
		end
	end

	if mask_generator_settings.mask_imdilate_imerode_enable_3
		SE=strel('disk',str2double(mask_generator_settings.imdilate_imerode_size_3));
		if mask_generator_settings.imdilate_imerode_selection_3==1 %dilate
			piv_image_3=imdilate(piv_image_3,SE);
		else
			piv_image_3=imerode(piv_image_3,SE);
		end
	end

	if mask_generator_settings.mask_remove_enable_3
		range=[str2double(mask_generator_settings.remove_size_3) inf];
		piv_image_3 = bwareafilt(piv_image_3,range);
	end
	if mask_generator_settings.mask_fill_enable_3
		piv_image_3 = imfill(piv_image_3,"holes");
	end

else
	piv_image_3=zeros(size(piv_image));
end

pixel_mask = piv_image | piv_image_2 | piv_image_3;

