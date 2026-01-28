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
I = double(generateCharucoBoard(imageSize,patternDims,markerFamily,checkerSize,markerSize,"OriginCheckerColor",originCheckerColor,"MinMarkerID",minMarkerID,"MarginSize",1))/255;

%% add logo, text information and qr code to image
if strcmp (markerFamily ,'DICT_4X4_1000')
    qr_fam=1;
else
    qr_fam=0;
end
if strcmpi(originCheckerColor,'white')
    qr_orig = 'w';
else
    qr_orig = 'b';
end
data=['F:' num2str(qr_fam) ',O:' qr_orig ',R:' num2str(patternDims(1)) ',C:' num2str(patternDims(2)) ',S:' num2str(checkerSize) ',M:' num2str(markerSize)];

qr_size=ceil(checkerSize* 300 / 25.4 *3.5); %size of three checkers...
qr = preproc.cam_encode_qr (data,qr_size);
white_pad=ones(size(qr,1),size(I,2)-size(qr,2));
white_pad = [white_pad  qr];

olt_logo=double(rgb2gray(imread(fullfile('images','OLT_logo.png'))))/255;
numrows = qr_size / 3;
numcols = size(olt_logo,2)/size(olt_logo,1) * numrows;
olt_logo = imresize(olt_logo,[round(numrows) round(numcols)],'bicubic');
%das hat jetzt gute größe muss jetzt eingefügt werden in white_pad

%by DGM Matlab answers:
sza = size(white_pad); sza = sza(1:2);
szb = size(olt_logo); szb = szb(1:2);
% vertical padding (centered)
pad_vert = (sza(1) - szb(1)) / 2;
pad_top    = ceil(pad_vert);
pad_bottom = floor(pad_vert);

% horizontal padding (left-aligned)
pad_left  = 0;
pad_right = sza(2) - szb(2);

olt_logo_padded = padarray(olt_logo, [pad_top pad_left], 255, 'pre');
olt_logo_padded = padarray(olt_logo_padded, [pad_bottom pad_right], 255, 'post');
white_pad=white_pad.*olt_logo_padded;
I=[white_pad;I];
I = insertText(I,[numcols + 10,qr_size/2],[originCheckerColor ',' markerFamily ',' num2str(patternDims(1)) 'x' num2str(patternDims(2)) ',' num2str(checkerSize) 'mm,' num2str(markerSize) 'mm'],'FontSize',40);
figure;imshow(I)
[file, location] = uiputfile('*.tif','Save charuco board as...',[markerFamily '_' num2str(patternDims(1)) 'x' num2str(patternDims(2)) '_' num2str(checkerSize) 'mm_' num2str(markerSize) 'mm_300dpi.tif']);
if file ~=0
    imwrite(I,fullfile(location,file),'tif','Resolution',300);
end
disp('skalierung muss noch verfeinert werden für Grenzfälle.')