function PIVlab_capture_charuco_detector(img,figure_handle,image_handle)
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
    [detectionOK, qr_markerFamily, qr_originCheckerColor,qr_patternDims,qr_checkerSize,qr_markerSize,loc] = preproc.cam_get_charuco_info_from_QRcode (img);
    if detectionOK && ~isempty(qr_patternDims(1)) && ~isempty(qr_patternDims(2))
        handles.calib_rows.String = num2str(qr_patternDims(1));
        handles.calib_columns.String = num2str(qr_patternDims(2));
        patternDims(1)=qr_patternDims(1);
        patternDims(2)=qr_patternDims(2);
        if large_img
            loc=loc*2;
        end
    else
        patternDims = [str2double(handles.calib_rows.String),str2double(handles.calib_columns.String)];
    end


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
        not_moving_threshold = 0.06;
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
        if size(locs,1) > 5
            %disp ('now calculate intrinsics once')
            %read saved images, get points. Aber die intrinsics müssten bleiben zwischen verschiedenen läufen.
        end
        %% estimate alpha and beta
%{
%hier müsste man sammeln alle bisheringen marker bilder. Dann daraus intrinsics berechnen. Vielleicht einmalig wenn bestimmte Anzahl guter bilde rrereciht?
camera_1_parameters = estimateCameraParameters(camera_1_points, worldPoints1, ImageSize=image_size);
camExtrinsics1 = estimateExtrinsics(imagePoints1_original,worldPoints1_original,camera_1_parameters.Intrinsics);
R1=camExtrinsics1.R;
t1=camExtrinsics1.Translation;
z_cam = [0; 0; 1];
z_world1 = R1 * z_cam;
alpha1 = atan2(z_world1(1), z_world1(3));   % yaw (X–Z plane)
beta1  = atan2(z_world1(2), z_world1(3));   % pitch (Y–Z plane)
alpha_deg1 = rad2deg(alpha1); %should be camera yaw
beta_deg1  = rad2deg(beta1); % should be camera pitch


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





%}


    end
    hold on
    scatter(locs_center_x,locs_center_y,'green','tag','charucolabel','Parent',figure_handle)
    hold off
    rectangle('Position',[min(locs_center_x), min(locs_center_y),max(locs_center_x) - min(locs_center_x), max(locs_center_y) - min(locs_center_y) ],'tag','charucolabel','EdgeColor','r','LineWidth',2,'Parent',figure_handle,'Curvature',0.15)
    text(mean_loc_x,mean_loc_y,['Markers: ' num2str(percentage_detected) ' %' newline infotxt newline infotxt2],'tag','charucolabel','Color','r','FontSize',36,'FontWeight','bold','HorizontalAlignment','center','VerticalAlignment','middle','Parent',figure_handle)
    if detectionOK %QR code detected
     rectangle('position',[min(loc(:,1))-20, min(loc(:,2))-20, max(loc(:,1)) - min(loc(:,1))+20 , max(loc(:,2)) - min(loc(:,2))+20],'tag','charucolabel','EdgeColor','b','LineWidth',6,'Parent',figure_handle,'Curvature',0.5)  
     text(mean(loc(:,1)),mean(loc(:,2)),['QR'],'tag','charucolabel','Color','w','FontSize',24,'FontWeight','bold','HorizontalAlignment','center','VerticalAlignment','middle','Parent',figure_handle)
    end
end