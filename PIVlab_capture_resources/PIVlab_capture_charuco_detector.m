function PIVlab_capture_charuco_detector(img,figure_handle,image_handle)
handles=gui.gethand;
patternDims = [str2double(handles.calib_rows.String),str2double(handles.calib_columns.String)];
img_original=img;
if numel(img) > 20000000 % more than 20 megapixels image --> reduce resolution for charuco detection
    large_img=1;
else
    large_img=0;
end
if large_img
    img=img(1:2:end,1:2:end,1);
end
img=mat2gray(img);
img=histeq(img);
[ids,locs] = readArucoMarker(img,'DICT_4X4_1000','WindowSizeRange',[3 23],'MarkerSizeRange',[0.005 1],'ResolutionPerBit',4,'SquarenessTolerance',0.03); %schnellere detektierung wenn bekannt. Am besten: Erstmal so gucken welche Familie dominant. Dann zweiter durchgang mit nur dieser familie

if large_img
    locs=locs*2;
end
ids=ids';
delete(findobj('tag','charucolabel'));
if ~isempty(locs) && size(locs,3) == size(ids,1)
    id_thresh = mean(ids,'omitnan')+2*std(ids,'omitnan');
    ids(ids>id_thresh) = nan;
    locs(:,:,isnan(ids))=[];
    ids(isnan(ids))=[];
    numMarkers = numel(ids);
    locs_center_x=squeeze(mean(locs(:,1,:),'omitnan'));
    locs_center_y=squeeze(mean(locs(:,2,:),'omitnan'));
    mean_loc_x=mean(locs_center_x,'omitnan');
    mean_loc_y=mean(locs_center_y,'omitnan');
    percentage_detected=round(numMarkers/(patternDims(1)*patternDims(2)/2)*100,0);
    if percentage_detected > 100
        percentage_detected = 100;
    end
    infotxt='Not enough markers';
    infotxt2='';
    if percentage_detected > 50
        locs=gui.retr('last_auto_detected_charuco_position');
        if isempty(locs)
            locs=[inf,inf];
        end
        newLoc=[mean_loc_x, mean_loc_y];
        dx = abs(locs(:,1) - newLoc(1));
        dy = abs(locs(:,2) - newLoc(2));
        threshold_location_change_x = size(img,2)/10; %with full panda resolution: ca. 500 px
        threshold_location_change_y = size(img,1)/10;
        isNew = all( dx > threshold_location_change_x | dy > threshold_location_change_y );
        not_moving_threshold = 0.05;
        infotxt='Existing position';
        if isNew
            infotxt='New position';
            old_charuco_img=gui.retr('old_charuco_img');
            if isempty(old_charuco_img)
                gui.put('old_charuco_img',img_original(1:2:end,1:2:end,:));
            else
                diff = abs(double(img_original(1:2:end,1:2:end,:)) - double(old_charuco_img));
                motion_metric = mean(diff(:)) / mean(double(old_charuco_img(:)));
                disp(['Image delta = ' num2str(motion_metric)]);
                if motion_metric < not_moving_threshold
                    acquisition.camera_snapshot_Callback
                    gui.put('last_auto_detected_charuco_position',[locs;newLoc]); %saves a list of all detected centers of board so far detected
                    infotxt2='Steady';
                else
                   infotxt2='Shaking';
                end
                gui.put('old_charuco_img',img_original(1:2:end,1:2:end,:));
            end
        end
    end
    hold on
    scatter(locs_center_x,locs_center_y,'green','tag','charucolabel','Parent',figure_handle)
    hold off
    rectangle('Position',[min(locs_center_x), min(locs_center_y),max(locs_center_x) - min(locs_center_x), max(locs_center_y) - min(locs_center_y) ],'tag','charucolabel','EdgeColor','r','LineWidth',2,'Parent',figure_handle)
    text(mean_loc_x,mean_loc_y,['Markers: ' num2str(percentage_detected) ' %' newline infotxt newline infotxt2],'tag','charucolabel','Color','r','FontSize',36,'FontWeight','bold','HorizontalAlignment','center','VerticalAlignment','middle','Parent',figure_handle)
end

%% Display coverage (it is okay, but find a better way.....)
%{
	locs=gui.retr('last_auto_detected_charuco_position');
	if ~isempty(locs)
		%man müsste den bereich markieren den das angezeigte rectangle einnimt...
		image_width=size(img_original,2);
		image_height=size(img_original,1);

		% Coverage setup
		Nx = 10;
		Ny = 10;

		xEdges = linspace(1, image_width+1, Nx+1);
		yEdges = linspace(1, image_height+1, Ny+1);

		% Occupancy matrix (Nx × Ny logical)
		occ = ones(Nx, Ny)*1.8;

		ix = discretize(locs(:,1), xEdges);
		iy = discretize(locs(:,2), yEdges);

		for k = 1:numel(ix)
			if ~isnan(ix(k)) && ~isnan(iy(k))
				occ(iy(k), ix(k)) = 0.65;
			end
		end
		
		occ_resize=imresize(occ,[image_height, image_width],'nearest');
		set(image_handle,'CData',double(img_original).*occ_resize)
	end
%}