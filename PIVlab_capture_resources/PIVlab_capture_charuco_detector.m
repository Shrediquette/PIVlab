function PIVlab_capture_charuco_detector(img,figure_handle,~)
handles=gui.gethand;
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
[ids,locs] = readArucoMarker(img,'DICT_4X4_1000','WindowSizeRange',[3 23],'MarkerSizeRange',[0.005 1],'ResolutionPerBit',16,'SquarenessTolerance',0.03); %schnellere detektierung wenn bekannt. Am besten: Erstmal so gucken welche Familie dominant. Dann zweiter durchgang mit nur dieser familie
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
	min_x = min(locs(:,1));
	max_x = max(locs(:,1));
	min_y = min(locs(:,2));
	max_y = max(locs(:,2));
	newBox = [min_x max_x min_y max_y];
	%mask charucos during QR detection
	mask = ones(size(img));
	if large_img
		mask(floor(min(locs_center_y/2)):ceil(max(locs_center_y/2)), floor(min(locs_center_x/2)) : ceil(max(locs_center_x/2)) )=0;
	else
		mask(floor(min(locs_center_y)):ceil(max(locs_center_y)), floor(min(locs_center_x)) : ceil(max(locs_center_x)) )=0;
	end
	img_masked=img.*mask;
	[detectionOK, qr_markerFamily, qr_originCheckerColor,qr_patternDims,qr_checkerSize,qr_markerSize,loc] = preproc.cam_get_charuco_info_from_QRcode (uint8(mat2gray(img_masked)*255));
	if detectionOK && ~isempty(qr_patternDims(1)) && ~isempty(qr_patternDims(2)) % if QR code detected: fill GUI with the detected values
		handles.calib_rows.String = num2str(qr_patternDims(1));
		handles.calib_columns.String = num2str(qr_patternDims(2));
		if strcmpi (qr_originCheckerColor,'Black')
			handles.calib_origincolor.Value = 1;
		else
			handles.calib_origincolor.Value = 2;
		end
		if strcmp (qr_markerFamily,'DICT_4X4_1000')
			handles.calib_boardtype.Value = 1; %no alternative
		end
		handles.calib_checkersize.String = num2str(qr_checkerSize);
		handles.calib_markersize.String= num2str(qr_markerSize);
		patternDims(1)=qr_patternDims(1);
		patternDims(2)=qr_patternDims(2);
		markerFamily=qr_markerFamily;
		originCheckerColor=qr_originCheckerColor;
		checkerSize=qr_checkerSize;
		markerSize=qr_markerSize;
		if large_img
			loc=loc*2;
		end
	else
		patternDims = [str2double(handles.calib_rows.String),str2double(handles.calib_columns.String)];
		if contains(handles.calib_boardtype.String{handles.calib_boardtype.Value}, 'DICT_4X4_1000')
			markerFamily = 'DICT_4X4_1000';
		else
			markerFamily = 'DICT_4X4_1000'; % no alternative
			disp('unsupported marker family')
		end
		originCheckerColor = handles.calib_origincolor.String{handles.calib_origincolor.Value};
		checkerSize=str2double(handles.calib_checkersize.String);
		markerSize=str2double(handles.calib_markersize.String);
	end
	percentage_detected=round(numMarkers/(patternDims(1)*patternDims(2)/2)*100,0);
	if percentage_detected > 100
		percentage_detected = 100;
	end
	infotxt=[newline 'Not enough markers'];
	infotxt2='';
	orientation_message='';
	if percentage_detected > 33
		oldBoxes = gui.retr('last_auto_detected_charuco_boxes');
		if isempty(oldBoxes)
			oldBoxes = [inf inf inf inf];
		end

		dx_min = abs(oldBoxes(:,1) - newBox(1));
		dx_max = abs(oldBoxes(:,2) - newBox(2));
		dy_min = abs(oldBoxes(:,3) - newBox(3));
		dy_max = abs(oldBoxes(:,4) - newBox(4));

		threshold_x = size(img,2)/7;
		threshold_y = size(img,1)/7;

		isNew = all( ...
			dx_min > threshold_x | ...
			dx_max > threshold_x | ...
			dy_min > threshold_y | ...
			dy_max > threshold_y ...
			);
		not_moving_threshold = 0.06;
		infotxt=[newline 'Existing position'];
		if isNew
			infotxt=[newline 'New position'];
			old_charuco_img=gui.retr('old_charuco_img');
			if isempty(old_charuco_img)
				gui.put('old_charuco_img',img_original(1:2:end,1:2:end,:));
			else
				diff = abs(double(img_original(1:2:end,1:2:end,:)) - double(old_charuco_img));
				motion_metric = mean(diff(:)) / mean(double(old_charuco_img(:)));
				disp(['Image delta = ' num2str(motion_metric)]);
				if motion_metric < not_moving_threshold
					acquisition.camera_snapshot_Callback
					if isempty(oldBoxes)
						oldBoxes = newBox;
					else
						oldBoxes = [oldBoxes; newBox];
					end
					gui.put('last_auto_detected_charuco_boxes',oldBoxes);
					infotxt2=[newline 'Steady!'];
				else
					infotxt2=[newline 'Shaking...'];
				end
				gui.put('old_charuco_img',img_original(1:2:end,1:2:end,:));
			end
		end

		%% estimate alpha and beta
		%multiplication with 255 is necessary, OMG...!
		imagePoints1 = detectCharucoBoardPoints(img*255,patternDims,markerFamily,checkerSize,markerSize, 'OriginCheckerColor', originCheckerColor,'ResolutionPerBit',16,'MarkerSizeRange',[0.005 1]);
		if ~isempty(imagePoints1)
			cameraParams = gui.retr('cameraParams');
			if ~isempty(cameraParams)
				detector = vision.calibration.monocular.CharucoBoardDetector();
				worldPoints1 = generateWorldPoints(detector, 'PatternDims', patternDims, 'CheckerSize', checkerSize);

				if patternDims(1) > patternDims(2) %Fixes the issue that high slender calibration bards result in rotated output
					% swap axes
					worldPoints1 = worldPoints1(:, [2 1]);
					% flip y axis
					worldPoints1(:,2) = -worldPoints1(:,2);
				end
				offs_x=max(worldPoints1(:,1));
				offs_y=max(worldPoints1(:,2));
				worldPoints1(isnan(imagePoints1))=NaN;
				imagePoints1 = rmmissing(imagePoints1); %remove missing entries... does that work simply like this? --> yes. If matching world points are also removed.
                worldPoints1 = rmmissing(worldPoints1);
                if size(worldPoints1,1)>3
                    try
                        camExtrinsics1 = estimateExtrinsics(imagePoints1,worldPoints1,cameraParams.Intrinsics);
                    catch
                        return
                    end
                    R1=camExtrinsics1.R;
                    t1=camExtrinsics1.Translation;
					z_cam = [0; 0; 1];
					z_world1 = R1 * z_cam;
					alpha1 = atan2(z_world1(1), z_world1(3));   % yaw (X–Z plane)
					beta1  = atan2(z_world1(2), z_world1(3));   % pitch (Y–Z plane)
					alpha_deg = rad2deg(alpha1); %should be camera yaw
					beta_deg  = rad2deg(beta1); % should be camera pitch
					% Roll (untested)
					% Kamera -> Welt Rotation
					R_wc = R1.';
					% Kamera-X-Achse im Weltkoordinatensystem
					x_cam_w = R_wc(:,1);
					% Projektion in die Welt-XY-Ebene
					x_proj = x_cam_w;
					x_proj(3) = 0;
					x_proj = x_proj / norm(x_proj);
					% Roll (Rotation um optische Achse)
					roll = atan2(x_proj(2), x_proj(1));
					roll_deg = rad2deg(roll);
					orientation_message=['Yaw: ' num2str(round(alpha_deg)) ' ; Pitch: ' num2str(round(beta_deg)) ' ; Roll: ' num2str(round(roll_deg,1)) newline 'X: ' num2str(round((t1(1)+offs_x)/1000,2)) ' ; Y: ' num2str(round((t1(2)+offs_y)/1000,2)) ' ; Z: ' num2str(round(t1(3)/1000,2))];
				else
					orientation_message='Perform camera calibration to display yaw / pitch / roll angle of camera';
                end
            else
                orientation_message='Perform camera calibration to display yaw / pitch / roll angle of camera';
            end
        end
    end
    if percentage_detected >= 3
    	hold on
    	scatter(locs_center_x,locs_center_y,'green','tag','charucolabel','Parent',figure_handle)
    	hold off
    	rectangle('Position',[min(locs_center_x), min(locs_center_y),max(locs_center_x) - min(locs_center_x), max(locs_center_y) - min(locs_center_y) ],'tag','charucolabel','EdgeColor','r','LineWidth',2,'Parent',figure_handle,'Curvature',0.15)
    	text(mean_loc_x,mean_loc_y,orientation_message,'tag','charucolabel','Color','r','Backgroundcolor','k','FontSize',18,'FontWeight','bold','HorizontalAlignment','center','VerticalAlignment','top','Parent',figure_handle)
    	text(mean_loc_x,mean_loc_y,['Markers: ' num2str(percentage_detected) ' %'  infotxt  infotxt2],'tag','charucolabel','Color','r','Backgroundcolor','k','FontSize',24,'FontWeight','bold','HorizontalAlignment','center','VerticalAlignment','bottom','Parent',figure_handle)
    	if detectionOK %QR code detected
    		rectangle('position',[min(loc(:,1))-20, min(loc(:,2))-20, max(loc(:,1)) - min(loc(:,1))+20 , max(loc(:,2)) - min(loc(:,2))+20],'tag','charucolabel','EdgeColor','b','LineWidth',6,'Parent',figure_handle,'Curvature',0.5)
    		text(mean(loc(:,1)),mean(loc(:,2)),'QR','tag','charucolabel','Color','w','FontSize',24,'FontWeight','bold','HorizontalAlignment','center','VerticalAlignment','middle','Parent',figure_handle)
        end
    end
end