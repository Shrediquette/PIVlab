function [OutputError, actually_saved_images] = PIVlab_capture_OPTOcam_save(OPTOcam_vid,nr_of_images,ImagePath,frame_nr_display,bitmode)
%Saves the image pairs of one OPTOcam 2/80 into the project folder, or of both cameras of a stereo setup into
%its subfolders cam1 and cam2 (acquisition.capture_folders). OPTOcam_vid: cell array with one videoinput per camera.
%Stereo: both cameras get the same triggers, so frame k of camera 1 belongs to frame k of camera 2. A camera that
%misses a trigger shifts its frames; the frame times of both cameras are compared to warn about that.
if ~iscell(OPTOcam_vid)
	OPTOcam_vid = {OPTOcam_vid};
end
n_cameras = numel(OPTOcam_vid);
warning('off','imaq:gentl:noSupportedPixelFormat')
if bitmode==8
    bitmultiplicator=1;
elseif bitmode==12
    bitmultiplicator = 16; %bring 12bit data to 16 bits full histogram, otherwise images outside Matlab are not displayed correctly (too dark).
end
hgui=getappdata(0,'hgui');
OutputError=0;
OPTOcam_frames_to_capture = nr_of_images*2;
acquired = zeros(1,n_cameras);
for k=1:n_cameras
	acquired(k) = OPTOcam_vid{k}.FramesAcquired;
end
do_save_frames=0;
if getappdata(hgui,'cancel_capture') ~=1 %capture was not cancelled --> save images from RAM to disk
    do_save_frames=OPTOcam_frames_to_capture;
else
    if min(acquired) > 2
        selec = gui.custom_msgbox('quest',getappdata(0,'hgui'),'Recording cancelled','Recording cancelled. Save acquired images?','modal',{'Yes','No'},'No');
		if strcmpi(selec,'Yes')
            do_save_frames = (floor(min(acquired)/2))*2;
            gui.put('cancel_capture',0); %set cancel to zero to enable getting captured frames to gui.
        end
    end
end

actually_saved_images=0;
if do_save_frames > 0
	folders = acquisition.capture_folders(ImagePath,n_cameras);
	frame_times = cell(1,n_cameras);
	for k=1:n_cameras
		if ~exist(folders{k},'dir')
			mkdir(folders{k});
		end
		[OPTOcam_data,frame_times{k}] = getdata(OPTOcam_vid{k},do_save_frames); %all frames of this camera from RAM (one camera at a time: less RAM)
		cntr=0;
		for image_save_number=1:2:do_save_frames
			imgA_path=fullfile(folders{k},['PIVlab_' sprintf('%4.4d',cntr) '_A.tif']);
			imgB_path=fullfile(folders{k},['PIVlab_' sprintf('%4.4d',cntr) '_B.tif']);
			imwrite(OPTOcam_data(:,:,:,image_save_number)*bitmultiplicator,imgA_path,'compression','none'); %tif file saving seems to be the fastest method for saving data...
			imwrite(OPTOcam_data(:,:,:,image_save_number+1)*bitmultiplicator,imgB_path,'compression','none');
			cntr=cntr+1;
			if n_cameras == 1
				set(frame_nr_display,'String',['Saving images to disk: Image pair ' num2str(cntr) ' of ' num2str(do_save_frames/2)]);
			else
				set(frame_nr_display,'String',['Saving images to disk: Camera ' int2str(k) ', image pair ' num2str(cntr) ' of ' num2str(do_save_frames/2)]);
			end
			drawnow limitrate;
		end
		clear OPTOcam_data
	end
	actually_saved_images=cntr;
	gui.put('capture_frame_times',frame_times); %frame times per camera (s), for checks of skipped frames
	if n_cameras == 2
		check_frame_times(frame_times{1},frame_times{2});
	end
end

function check_frame_times(t1,t2)
%The frames of both cameras arrive at the same times (same trigger), up to the transfer delay. If one camera
%missed a trigger, its frames belong to the next trigger: the time difference jumps by one frame period.
period = median(diff(t1));
offset = t2 - t1;
reference = median(offset(1:min(5,numel(offset)))); %both cameras start with the same trigger
%a single frame that arrives late (USB / Windows) is jitter; a missed trigger shifts all following frames
deviation = movmedian(abs(offset - reference), 5);
bad = find(deviation > period/2, 1);
if ~isempty(bad)
	pair = ceil(bad/2);
	message = ['The two cameras are probably out of step from image pair ' int2str(pair) ' on (one camera missed a trigger). ' ...
		'Please check the images; a lower frame rate or a smaller ROI helps.'];
	disp(message)
	gui.custom_msgbox('warn',getappdata(0,'hgui'),'Stereo recording',message,'modal');
end
