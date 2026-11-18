function PIVlab_capture_charuco_detector(img,figure_handle,~,x_offset,camera)
%x_offset, camera (optional): stereo acquisition, image of camera 1 or 2 side by side in the PIVlab axis
%(camera 2 starts at x = x_offset+1). With both cameras shown: markers only (stereo_detection below). With one
%camera shown (CAM button, acquisition.camera_view): the full detection for this camera (QR code, pose, automatic
%snapshots of this camera), like with a single camera.
%Speed: the markers are detected in a reduced image (detection_step); the QR code is read in the full image.
if nargin < 4
	x_offset=0;
	camera=0;
elseif acquisition.camera_view() ~= camera
	stereo_detection(img,figure_handle,x_offset,camera);
	return
else
	switch_camera_state(camera); %positions of the automatic snapshots etc. per camera
end
handles=gui.gethand;
calibration_demo_mode = gui.retr('calibration_demo_mode');
if isempty(calibration_demo_mode)
    calibration_demo_mode=0;
end
img_original=img;
large_img = numel(img) > 20000000 || calibration_demo_mode; %as before: thresholds below are for the reduced image
step = detection_step(img_original, camera);
if calibration_demo_mode
	step = max(step,2);
end
if step > 1
	img=img(1:step:end,1:step:end,1);
end

img=mat2gray(img);
img=histeq(img);
if calibration_demo_mode
    img=adapthisteq(img);
    %img(img> 0.5)=1;
    %img(img<= 0.5)=0;
else
   
end
 [ids,locs] = readArucoMarker(img,'DICT_4X4_1000','WindowSizeRange',[3 23],'MarkerSizeRange',[0.005 1],'ResolutionPerBit',16,'SquarenessTolerance',0.03); %schnellere detektierung wenn bekannt. Am besten: Erstmal so gucken welche Familie dominant. Dann zweiter durchgang mit nur dieser familie
