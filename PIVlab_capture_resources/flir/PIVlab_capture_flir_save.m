function [OutputError] = PIVlab_capture_flir_save(flir_vid,nr_of_images,ImagePath,frame_nr_display)

hgui=getappdata(0,'hgui');

OutputError=0;

basler_frames_to_capture = nr_of_images*2;

if getappdata(hgui,'cancel_capture') ~=1 %capture was not cancelled --> save images from RAM to disk
	flir_data = getdata(flir_vid,basler_frames_to_capture); %ruft alle Frames in RAM ab. Frame 1,2,3 sind müll
	cntr=0;
	for image_save_number=1:2:size(flir_data,4)
		if getappdata(hgui,'cancel_capture') == 1 %Abort pressed while saving
			message = ['Saving aborted: ' int2str(cntr) ' of ' int2str(size(flir_data,4)/2) ' image pairs were saved.'];
			disp(message)
			set(frame_nr_display,'String',message);
			break
		end
		imgA_path=fullfile(ImagePath,['PIVlab_' sprintf('%4.4d',cntr) '_A.tif']);
		imgB_path=fullfile(ImagePath,['PIVlab_' sprintf('%4.4d',cntr) '_B.tif']);
		imwrite(flir_data(:,:,:,image_save_number),imgA_path,'compression','none'); %tif file saving seems to be the fastest method for saving data...
		imwrite(flir_data(:,:,:,image_save_number+1),imgB_path,'compression','none');
		cntr=cntr+1;
		set(frame_nr_display,'String',['Saving images to disk: Image pair ' num2str(cntr) ' of ' num2str(size(flir_data,4)/2)]);
		drawnow limitrate;
	end
end