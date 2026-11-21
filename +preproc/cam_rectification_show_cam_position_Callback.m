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
    % also detects a mirrored board (camera behind the light sheet)
    [imagePoints1,mirrored] = preproc.cam_detect_rectification_board(imread(cam_selected_rectification_image),patternDims,markerFamily,checkerSize,markerSize,originCheckerColor);
    if isempty(imagePoints1) || all(isnan(imagePoints1(:)))
        gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','No ChArUco markers detected.','modal');
        gui.toolsavailable(1)
        return
    end
end

% camera pose as in the live image of the image acquisition (checker size in mm: extrinsics in mm)
[message,~,pose] = acquisition.charuco_pose(imagePoints1,patternDims,checkerSize,mirrored,cameraParams.Intrinsics,[false false]);
gui.toolsavailable(1)
if isempty(pose)
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Too few ChArUco corners detected to estimate the camera position.','modal');
    return
end
orientation_message = strtok(message, newline); % first line: yaw, pitch, roll
worldPoints = pose.world_points; % in the board coordinates of the pose

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
camfig=figure('Name','Camera position in 3D','DockControls','off','WindowStyle','normal','Scrollable','off','MenuBar','figure','Resize','on','ToolBar','none','NumberTitle','off');
camax=axes(camfig);
plot3(worldPoints(:,1),worldPoints(:,2),zeros(size(worldPoints, 1),1),"*",'Parent',camax);
hold on
plot3(0,0,0,"g*",'Parent',camax);
absPose1 = extr2pose(pose.extrinsics);
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