locs=(locs-1)*step+1; %pixel coordinates of the full image
remember_marker_size(locs, camera); %next detection_step
ids=ids';
delete(findobj(figure_handle,'-regexp','tag','^charucolabel')); %in the image axes only (searching all windows is slow); also labels of both cameras (CAM 1+2) drawn just before the CAM button was pressed
draw_qr_status(figure_handle,calibration_demo_mode);

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
	% the QR code is in the centre of the board (preproc.cam_board_layout); first in the camera image
	% (the equalised image destroys small QR codes), then in the equalised image
	[detectionOK, qr_markerFamily, qr_originCheckerColor,qr_patternDims,qr_checkerSize,qr_markerSize,loc] = preproc.cam_get_charuco_info_from_QRcode (stretched_uint8(img_original));
	if ~detectionOK
		[detectionOK, qr_markerFamily, qr_originCheckerColor,qr_patternDims,qr_checkerSize,qr_markerSize,loc] = preproc.cam_get_charuco_info_from_QRcode (uint8(mat2gray(img)*255));
		if step > 1 && ~isempty(loc)
			loc = (loc - 1) * step + 1; % reduced image: back to full resolution
		end
	end
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
		%remember that the board parameters came from a QR code (persistent status display)
		qr_params.markerFamily=qr_markerFamily;
		qr_params.originCheckerColor=qr_originCheckerColor;
		qr_params.patternDims=qr_patternDims;
		qr_params.checkerSize=qr_checkerSize;
		qr_params.markerSize=qr_markerSize;
		qr_params.time=datetime('now');
		gui.put('charuco_qr_params',qr_params);
		delete(findobj(figure_handle,'tag','charucolabel')); %only the status text exists at this point, redraw it with the new values
		draw_qr_status(figure_handle,calibration_demo_mode);
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
		if calibration_demo_mode % in demo mode, do not remember all positions, but only the last two.
			try
				oldBoxes(1:size(oldBoxes,1)-1,:)=[];
			catch
			end
        end
        dx_min = abs(oldBoxes(:,1) - newBox(1));
        dx_max = abs(oldBoxes(:,2) - newBox(2));
        dy_min = abs(oldBoxes(:,3) - newBox(3));
        dy_max = abs(oldBoxes(:,4) - newBox(4));


        threshold_x = size(img_original,2)/7/(1+large_img); %as before (half resolution for large images)
        threshold_y = size(img_original,1)/7/(1+large_img);

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
					if ~calibration_demo_mode
						acquisition.camera_snapshot_Callback
					else
						demotxt=text(x_offset+size(img_original,2)/2,size(img_original,1)/6*5,'SNAPSHOT!','tag','demolabel','Color','y','Backgroundcolor','k','FontSize',70,'FontWeight','bold','HorizontalAlignment','center','VerticalAlignment','top','Parent',figure_handle);
						pause(0.1)
						demotxt.Color='r';
						pause(0.1)
						demotxt.Color='y';
						pause(0.1)
						demotxt.Color='r';
						pause(0.1)
						delete(findobj('tag','demolabel'));
					end
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
		cameraParams = camera_params(camera); %the corners are only needed for the pose, which needs the lens calibration
		imagePoints1 = [];
		if ~isempty(cameraParams)
			imagePoints1 = detectCharucoBoardPoints(img*255,patternDims,markerFamily,checkerSize,markerSize, 'OriginCheckerColor', originCheckerColor,'ResolutionPerBit',16,'MarkerSizeRange',[0.005 1]);
			imagePoints1 = preproc.cam_filter_charuco_corners(imagePoints1, patternDims); % corners of wrongly decoded markers
			imagePoints1 = (imagePoints1-1)*step+1; %corners were detected in the reduced image, the camera calibration is for the full resolution
		else
			orientation_message='Perform camera calibration to display yaw / pitch / roll angle of camera';
		end
		if ~isempty(imagePoints1)
			if ~isempty(cameraParams)
				detector = vision.calibration.monocular.CharucoBoardDetector();
				worldPoints1 = generateWorldPoints(detector, 'PatternDims', patternDims, 'CheckerSize', checkerSize);
				if patternDims(1) > patternDims(2) %Fixes the issue that high slender calibration bards result in rotated output
					% swap axes
					worldPoints1 = worldPoints1(:, [2 1]);
					% flip y axis
					worldPoints1(:,2) = -worldPoints1(:,2);
				end
				%board centre in board coordinates
				board_centre=[(min(worldPoints1(:,1))+max(worldPoints1(:,1)))/2; (min(worldPoints1(:,2))+max(worldPoints1(:,2)))/2; 0];
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
					% Camera position relative to the board centre, in board coordinates (mm).
					% R1 and t1 map board to camera coordinates, so the camera centre in board coordinates is -R1'*t1.
					% X and Y run along the board (right / down in the image, like PIV x / y), Z is the distance in front of the board.
					cam_pos = -R_wc*t1(:) - board_centre;
					% axis directions as set for the PIV data (calibration panel)
					if handles.x_axis_direction.Value == 2
						cam_pos(1) = -cam_pos(1);
					end
					if handles.y_axis_direction.Value == 2
						cam_pos(2) = -cam_pos(2);
					end
					orientation_message=['Yaw: ' num2str(round(alpha_deg)) ' ; Pitch: ' num2str(round(beta_deg)) ' ; Roll: ' num2str(round(roll_deg,1)) newline 'Camera X: ' num2str(round(cam_pos(1))) ' ; Y: ' num2str(round(cam_pos(2))) ' ; Z: ' num2str(round(abs(cam_pos(3)))) ' mm'];
				else
					orientation_message='Perform camera calibration to display yaw / pitch / roll angle of camera';
				end
			else
				orientation_message='Perform camera calibration to display yaw / pitch / roll angle of camera';
			end
		end
	end
	if percentage_detected >= 3
		mean_loc_x_old=gui.retr('mean_loc_x');
		mean_loc_y_old=gui.retr('mean_loc_y');
		if isempty(mean_loc_x_old)
			mean_loc_x_old=size(img_original,2)/2;
			mean_loc_y_old=size(img_original,1)/2;
		end
		lowpassed_mean_loc_x=mean_loc_x*0.1+mean_loc_x_old*0.9;
        lowpassed_mean_loc_y=mean_loc_y*0.1+mean_loc_y_old*0.9;
        gui.put('mean_loc_x',lowpassed_mean_loc_x);
        gui.put('mean_loc_y',lowpassed_mean_loc_y);
        hold(figure_handle,'on');
        if calibration_demo_mode
    		scatter(x_offset+locs_center_x,locs_center_y,1000,'green','tag','charucolabel','Parent',figure_handle,'LineWidth',5)
        else
            scatter(x_offset+locs_center_x,locs_center_y,200,'green','tag','charucolabel','Parent',figure_handle,'LineWidth',2)
        end
        hold(figure_handle,'off');
        rectangle('Position',[x_offset+min(locs_center_x), min(locs_center_y),max(locs_center_x) - min(locs_center_x), max(locs_center_y) - min(locs_center_y) ],'tag','charucolabel','EdgeColor','r','LineWidth',2,'Parent',figure_handle,'Curvature',0.15)

        text(x_offset+lowpassed_mean_loc_x,lowpassed_mean_loc_y,orientation_message,'tag','charucolabel','Color','r','Backgroundcolor','k','FontSize',18,'FontWeight','bold','HorizontalAlignment','center','VerticalAlignment','top','Parent',figure_handle)
        text(x_offset+lowpassed_mean_loc_x,lowpassed_mean_loc_y,['Markers: ' num2str(percentage_detected) ' %'  infotxt  infotxt2],'tag','charucolabel','Color','r','Backgroundcolor','k','FontSize',24,'FontWeight','bold','HorizontalAlignment','center','VerticalAlignment','bottom','Parent',figure_handle)
        if calibration_demo_mode
            text (figure_handle,x_offset+50,50,'Demonstration of the new camera calibration feature with automatic image capture and pose estimation.','tag','charucolabel','Color','k','FontSize',16,'FontWeight','bold')
        end
        if detectionOK %QR code detected
			rectangle('position',[x_offset+min(loc(:,1))-20, min(loc(:,2))-20, max(loc(:,1)) - min(loc(:,1))+20 , max(loc(:,2)) - min(loc(:,2))+20],'tag','charucolabel','EdgeColor','b','LineWidth',6,'Parent',figure_handle,'Curvature',0.5)
			text(x_offset+mean(loc(:,1)),mean(loc(:,2)),'QR','tag','charucolabel','Color','w','FontSize',24,'FontWeight','bold','HorizontalAlignment','center','VerticalAlignment','middle','Parent',figure_handle)
		end
	end
