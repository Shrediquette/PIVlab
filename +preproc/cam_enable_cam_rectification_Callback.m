function cam_enable_cam_rectification_Callback(caller,~,~)
handles=gui.gethand;
filepath=gui.retr('filepath');
filename=gui.retr('filename');
if size(filepath,1) <= 1 && handles.calib_userectification.Value == 1 %did the user load piv images?
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','No PIV images were loaded.','modal');
    handles.calib_userectification.Value = 0;
    return
end

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



if ~strcmpi(caller,'calib_viewtype')
    res=gui.custom_msgbox('msg',getappdata(0,'hgui'),'Warning','Masks, ROI, background images, and results will be reset when changing this setting. Continue?','modal',{'OK','Cancel'},'OK');
else
    res='OK';
end
if ~strcmpi(res,'OK')
    if handles.calib_userectification.Value == 1
        handles.calib_userectification.Value = 0;
    else
        handles.calib_userectification.Value = 1;
    end
    return
end
if ~isempty (cameraParams) && ~isempty(cam_selected_rectification_image)
    %disp('muss bei jeder Änderung eigentlich masken löschen, ROI löschen, ergebnisse löschen...')
    gui.put ('resultslist', []); %clears old results
    gui.put ('derived',[]);
    gui.put('displaywhat',1);%vectors
    gui.put('framemanualdeletion',[]);
    gui.put('manualdeletion',[]);
    gui.put('streamlinesX',[]);
    gui.put('streamlinesY',[]);
    gui.put('bg_img_A',[]);
    gui.put('bg_img_B',[]);
    set(handles.bg_subtract,'Value',1);
    set(handles.fileselector, 'value',1);
    set(handles.minintens, 'string', 0);
    set(handles.maxintens, 'string', 1);
    roi.clear_roi_Callback
    gui.put('masks_in_frame',[]);
    ismean=gui.retr('ismean');
    for i=size(ismean,1):-1:1 %remove averaged results
        if ismean(i,1)==1
            filepath(i*2,:)=[];
            filename(i*2,:)=[];

            filepath(i*2-1,:)=[];
            filename(i*2-1,:)=[];
        end
    end
    gui.put('filepath',filepath);
    gui.put('filename',filename);
    gui.put('ismean',[]);
end
if handles.calib_userectification.Value == 1
    if ~isempty (cameraParams) && ~isempty(cam_selected_rectification_image)
        gui.put('cam_use_rectification',1);
    else
        gui.put('cam_use_rectification',0);
        handles.calib_userectification.Value = 0;
    end
else
    gui.put('cam_use_rectification',0);
end
originCheckerColor = handles.calib_origincolor.String{handles.calib_origincolor.Value} ;
if strcmpi (originCheckerColor,'white') && mod(str2double(handles.calib_rows.String),2)~=0
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Number of rows of the ChArUco board, dim1, must be even when OriginCheckerColor is white.','modal')
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
        gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Marker size must be smaller than checker size.','modal')
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
        gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','No ChArUco markers detected.','modal')
        gui.toolsavailable(1)
        return
    end
end

[mean_checker_size_x,mean_checker_size_y]=preproc.cam_meanCharucoSize(tmp_img,markerFamily,checkerSize,markerSize);

worldPoints = patternWorldPoints("charuco-board",patternDims,(mean_checker_size_y+mean_checker_size_x)/2);%checkerSize); %checkersize muss die Größe haben, die die quadrate im eingangsbild in pixeln haben.
worldPoints(isnan(imagePoints1))=NaN;
imagePoints1 = rmmissing(imagePoints1); %remove missing entries... does that work simply like this? --> yes. If matching world points are also removed.
worldPoints = rmmissing(worldPoints);

if strcmpi (class(cameraParams),'cameraParameters')
    undistortedPoints = undistortPoints(imagePoints1,cameraParams.Intrinsics);
elseif strcmpi (class(cameraParams),'fisheyeParameters')
    undistortedPoints = undistortFisheyePoints(imagePoints1,cameraParams.Intrinsics);
end

if patternDims(1) > patternDims(2) %Fixes the issue that high slender calibration bards result in rotated output
    % swap axes
    worldPoints = worldPoints(:, [2 1]);
    % flip y axis
    worldPoints(:,2) = -worldPoints(:,2);
end

rectification_tform = fitgeotform2d(undistortedPoints,worldPoints,'projective'); % standard für schräge ansicht
%rectification_tform = fitgeotform2d(undistortedPoints,worldPoints,'polynomial',4); % langsam, aber gar nicht so schlecht, könnte für Rohre gehen...

gui.put('rectification_tform',rectification_tform);
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