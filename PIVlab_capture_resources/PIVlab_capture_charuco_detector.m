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
[ids,locs,mirrored] = read_markers(img,camera,handles); %also a board seen from behind (mirrored)
locs=(locs-1)*step+1; %pixel coordinates of the full image
remember_marker_size(locs, camera); %next detection_step
ids=ids';
clear_labels(figure_handle,camera); %labels of the last update; also those of both cameras (CAM 1+2) drawn just before the CAM button was pressed
draw_qr_status(figure_handle,calibration_demo_mode);
status_lines = {'Markers: 0 %'};
marker_locs = [];
qr_loc = []; %finder patterns of the QR code, when read

if ~isempty(locs) && size(locs,3) == size(ids,1)
    id_thresh = mean(ids,'omitnan')+2*std(ids,'omitnan');
    ids(ids>id_thresh) = nan;
	locs(:,:,isnan(ids))=[];
	ids(isnan(ids))=[];
	numMarkers = numel(ids);
	marker_locs = locs;
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
	if detectionOK
		qr_loc = loc;
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
		draw_qr_status(figure_handle,calibration_demo_mode); %with the new values
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
			if mirrored %board seen from behind: corners can only be read in the mirrored image
				imagePoints1 = detectCharucoBoardPoints(fliplr(img*255),patternDims,markerFamily,checkerSize,markerSize, 'OriginCheckerColor', originCheckerColor,'ResolutionPerBit',16,'MarkerSizeRange',[0.005 1]);
				if ~isempty(imagePoints1)
					imagePoints1(:,1) = size(img,2) + 1 - imagePoints1(:,1); %back to the coordinates of the image as recorded
				end
			else
				imagePoints1 = detectCharucoBoardPoints(img*255,patternDims,markerFamily,checkerSize,markerSize, 'OriginCheckerColor', originCheckerColor,'ResolutionPerBit',16,'MarkerSizeRange',[0.005 1]);
			end
			imagePoints1 = preproc.cam_filter_charuco_corners(imagePoints1, patternDims); % corners of wrongly decoded markers
			imagePoints1 = (imagePoints1-1)*step+1; %corners were detected in the reduced image, the camera calibration is for the full resolution
		else
			orientation_message='Perform camera calibration to display yaw / pitch / roll angle of camera';
		end
		if ~isempty(imagePoints1)
			if ~isempty(cameraParams)
				detector = vision.calibration.monocular.CharucoBoardDetector();
				worldPoints1 = generateWorldPoints(detector, 'PatternDims', patternDims, 'CheckerSize', checkerSize);
				if mirrored
					worldPoints1(:,1) = -worldPoints1(:,1); %board seen from behind (as preproc.cam_rectification_show_cam_position_Callback)
				end
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
						draw_overlays(figure_handle,camera,x_offset,size(img_original),marker_locs,qr_loc,{['Markers: ' num2str(percentage_detected) ' %']},calibration_demo_mode);
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
	%status block in the top left corner of the camera image (not on the board: it would hide markers)
	status_lines = {['Markers: ' num2str(percentage_detected) ' %']};
	if percentage_detected >= 3
		status_lines{end+1} = strtrim(infotxt);
		if isempty(infotxt2)
			status_lines{end+1} = ' '; %"Steady!" / "Shaking..." only after a new position: keep its line, the lines below do not jump
		else
			status_lines{end+1} = strtrim(infotxt2);
		end
		if mirrored
			status_lines{end+1} = 'Board seen from behind';
		end
		if ~isempty(orientation_message)
			status_lines = [status_lines, strsplit(orientation_message, newline)];
		end
        if calibration_demo_mode
            text (figure_handle,x_offset+50,50,'Demonstration of the new camera calibration feature with automatic image capture and pose estimation.','tag','charucolabel','Color','k','FontSize',16,'FontWeight','bold')
        end
	end
end
draw_overlays(figure_handle,camera,x_offset,size(img_original),marker_locs,qr_loc,status_lines,calibration_demo_mode);

function draw_overlays(figure_handle,camera,x_offset,image_size,marker_locs,qr_loc,status_lines,calibration_demo_mode)
%detected markers, QR code and status block of the full detection (one camera)
if calibration_demo_mode
	draw_markers(figure_handle,camera,x_offset,marker_locs,4);
	draw_qr_box(figure_handle,camera,x_offset,qr_loc,18);
	draw_status(figure_handle,camera,x_offset,image_size,status_lines,24,0.09);
else
	draw_markers(figure_handle,camera,x_offset,marker_locs,2);
	draw_qr_box(figure_handle,camera,x_offset,qr_loc,9);
	draw_status(figure_handle,camera,x_offset,image_size,status_lines,14,0.06);
end

function stereo_detection(img,figure_handle,x_offset,camera)
%Stereo acquisition, both cameras shown: the markers of the board in the light sheet that one of the two cameras
%sees, so that the board can be placed where both cameras see it, and the QR code (board parameters). No automatic
%snapshots and no camera pose: with one camera shown (CAM button), the full detection runs for it.
img_original=img;
step = detection_step(img_original, camera);
if step > 1
	img=img(1:step:end,1:step:end,1);