end

function stereo_detection(img,figure_handle,x_offset,camera)
%Stereo acquisition, both cameras shown: the markers of the board in the light sheet that one of the two cameras
%sees, so that the board can be placed where both cameras see it, and the QR code (board parameters). No automatic
%snapshots and no camera pose: with one camera shown (CAM button), the full detection runs for it.
label_tag=sprintf('charucolabel_cam%d',camera);
img_original=img;
step = detection_step(img_original, camera);
if step > 1
	img=img(1:step:end,1:step:end,1);
end
img=histeq(mat2gray(img));
[ids,locs] = readArucoMarker(img,'DICT_4X4_1000','WindowSizeRange',[3 23],'MarkerSizeRange',[0.005 1],'ResolutionPerBit',16,'SquarenessTolerance',0.03);
locs=(locs-1)*step+1; %pixel coordinates of the full image
remember_marker_size(locs, camera);
delete(findobj(figure_handle,'tag',label_tag));
delete(findobj(figure_handle,'tag','charucolabel')); %QR status text (one for both cameras)
draw_qr_status(figure_handle,0);
[qr_ok,~,~,~,~,~,qr_loc] = stereo_qr(img_original); %full resolution: small QR codes
if qr_ok
	rectangle('position',[x_offset+min(qr_loc(:,1))-20, min(qr_loc(:,2))-20, max(qr_loc(:,1)) - min(qr_loc(:,1))+20 , max(qr_loc(:,2)) - min(qr_loc(:,2))+20],'tag',label_tag,'EdgeColor','b','LineWidth',3,'Parent',figure_handle,'Curvature',0.5)
	text(x_offset+mean(qr_loc(:,1)),mean(qr_loc(:,2)),'QR','tag',label_tag,'Color','w','FontSize',14,'FontWeight','bold','HorizontalAlignment','center','VerticalAlignment','middle','Parent',figure_handle)
