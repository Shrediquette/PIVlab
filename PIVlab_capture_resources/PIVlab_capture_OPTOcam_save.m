function [OutputError, actually_saved_images] = PIVlab_capture_OPTOcam_save(OPTOcam_vid,nr_of_images,ImagePath,frame_nr_display,bitmode)
warning('off','imaq:gentl:noSupportedPixelFormat')
if bitmode==8
    bitmultiplicator=1;
elseif bitmode==12
    bitmultiplicator = 16; %bring 12bit data to 16 bits full histogram, otherwise images outside Matlab are not displayed correctly (too dark).
end
hgui=getappdata(0,'hgui');
OutputError=0;
OPTOcam_frames_to_capture = nr_of_images*2;
do_save_frames=0;
if getappdata(hgui,'cancel_capture') ~=1 %capture was not cancelled --> save images from RAM to disk
    do_save_frames=OPTOcam_frames_to_capture;
else
    if OPTOcam_vid.FramesAcquired > 2
        selec = gui.custom_msgbox('quest',getappdata(0,'hgui'),'Recording cancelled','Recording cancelled. Save acquired images?','modal',{'Yes','No'},'No');
		if strcmpi(selec,'Yes')
            do_save_frames = (floor(OPTOcam_vid.FramesAcquired/2))*2;
            gui.put('cancel_capture',0); %set cancel to zero to enable getting captured frames to gui.
        end
    end
end

if do_save_frames > 0
    OPTOcam_data = getdata(OPTOcam_vid,do_save_frames); %ruft alle Frames in RAM ab. Frame 1,2,3 sind müll
    cntr=0;
    for image_save_number=1:2:do_save_frames
        imgA_path=fullfile(ImagePath,['PIVlab_' sprintf('%4.4d',cntr) '_A.tif']);
        imgB_path=fullfile(ImagePath,['PIVlab_' sprintf('%4.4d',cntr) '_B.tif']);
        imwrite(OPTOcam_data(:,:,:,image_save_number)*bitmultiplicator,imgA_path,'compression','none'); %tif file saving seems to be the fastest method for saving data...
        imwrite(OPTOcam_data(:,:,:,image_save_number+1)*bitmultiplicator,imgB_path,'compression','none');
        cntr=cntr+1;
        set(frame_nr_display,'String',['Saving images to disk: Image pair ' num2str(cntr) ' of ' num2str(size(OPTOcam_data,4)/2)]);
        drawnow limitrate;
    end
    actually_saved_images=cntr;
else
    actually_saved_images=0;
end