function [OutputError, actually_saved_images] = PIVlab_capture_OPTRONIS_save(OPTRONIS_vid,nr_of_images,ImagePath,frame_nr_display,bitmode)
warning('off','imaq:gentl:hardwareTriggerTriggerModeOff')
fix_Optronis_skipped_frame=0;
if bitmode==8
    bitmultiplicator=1;
elseif bitmode==10
    bitmultiplicator = 64; %bring 10bit data to 16 bits full histogram, otherwise images outside Matlab are not displayed correctly (too dark).
end
OPTRONIS_settings = get(OPTRONIS_vid);
OPTRONIS_settings.Source.EnableFan = 'On';
hgui=getappdata(0,'hgui');
OutputError=0;
OPTRONIS_frames_to_capture = nr_of_images*2+fix_Optronis_skipped_frame;
do_save_frames=0;
if getappdata(hgui,'cancel_capture') ~=1 %capture was not cancelled --> save all images from RAM to disk
    do_save_frames=OPTRONIS_frames_to_capture;
else
    if OPTRONIS_vid.FramesAcquired > 4
        selec=questdlg('Recording cancelled. Save acquired images?','Recording cancelled','Yes','No','No');
        if strcmpi(selec,'Yes')
            do_save_frames = (floor(OPTRONIS_vid.FramesAcquired/2))*2-2;
            gui.put('cancel_capture',0); %set cancel to zero to enable getting captured frames to gui.
        end
    end
