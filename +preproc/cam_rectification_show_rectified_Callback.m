function cam_rectification_show_rectified_Callback (~,~,~)
handles=gui.gethand;
cameraParams=gui.retr('cameraParams');
cam_selected_rectification_image = gui.retr('cam_selected_rectification_image');
if ~isempty (cameraParams) && ~isempty(cam_selected_rectification_image)
    %detector = vision.calibration.monocular.CharucoBoardDetector();
    patternDims = [str2double(handles.calib_rows.String),str2double(handles.calib_columns.String)];
    if contains(handles.calib_boardtype.String{handles.calib_boardtype.Value}, 'DICT_4X4_1000')
        markerFamily = 'DICT_4X4_1000';
    end
    checkerSize = str2double(handles.calib_checkersize.String);
    markerSize = str2double(handles.calib_markersize.String);
    originCheckerColor = handles.calib_origincolor.String{handles.calib_origincolor.Value} ;

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
        return
    end
    [mean_checker_size_x,mean_checker_size_y]=preproc.cam_meanCharucoSize(tmp_img,markerFamily,checkerSize,markerSize);
    checker_size_px=(mean_checker_size_y+mean_checker_size_x)/2 * handles.calib_upscale.Value;
    worldPoints = patternWorldPoints("charuco-board",patternDims,checker_size_px);%checkerSize); %checkersize muss die Größe haben, die die quadrate im eingangsbild in pixeln haben.

    if patternDims(1) > patternDims(2) %Fixes the issue that high slender calibration bards result in rotated output
        % swap axes
        worldPoints = worldPoints(:, [2 1]);
        % flip y axis
        worldPoints(:,2) = -worldPoints(:,2);
    end

    worldPoints(isnan(imagePoints1))=NaN;
    imagePoints1 = rmmissing(imagePoints1); %remove missing entries... does that work simply like this? --> yes. If matching world points are also removed.
    worldPoints = rmmissing(worldPoints);

    if strcmpi (class(cameraParams),'cameraParameters')
        undistortedPoints = undistortPoints(imagePoints1,cameraParams.Intrinsics);
    elseif strcmpi (class(cameraParams),'fisheyeParameters')
        undistortedPoints = undistortFisheyePoints(imagePoints1,cameraParams.Intrinsics);
    end
    rectification_tform = fitgeotform2d(undistortedPoints,worldPoints,'projective'); % standard für schräge ansicht
    %rectification_tform = fitgeotform2d(undistortedPoints,worldPoints,'polynomial',4); % langsam, aber gar nicht so schlecht, könnte für Rohre gehen...

    view_raw=handles.calib_viewtype.Value;
    if view_raw==1
        view='valid';
    elseif view_raw==2
        view='same';
    elseif view_raw==3
        view='full';
    end
    img_out = preproc.cam_undistort(imread(cam_selected_rectification_image),'cubic',view,1,1,cameraParams,rectification_tform);
    imshow(img_out,'Parent',gui.retr('pivlab_axis'))
else
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Camera calibration not activated or no images for camera rectification loaded.','modal');
end