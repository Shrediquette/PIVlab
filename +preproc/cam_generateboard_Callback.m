function cam_generateboard_Callback (~,~,~)
dpi=300;
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
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error',['Too many checkers (1000 checkers are the maximum). Reduce the amount of rows or columns, so that' newline 'Rows * Columns <= 1000.'],'modal');
    return
end
if patternDims(1) == patternDims(2)
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Amount of rows and columns should not be equal to avoid ambiguity.','modal');
    return
end
minMarkerID = 0;
%margins are 3 checkers wide
marginsize=round(checkerSize* dpi / 25.4*3);
%margins are 10% of image wide:
%marginsize=max([round(patternDims(1)*checkerSize* dpi / 25.4*0.1) round(patternDims(2)*checkerSize* dpi / 25.4*0.1)]);
imageSize (1) =ceil(patternDims(1)*checkerSize* dpi / 25.4)+2*marginsize; %size in pixels at  dpi
imageSize (2) = ceil(patternDims(2)*checkerSize* dpi / 25.4)+2*marginsize; %size in pixels at  dpi

answer = gui.custom_msgbox('quest',getappdata(0,'hgui'),'Generate board?',['Generate a board with a size of ' num2str(imageSize(2)) '*' num2str(imageSize(1)) ' pixels?' newline 'At ' num2str(dpi) ' dpi, this is ' num2str(round(imageSize(2)/dpi*25.4)) '*' num2str(round(imageSize(1)/dpi*25.4)) ' mm.' newline 'Save the image, then print at ' num2str(dpi) ' dpi and 100 % scaling.'],'modal',{'Yes','Cancel'},'Yes');
if ~strcmpi(answer,'Yes')
    gui.toolsavailable(1)
    return
end

gui.toolsavailable(0,'Generating Charuco board...');drawnow;
I = double(generateCharucoBoard(imageSize,patternDims,markerFamily,checkerSize,markerSize,"OriginCheckerColor",originCheckerColor,"MinMarkerID",minMarkerID,"MarginSize",marginsize))/255;
%% add logo, text information and qr code to image
gui.toolsavailable(1)
gui.toolsavailable(0,'Generating QR code and decorations...');drawnow;
I = preproc.cam_decorate_board(I, patternDims, markerFamily, checkerSize, markerSize, originCheckerColor, marginsize, dpi / 25.4);
gui.toolsavailable(1)
figure;imshow(I)
[file, location] = uiputfile('*.tif','Save charuco board as...',[originCheckerColor '_' markerFamily '_' num2str(patternDims(1)) 'x' num2str(patternDims(2)) '_' num2str(checkerSize) 'mm_' num2str(markerSize) 'mm_' num2str(dpi) 'dpi.tif']);
if file ~=0
    imwrite(I,fullfile(location,file),'tif','Resolution',dpi);
end
