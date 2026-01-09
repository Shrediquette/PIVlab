function display_cali_img (caliimg)
handles=gui.gethand;
if get(handles.optimize_calib_img,'value')==1
	numberoftiles1=round(size(caliimg,1)/40);
	numberoftiles2=round(size(caliimg,2)/40);
	if numberoftiles1 < 2
		numberoftiles1=2;
	end
	if numberoftiles2 < 2
		numberoftiles2=2;
	end

	if size(caliimg,3) == 1
		caliimg=adapthisteq(imadjust(caliimg),'NumTiles',[numberoftiles1 numberoftiles2],'clipLimit',0.01);
	else
		try
			caliimg=adapthisteq(imadjust(rgb2gray(caliimg)),'NumTiles',[numberoftiles1 numberoftiles2],'clipLimit',0.01);
		catch
		end
	end
end
%%undistort calibration image (treat it the same way as the PIV images)
view_raw=handles.calib_viewtype.Value;
if view_raw==1
    view='valid';
elseif view_raw==2
    view='same';
elseif view_raw==3
    view='full';
end
cam_use_calibration = gui.retr('cam_use_calibration');
cam_use_rectification = gui.retr('cam_use_rectification');
cameraParams=gui.retr('cameraParams');
rectification_tform = gui.retr('rectification_tform');

caliimg = preproc.cam_undistort(caliimg,'cubic',view,cam_use_calibration,cam_use_rectification,cameraParams,rectification_tform);
data_size=gui.retr('expected_image_size');
if ~isempty (data_size)
    if size(caliimg,1) ~= data_size(1) || size(caliimg,2) ~= data_size(2)
        gui.custom_msgbox('warn',getappdata(0,'hgui'),'Size inconsistent',{'Your calibration image has a size that differs from your PIV data. Usually, calibration images and PIV data must have identical size.' '' 'Probably your calibration will be incorrect.'},'modal');
    end
end

pivlab_axis=gui.retr('pivlab_axis');
image(caliimg, 'parent',pivlab_axis, 'cdatamapping', 'scaled');
colormap('gray');
axis image;
set(gca,'ytick',[])
set(gca,'xtick',[])