end
ids=ids(:);
if isempty(locs) || size(locs,3) ~= numel(ids)
	text(x_offset+size(img_original,2)/2,size(img_original,1)/2,'Markers: 0 %','tag',label_tag,'Color','r','Backgroundcolor','k','FontSize',14,'FontWeight','bold','HorizontalAlignment','center','VerticalAlignment','middle','Parent',figure_handle);
	return
end
id_thresh = mean(ids,'omitnan')+2*std(ids,'omitnan'); %wrongly decoded markers have far too high ids
locs(:,:,ids>id_thresh)=[];
ids(ids>id_thresh)=[];
handles=gui.gethand;
patternDims = [str2double(handles.calib_rows.String),str2double(handles.calib_columns.String)];
percentage_detected=min(100,round(numel(ids)/(patternDims(1)*patternDims(2)/2)*100,0));
locs_center_x=squeeze(mean(locs(:,1,:),'omitnan'))+x_offset;
locs_center_y=squeeze(mean(locs(:,2,:),'omitnan'));
hold(figure_handle,'on');
scatter(locs_center_x,locs_center_y,40,'green','tag',label_tag,'Parent',figure_handle,'LineWidth',1.5) %smaller than in 2D: two images share the display
hold(figure_handle,'off');
rectangle('Position',[min(locs_center_x), min(locs_center_y),max(locs_center_x) - min(locs_center_x), max(locs_center_y) - min(locs_center_y) ],'tag',label_tag,'EdgeColor','r','LineWidth',2,'Parent',figure_handle,'Curvature',0.15)
text(mean(locs_center_x),mean(locs_center_y),['Markers: ' num2str(percentage_detected) ' %'],'tag',label_tag,'Color','r','Backgroundcolor','k','FontSize',14,'FontWeight','bold','HorizontalAlignment','center','VerticalAlignment','middle','Parent',figure_handle)

function draw_qr_status(figure_handle,calibration_demo_mode)
%Persistent info in the top left corner: were the board parameters read from a QR code?
qr_params=gui.retr('charuco_qr_params');
if calibration_demo_mode
	fontsize=24;
else
	fontsize=14;
end
if ~isempty(qr_params)
	statustxt=['QR code: ' num2str(qr_params.patternDims(1)) ' x ' num2str(qr_params.patternDims(2)) ' | checker ' num2str(qr_params.checkerSize) ' mm | marker ' num2str(qr_params.markerSize) ' mm | origin ' qr_params.originCheckerColor];
	bgcolor='b';
else
	statustxt='No QR code detected: using manual board parameters';
	bgcolor=[0.85 0.4 0];
end
text(figure_handle,0.01,0.99,statustxt,'Units','normalized','tag','charucolabel','Color','w','Backgroundcolor',bgcolor,'FontSize',fontsize,'FontWeight','bold','HorizontalAlignment','left','VerticalAlignment','top','Interpreter','none');

function out = stretched_uint8(img)
%8 bit image stretched from its minimum to its maximum (as uint8(mat2gray(img)*255), but in integer arithmetic:
%about 7x faster for a 20 megapixel frame; min and max from every 16th pixel)
img = img(:,:,1);
sample = img(1:16:end,1:16:end);
lo = double(min(sample(:)));
hi = double(max(sample(:)));
if hi <= lo
	out = uint8(mat2gray(img)*255);
	return
end
out = imlincomb(255/(hi-lo), img, -255*lo/(hi-lo), 'uint8');

