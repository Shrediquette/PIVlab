function [OutputError, actually_saved_images] = PIVlab_capture_OPTOcam_20_9_save(OPTOcam_vid,nr_of_images,ImagePath,frame_nr_display,bitmode,pair_rate)
% Save the acquired OPTOcam 20/9 double-frame data to disk as _A/_B image pairs: one camera into the project
% folder, both cameras of a stereo setup into its subfolders cam1 and cam2 (acquisition.capture_folders).
% OPTOcam_vid: cell array with one videoinput per camera.
% Frames arrive as a stream A,B,A,B,... (one image pair per external trigger, produced by the sensor's
% mvPivShutter double frame). Odd frames -> _A (1st exposure), even frames -> _B (2nd exposure) (A/B order
% confirmed on the rig). Stereo: both cameras get the same triggers, so pair k of camera 1 belongs to pair k
% of camera 2. After saving, a warning reports missing frames per camera, from the arrival times of the A
% frames (pair_rate = trigger rate, image pairs/s; a camera that misses a trigger shifts its pairs).
if nargin < 6
	pair_rate = inf; %no check
end
if ~iscell(OPTOcam_vid)
	OPTOcam_vid = {OPTOcam_vid};
end
n_cameras = numel(OPTOcam_vid);
warning('off','imaq:gentl:noSupportedPixelFormat')
if bitmode==8
    bitmultiplicator=1;
elseif bitmode==12
    bitmultiplicator = 16; %bring 12bit data to 16 bits full histogram, otherwise images outside Matlab are too dark.
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
	for k=1:n_cameras
		if ~exist(folders{k},'dir')
			mkdir(folders{k});
		end
	end
	%The frames are taken from RAM in blocks of 50 image pairs, camera after camera. Abort stops between two
	%blocks, so all cameras keep the same number of image pairs; and only one block is copied in RAM at a time.
	block = 100; %frames
	frame_times = cell(1,n_cameras);
	cntr=0; %saved image pairs per camera
	aborted = false;
	for first_frame=1:block:do_save_frames
		if getappdata(hgui,'cancel_capture') == 1 %Abort pressed while saving
			aborted = true;
			break
		end
		n_frames = min(block,do_save_frames-first_frame+1);
		for k=1:n_cameras
			[OPTOcam_data,times] = getdata(OPTOcam_vid{k},n_frames);
			frame_times{k} = [frame_times{k}; times(:)];
			pair = cntr;
			for image_save_number=1:2:n_frames
				imgA_path=fullfile(folders{k},['PIVlab_' sprintf('%4.4d',pair) '_A.tif']);
				imgB_path=fullfile(folders{k},['PIVlab_' sprintf('%4.4d',pair) '_B.tif']);
				imwrite(OPTOcam_data(:,:,:,image_save_number)*bitmultiplicator,imgA_path,'compression','none'); %tif saving is the fastest method
				imwrite(OPTOcam_data(:,:,:,image_save_number+1)*bitmultiplicator,imgB_path,'compression','none');
				pair=pair+1;
				if n_cameras == 1
					set(frame_nr_display,'String',['Saving images to disk: Image pair ' num2str(pair) ' of ' num2str(do_save_frames/2)]);
				else
					set(frame_nr_display,'String',['Saving images to disk: Camera ' int2str(k) ', image pair ' num2str(pair) ' of ' num2str(do_save_frames/2)]);
				end
				drawnow limitrate; %also processes the Abort button
			end
		end
		cntr = cntr + n_frames/2;
	end
	clear OPTOcam_data
	actually_saved_images=cntr;
	gui.put('capture_frame_times',frame_times); %frame times per camera (s), for checks of skipped frames
	if aborted
		for k=1:n_cameras
			flushdata(OPTOcam_vid{k}); %free the RAM of the frames that were not saved
		end
		message = ['Saving aborted: ' int2str(cntr) ' of ' int2str(do_save_frames/2) ' image pairs were saved.'];
		disp(message)
		set(frame_nr_display,'String',message);
		return
	end
	missing = zeros(1,n_cameras); %image pairs per camera missing in the recording (ignored triggers or lost frames)
	first_missing = zeros(1,n_cameras);
	for k=1:n_cameras
		[missing(k),first] = acquisition.missing_frames(frame_times{k}(1:2:end),pair_rate); %A frames: one per trigger
		if ~isempty(first)
			first_missing(k) = first;
		end
	end
	gui.put('capture_missing_frames',missing);
	if any(missing)
		message = '';
		for k=1:n_cameras
			if missing(k) > 0
				if n_cameras > 1
					message = [message 'Camera ' int2str(k) ': ']; %#ok<AGROW>
				end
				message = [message int2str(missing(k)) ' image pair(s) missing, the first one before image pair ' int2str(first_missing(k)) '. ']; %#ok<AGROW>
			end
		end
		message = [message 'The camera ignored triggers or frames were lost (USB connection too slow, or frame rate too high for the camera settings). ' ...
			'The image pairs from there on are not reliable. Use a lower frame rate or a smaller ROI.'];
		disp(message)
		gui.custom_msgbox('warn',getappdata(0,'hgui'),'Recording problem',message,'modal');
	end
end
