function cam_imagerectification_Callback(~, ~, ~)
warning off 'MATLAB:imagesci:imfinfo:unknownXMPpacket'
handles=gui.gethand;

cam_selected_target_images = gui.retr('cam_selected_target_images');

contains(handles.calib_boardtype.String{handles.calib_boardtype.Value}, 'DICT_4X4_1000')


str2double(handles.calib_rows.String)

str2double(handles.calib_columns.String)

handles.calib_usecalibration.Value
originCheckerColor = handles.calib_origincolor.String{handles.calib_origincolor.Value} ;
if strcmpi (originCheckerColor,'white') && mod(str2double(handles.calib_rows.String),2)~=0
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Number of rows of the ChArUco board, dim1, must be even when OriginCheckerColor is white.','modal')
    return
end

% Detect calibration pattern in images
if ~isempty(cam_selected_target_images)
    handles.calib_usecalibration.Value = 0;
    gui.toolsavailable(0,'Detecting markers...');drawnow;
    detector = vision.calibration.monocular.CharucoBoardDetector();
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
    % histeq machen von jedem Bild. Dann muss man das aber als loop mit bilddateien machen, nicht mit bilderliste... Schade.
    [imagePoints, imagesUsed] = detectPatternPoints(detector, cam_selected_target_images, patternDims, markerFamily, checkerSize, markerSize, 'MinMarkerID', minMarkerID, 'OriginCheckerColor', originCheckerColor);
    if isempty(imagePoints)
        gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','No ChArUco markers detected.','modal')
        gui.toolsavailable(1)
        return
    end
    gui.toolsavailable(1)
    gui.toolsavailable(0,'Calculating camera parameters...');drawnow;

    imageFileNames = cam_selected_target_images(imagesUsed);

    % Read the first image to obtain image size
    originalImage = imread(cam_selected_target_images{1});
    [mrows, ncols, ~] = size(originalImage);

    % Generate world coordinates for the planar pattern keypoints
    worldPoints = generateWorldPoints(detector, 'PatternDims', patternDims, 'CheckerSize', checkerSize);

    % Calibrate the camera
    try
        if handles.calib_fisheye.Value == 0
            [cameraParams, imagesUsed, ~] = estimateCameraParameters(imagePoints, worldPoints, 'EstimateSkew', false, 'EstimateTangentialDistortion', true, 'NumRadialDistortionCoefficients', 2, 'WorldUnits', 'millimeters', 	'InitialIntrinsicMatrix', [], 'InitialRadialDistortion', [], 'ImageSize', [mrows, ncols]);
        else
            [cameraParams, imagesUsed, ~] = estimateFisheyeParameters(imagePoints, worldPoints, [mrows, ncols]);
        end
        gui.toolsavailable(1)
        gui.toolsavailable(0,'Refining camera parameters...');drawnow;

        imageFileNames = imageFileNames(imagesUsed);

        errors = cameraParams.ReprojectionErrors;
        numImages = size(errors, 3);
        meanErrorPerImage = zeros(numImages, 1);

        for i = 1:numImages
            e = errors(:, :, i);
            meanErrorPerImage(i) = mean(sqrt(sum(e.^2, 2)),'omitnan');
        end

        threshold = mean(meanErrorPerImage) + 1.5*std(meanErrorPerImage);
        badImages = find(meanErrorPerImage > threshold);
        goodImages = find(meanErrorPerImage <= threshold);
        if numel(badImages)>0 && numel(goodImages)>3 %if some images have been bad
            disp(['Skipping ' num2str(numel(badImages)) ' image(s) due to high reprojection errors.'])
            imagePoints = imagePoints(:, :, goodImages);
            imageFileNames = imageFileNames(goodImages);
            if handles.calib_fisheye.Value == 0
                [cameraParams, imagesUsed, ~] = estimateCameraParameters(imagePoints, worldPoints, 'EstimateSkew', false, 'EstimateTangentialDistortion', true, 'NumRadialDistortionCoefficients', 2, 'WorldUnits', 'millimeters',  'ImageSize', [mrows, ncols],'InitialK',cameraParams.K,'InitialRadialDistortion',cameraParams.RadialDistortion);
                %[cameraParams, imagesUsed, ~] = estimateCameraParameters(imagePoints, worldPoints, 'EstimateSkew', false, 'EstimateTangentialDistortion', true, 'NumRadialDistortionCoefficients', 2, 'WorldUnits', 'millimeters', 	'InitialIntrinsicMatrix', [], 'InitialRadialDistortion', [], 'ImageSize', [mrows, ncols]);
            else
                [cameraParams, imagesUsed, ~] = estimateFisheyeParameters(imagePoints, worldPoints, [mrows, ncols]);
            end
            imageFileNames = imageFileNames(imagesUsed);
            disp('Images used:')
            for i=1:numel(imageFileNames)
                disp(imageFileNames{i})
            end
        end

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
else
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','No calibration image data was loaded.','modal')

end



