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

qr_size=marginsize;
gui.toolsavailable(1)
gui.toolsavailable(0,'Generating QR code...');drawnow;
qr_0 = preproc.cam_encode_qr (data,qr_size);
gui.toolsavailable(1)
gui.toolsavailable(0,'Generating decorations...');drawnow;
qr_180=rot90(qr_0,2);

padval1 = imageSize (1) - qr_size;
padval2 = imageSize (2) - qr_size;

B_t_0 = padarray(qr_0,[padval1 0],1,'post');
B_tr = padarray(B_t_0,[0 padval2],1,'pre');
B_tl = padarray(B_t_0,[0 padval2],1,'post');
B_b_180 = padarray(qr_180,[padval1 0],1,'pre');
B_br = padarray(B_b_180,[0 padval2],1,'pre');
B_bl = padarray(B_b_180,[0 padval2],1,'post');
QR_background=B_tr.*B_tl.*B_br.*B_bl;

olt_logo=double(imread(fullfile('images','OLT_logo.png')))/255;
olt_logo = padarray(olt_logo,[50 50],1,'both');
max_width=floor(patternDims(2)*checkerSize* dpi / 25.4);
max_height=qr_size;

olt_width1= floor(size(olt_logo,2)/size(olt_logo,1) * max_height);
oltsize1=[max_height olt_width1];

olt_height1= floor(size(olt_logo,1)/size(olt_logo,2) * max_width);
oltsize2=[olt_height1 max_width];

if olt_width1 > max_width
	oltsize=oltsize2;
end
if olt_height1 > max_height
	oltsize=oltsize1;
end
olt_logo = imresize(olt_logo,[oltsize(1) oltsize(2)],'bicubic');

padval1 = imageSize(1) - oltsize(1);
padval2 = imageSize(2) - oltsize(2);

olt_logo_pad = padarray(olt_logo,[padval1,0],1,'pre');
olt_logo_pad = padarray(olt_logo_pad,[0,floor(padval2/2)],1,'pre');
olt_logo_pad = padarray(olt_logo_pad,[0,ceil(padval2/2)],1,'post');

QR_background=QR_background.*olt_logo_pad;
I=I.*QR_background;

textx=round(imageSize(2)/2);
texty=round(marginsize/2);
I = insertText(I,[textx,texty],[originCheckerColor '; ' markerFamily '; ' num2str(patternDims(1)) 'x' num2str(patternDims(2)) '; ' num2str(checkerSize) 'mm/' num2str(markerSize) 'mm'],'FontSize',round(checkerSize*patternDims(2)/2.5),'FontColor','black','TextBoxColor','white','BoxOpacity',0,'Font','Arial Black','AnchorPoint','Center');
gui.toolsavailable(1)
figure;imshow(I)
[file, location] = uiputfile('*.tif','Save charuco board as...',[originCheckerColor '_' markerFamily '_' num2str(patternDims(1)) 'x' num2str(patternDims(2)) '_' num2str(checkerSize) 'mm_' num2str(markerSize) 'mm_' num2str(dpi) 'dpi.tif']);
if file ~=0
    imwrite(I,fullfile(location,file),'tif','Resolution',dpi);
end