function [OutputError,OPTRONIS_vid] = PIVlab_capture_OPTRONIS_bitflow_synced_capture(OPTRONIS_vid,nr_of_images,do_realtime,ROI_live,frame_nr_display,bitmode)
%OPTRONIS_vid: cell array with one videoinput per camera (stereo: two cameras on the same trigger)
fix_Optronis_skipped_frame=0;
hgui=getappdata(0,'hgui');
if ~iscell(OPTRONIS_vid)
    OPTRONIS_vid = {OPTRONIS_vid};
end
n_cameras = numel(OPTRONIS_vid);
image_handles = getappdata(hgui,'image_handles_OPTRONIS');
OutputError=0;

OPTRONIS_frames_to_capture = nr_of_images*2+fix_Optronis_skipped_frame;
set(frame_nr_display,'backgroundcolor','k');
%% capture data
%preview() is not used (see synced_start). The latest frame is shown with peekdata and acquisition.show_frame
%(only the visible part at screen resolution). Displaying the full frames in the PIVlab window causes skipped
%frames and a high CPU load.
is_preview = isinf(OPTRONIS_frames_to_capture); %PIV preview: endless acquisition, frames are discarded with flushdata
if ~is_preview
    update_interval = 1/5;
else
    update_interval = 1/10;
end
t0 = tic;
next_update = 0;
ima = image_handles{1}.CData;
while frames_acquired(OPTRONIS_vid) < (OPTRONIS_frames_to_capture+2) &&  getappdata(hgui,'cancel_capture') ~=1
    %% Stop camera the instant enough frames are in — do this at the TOP of
    %% the loop body, before any slow display operations (drawnow, histogram,
    %% sharpness) that would otherwise let the camera fire hundreds of extra
    %% frames into the DMA ring during the final loop iteration.
    if ~is_preview && frames_acquired(OPTRONIS_vid) >= (OPTRONIS_frames_to_capture+2)
        break;
    end
    if toc(t0) < next_update
        if is_preview
            for k=1:n_cameras
                if OPTRONIS_vid{k}.FramesAvailable > 50
                    flushdata(OPTRONIS_vid{k}); %keep RAM usage low when the loop was blocked for a while
                end
            end
        end
        pause(0.01); %sleep and process GUI callbacks instead of spinning
        continue
    end
    next_update = toc(t0) + update_interval;
	if frames_acquired(OPTRONIS_vid) == 0
        if ~is_preview
			set(frame_nr_display,'String','Waiting for trigger...')
        else
            set(frame_nr_display,'String','PIV preview');
        end
	else
        for k=1:n_cameras
            frame = peekdata(OPTRONIS_vid{k},1); %full resolution for sharpness indicator, histogram and autofocus
            if is_preview
                flushdata(OPTRONIS_vid{k}); %frames are not saved in PIV preview
            end
            acquisition.show_frame(image_handles{k},frame,1);
            if k == 1
                ima = frame;
            end
        end
        if ~is_preview
			set(frame_nr_display,'String',['Image nr.: ' int2str(round(frames_acquired(OPTRONIS_vid)/2))]);
        else
            set(frame_nr_display,'String','PIV preview');
        end
	end

	acquisition.live_overlays(image_handles,'capture'); %sharpness, grid
    drawnow limitrate;
    if n_cameras > 1 %autofocus: one camera (one lens controller)
        continue
    end
    %% Autofocus
    autofocus_enabled = getappdata(hgui,'autofocus_enabled');

    if autofocus_enabled == 1
        delaycounter=delaycounter+1;
    else
        delaycounter=0;
        delaycounter2=0;
        delay_time_1=tic;
    end

    delay_time= 0.5;
    if autofocus_enabled == 1
        if delaycounter>10
            focus_start = getappdata(hgui,'focus_servo_lower_limit');
            focus_end = getappdata(hgui,'focus_servo_upper_limit');
            amount_of_raw_steps=20;
            fine_step_resolution_increase = 8;
            focus_step_raw=round(abs(focus_end - focus_start)/amount_of_raw_steps);
            focus_step_fine=round(1/fine_step_resolution_increase*(abs(focus_end - focus_start)/amount_of_raw_steps));
            if ~exist('sharpness_focus_table','var') || isempty(sharpness_focus_table) || isempty(sharp_loop_cnt)
                sharpness_focus_table=zeros(1,2);
                sharp_loop_cnt=0;
                focus=focus_start;
                raw_finished=0;
                aperture=getappdata(hgui,'aperture');
                lighting=getappdata(hgui,'lighting');
                PIVlab_capture_lensctrl(focus,aperture,lighting)
            end
            if raw_finished==0
                if focus < focus_end
                    if toc(delay_time_1)>=delay_time
                        delay_time_1=tic;
                        sharp_loop_cnt=sharp_loop_cnt+1;
                        [sharpness,~] = PIVlab_capture_sharpness_indicator (ima,0);
                        sharpness_focus_table(sharp_loop_cnt,1)=focus;
                        sharpness_focus_table(sharp_loop_cnt,2)=sharpness;
                        focus=focus+focus_step_raw;
                        PIVlab_capture_lensctrl(focus,aperture,lighting)
                        autofocus_notification(1)
                    else
                        %do nothing
                    end
                else
                    [r,~]=find(sharpness_focus_table == max(sharpness_focus_table(:,2)));
                    focus_peak=sharpness_focus_table(r(1),1);
                    disp(['Best raw focus: ' num2str(focus_peak)])
                    raw_finished=1;
                    focus_start_fine=focus_peak-6*focus_step_raw;
                    focus_end_fine=focus_peak+3*focus_step_raw;
                    if focus_start_fine < focus_start
                        focus_start_fine = focus_start;
                    end
                    if focus_end_fine > focus_end
                        focus_end_fine = focus_end;
                    end
                    focus=focus_start_fine;
                    PIVlab_capture_lensctrl(focus,aperture,lighting)
                    sharp_loop_cnt=0;
                    raw_data=[sharpness_focus_table(:,1),normalize(sharpness_focus_table(:,2),'range')];
                    sharpness_focus_table=zeros(1,2);
                end
            end

            if raw_finished == 1
                delaycounter2=delaycounter2+1;
            else
                delaycounter2=0;
            end

            if raw_finished == 1
                delay_time= 0.35;
                if delaycounter2>10
                    if focus < focus_end_fine
                        if toc(delay_time_1)>=delay_time
                            delay_time_1=tic;
                            sharp_loop_cnt=sharp_loop_cnt+1;
                            [sharpness,~] = PIVlab_capture_sharpness_indicator (ima,0);
                            sharpness_focus_table(sharp_loop_cnt,1)=focus;
                            sharpness_focus_table(sharp_loop_cnt,2)=sharpness;
                            focus=focus+focus_step_fine;
                            PIVlab_capture_lensctrl(focus,aperture,lighting)
                            autofocus_notification(1)
                        else
                            %do nothing
                        end
                    else
                        [r,~]=find(sharpness_focus_table == max(sharpness_focus_table(:,2)));
                        focus_peak=sharpness_focus_table(r(1),1);
                        disp(['Best fine focus: ' num2str(focus_peak)])
                        PIVlab_capture_lensctrl(focus_end_fine,aperture,lighting)
                        pause(0.5)
                        PIVlab_capture_lensctrl(focus_start_fine,aperture,lighting)
                        pause(0.5)
                        PIVlab_capture_lensctrl(focus_peak,aperture,lighting)

                        setappdata(hgui,'autofocus_enabled',0);

                        lens_control_window = getappdata(0,'hlens');
                        focus_edit_field=getappdata(lens_control_window,'handle_to_focus_edit_field');
                        set(focus_edit_field,'String',num2str(focus_peak));
                        figure;plot(raw_data(:,1),raw_data(:,2),'Linewidth',2)
                        hold on;plot(sharpness_focus_table(:,1),normalize(sharpness_focus_table(:,2),'range'),'Linewidth',2);hold off
                        title('Focus search')
                        xlabel('Pulsewidth us')
                        ylabel('Sharpness')
                        legend('Coarse search','Fine search')
                        grid on
                    end
                end
            end
        end
    else
        autofocus_notification(0)
        sharpness_focus_table=[];
        sharp_loop_cnt=[];
    end
