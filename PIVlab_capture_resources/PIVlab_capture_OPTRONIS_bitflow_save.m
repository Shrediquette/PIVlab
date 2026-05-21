function [OutputError, actually_saved_images] = PIVlab_capture_OPTRONIS_bitflow_save(OPTRONIS_vid,nr_of_images,ImagePath,frame_nr_display,bitmode)
fix_Optronis_skipped_frame=0;
if bitmode==8
    bitmultiplicator=1;
elseif bitmode==10
    bitmultiplicator = 64; %bring 10bit data to 16 bits full histogram
end
OPTRONIS_src = getselectedsource(OPTRONIS_vid);
OPTRONIS_src.BFGTLNodeName     = 'EnableFan';
OPTRONIS_src.BFGTLNodeValueStr = 'On';
hgui=getappdata(0,'hgui');
OutputError=0;
OPTRONIS_frames_to_capture = nr_of_images*2+fix_Optronis_skipped_frame;
do_save_frames=0;
if getappdata(hgui,'cancel_capture') ~=1
    do_save_frames=OPTRONIS_frames_to_capture;
else
    if OPTRONIS_vid.FramesAcquired > 4
        selec = gui.custom_msgbox('quest',getappdata(0,'hgui'),'Recording cancelled','Recording cancelled. Save acquired images?','modal',{'Yes','No'},'No');
        if strcmpi(selec,'Yes')
            do_save_frames = (floor(OPTRONIS_vid.FramesAcquired/2))*2-2;
            gui.put('cancel_capture',0);
        end
    end
end
if do_save_frames > 0
    set(frame_nr_display,'String','Getting data from RAM...');
    drawnow;
    'Available frames'
    OPTRONIS_vid.FramesAvailable
    OPTRONIS_data = getdata(OPTRONIS_vid,do_save_frames+2);

%diff over the images, and check mean difference.

oldhandle=gcf;
figure;plot(squeeze(mean(diff(OPTRONIS_data(:,:,1,1:2:end),1,4),[1 2])))
figure(oldhandle)


    %% Detect if first frame is empty
    
    bug_fix_skipped_frame=0;
    %{
    max_imgs=30;
    if size(OPTRONIS_data,4) >= 10
        if size(OPTRONIS_data,4) < max_imgs
            max_imgs=size(OPTRONIS_data,4);
        end
        datalength=numel(1:round(size(OPTRONIS_data,4)/(max_imgs*2))*2:size(OPTRONIS_data,4)-2);
        corr_img_A=zeros(1,datalength);
        corr_img_B=zeros(1,datalength);
        cntr=1;
        for i=1:round(size(OPTRONIS_data,4)/(max_imgs*2))*2:size(OPTRONIS_data,4)-2
            corr_img_A(cntr)=corr2(OPTRONIS_data(:,:,:,i),OPTRONIS_data(:,:,:,i+1));
            corr_img_B(cntr)=corr2(OPTRONIS_data(:,:,:,i+1),OPTRONIS_data(:,:,:,i+2));
            cntr=cntr+1;
        end
        if mean(corr_img_B,'omitnan') > mean(corr_img_A,'omitnan')
            disp('First frame removed (skipped frame bug fix)')
            bug_fix_skipped_frame=1;
        end
    else
        disp('Automatic bug fix for skipped frame could not be run, needs to have at least 5 image pairs')
    end
    %}
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
        disp('Getting timestamps from images...')
        for i=bug_fix_skipped_frame + (1+fix_Optronis_skipped_frame) : 1 : do_save_frames
            timestamp(cntr2)=extractOptronisMetadata(OPTRONIS_data(1,1:5,:,cntr2)*bitmultiplicator).MicrosecondCounter;
            cntr2=cntr2+1;
        end
       disp('... done.')
        OPTRONIS_src.BFGTLNodeName = 'AcquisitionFrameRate';
        setpoint_delta_t=1/str2double(OPTRONIS_src.BFGTLNodeValueStr)*1000^2;
        diff_timestamps=diff(timestamp);
        outliers=find(abs(diff_timestamps)>100000);
        diff_timestamps(outliers)=nan;
        error_delta_t=abs(diff_timestamps-setpoint_delta_t);
        old_figure=gcf;
        figure;plot(diff(timestamp(1:end-1)));ylim([setpoint_delta_t*0.9 setpoint_delta_t*1.1]);
        figure;plot(timestamp);
        figure(old_figure)
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
            imwrite(OPTRONIS_data(:,:,:,image_save_number)*bitmultiplicator,imgA_path,'compression','none');
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