end
img=histeq(mat2gray(img));
handles=gui.gethand;
[ids,locs] = read_markers(img,camera,handles); %also a board seen from behind (mirrored)
locs=(locs-1)*step+1; %pixel coordinates of the full image
remember_marker_size(locs, camera);
delete(findobj(figure_handle,'tag','charucolabel')); %labels of the full detection (CAM 1 / CAM 2 shown before)
draw_qr_status(figure_handle,0);
[qr_ok,~,~,~,~,~,qr_loc] = stereo_qr(img_original); %full resolution: small QR codes
if ~qr_ok
	qr_loc = [];
end
draw_qr_box(figure_handle,camera,x_offset,qr_loc,6);
ids=ids(:);
if isempty(locs) || size(locs,3) ~= numel(ids)
	store_markers(camera,[],[],size(img_original)); %acquisition.draw_camera_overlap
	draw_markers(figure_handle,camera,x_offset,[],1.5);
	draw_status(figure_handle,camera,x_offset,size(img_original),{'Markers: 0 %'},12,0.06);
	return
end
id_thresh = mean(ids,'omitnan')+2*std(ids,'omitnan'); %wrongly decoded markers have far too high ids
locs(:,:,ids>id_thresh)=[];
ids(ids>id_thresh)=[];
store_markers(camera,ids,locs,size(img_original)); %acquisition.draw_camera_overlap: view of the other camera
patternDims = [str2double(handles.calib_rows.String),str2double(handles.calib_columns.String)];
percentage_detected=min(100,round(numel(ids)/(patternDims(1)*patternDims(2)/2)*100,0));
draw_markers(figure_handle,camera,x_offset,locs,1.5); %thinner than with one camera: two images share the display
draw_status(figure_handle,camera,x_offset,size(img_original),{['Markers: ' num2str(percentage_detected) ' %']},12,0.06);

function draw_markers(figure_handle,camera,x_offset,locs,line_width)
%Outline of each detected marker (its 4 corners), one yellow line: it lies on the light border around the
%marker, readable without a dark edge (a second, wider line below it looked uneven: both are rasterised
%separately). One patch object per camera with one face per marker (closed outlines: all corners joined the
%same way), kept and updated (no flicker, no new objects per frame).
vertices = NaN(1,2);
faces = NaN(1,4);
if ~isempty(locs)
	n = size(locs,3);
	vertices = [reshape(locs(:,1,:),[],1) + x_offset, reshape(locs(:,2,:),[],1)]; % corner c of marker i in row 4*(i-1)+c
	faces = reshape(1:4*n,4,n)';
end
markers = overlay_object(figure_handle,sprintf('charucolabel_markers_cam%d',camera),'patch');
set(markers,'Faces',faces,'Vertices',vertices,'EdgeColor',[1 0.85 0],'LineWidth',line_width);

function draw_qr_box(figure_handle,camera,x_offset,loc,line_width)
%Four corner brackets around the QR code, along its edges (follows rotation and perspective); hidden when no
%QR code was read. loc: finder pattern centres from readBarcode (bottom left, top left, top right).
x = NaN;
y = NaN;
if size(loc,1) == 3
	corners = [loc(2,:); loc(3,:); loc(3,:)+loc(1,:)-loc(2,:); loc(1,:)]; % finder centres + the 4th corner
	centre = mean(corners,1);
	% version 1 code: 21 modules, finder centres 7 modules from the centre, edge at 10.5; bracket 1 module outside
	corners = centre + (corners - centre) * (11.5/7);
	x = [];
	y = [];
	for i = 1:4
		previous = corners(mod(i-2,4)+1,:);
		next = corners(mod(i,4)+1,:);
		bracket = [corners(i,:) + 0.25*(previous-corners(i,:)); corners(i,:); corners(i,:) + 0.25*(next-corners(i,:)); NaN NaN];
		x = [x; bracket(:,1)]; %#ok<AGROW>
		y = [y; bracket(:,2)]; %#ok<AGROW>
	end
	x = x + x_offset;
end
box = overlay_object(figure_handle,sprintf('charucolabel_qr_cam%d',camera),'line');
set(box,'XData',x,'YData',y,'Color',[0.3 0.6 1],'LineWidth',line_width);

function draw_status(figure_handle,camera,x_offset,image_size,lines,fontsize,y_fraction)
%Status block (marker percentage, position, pose) in the top left corner of the camera image, below the QR status
status = overlay_object(figure_handle,sprintf('charucolabel_status_cam%d',camera),'text');
y = y_fraction*image_size(1);
qr_status = findobj(figure_handle,'tag','charucolabel_qrstatus');
if ~isempty(qr_status) && strcmp(figure_handle.YDir,'reverse')
	% directly below the QR status line (its height on screen depends on the display size)
	extent = qr_status(1).Extent; % normalized axes units: [left bottom width height], bottom of the axes = YLim(2)
	y_limits = figure_handle.YLim;
	y = y_limits(2) - extent(2)*diff(y_limits) + 0.005*diff(y_limits);
