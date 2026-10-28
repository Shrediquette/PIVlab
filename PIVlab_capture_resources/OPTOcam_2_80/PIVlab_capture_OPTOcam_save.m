function [OutputError, actually_saved_images] = PIVlab_capture_OPTOcam_save(OPTOcam_vid,nr_of_images,ImagePath,frame_nr_display,bitmode,frame_rate)
%Saves the image pairs of one OPTOcam 2/80 into the project folder, or of both cameras of a stereo setup into
%its subfolders cam1 and cam2 (acquisition.capture_folders). OPTOcam_vid: cell array with one videoinput per camera.
%Stereo: both cameras get the same triggers, so frame k of camera 1 belongs to frame k of camera 2.
%After saving, one warning reports incomplete images (USB too slow; checked during the recording on the displayed
%frames, PIVlab_capture_OPTOcam_synced_capture) and missing frames per camera from the frame times
%(frame_rate = trigger rate of the cameras, Hz); a camera that misses a trigger shifts its frames.
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
	for k=1:n_cameras
		if ~exist(folders{k},'dir')
			mkdir(folders{k});
		end
	end
	frame_times = cell(1,n_cameras);
	%The frames are taken from RAM in blocks of 50 image pairs, camera after camera. Abort stops between two
	%blocks, so all cameras keep the same number of image pairs; and only one block is copied in RAM at a time.
	block = 100; %frames
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
				imwrite(OPTOcam_data(:,:,:,image_save_number)*bitmultiplicator,imgA_path,'compression','none'); %tif file saving seems to be the fastest method for saving data...
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
	missing = zeros(1,n_cameras); %frames per camera missing in the recording (ignored triggers or lost frames)
	first_missing = zeros(1,n_cameras);
	for k=1:n_cameras
		[missing(k),first] = acquisition.missing_frames(frame_times{k},frame_rate);
		if ~isempty(first)
			first_missing(k) = first;
		end
	end
	gui.put('capture_missing_frames',missing);
	message = [incomplete_message(gui.retr('capture_incomplete_frames')) missing_message(missing,first_missing)];
	if ~isempty(message)
		disp(message)
		gui.custom_msgbox('warn',getappdata(0,'hgui'),'Recording problem',message,'modal');
	end
end

function message = incomplete_message(incomplete)
%A too slow USB connection delivers images whose lower part is black or from an older frame. Checked during the
%recording on the displayed frames (PIVlab_capture_OPTOcam_synced_capture): incomplete = [found; checked] per camera.
message = '';
if isempty(incomplete) || ~any(incomplete(1,:))
	return
end
n_cameras = size(incomplete,2);
for k=1:n_cameras
	if incomplete(1,k) > 0
		message = [message camera_name(k,n_cameras) int2str(incomplete(1,k)) ' of ' int2str(incomplete(2,k)) ' checked images are incomplete. ']; %#ok<AGROW>
	end
end
message = [message 'The lower part of these images is black or shows an older image: the USB connection is too slow for this frame rate. ' ...
	'Use a lower frame rate or a smaller ROI, or connect each camera directly to its own USB 3 port (no USB hub). '];

function message = missing_message(missing,first_missing)
%A camera that ignores triggers or loses frames delivers fewer frames than triggers (acquisition.missing_frames).
%Stereo: both cameras get the same triggers, so this also shows when the cameras are out of step.
message = '';
if ~any(missing)
	return
end
for k=1:numel(missing)
	if missing(k) > 0
		if missing(k) == 1
			amount = '1 frame is missing';
		else
			amount = [int2str(missing(k)) ' frames are missing'];
		end
		message = [message camera_name(k,numel(missing)) amount ', the first one before image pair ' ...
			int2str(ceil(first_missing(k)/2)) '. ']; %#ok<AGROW>
	end
end
message = [message 'The camera ignored triggers or frames were lost (USB connection too slow, or frame rate too high for the camera settings). ' ...
	'The image pairs from there on are not reliable. Use a lower frame rate or a smaller ROI.'];

function name = camera_name(k,n_cameras)
if n_cameras == 1
	name = '';
else
	name = ['Camera ' int2str(k) ': '];
end
