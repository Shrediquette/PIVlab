function calibrate_display_cali_img (caliimg)
handles=gui_NameSpace.gui_gethand;
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
pivlab_axis=gui_NameSpace.gui_retr('pivlab_axis');
image(caliimg, 'parent',pivlab_axis, 'cdatamapping', 'scaled');
colormap('gray');
axis image;
set(gca,'ytick',[])
set(gca,'xtick',[])