end
pause(0.05);
for k=1:n_cameras
    OPTRONIS_src = OPTRONIS_vid{k}.Source;
    OPTRONIS_src.BFGTLNodeName     = 'EnableFan';
    OPTRONIS_src.BFGTLNodeValueStr = 'On';
    stop(OPTRONIS_vid{k});
    if is_preview
        flushdata(OPTRONIS_vid{k}); %free the RAM, nothing is saved in PIV preview
    end
end

if ~isinf(OPTRONIS_frames_to_capture)
    set(frame_nr_display,'String',['Image nr.: ' int2str(round(frames_acquired(OPTRONIS_vid)/2))]);
else
    set(frame_nr_display,'String','PIV preview stopped.');
end
drawnow;

function n = frames_acquired(OPTRONIS_vid)
%frames of the slowest camera (stereo: both cameras get the same triggers)
n = inf;
for k=1:numel(OPTRONIS_vid)
    n = min(n,OPTRONIS_vid{k}.FramesAcquired);
end

function autofocus_notification(running)
auto_focus_active_hint=findobj('tag', 'auto_focus_active');
if running == 1
    hgui=getappdata(0,'hgui');
    PIVlab_axis = gui.retr('pivlab_axis');
    postix=get(PIVlab_axis,'XLim');
    postiy=get(PIVlab_axis,'YLim');
    bg_col=get(auto_focus_active_hint,'BackgroundColor');

    if ~isempty(bg_col)
        if  sum(bg_col)==0.75
            bg_col = [0.05 0.05 0.05];
        else
            bg_col = [0.25 0.25 0.25];
        end
        set(auto_focus_active_hint,'BackgroundColor',bg_col);
    else
        bg_col= [0.25 0.25 0.25];
        text(PIVlab_axis,postix(2)/2,postiy(2)/2,'Autofocus running, please wait...','HorizontalAlignment','center','VerticalAlignment','middle','color','y','fontsize',24, 'BackgroundColor', bg_col,'tag','auto_focus_active','margin',10,'Clipping','on');
    end
else
    delete(auto_focus_active_hint);
end
