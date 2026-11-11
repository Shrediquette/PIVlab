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
if patternDims(1)*patternDims(2) > 2000 % DICT_4X4_1000 has 1000 markers, one on every second checker
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error',['Too many checkers (2000 checkers are the maximum). Reduce the amount of rows or columns, so that' newline 'Rows * Columns <= 2000.'],'modal');
    return
end
if patternDims(1) == patternDims(2)
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Amount of rows and columns should not be equal to avoid ambiguity.','modal');
    return
end
minMarkerID = 0;
layout = preproc.cam_board_layout(patternDims, markerFamily, checkerSize, markerSize, originCheckerColor);
marginsize=round(layout.margin * dpi / 25.4);
imageSize (1) =ceil(patternDims(1)*checkerSize* dpi / 25.4)+2*marginsize; %size in pixels at  dpi
imageSize (2) = ceil(patternDims(2)*checkerSize* dpi / 25.4)+2*marginsize; %size in pixels at  dpi

final_height = imageSize(1) + max(0, round(layout.margin_top * dpi / 25.4) - marginsize); % cam_decorate_board adds the taller top margin
answer = gui.custom_msgbox('quest',getappdata(0,'hgui'),'Generate board?',['Generate a board with a size of ' num2str(imageSize(2)) '*' num2str(final_height) ' pixels?' newline 'At ' num2str(dpi) ' dpi, this is ' num2str(round(imageSize(2)/dpi*25.4)) '*' num2str(round(final_height/dpi*25.4)) ' mm.' newline 'Save the image, then print at ' num2str(dpi) ' dpi and 100 % scaling.' newline newline 'The margin shows the board coordinate system: origin at the first inner corner (top left), x to the right, y down, z into the board.'],'modal',{'Yes','Cancel'},'Yes');
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
% default file name with the board size (width x height, with margins)
board_mm = [layout.width, layout.height];
default_name = [originCheckerColor '_' markerFamily '_' num2str(patternDims(1)) 'x' num2str(patternDims(2)) '_' num2str(checkerSize) 'mm_' num2str(markerSize) 'mm_' num2str(board_mm(1)) 'x' num2str(board_mm(2)) 'mm'];
[file, location] = uiputfile({'*.tif','TIFF image (300 dpi)';'*.pdf','PDF vector, print-ready (exact size in mm, also for transparent material)'},'Save charuco board as...',default_name);
if file ~=0
    [~,name,ext] = fileparts(file);
    if strcmpi(ext,'.pdf')
        if strcmp(name, default_name) % default name: the PDF page has 5 mm bleed on every side (preproc.cam_board_pdf)
            file = [name '_plus_5mm_bleed.pdf'];
            if isfile(fullfile(location,file))
                answer = gui.custom_msgbox('quest',getappdata(0,'hgui'),'File exists',[file ' already exists. Overwrite it?'],'modal',{'Yes','Cancel'},'Cancel');
                if ~strcmpi(answer,'Yes')
                    return
                end
            end
        end
        gui.toolsavailable(0,'Writing PDF file...');drawnow;
        preproc.cam_board_pdf(fullfile(location,file), patternDims, markerFamily, checkerSize, markerSize, originCheckerColor);
        gui.toolsavailable(1)
    else
        if ~strcmpi(ext,'.tif')
            file = [file '.tif'];
        end
        imwrite(I,fullfile(location,file),'tif','Resolution',dpi);
    end
end
