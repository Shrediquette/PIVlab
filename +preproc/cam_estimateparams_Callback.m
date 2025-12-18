function cam_estimateparams_Callback(~, ~, ~)
warning off 'MATLAB:imagesci:imfinfo:unknownXMPpacket'
handles=gui.gethand;

cam_selected_target_images = gui.retr('cam_selected_target_images');

contains(handles.calib_boardtype.String{handles.calib_boardtype.Value}, 'DICT_4X4_1000')


str2double(handles.calib_rows.String)

str2double(handles.calib_columns.String)

handles.calib_usecalibration.Value



%am ende das callback der enable_checkbox ausführen
%dieses macht bei änderung: PIV ergebnisse, ROI und Masken löschen und dann sliderdisp
%sliderdisp respektiert die image undistortion.

% sliderdisp macht es so:
% if handles.calib_usecalibration.Value == 1
% cameraParams = gui.retr('cameraParams');
% J1 = undistortImage(I,cameraParams,'nearest','OutputView','valid'); %cubic only before passing images to PIV
% end


% it seems like the charuco board is more accurately detected in the
% correct orientation when e.g. rows = 23 and cols = 24
% Es ist egal ob das ganze board gesehen wird. Geht auch Ausschnitt aus der
% Mitte.

% Detect calibration pattern in images
if ~isempty(cam_selected_target_images)
    gui.toolsavailable(0,'Calculating camera parameters...');drawnow;
    detector = vision.calibration.monocular.CharucoBoardDetector();
    patternDims = [str2double(handles.calib_rows.String),str2double(handles.calib_columns.String)];
    if contains(handles.calib_boardtype.String{handles.calib_boardtype.Value}, 'DICT_4X4_1000')
        markerFamily = 'DICT_4X4_1000';
    end
    checkerSize = str2double(handles.calib_checkersize.String);
    markerSize = str2double(handles.calib_markersize.String);

    minMarkerID = 0;
    originCheckerColor = handles.calib_origincolor.String{handles.calib_origincolor.Value} ;
    [imagePoints, imagesUsed] = detectPatternPoints(detector, cam_selected_target_images, patternDims, markerFamily, checkerSize, markerSize, 'MinMarkerID', minMarkerID, 'OriginCheckerColor', originCheckerColor);
    imageFileNames = cam_selected_target_images(imagesUsed);

    % Read the first image to obtain image size
    originalImage = imread(cam_selected_target_images{1});
    [mrows, ncols, ~] = size(originalImage);

    % Generate world coordinates for the planar pattern keypoints
    worldPoints = generateWorldPoints(detector, 'PatternDims', patternDims, 'CheckerSize', checkerSize);


    % Calibrate the camera
    try
        [cameraParams, imagesUsed, estimationErrors] = estimateCameraParameters(imagePoints, worldPoints, 'EstimateSkew', false, 'EstimateTangentialDistortion', true, 'NumRadialDistortionCoefficients', 2, 'WorldUnits', 'millimeters', 	'InitialIntrinsicMatrix', [], 'InitialRadialDistortion', [], 'ImageSize', [mrows, ncols]);
        gui.put('cameraParams',cameraParams);

        imshow(imageFileNames{1},'Parent',gui.retr('pivlab_axis'));
        hold on;
        plot(imagePoints(:,1,1), imagePoints(:,2,1),'go');
        plot(cameraParams.ReprojectedPoints(:,1,1),cameraParams.ReprojectedPoints(:,2,1),'r+');
        legend('Detected Points','ReprojectedPoints');
        hold off;

        possible_grid_points = (patternDims(1)-1) * (patternDims(2)-1) * sum(imagesUsed);
        detected_grid_points = sum(~isnan(imagePoints(:)))/2;
        percentage_detected=round(detected_grid_points/possible_grid_points*100,1);

        gui.custom_msgbox('msg',getappdata(0,'hgui'),'Success',{'Camera parameter estimation successful.' ;  ['Detected ' num2str(percentage_detected) '% of the available checkers.']},'modal',{'OK'},'OK')

    catch ME
        gui.custom_msgbox('error',getappdata(0,'hgui'),'Error',{'Are the numbers for columns and rows correct?' ;' '; ME.message},'modal')
    end


    gui.toolsavailable(1)
end






