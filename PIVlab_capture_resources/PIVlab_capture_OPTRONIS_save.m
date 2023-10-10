function [OutputError] = PIVlab_capture_OPTRONIS_save(OPTRONIS_vid,nr_of_images,ImagePath,frame_nr_display,bitmode)
if bitmode==8
	bitmultiplicator=1;
elseif bitmode==10
	bitmultiplicator = 32; %bring 10bit data to 16 bits full histogram, otherwise images outside Matlab are not displayed correctly (too dark).
	disp(mfilename)
	disp('needs testing')
end
hgui=getappdata(0,'hgui');
OutputError=0;
OPTRONIS_frames_to_capture = nr_of_images*2;
if getappdata(hgui,'cancel_capture') ~=1 %capture was not cancelled --> save images from RAM to disk
	OPTRONIS_data = getdata(OPTRONIS_vid,OPTRONIS_frames_to_capture);
	cntr=0;
	starttime=tic;
	disp('hier einfach machen: ein bild später starten wenn kameratyp=2-2000...')
	for image_save_number=1:2:size(OPTRONIS_data,4)
		if getappdata(hgui,'cancel_capture') ~=1
			imgA_path=fullfile(ImagePath,['PIVlab_' sprintf('%4.4d',cntr) '_A.tif']);
			imgB_path=fullfile(ImagePath,['PIVlab_' sprintf('%4.4d',cntr) '_B.tif']);
			imwrite(OPTRONIS_data(:,:,:,image_save_number)*bitmultiplicator,imgA_path,'compression','none'); %tif file saving seems to be the fastest method for saving data...
			imwrite(OPTRONIS_data(:,:,:,image_save_number+1)*bitmultiplicator,imgB_path,'compression','none');
			cntr=cntr+1;
			set(frame_nr_display,'String',['Saving images to disk: Image pair ' num2str(cntr) ' of ' num2str(size(OPTRONIS_data,4)/2)]);
			drawnow limitrate;
		end
	end
	disp([num2str(toc(starttime)/cntr *1000) ' ms/image'])
end