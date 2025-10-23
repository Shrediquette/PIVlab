function load_ext_img_Callback(~, ~, ~) %load extra calibration image
cali_folder=gui.retr('cali_folder');
if isempty (cali_folder)==1
	if ispc==1
		cali_folder=[gui.retr('pathname') '\'];
	else
		cali_folder=[gui.retr('pathname') '/'];
	end
end
try
	[filename, pathname, filterindex] = uigetfile({'*.bmp;*.tif;*.jpg;*.tiff;*.b16;','Image Files (*.bmp,*.tif,*.jpg,*.tiff,*.b16)'; '*.tif','tif'; '*.jpg','jpg'; '*.bmp','bmp'; '*.tiff','tiff';'*.b16','b16'; },'Select calibration image',cali_folder);
catch
	[filename, pathname, filterindex] = uigetfile({'*.bmp;*.tif;*.jpg;*.tiff;*.b16;','Image Files (*.bmp,*.tif,*.jpg,*.tiff,*.b16)'; '*.tif','tif'; '*.jpg','jpg'; '*.bmp','bmp';  '*.tiff','tiff';'*.b16','b16';},'Select calibration image'); %unix/mac system may cause problems, can't be checked due to lack of unix/mac systems...
end
if ~isequal(filename,0)
	[~,~,ext] = fileparts(fullfile(pathname, filename));
	if strcmp(ext,'.b16')
		caliimg=import.f_readB16(fullfile(pathname, filename));
	else
		caliimg=imread(fullfile(pathname, filename));
	end
	data_size=gui.retr('expected_image_size');
	if ~isempty (data_size)
		if size(caliimg,1) ~= data_size(1) || size(caliimg,2) ~= data_size(2)
			gui.custom_msgbox('warn',getappdata(0,'hgui'),'Size inconsistent',{'Your calibration image has a size that differs from your PIV data. Usually, calibration images and PIV data must have identical size.' '' 'Probably your calibration will be incorrect.'},'modal');
		end
	end
	gui.put('caliimg', caliimg);
	gui.put('cali_folder', pathname);
	calibrate.display_cali_img (caliimg)
end

