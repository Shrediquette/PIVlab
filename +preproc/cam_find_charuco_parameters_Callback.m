function [outputArg1,outputArg2] = cam_find_charuco_parameters_Callback(~,~,~)
warning off 'vision:calibrate:boardShouldBeAsymmetric'
handles=gui.gethand;
[filename,location]=uigetfile(...
    {'*.bmp;*.tif;*.tiff;*.jpg;*.png','Image files';
    '*.bmp','Bitmaps'; ...
    '*.tif;*.tiff','TIF'; ...
    '*.jpg','JPEG'; ...
    '*.png','PNG'; ...
    '*.*',  'All Files'}...
    ,"MultiSelect","off",'Select images of the calibration target',gui.retr('pathname'));
if ~isempty(filename)


    tmp_img=imread(fullfile(location,filename));

    tmp_img2=mat2gray(tmp_img(:,:,1));
    tmp_img2=histeq(tmp_img2);

    tmp_img=imadjust(tmp_img(:,:,1));


    [ids,locs,detectedFamily] = readArucoMarker(tmp_img);

    [imagePointsA,boardSizeA] = detectCheckerboardPoints(tmp_img,'HighDistortion',false);
    [imagePointsB,boardSizeB] = detectCheckerboardPoints(tmp_img2,'HighDistortion',false);


    diff_A=abs(size(ids,2) - size(imagePointsA,1)/2);
    diff_B=abs(size(ids,2) - size(imagePointsB,1)/2);

    if diff_A <= diff_B
        imagePoints=imagePointsA;
        boardSize=boardSizeA;
    else
        imagePoints=imagePointsB;
        boardSize=boardSizeB;
    end
    if isempty(imagePoints)
        gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Could not estimate parameters','modal')
        return
    end
    num_markers=boardSize(1)*boardSize(2);

    imshow(tmp_img2);
    hold on
    scatter(imagePoints(:,1),imagePoints(:,2),150,'rx','LineWidth',2)
    hold off


    [u, ~, idx] = unique(detectedFamily, 'stable');
    counts = accumarray(idx, 1);
    [~, iMax] = max(counts);
    mostCommonFamily = u(iMax);

    try
        imagePoints_black = detectCharucoBoardPoints(tmp_img,boardSize,mostCommonFamily,10,7, 'MinMarkerID', 0, 'OriginCheckerColor', 'Black','ResolutionPerBit',16,'MarkerSizeRange',[0.005 1]);
    catch
        imagePoints_black=0;
    end
    try
        imagePoints_white = detectCharucoBoardPoints(tmp_img,boardSize,mostCommonFamily,10,7, 'MinMarkerID', 0, 'OriginCheckerColor', 'White','ResolutionPerBit',16,'MarkerSizeRange',[0.005 1]);
    catch
        imagePoints_white=0;
    end

    diff_black=abs(size(imagePoints_black,1) - num_markers);
    diff_white=abs(size(imagePoints_white,1) - num_markers);

    if diff_black < diff_white
        OriginCheckerColor = 'Black';
    end

    if diff_black == diff_white
        stdev_white=std(diff(imagePoints_white(:,1))) + std(diff(imagePoints_white(:,2)));
        stdev_black=std(diff(imagePoints_black(:,1))) + std(diff(imagePoints_black(:,2)));
        if stdev_black <= stdev_white
            OriginCheckerColor = 'Black';
        else
            OriginCheckerColor = 'White';
        end
    end

    if diff_black > diff_white
        OriginCheckerColor = 'White';
    end



    gui.custom_msgbox('msg',getappdata(0,'hgui'),'Results (may be inaccurate)',['Origin checker color: ' OriginCheckerColor  'Marker family: ' mostCommonFamily  'Rows: ' int2str(boardSize(1))  'Columns: ' int2str(boardSize(2)) ],'modal','OK','OK')

    if strcmpi('DICT_4X4_1000',mostCommonFamily)
        handles.calib_boardtype.Value = 1;
    else
        %other marker families are not supported.
    end

    if strcmpi('Black',OriginCheckerColor)
        handles.calib_origincolor.Value=1;
    else
        handles.calib_origincolor.Value=2;
    end
    handles.calib_rows.String=int2str(boardSize(1));
    handles.calib_columns.String=int2str(boardSize(2));
end
