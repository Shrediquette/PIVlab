function cam_rectification_show_cam_position_Callback (~,~,~)
handles=gui.gethand;
cameraParams=gui.retr('cameraParams');
if isempty (cameraParams)
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','"Estimate cam parameters" or "Load parameters" needs to be performed first','modal');
    handles.calib_userectification.Value = 0;
    return
end
cam_selected_rectification_image = gui.retr('cam_selected_rectification_image');
if isempty (cam_selected_rectification_image)
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','No target image selected.','modal');
    handles.calib_userectification.Value = 0;
    return
end
originCheckerColor = handles.calib_origincolor.String{handles.calib_origincolor.Value} ;
if strcmpi (originCheckerColor,'white') && mod(str2double(handles.calib_rows.String),2)~=0
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Number of rows of the ChArUco board, dim1, must be even when OriginCheckerColor is white.','modal');
    return
end
if ~isempty(cam_selected_rectification_image)
    %handles.calib_usecalibration.Value = 0;
    gui.toolsavailable(0,'Detecting markers...');drawnow;
    %detector = vision.calibration.monocular.CharucoBoardDetector();
    patternDims = [str2double(handles.calib_rows.String),str2double(handles.calib_columns.String)];
    if contains(handles.calib_boardtype.String{handles.calib_boardtype.Value}, 'DICT_4X4_1000')
        markerFamily = 'DICT_4X4_1000';
    end
    checkerSize = str2double(handles.calib_checkersize.String);
    markerSize = str2double(handles.calib_markersize.String);
    if markerSize >= checkerSize
        gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Marker size must be smaller than checker size.','modal');
        gui.toolsavailable(1)
        return
    end
    minMarkerID = 0;
    %% Slower but more robust due to image preprocessing:
    %%{
    tmp_img=imread(cam_selected_rectification_image);
    tmp_img=imadjust(tmp_img);
    tmp_img=imsharpen(tmp_img);
    imagePoints1 = detectCharucoBoardPoints(tmp_img,patternDims,markerFamily,checkerSize,markerSize, 'MinMarkerID', minMarkerID, 'OriginCheckerColor', originCheckerColor,'RefineCorners',true,'ResolutionPerBit',16,'MarkerSizeRange',[0.005 1]);
    %%}
    %% faster but no preproc possible
    %[imagePoints1, ~] = detectPatternPoints(detector, cam_selected_rectification_image, patternDims, markerFamily, checkerSize, markerSize, 'MinMarkerID', minMarkerID, 'OriginCheckerColor', originCheckerColor);
    if isempty(imagePoints1)
        gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','No ChArUco markers detected.','modal');
        gui.toolsavailable(1)
        return
    end
end

%[mean_checker_size_x,mean_checker_size_y]=preproc.cam_meanCharucoSize(tmp_img,markerFamily,checkerSize,markerSize);

worldPoints = patternWorldPoints("charuco-board",patternDims,checkerSize);%checkerSize); %here, checkersize units are also mm to get correct extrinsics of camera.

worldPoints(isnan(imagePoints1))=NaN;
imagePoints1 = rmmissing(imagePoints1); %remove missing entries... does that work simply like this? --> yes. If matching world points are also removed.
worldPoints = rmmissing(worldPoints);

if patternDims(1) > patternDims(2) %Fixes the issue that high slender calibration bards result in rotated output
    % swap axes
    worldPoints = worldPoints(:, [2 1]);
    % flip y axis
    worldPoints(:,2) = -worldPoints(:,2);
end
gui.toolsavailable(1)

%% check what the image size will be after image undistortion
if handles.calib_userectification.Value ==1
    gui.put('expected_image_size',[]);
    gui.put('cam_use_rectification',1);
    [currentimage,~] = import.get_img(1);
    expected_image_size_after_rectification = size(currentimage(:,:,1));
    gui.put('expected_image_size',expected_image_size_after_rectification);
else
    if ~isempty(gui.retr('filepath'))
        gui.put('cam_use_rectification',0);
        gui.put('expected_image_size',[]);
        [currentimage,~] = import.get_img(1);
        expected_image_size = size(currentimage);
        expected_image_size=expected_image_size(1:2);
        gui.put('expected_image_size',expected_image_size);
    end
end
gui.sliderdisp(gui.retr('pivlab_axis'));
camExtrinsics1 = estimateExtrinsics(imagePoints1,worldPoints,cameraParams.Intrinsics);
% get angles
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
orientation_message=['Yaw: ' num2str(round(alpha_deg)) ' ; Pitch: ' num2str(round(beta_deg)) ' ; Roll: ' num2str(round(roll_deg,1))];

camfig=figure('Name','Camera position in 3D','DockControls','off','WindowStyle','normal','Scrollable','off','MenuBar','figure','Resize','on','ToolBar','none','NumberTitle','off');
camax=axes(camfig);
plot3(worldPoints(:,1),worldPoints(:,2),zeros(size(worldPoints, 1),1),"*",'Parent',camax);
hold on
plot3(0,0,0,"g*",'Parent',camax);
absPose1 = extr2pose(camExtrinsics1);
%absPose2 = extr2pose(camExtrinsics2);
plotcam1 = plotCamera(AbsolutePose=absPose1,Size=5,Color="red",AxesVisible=true,Label=['Cam1' newline orientation_message],Parent=camax);
%plotcam2 = plotCamera(AbsolutePose=absPose2,Size=30,Color="blue",AxesVisible=true,Label="Cam2",Parent=camax);
axis equal
grid on
set(camax,CameraUpVector=[0 -1 0]);
axis equal
grid on
cameratoolbar(camfig,'SetMode','orbit');
cameratoolbar(camfig,"SetCoordSys","y")
xlabel("X (mm)");
ylabel("Y (mm)");
zlabel("Z (mm)");
view(camax,[0 -45]);
camorbit(camax,-45,0,'data',[0 1 0])
camproj(camax,'perspective')
%{
figure(getappdata(0,'hgui'));drawnow
%reset zoom
set(handles.panon,'Value',0);
set(handles.zoomon,'Value',0);
gui.put('xzoomlimit', []);
gui.put('yzoomlimit', []);
gui.sliderdisp(gui.retr('pivlab_axis'))
drawnow;
figure(camfig)
%}