end
set(status,'Position',[x_offset+0.01*image_size(2), y, 0],'String',lines,'FontSize',fontsize);

function h = overlay_object(figure_handle,tag,kind)
%patch, line or text of the live detection: the existing one (updated by the caller) or a new one
h = findobj(figure_handle,'tag',tag);
if numel(h) > 1
	delete(h(2:end));
	h = h(1);
end
if isempty(h)
	if strcmp(kind,'patch')
		h = patch(figure_handle,'Faces',NaN(1,4),'Vertices',NaN(1,2),'FaceColor','none','LineJoin','round','tag',tag,'HitTest','off','PickableParts','none');
	elseif strcmp(kind,'line')
		h = line(figure_handle,NaN,NaN,'LineJoin','round','tag',tag,'HitTest','off','PickableParts','none');
	else
		h = text(figure_handle,0,0,'','tag',tag,'Color','w','BackgroundColor',[0 0 0 0.6],'FontWeight','bold', ...
			'HorizontalAlignment','left','VerticalAlignment','top','Interpreter','none','HitTest','off','PickableParts','none');
	end
end

function clear_labels(figure_handle,camera)
%Full detection of one camera: removes the labels of the last update and of the other camera (both cameras were
%shown before), except the objects of this camera and the QR status that are kept and updated
keep = {sprintf('charucolabel_markers_cam%d',camera), sprintf('charucolabel_qr_cam%d',camera), ...
	sprintf('charucolabel_status_cam%d',camera), 'charucolabel_qrstatus'};
labels = findobj(figure_handle,'-regexp','tag','^charucolabel');
remove = true(numel(labels),1);
for i = 1:numel(labels)
	remove(i) = ~any(strcmp(labels(i).Tag, keep));
end
delete(labels(remove));

function store_markers(camera,ids,locs,image_size)
%markers of this camera in the current frame (full image coordinates), for the overlap of the two camera views
%(acquisition.draw_camera_overlap, called by acquisition.live_overlays after both cameras)
markers = gui.retr('charuco_live_markers');
if ~iscell(markers) || numel(markers) ~= 2
	markers = cell(1,2);
end
m.ids = ids;
m.locs = locs;
m.size = image_size(1:2);
markers{camera} = m;
gui.put('charuco_live_markers',markers);

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
status = findobj(figure_handle,'tag','charucolabel_qrstatus'); %kept and updated
if isempty(status)
	status = text(figure_handle,0.01,0.99,'','Units','normalized','tag','charucolabel_qrstatus','Color','w','FontWeight','bold','HorizontalAlignment','left','VerticalAlignment','top','Interpreter','none','HitTest','off');
end
set(status,'String',statustxt,'BackgroundColor',bgcolor,'FontSize',fontsize);

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

function [ids,locs,mirrored] = read_markers(img,camera,handles)
%ArUco markers in the (reduced, equalised) image. A camera behind the light sheet sees the board mirrored
%(transparent board): the markers can then only be read in the mirrored image (as
%preproc.cam_detect_rectification_board). The orientation of the last detection of this camera is tried first; the
%other one only when less than half of the markers of the board are found.
%locs: in the coordinates of the image as given (also when mirrored)
mirrored_states = gui.retr('charuco_mirrored');
if numel(mirrored_states) < camera+1
	mirrored_states(camera+1) = 0;
end
n_markers = str2double(handles.calib_rows.String)*str2double(handles.calib_columns.String)/2;
ids = [];
locs = [];
mirrored = logical(mirrored_states(camera+1));
for t = 1:2
	try_mirrored = mirrored_states(camera+1);
	if t == 2
		try_mirrored = ~try_mirrored;
	end
	if try_mirrored
		try_img = fliplr(img);
	else
		try_img = img;
	end
	[try_ids,try_locs] = readArucoMarker(try_img,'DICT_4X4_1000','WindowSizeRange',[3 23],'MarkerSizeRange',[0.005 1],'ResolutionPerBit',16,'SquarenessTolerance',0.03); %schnellere detektierung wenn bekannt. Am besten: Erstmal so gucken welche Familie dominant. Dann zweiter durchgang mit nur dieser familie
	if numel(try_ids) > numel(ids)
		if try_mirrored
			try_locs(:,1,:) = size(img,2) + 1 - try_locs(:,1,:); %back to the coordinates of the image as given
		end
		ids = try_ids;
		locs = try_locs;
		mirrored = logical(try_mirrored);
	end
	if ~(numel(ids) < 0.5*n_markers) %also when the board size is unknown (NaN)
		break
	end
end
if ~isempty(ids)
	mirrored_states(camera+1) = mirrored; %no board in view: keep the last orientation
end
gui.put('charuco_mirrored',mirrored_states);

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
%Stereo acquisition, one camera shown: the state of the automatic snapshots (positions taken, last image) belongs
%to this camera. When the shown camera changes, it is stored and the other one loaded.
keys = {'last_auto_detected_charuco_boxes','old_charuco_img'};
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