%{

keyboard














% View reprojection errors
%h1=figure; showReprojectionErrors(cameraParams);




figure;
showExtrinsics(cameraParams,'Parent',gui.retr('pivlab_axis'));
figure; 
imshow(imageFileNames{1}); 
hold on;
plot(imagePoints(:,1,1), imagePoints(:,2,1),'go');
plot(cameraParams.ReprojectedPoints(:,1,1),cameraParams.ReprojectedPoints(:,2,1),'r+');
legend('Detected Points','ReprojectedPoints');
hold off;
%% undistort image
I = imread(imageFileNames{1});
J1 = undistortImage(I,cameraParams,'cubic','OutputView','valid');
figure;imagesc(I);figure;imagesc(J1)


%% another functionality: warp two images together when I have an image of a charuco board.
%{
imageFileName1 = 'C:\Users\trash\Downloads\moving board\CAM1_PIVlab_0000_A.tif';
imageFileName2 = 'C:\Users\trash\Downloads\moving board\CAM2_PIVlab_0000_A.tif';
image1=imread(imageFileName1);
image2=imread(imageFileName2);

%images should be undistorted before doing the overlap
%image1 = undistortImage(image1,params,'cubic','OutputView','valid'); %auch hier: params sollten eigentlich pro Kamera errechnet werden.
%image2 = undistortImage(image2,params,'cubic','OutputView','valid');



[imagePoints1] = detectCharucoBoardPoints(imageFileName1,patternDims,markerFamily,checkerSize,markerSize);
[imagePoints2] = detectCharucoBoardPoints(imageFileName2,patternDims,markerFamily,checkerSize,markerSize);
worldPoints = patternWorldPoints("charuco-board",patternDims,checkerSize);


%[gH, inlierIdx] = estimateGeometricTransform2D(imagePoints1, imagePoints2, 'projective', 'MaxNumTrials',2000,'Confidence',99.9,'MaxDistance',4);

[gH, inlierIdx] = estgeotform2d(imagePoints1, imagePoints2, 'projective', 'MaxNumTrials',2000,'Confidence',99.9,'MaxDistance',4);

tform = projective2d(gH.T);
ref = imref2d(size(image2));
I1_warped = imwarp(image1, tform, 'OutputView', ref);

% Visualize
figure;
imshowpair(image2, I1_warped);
%}

%% another functionality: Image rectification. How to do it?

imageNrToProcess = 3;
[imagePoints1] = detectPatternPoints(detector, imageFileNames{imageNrToProcess}, patternDims, markerFamily, checkerSize, markerSize, 'MinMarkerID', minMarkerID, 'OriginCheckerColor', originCheckerColor);


[mean_checker_size_x,mean_checker_size_y]=meanCharucoSize(imagePoints1)


worldPoints = patternWorldPoints("charuco-board",patternDims,(mean_checker_size_y+mean_checker_size_x)/2);%checkerSize); %checkersize muss die Größe haben, die die quadrate im eingangsbild in pixeln haben.

worldPoints(isnan(imagePoints1))=NaN;

imagePoints1 = rmmissing(imagePoints1); %remove missing entries... does that work simply like this? --> yes. If matching world points are also removed.
worldPoints = rmmissing(worldPoints);


undistortedPoints = undistortPoints(imagePoints1,cameraParams.Intrinsics);
I=imread(imageFileNames{imageNrToProcess});
[J1, ~] = undistortImage(I,cameraParams.Intrinsics,"cubic");
tform = fitgeotform2d(undistortedPoints,worldPoints,'Projective');
undistorted_rectified = imwarp(J1,tform);
figure;imshow(I)
figure;imshow(J1)
figure;imshow(undistorted_rectified)



for i=0:99
    fnameA=['D:\PIV Data\PIV_mit_charuco\PIVlab_' sprintf('%4.4d',i) '_A.tif'];
    fnameB=['D:\PIV Data\PIV_mit_charuco\PIVlab_' sprintf('%4.4d',i) '_B.tif'];
   tic

   %% do this in real time, or once before analysis?
   %% takes 0.1 seconds for OPTOcam... but way longer for panda I guess...?
   %% Man könnte in sliderdisp nearest neighbor nehmen, und nur für die analyse dann die ordentliche variante.
    [A, ~] = undistortImage(imread(fnameA),cameraParams.Intrinsics,"cubic");
    A = imwarp(A,tform);
    [B, ~] = undistortImage(imread(fnameB),cameraParams.Intrinsics,"cubic");
    B = imwarp(B,tform);
    toc

    %imwrite(A,['D:\PIV Data\PIV_mit_charuco\PIVlab_rectified_' sprintf('%4.4d',i) '_A.tif'])
    %imwrite(B,['D:\PIV Data\PIV_mit_charuco\PIVlab_rectified_' sprintf('%4.4d',i) '_B.tif'])
end


%% Jetzt müsste man sich einen Workflow ausdenken wie man das macht.
% Erst Mit vielen Charuco Bildern beide Kameras kalibrieren. (Man könnte auch Charuco fix machen und Kameras drumrum bewegen)
% Dann ein Board genau in Laserebene. Mit beiden Kameras ein Foto von Charuco
% Dann diese beiden Bilder undistorten
% Dann rektifizieren
% Dann alignment

%}