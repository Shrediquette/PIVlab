function [OutputError, actually_saved_images] = PIVlab_capture_OPTRONIS_bitflow_save(OPTRONIS_vid,nr_of_images,ImagePath,frame_nr_display,bitmode)
% Save the recorded OPTRONIS Cyclone frames (BitFlow grabber) as _A/_B image pairs: one camera into the
% project folder, both cameras of a stereo setup into its subfolders cam1 and cam2 (acquisition.capture_folders).
% OPTRONIS_vid: cell array with one videoinput per camera. Stereo: both cameras get the same triggers, so
% pair k of camera 1 belongs to pair k of camera 2; the image counter check is done per camera.
fix_Optronis_skipped_frame=0;
if ~iscell(OPTRONIS_vid)
    OPTRONIS_vid = {OPTRONIS_vid};
end
n_cameras = numel(OPTRONIS_vid);
if bitmode==8
    bitmultiplicator=1;
elseif bitmode==10
    bitmultiplicator = 64; %bring 10bit data to 16 bits full histogram
end
acquired = zeros(1,n_cameras);
for k=1:n_cameras
    OPTRONIS_src = getselectedsource(OPTRONIS_vid{k});
    OPTRONIS_src.BFGTLNodeName     = 'EnableFan';
    OPTRONIS_src.BFGTLNodeValueStr = 'On';
    acquired(k) = OPTRONIS_vid{k}.FramesAcquired;
end
hgui=getappdata(0,'hgui');
OutputError=0;
OPTRONIS_frames_to_capture = nr_of_images*2+fix_Optronis_skipped_frame;
do_save_frames=0;
if getappdata(hgui,'cancel_capture') ~=1
    do_save_frames=OPTRONIS_frames_to_capture;
else
    if min(acquired) > 4
        selec = gui.custom_msgbox('quest',getappdata(0,'hgui'),'Recording cancelled','Recording cancelled. Save acquired images?','modal',{'Yes','No'},'No');
        if strcmpi(selec,'Yes')
            do_save_frames = (floor(min(acquired)/2))*2-2;
            gui.put('cancel_capture',0);
        end
    end
end
actually_saved_images=0;
if do_save_frames > 0
    folders = acquisition.capture_folders(ImagePath,n_cameras);
    OPTRONIS_counter = gui.camera_setting('OPTRONIS_counter');
    if isempty(OPTRONIS_counter)
        OPTRONIS_counter=0;
    end
    starttime=tic;
    saved = zeros(1,n_cameras);
    for k=1:n_cameras
        if ~exist(folders{k},'dir')
            mkdir(folders{k});
        end
        set(frame_nr_display,'String','Getting data from RAM...');
        drawnow;
        OPTRONIS_data = getdata(OPTRONIS_vid{k},do_save_frames+2);
        if n_cameras > 1
            disp(['Camera ' int2str(k) ':'])
        end
        if OPTRONIS_counter ==1
            check_timestamps(OPTRONIS_data,OPTRONIS_vid{k},do_save_frames,nr_of_images,bitmultiplicator,fix_Optronis_skipped_frame);
        end
        cntr=0;
        skipr=0;
        for image_save_number=(1+fix_Optronis_skipped_frame) : 2 : do_save_frames
            if getappdata(hgui,'cancel_capture') ~=1
                imgA_path=fullfile(folders{k},['PIVlab_' sprintf('%4.4d',cntr) '_A.tif']);
                imgB_path=fullfile(folders{k},['PIVlab_' sprintf('%4.4d',cntr) '_B.tif']);
                imwrite(OPTRONIS_data(:,:,:,image_save_number)*bitmultiplicator,imgA_path,'compression','none');
                imwrite(OPTRONIS_data(:,:,:,image_save_number+1)*bitmultiplicator,imgB_path,'compression','none');
                cntr=cntr+1;
                if skipr<20
                    skipr=skipr+1;
                else
                    skipr=0;
                    if n_cameras > 1
                        status = ['Saving images to disk: camera ' int2str(k) ', image pair ' num2str(cntr) ' of ' num2str(do_save_frames/2)];
                    else
                        status = ['Saving images to disk: Image pair ' num2str(cntr) ' of ' num2str(do_save_frames/2)];
                    end
                    set(frame_nr_display,'String',status);
                    drawnow limitrate;
                end
            end
        end
        saved(k)=cntr;
        clear OPTRONIS_data %RAM for the next camera
    end
    actually_saved_images=min(saved);
    if actually_saved_images > 0
        disp([num2str(toc(starttime)/(actually_saved_images*n_cameras) *1000) ' ms/image pair'])
    end
end

function check_timestamps(OPTRONIS_data,OPTRONIS_vid,do_save_frames,nr_of_images,bitmultiplicator,fix_Optronis_skipped_frame)
%time between the frames from the microsecond counter in the image header (image counter / stamp on)
timestamp=nan(nr_of_images*2,1);
cntr2=1;
disp('Getting timestamps from images...')
for i=(1+fix_Optronis_skipped_frame) : 1 : do_save_frames
    timestamp(cntr2)=extractOptronisMetadata(OPTRONIS_data(1,1:5,:,cntr2)*bitmultiplicator).MicrosecondCounter;
    cntr2=cntr2+1;
end
disp('... done.')
OPTRONIS_src = getselectedsource(OPTRONIS_vid);
OPTRONIS_src.BFGTLNodeName = 'AcquisitionFrameRate';
setpoint_delta_t=1/str2double(OPTRONIS_src.BFGTLNodeValueStr)*1000^2;
%the microsecond counter in the image header has 24 bits and wraps around every 2^24 us = 16.78 s: unwrap it
diff_timestamps=diff(timestamp);
wrapped=diff_timestamps < -2^23;
diff_timestamps(wrapped)=diff_timestamps(wrapped) + 2^24;
timestamp=timestamp(1) + [0; cumsum(diff_timestamps)];
outliers=find(abs(diff_timestamps)>100000);
diff_timestamps(outliers)=nan;
error_delta_t=abs(diff_timestamps-setpoint_delta_t);
disp('Image timestamps in microseconds (exposure starts):')
disp(['Mean delta t = ' num2str(mean(diff_timestamps,'omitnan'))])
disp(['Max delta t = ' num2str(max(diff_timestamps,[],'omitnan'))])
disp(['Min delta t = ' num2str(min(diff_timestamps,[],'omitnan'))])
disp(['Nr of wrong delta t = ' num2str(numel(find(error_delta_t>=20)))])
disp(['Nr of outliers (most likely bad counter encoding / decoding) = ' num2str(numel(outliers))])
disp(['Duration of recording = ' num2str(round((timestamp(end) - timestamp(1))/1000^2,2)) ' s. (should be '       num2str(round(setpoint_delta_t / 1000^2* nr_of_images*2,2)) ' s)'])
if numel(outliers) > 0
    disp('Outlier image nr = ')
    disp(num2str(outliers/2))
end
if numel(find(error_delta_t>=20)) > 0
    disp('')
    disp('Warning: Matlab might have skipped frames during acquisition.')
    disp('There is an issue with Matlab not being able to capture data fast enough.')
    disp('Double check that the grabber is in a PCie Gen3 x8 slot. Slower interfaces are not supported.')
    disp('Until Mathworks found a solution, we recommend to reduce the frame rate.')
    disp('Please check that frame pairs do not have missing images.')
end
