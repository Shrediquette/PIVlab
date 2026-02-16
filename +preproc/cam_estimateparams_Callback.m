function cam_estimateparams_Callback(~, ~, ~)
warning off 'MATLAB:imagesci:imfinfo:unknownXMPpacket'
handles=gui.gethand;
cam_selected_target_images = gui.retr('cam_selected_target_images');
originCheckerColor = handles.calib_origincolor.String{handles.calib_origincolor.Value};
if strcmpi (originCheckerColor,'white') && mod(str2double(handles.calib_rows.String),2)~=0
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Number of rows of the ChArUco board, dim1, must be even when OriginCheckerColor is white.','modal');
    return
end
if str2double(handles.calib_rows.String)<3 || str2double(handles.calib_columns.String)<3
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Number of rows and columns of the ChArUco board must be >= 3.','modal');
    return
end
if isempty(cam_selected_target_images) || ~iscell(cam_selected_target_images) || numel(cam_selected_target_images) <=1
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Not enough marker board images selected.','modal');
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
        gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Marker size must be smaller than checker size.','modal');
        gui.toolsavailable(1)
        return
    end
    minMarkerID = 0;
    for i=1:numel(cam_selected_target_images)
        tmp_img=imread(cam_selected_target_images{i});
        tmp_img=tmp_img(:,:,1);
        tmp_img=imadjust(tmp_img);
        [detectionOK,qr_markerFamily, qr_originCheckerColor,qr_patternDims,qr_checkerSize,qr_markerSize,~] = preproc.cam_get_charuco_info_from_QRcode (tmp_img);
        %check if it differs from manually entered numbers
        if detectionOK
            if  ~strcmp(markerFamily,qr_markerFamily) || ~strcmp(originCheckerColor,qr_originCheckerColor) ||  patternDims(1) ~= qr_patternDims(1) ||  patternDims(2) ~= qr_patternDims(2) || checkerSize ~= qr_checkerSize || markerSize ~= qr_markerSize
                button = gui.custom_msgbox('quest',getappdata(0,'hgui'),'Warning',['User supplied information for Charuco board differs from the information found in the QR code on the board.' newline newline 'Use the information from the QR code on the board?'],'modal',{'Yes','No'},'Yes');
                if strmatch(button,'Yes')==1
                    markerFamily = qr_markerFamily;
                    originCheckerColor = qr_originCheckerColor;
                    patternDims = qr_patternDims;
                    checkerSize = qr_checkerSize;
                    markerSize = qr_markerSize;
                    if strcmp(originCheckerColor,'Black')
                        handles.calib_origincolor.Value = 1;
                    elseif strcmp(originCheckerColor,'White')
                        handles.calib_origincolor.Value = 2;
                    end
                    handles.calib_rows.String = num2str(patternDims(1));
                    handles.calib_columns.String = num2str(patternDims(2));
                    if strcmp(markerFamily,'DICT_4X4_1000')
                        handles.calib_boardtype.Value = 1;
                    end
                    handles.calib_checkersize.String = num2str(checkerSize);
                    handles.calib_markersize.String = num2str(markerSize);
                end
            else
                disp('QR info and user info match.')
            end
            break
        end
    end
    %% Slower but more robust due to image preprocessing:
    %%{
    if isMATLABReleaseOlderThan("R2025b")
        fig = uifigure;
        d = uiprogressdlg(fig,'Title','ChArUco board pattern detection...','Message','Starting ChArUco board pattern detection...');
    else
        d = uiprogressdlg(gcf,'Title','ChArUco board pattern detection...','Message','Starting ChArUco board pattern detection...');
    end
    
    imagesUsed=false(numel(cam_selected_target_images),1);
    imagePoints=[];
    for i=1:numel(cam_selected_target_images)
        tmp_img=imread(cam_selected_target_images{i});
        tmp_img=tmp_img(:,:,1);
        tmp_img=imadjust(tmp_img);
        try
            imagePoints_single = detectCharucoBoardPoints(tmp_img,patternDims,markerFamily,checkerSize,markerSize, 'MinMarkerID', minMarkerID, 'OriginCheckerColor', originCheckerColor,'ResolutionPerBit',16,'MarkerSizeRange',[0.005 1]);
        catch ME
         gui.custom_msgbox('error',getappdata(0,'hgui'),'Error',ME.message,'modal','OK');
            gui.toolsavailable(1)
            return
        end
        if numel(imagePoints_single)>0
            if numel(imagePoints)==0
                imagePoints(:,:,end)=imagePoints_single;
            else
                imagePoints(:,:,end+1)=imagePoints_single;
            end
            imagesUsed(i)=true;
        end
        [~,name,ext] = fileparts(cam_selected_target_images{i});
        percentage_detected=  round(numel(find(~isnan(imagePoints_single)))  / (numel(imagePoints_single)+0.00001) * 100);
        d.Message = [name ext '  -->  '  num2str(percentage_detected) ' % valid markers.' ];
        d.Value=i/numel(cam_selected_target_images);
    end
    if isMATLABReleaseOlderThan("R2025b")
        close(fig)
    else
        close(d)
    end

		%debug
%{
		for i=1:size(imagePoints,3)
			figure;
			imshow(imread(cam_selected_target_images{i}));
			hold on;
			plot(imagePoints(:,1,i), imagePoints(:,2,i),'ro');
			legend('Detected Points','ReprojectedPoints');
			hold off;
		end
%}
    %%}
    %% Faster, but dark images are ignored:
    %[imagePoints, imagesUsed] = detectPatternPoints(detector, cam_selected_target_images, patternDims, markerFamily, checkerSize, markerSize, 'MinMarkerID', minMarkerID, 'OriginCheckerColor', originCheckerColor);
    if isempty(imagePoints)
        gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','No ChArUco markers detected.','modal');
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

        imshow(imread(imageFileNames{1}),'Parent',gui.retr('pivlab_axis'));
        hold on;
        plot(imagePoints(:,1,1), imagePoints(:,2,1),'go');
        plot(cameraParams.ReprojectedPoints(:,1,1),cameraParams.ReprojectedPoints(:,2,1),'r+');
        legend('Detected Points','ReprojectedPoints');
        hold off;

        possible_grid_points = (patternDims(1)-1) * (patternDims(2)-1) * sum(imagesUsed);
		detected_grid_points = sum(~isnan(imagePoints(:)))/2;
		percentage_detected=round(detected_grid_points/possible_grid_points*100,1);

		err = cameraParams.ReprojectionErrors;
		errNorm = sqrt(err(:,1,:).^2 + err(:,2,:).^2);
		meanReprojError = mean(errNorm(:), 'omitnan');

        gui.custom_msgbox('msg',getappdata(0,'hgui'),'Success',{'Success.' ;  ['Detected ' num2str(percentage_detected) '% of checkers.' ] ; ['Mean reprojection eror: ' num2str(round(meanReprojError,2)) ' px']},'modal',{'OK'},'OK');

    catch ME
        gui.custom_msgbox('error',getappdata(0,'hgui'),'Error',{'Problem with camera calibration: ' ;' '; ME.message},'modal');
    end

    gui.toolsavailable(1)
else
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','No calibration image data was loaded.','modal');
end