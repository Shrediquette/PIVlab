function PIVlab_capture_charuco_detector(img,image_handle)
handles=gui.gethand;
patternDims = [str2double(handles.calib_rows.String),str2double(handles.calib_columns.String)];
img_original=img;
if numel(img) > 10000000 % more than 10 megapixels image --> reduce resolution for charuco detection
    large_img=1;
else
    large_img=0;
end
if large_img
    img=img(1:2:end,1:2:end,1);
end
img=mat2gray(img);
img=histeq(img);
[ids,locs] = readArucoMarker(img,'DICT_4X4_1000'); %schnellere detektierung wenn bekannt. Am besten: Erstmal so gucken welche Familie dominant. Dann zweiter durchgang mit nur dieser familie
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
    hold on
    scatter(locs_center_x,locs_center_y,'green','tag','charucolabel')
    hold off
    text(mean_loc_x,mean_loc_y,[num2str(percentage_detected) ' %'],'tag','charucolabel','Color','r','BackgroundColor','k')
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
        if isNew
            gui.put('last_auto_detected_charuco_position',[locs;newLoc]); %saves a list of all detected centers of board so far detected
            disp('snapshot!')
            %acquisition.camera_snapshot_Callback
        end

hold on;
image_width=size(img_original,2);
image_height=size(img_original,1);

% Coverage setup
Nx = 10;
Ny = 10;

xEdges = linspace(1, image_width+1, Nx+1);
yEdges = linspace(1, image_height+1, Ny+1);

% Occupancy matrix (Nx × Ny logical)
occ = false(Nx, Ny);
ix = discretize(locs(:,1), xEdges);
iy = discretize(locs(:,2), yEdges);

for k = 1:numel(ix)
    if ~isnan(ix(k)) && ~isnan(iy(k))
        occ(ix(k), iy(k)) = true;
    end
end

% pcolor expects size = (Ny+1) × (Nx+1)
C = double(occ');           % transpose for image coordinates
C(end+1, end+1) = 0;

% Overlay
h = pcolor(xEdges, yEdges, C,'tag','charucolabel');
shading flat;

h.FaceAlpha = 0.5;
h.EdgeColor = 'none';
colormap([1 0 0; 0 1 0]);   % red = empty, green = filled
caxis([0 1]);
hold off

















    end
end