end
if do_save_frames > 0
    set(frame_nr_display,'String','Getting data from RAM...');
    drawnow;
    OPTRONIS_data = getdata(OPTRONIS_vid,do_save_frames+2);
    %% Detect if first frame is empty
    % There are a number of bugs with the OPTRONIS cameras and Matlabs IMAQ
    % toolbox. I had discussion with both parties, noone feels responsible.
    % E.g. the Optronis returns color formats that Matlab does not understand,
    % and Matlab cannot configure the Optronis to run on external trigger. This
    % is EXTREMELY annoying to me, as I can't do anything.
    %These lines of code check if the first frame is substantially darker than
    %the following frames. If it is, then it is likely, that the camera didn't
    %start properly, then we have to remove the first frame.
    bug_fix_skipped_frame=0;
    max_imgs=30;
    if size(OPTRONIS_data,4) >= 10
        if size(OPTRONIS_data,4) < max_imgs
            max_imgs=size(OPTRONIS_data,4);
        end
        %sum_img=zeros(1,max_imgs);
        datalength=numel(1:round(size(OPTRONIS_data,4)/(max_imgs*2))*2:size(OPTRONIS_data,4)-2);
        corr_img_A=zeros(1,datalength);
        corr_img_B=zeros(1,datalength);
        %for i=1:max_imgs
        %    sum_img(i)=sum(OPTRONIS_data(:,:,:,i),'all');
        %end
        cntr=1;
        for i=1:round(size(OPTRONIS_data,4)/(max_imgs*2))*2:size(OPTRONIS_data,4)-2 %test correlation
            corr_img_A(cntr)=corr2(OPTRONIS_data(:,:,:,i),OPTRONIS_data(:,:,:,i+1));
            corr_img_B(cntr)=corr2(OPTRONIS_data(:,:,:,i+1),OPTRONIS_data(:,:,:,i+2));
            cntr=cntr+1;
        end
        %bla=gcf;
        %figure;plot(corr_img_A);hold on;plot(corr_img_B)
        %mean(corr_img_A,'omitnan')
        %mean(corr_img_B,'omitnan')
        %figure(bla)
        if mean(corr_img_B,'omitnan') > mean(corr_img_A,'omitnan')
            disp('First frame removed. Bug fix for OPTRONIS and Mathworks (not for PIVlab...!)')
            bug_fix_skipped_frame=1;
        end
        %mean_img=mean((sum_img(:,2:end)));
        %stdev_img=5*std(sum_img(:,2:end)); %5x stdev is allowed
        %if (sum_img(1) < (mean_img-stdev_img))
        %disp('bild skipped')
        %disp(['value: ' num2str(sum_img(1))])
        %disp(['lower bound: ' num2str(mean_img-stdev_img) '| upper bound: ' num2str(mean_img+stdev_img)])
        %    disp('First frame removed. Bug fix for OPTRONIS and Mathworks (not for PIVlab...!)')
        %    bug_fix_skipped_frame=1;
        %else
        %disp('OK')
        %end
    else
        disp('Automatic bug fix for skipped frame could not be run, needs to have at least 5 image pairs')
    end
    %%
    cntr=0;
    starttime=tic;

    timestamp=nan(nr_of_images*2,1);
   
    OPTRONIS_counter = gui.retr('OPTRONIS_counter');
    if isempty(OPTRONIS_counter)
        OPTRONIS_counter=0;
    end
    if OPTRONIS_counter ==1
        cntr2=1;
        for i=bug_fix_skipped_frame + (1+fix_Optronis_skipped_frame) : 1 : do_save_frames
            %bitmode unterscheiden und entsprechend senden.....
           % bitmode
            timestamp(cntr2)=extractOptronisMetadata(OPTRONIS_data(1,1:5,:,cntr2)*bitmultiplicator).MicrosecondCounter;
            cntr2=cntr2+1;
        end
        setpoint_delta_t=1/OPTRONIS_settings.Source.AcquisitionFrameRate*1000^2;
        diff_timestamps=diff(timestamp);
        outliers=find(abs(diff_timestamps)>100000);
        diff_timestamps(outliers)=nan;
        error_delta_t=abs(diff_timestamps-setpoint_delta_t);
        disp('Image timestamps in microseconds (exposure starts):')
        disp(['Mean delta t = ' num2str(mean(diff_timestamps,'omitnan'))])
        disp(['Max delta t = ' num2str(max(diff_timestamps,[],'omitnan'))])
        disp(['Min delta t = ' num2str(min(diff_timestamps,[],'omitnan'))])
        disp(['Nr of wrong delta t = ' num2str(numel(find(error_delta_t>=20)))])
        disp(['Nr of outliers (most likely bad counter encoding / decoding) = ' num2str(numel(outliers))])
        if numel(outliers) > 0
            disp('Outlier image nr = ')
            disp(num2str(outliers/2))
        end
        if numel(find(error_delta_t>=20)) > 0
            disp('')
            disp('!!! WARNING: Matlab might have skipped frames !!!')
            disp('There is an issue with Matlab not being able to capture data fast enough.')
            disp('Until Mathworks found a solution, we recommend to reduce the frame rate.')
            disp('')
        end
    end
    skipr=0;
    for image_save_number=bug_fix_skipped_frame + (1+fix_Optronis_skipped_frame) : 2 : do_save_frames
        if do_save_frames > 0 &&  getappdata(hgui,'cancel_capture') ~=1
            imgA_path=fullfile(ImagePath,['PIVlab_' sprintf('%4.4d',cntr) '_A.tif']);
            imgB_path=fullfile(ImagePath,['PIVlab_' sprintf('%4.4d',cntr) '_B.tif']);
            imwrite(OPTRONIS_data(:,:,:,image_save_number)*bitmultiplicator,imgA_path,'compression','none'); %tif file saving seems to be the fastest method for saving data...
            imwrite(OPTRONIS_data(:,:,:,image_save_number+1)*bitmultiplicator,imgB_path,'compression','none');
            cntr=cntr+1;
            if skipr<20
                skipr=skipr+1;
            else
                skipr=0;
                set(frame_nr_display,'String',['Saving images to disk: Image pair ' num2str(cntr) ' of ' num2str(do_save_frames/2)]);
                drawnow limitrate;
            end
        end
    end
    actually_saved_images=cntr;
    disp([num2str(toc(starttime)/cntr *1000) ' ms/image'])
else
    actually_saved_images=0;
end