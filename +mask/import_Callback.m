function import_Callback (~,~,~)
filepath=gui.retr('filepath');
tic
if size(filepath,1) > 1 %did the user load images?
	sessionpath=gui.retr('sessionpath');
	if isempty(sessionpath)
		sessionpath=gui.retr('pathname');
	end
	[FileName,PathName] = uigetfile({'*.bmp;*.tif;*.tiff;*.jpg;*.png;','Image Files (*.bmp,*.tif,*.tiff,*.jpg,*.png)'; '*.tif','tif'; '*.tiff','tiff'; '*.jpg','jpg'; '*.bmp','bmp'; '*.png','png'},'Select the binary image mask file(s)',sessionpath, 'multiselect','on');
	if ~isequal(FileName,0) && ~isequal(PathName,0)
		if ischar(FileName)==1
			AnzahlMasks=1;
		else
			AnzahlMasks=numel(FileName);
		end
		pivlab_axis=gui.retr('pivlab_axis');
		handles=gui.gethand;
		gui.toolsavailable(0,'Converting masks, please wait...')
		for i= 1:AnzahlMasks
			%set (handles.mask_import,'String', ['Progress: ' num2str(round(i/AnzahlMasks*100)) ' %']);
			gui.update_progress(round(i/AnzahlMasks*100))
			%drawnow limitrate
			if AnzahlMasks==1
				pixel_mask=imread(fullfile(PathName,FileName));
			else
				pixel_mask=imread(fullfile(PathName,FileName{i}));
			end
			pixel_mask=pixel_mask(:,:,1);
			pixel_mask=imbinarize(pixel_mask);
			CC = bwconncomp(pixel_mask);
			CC2 = bwconncomp(1-pixel_mask);
			numconnected=CC.NumObjects + CC2.NumObjects;
			if numconnected > 100
				disp('Many mask blobs detected. Now filtering the mask input images.')
				pixel_mask = imclose(pixel_mask,strel('disk',5)); %remove small holes
				pixel_mask = bwareaopen(pixel_mask,25); %remove areas with less than 25 pixels area
			end
			pixel_mask = bwareafilt(pixel_mask,[400 inf]); %only try to get blobs with more than 400 pixels
			pixel_mask = bwareafilt(pixel_mask, 100);
			blocations = bwboundaries(pixel_mask,'holes');
			%imshow(A, 'Parent',pivlab_axis);
			handles=gui.gethand;
			masks_in_frame=gui.retr('masks_in_frame');
			masks_in_frame=mask.px_to_rois(blocations,floor(get(handles.fileselector, 'value'))-1+i,masks_in_frame,'off');%apply mask at the current frame and the following frames.
			gui.put('masks_in_frame',masks_in_frame);
		end
		mask.redraw_masks
		gui.sliderdisp(gui.retr('pivlab_axis'))
		%set (handles.mask_import,'String', 'Import pixel mask');
		gui.update_progress(0)
		gui.toolsavailable(1)
	end
end
toc

