function cam_generateboard_Callback (~,~,~)
handles=gui.gethand;
originCheckerColor = handles.calib_origincolor.String{handles.calib_origincolor.Value};
patternDims = [str2double(handles.calib_rows.String),str2double(handles.calib_columns.String)];
if contains(handles.calib_boardtype.String{handles.calib_boardtype.Value}, 'DICT_4X4_1000')
    markerFamily = 'DICT_4X4_1000';
end
checkerSize = str2double(handles.calib_checkersize.String);
markerSize = str2double(handles.calib_markersize.String);
if patternDims(1)<3 || patternDims(2)<3 
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Rows and columns must both be >= 3.','modal');
    return
end
if strcmpi(originCheckerColor,'white') ~=0 && mod(patternDims(1), 2) ~= 0
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Number of rows of the ChArUco board must be even when OriginCheckerColor is white.','modal');
    return
end
if markerSize >= checkerSize
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Marker size must be smaller than checker size.','modal');
    return
end
if patternDims(1)*patternDims(2) > 1000
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Too many checkers (1000 checkers are the maximum). Reduce the amount of rows or columns. ','modal');
    return
end
minMarkerID = 0;
imageSize (1) =ceil(patternDims(1)*checkerSize* 300 / 25.4)+2; %size in pixels at 300 dpi
imageSize (2) = ceil(patternDims(2)*checkerSize* 300 / 25.4)+2; %size in pixels at 300 dpi
I = generateCharucoBoard(imageSize,patternDims,markerFamily,checkerSize,markerSize,"OriginCheckerColor",originCheckerColor,"MinMarkerID",minMarkerID,"MarginSize",1);
figure;imshow(I)
[file, location] = uiputfile('*.tif','Save charuco board as...',[markerFamily '_' num2str(patternDims(1)) 'x' num2str(patternDims(2)) '_' num2str(checkerSize) 'mm_' num2str(markerSize) 'mm_300dpi.tif']);
if file ~=0
    imwrite(I,fullfile(location,file),'tif','Resolution',300);
end