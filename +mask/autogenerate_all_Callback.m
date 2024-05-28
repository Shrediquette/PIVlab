function autogenerate_all_Callback (~,~,~)
handles=gui.gui_gethand;
filepath=gui.gui_retr('filepath');
if size(filepath,1) > 1 %did the user load images?
	handles=gui.gui_gethand;
	if gui.gui_retr('video_selection_done') == 0
		num_frames_to_process=floor(size(filepath,1)/2)+1;
	else
		video_frame_selection=gui.gui_retr('video_frame_selection');
		num_frames_to_process=floor(numel(video_frame_selection)/2)+1;
	end
	mask_generator_settings=mask.mask_get_mask_generator_settings();
	gui.gui_put('masks_in_frame',[]);%remove existing masks before calculating new ones.
	%masks_in_frame=retr('masks_in_frame');
	%resulting_masks_in_frame_cell=cell(0);
	%if retr('video_selection_done') == 1 || retr('parallel')==0 %if post-processing a video, parallelization cannot be used.
	if gui.gui_retr('video_selection_done')==0
		num_frames_to_process = size(filepath,1);
	else
		video_frame_selection=gui.gui_retr('video_frame_selection');
		num_frames_to_process = numel(video_frame_selection);
	end
	gui.gui_toolsavailable(0,'Busy, please wait...')
	for i=1:2:num_frames_to_process
		[~,piv_image_A]=import.import_get_img(i);
		[~,piv_image_B]=import.import_get_img(i+1);
		if size(piv_image_A,3)>1 %color image cannot be displayed properly when bg subtraction is enabled.
			piv_image_A = rgb2gray(piv_image_A);
			piv_image_B = rgb2gray(piv_image_B);
		end
		pixel_mask=mask.mask_pixel_mask_from_piv_image(piv_image_A,piv_image_B,mask_generator_settings);
		gui.gui_update_progress((round(i/num_frames_to_process*100)))
		blocations = bwboundaries(pixel_mask,'holes');
		masks_in_frame=gui.gui_retr('masks_in_frame');
		masks_in_frame=mask.mask_px_to_rois(blocations,(i+1)/2,masks_in_frame);
		gui.gui_put('masks_in_frame',masks_in_frame);
		mask.mask_redraw_masks
	end
	gui.gui_update_progress(0)
	gui.gui_toolsavailable(1)
	%{
	else %not using a video file --> parallel processing possible
		slicedfilepath1=cell(0);
		slicedfilepath2=cell(0);
		for i=1:2:size(filepath,1)%num_frames_to_process
			k=(i+1)/2;
			slicedfilepath1{k}=filepath{i};
			slicedfilepath2{k}=filepath{i+1};
		end
		parfor i=1:num_frames_to_process-1
			%% load images in a parfor loop
			[~,~,ext] = fileparts(slicedfilepath1{i});
			if strcmp(ext,'.b16')
				currentimage1=f_readB16(slicedfilepath1{i});
				currentimage2=f_readB16(slicedfilepath2{i});
			else
				currentimage1=imread(slicedfilepath1{i});
				currentimage2=imread(slicedfilepath2{i});
			end
			pixel_mask=pixel_mask_from_piv_image(currentimage1,currentimage2,mask_generator_settings);
			blocations = bwboundaries(pixel_mask,'holes');
			resulting_masks_in_frame_cell{i}=px_to_rois(blocations,i,masks_in_frame);
		end
		for i=1:num_frames_to_process-1
		masks_in_frame{i,1}=resulting_masks_in_frame_cell{i}{i};
	end
	end
	%}
	%	put('masks_in_frame',masks_in_frame);
	%	redraw_masks
end
gui.gui_sliderdisp(gui.gui_retr('pivlab_axis'));