function step = detection_step(img, camera)
%Every step-th pixel is used for the marker detection (speed: about step^2 faster). As before, large images
%(> 20 megapixels) are halved. When the markers of the last detection of this camera were large, a coarser image
%is used, with at least 30 pixels per marker side; when no markers were found, the default again. Small markers
%are therefore detected as before.
default_step = 1;
if numel(img) > 20000000
	default_step = 2;
end
step = default_step;
sizes = gui.retr('charuco_marker_size');
if numel(sizes) >= camera+1 && sizes(camera+1) > 0
	step = max(default_step, min(4, floor(sizes(camera+1)/30)));
end

function remember_marker_size(locs, camera)
%median side length (full image pixels) of the detected markers, per camera (0 = single camera): see detection_step
sizes = gui.retr('charuco_marker_size');
if numel(sizes) < camera+1
	sizes(camera+1) = 0;
end
sizes(camera+1) = 0;
if ~isempty(locs)
	sides = sqrt(sum((locs(2,:,:)-locs(1,:,:)).^2,2));
	sizes(camera+1) = median(sides(:),'omitnan');
	if isnan(sizes(camera+1))
		sizes(camera+1) = 0;
	end
end
gui.put('charuco_marker_size',sizes);

function switch_camera_state(camera)
%Stereo acquisition, one camera shown: the state of the automatic snapshots (positions taken, last image,
%label position) belongs to this camera. When the shown camera changes, it is stored and the other one loaded.
keys = {'last_auto_detected_charuco_boxes','old_charuco_img','mean_loc_x','mean_loc_y'};
last_camera = gui.retr('charuco_last_camera');
if isequal(last_camera, camera)
	return
end
states = gui.retr('charuco_camera_states');
if ~isstruct(states)
	states = struct();
end
if ~isempty(last_camera)
	for i = 1:numel(keys)
		states.(sprintf('cam%d',last_camera)).(keys{i}) = gui.retr(keys{i});
	end
end
field = sprintf('cam%d',camera);
for i = 1:numel(keys)
	value = [];
	if isfield(states, field) && isfield(states.(field), keys{i})
		value = states.(field).(keys{i});
	end
	gui.put(keys{i}, value);
end
gui.put('charuco_camera_states', states);
gui.put('charuco_last_camera', camera);

function cameraParams = camera_params(camera)
%lens calibration of the camera: in stereo-PIV mode the one of this camera (the other camera's is stored in
%stereo_cam_state), otherwise the one in the GUI
cameraParams = gui.retr('cameraParams');
if camera > 0 && isequal(gui.retr('stereomode'),1)
	active = gui.retr('stereo_active_camera');
	if isempty(active)
		active = 1;
	end
	if camera ~= active
		cameraParams = [];
		state = gui.retr('stereo_cam_state');
		if iscell(state) && numel(state) >= camera && isfield(state{camera},'cameraParams')
			cameraParams = state{camera}.cameraParams;
		end
	end
end

function [detectionOK,markerFamily,originCheckerColor,patternDims,checkerSize,markerSize,loc] = stereo_qr(img)
%QR code in the full camera image; when found, the board parameters are put into the calibration panel (as in
%the detection of a single camera)
[detectionOK,markerFamily,originCheckerColor,patternDims,checkerSize,markerSize,loc] = preproc.cam_get_charuco_info_from_QRcode(stretched_uint8(img));
if ~detectionOK || isempty(patternDims)
	detectionOK = 0;
	return
end
handles=gui.gethand;
handles.calib_rows.String = num2str(patternDims(1));
handles.calib_columns.String = num2str(patternDims(2));
if strcmpi(originCheckerColor,'Black')
	handles.calib_origincolor.Value = 1;
else
	handles.calib_origincolor.Value = 2;
end
handles.calib_checkersize.String = num2str(checkerSize);
handles.calib_markersize.String = num2str(markerSize);
qr_params.markerFamily=markerFamily;
qr_params.originCheckerColor=originCheckerColor;
qr_params.patternDims=patternDims;
qr_params.checkerSize=checkerSize;
qr_params.markerSize=markerSize;
qr_params.time=datetime('now');
gui.put('charuco_qr_params',qr_params);

